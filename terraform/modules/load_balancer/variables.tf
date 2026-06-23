variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "lb_name" {
  description = "Load balancer name prefix"
  type        = string
}

variable "lb_ip_name" {
  description = "Global IP address resource name"
  type        = string
}

variable "lb_hc_name" {
  description = "Health check resource name"
  type        = string
}

variable "ssl_cert_name" {
  description = "SSL certificate resource name"
  type        = string
}

variable "ssl_cert_domains" {
  description = "Domains for SSL certificate"
  type        = list(string)
}

variable "mig_self_link" {
  description = "MIG instance group self link"
  type        = string
}

variable "keycloak_port" {
  description = "Keycloak port"
  type        = number
}

variable "health_check_port" {
  description = "Health check port"
  type        = number
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
}

variable "health_check_interval_sec" {
  description = "Health check interval seconds"
  type        = number
}

variable "health_check_timeout_sec" {
  description = "Health check timeout seconds"
  type        = number
}

variable "health_check_healthy_threshold" {
  description = "Healthy threshold"
  type        = number
}

variable "health_check_unhealthy_threshold" {
  description = "Unhealthy threshold"
  type        = number
}

variable "keycloak_hostname" {
  description = "Keycloak FQDN for host rule"
  type        = string
}

variable "lb_protocol" {
  description = "Backend protocol"
  type        = string
}

variable "lb_port_name" {
  description = "Named port"
  type        = string
}

variable "lb_scheme" {
  description = "Load balancing scheme"
  type        = string
}

variable "lb_timeout_sec" {
  description = "Backend timeout seconds"
  type        = number
}

variable "lb_balancing_mode" {
  description = "Backend balancing mode"
  type        = string
}

variable "lb_capacity_scaler" {
  description = "Backend capacity scaler"
  type        = number
}

variable "lb_session_affinity" {
  description = "Session affinity type"
  type        = string
}

variable "lb_session_cookie_name" {
  description = "Session cookie name"
  type        = string
}

variable "lb_session_cookie_ttl_seconds" {
  description = "Session cookie TTL seconds"
  type        = number
}

variable "lb_log_sample_rate" {
  description = "Log sample rate"
  type        = number
}

variable "lb_https_port" {
  description = "HTTPS forwarding port"
  type        = string
}

variable "lb_http_port" {
  description = "HTTP redirect port"
  type        = string
}

variable "lb_http_redirect_response_code" {
  description = "HTTP to HTTPS redirect response code"
  type        = string
}

variable "labels" {
  description = "Labels to apply"
  type        = map(string)
}