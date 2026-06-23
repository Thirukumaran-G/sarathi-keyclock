#!/bin/bash
set -euo pipefail

PROJECT_ID=$1
ENVIRONMENT=$2
REGION=$3
GITHUB_REPO=$4

if [[ -z "$PROJECT_ID" || -z "$ENVIRONMENT" || -z "$REGION" || -z "$GITHUB_REPO" ]]; then
  echo "Usage: ./bootstrap.sh <project_id> <environment> <region> <github_org/repo>"
  echo "Example: ./bootstrap.sh my-project dev us-central1 myorg/myrepo"
  exit 1
fi

STATE_BUCKET="sarthi-tfstate-${PROJECT_ID}-${ENVIRONMENT}"
TF_SA_NAME="sarthi-sa-terraform-${ENVIRONMENT}-01"
TF_SA_EMAIL="${TF_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
WIF_POOL_NAME="sarthi-wif-pool-${ENVIRONMENT}-01"
WIF_POOL_ID="sarthi-wif-pool-${ENVIRONMENT}-01"
WIF_PROVIDER_NAME="sarthi-wif-gh-${ENVIRONMENT}-01"
WIF_PROVIDER_ID="sarthi-wif-github-${ENVIRONMENT}-01"
GITHUB_ISSUER="https://token.actions.githubusercontent.com"

echo "==> Setting project"
gcloud config set project "$PROJECT_ID"

echo "==> Enabling required APIs"
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  sts.googleapis.com \
  compute.googleapis.com \
  sqladmin.googleapis.com \
  secretmanager.googleapis.com \
  dns.googleapis.com \
  storage.googleapis.com \
  servicenetworking.googleapis.com \
  --project="$PROJECT_ID"

echo "==> Creating Terraform state GCS bucket"
if gcloud storage buckets describe "gs://${STATE_BUCKET}" \
  --project="$PROJECT_ID" &>/dev/null; then
  echo "    Bucket already exists — skipping"
else
  gcloud storage buckets create "gs://${STATE_BUCKET}" \
    --project="$PROJECT_ID" \
    --location="$REGION" \
    --uniform-bucket-level-access \
    --public-access-prevention
fi

echo "==> Enabling versioning on state bucket"
gcloud storage buckets update "gs://${STATE_BUCKET}" \
  --versioning

echo "==> Creating Terraform runner service account"
if gcloud iam service-accounts describe "$TF_SA_EMAIL" \
  --project="$PROJECT_ID" &>/dev/null; then
  echo "    Service account already exists — skipping"
else
  gcloud iam service-accounts create "$TF_SA_NAME" \
    --display-name="Terraform Runner SA - ${ENVIRONMENT}" \
    --project="$PROJECT_ID"
fi

echo "==> Granting roles to Terraform SA"
ROLES=(
  "roles/compute.admin"
  "roles/iam.serviceAccountAdmin"
  "roles/iam.serviceAccountUser"
  "roles/secretmanager.admin"
  "roles/cloudsql.admin"
  "roles/dns.admin"
  "roles/storage.admin"
  "roles/servicenetworking.networksAdmin"
  "roles/resourcemanager.projectIamAdmin"
)

for ROLE in "${ROLES[@]}"; do
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:${TF_SA_EMAIL}" \
    --role="$ROLE" \
    --condition=None
done

echo "==> Granting Terraform SA access to state bucket"
gcloud storage buckets add-iam-policy-binding "gs://${STATE_BUCKET}" \
  --member="serviceAccount:${TF_SA_EMAIL}" \
  --role="roles/storage.objectAdmin"

echo "==> Creating Workload Identity Pool"
if gcloud iam workload-identity-pools describe "$WIF_POOL_ID" \
  --project="$PROJECT_ID" \
  --location="global" &>/dev/null; then
  echo "    WIF pool already exists — skipping"
else
  gcloud iam workload-identity-pools create "$WIF_POOL_ID" \
    --project="$PROJECT_ID" \
    --location="global" \
    --display-name="$WIF_POOL_NAME" \
    --description="Workload Identity Pool for GitHub Actions - ${ENVIRONMENT}"
fi

echo "==> Creating Workload Identity Provider for GitHub"
if gcloud iam workload-identity-pools providers describe "$WIF_PROVIDER_ID" \
  --project="$PROJECT_ID" \
  --location="global" \
  --workload-identity-pool="$WIF_POOL_ID" &>/dev/null; then
  echo "    WIF provider already exists — skipping"
else
  gcloud iam workload-identity-pools providers create-oidc "$WIF_PROVIDER_ID" \
    --project="$PROJECT_ID" \
    --location="global" \
    --workload-identity-pool="$WIF_POOL_ID" \
    --display-name="$WIF_PROVIDER_NAME" \
    --issuer-uri="$GITHUB_ISSUER" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
    --attribute-condition="assertion.repository=='${GITHUB_REPO}'"
fi

echo "==> Getting Workload Identity Pool project number"
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" \
  --format="value(projectNumber)")

WIF_PROVIDER_FULL="projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${WIF_POOL_ID}/providers/${WIF_PROVIDER_ID}"
WIF_POOL_FULL="projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${WIF_POOL_ID}"

echo "==> Binding Workload Identity to Terraform SA"
gcloud iam service-accounts add-iam-policy-binding "$TF_SA_EMAIL" \
  --project="$PROJECT_ID" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${WIF_POOL_FULL}/attribute.repository/${GITHUB_REPO}"

echo ""
echo "===================================================="
echo "Bootstrap complete"
echo ""
echo "State bucket     : gs://${STATE_BUCKET}"
echo "TF SA email      : ${TF_SA_EMAIL}"
echo "WIF Pool         : ${WIF_POOL_FULL}"
echo "WIF Provider     : ${WIF_PROVIDER_FULL}"
echo ""
echo "GitHub Actions SECRETS to add:"
echo "  GCP_PROJECT_ID  -> ${PROJECT_ID}"
echo "  TF_STATE_BUCKET -> ${STATE_BUCKET}"
echo "  WIF_PROVIDER    -> ${WIF_PROVIDER_FULL}"
echo "  WIF_SA_EMAIL    -> ${TF_SA_EMAIL}"
echo ""
echo "GitHub Actions VARIABLES to add:"
echo "  ENVIRONMENT     -> ${ENVIRONMENT}"
echo "===================================================="