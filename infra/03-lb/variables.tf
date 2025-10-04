variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region_primary" {
  description = "Primary region for Cloud Run"
  type        = string
  default     = "europe-west1"
}

variable "region_secondary" {
  description = "Secondary region for Cloud Run"
  type        = string
  default     = "us-west1"
}

variable "service_image" {
  description = "Container image for Cloud Run services"
  type        = string
}
