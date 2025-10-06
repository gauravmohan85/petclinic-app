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

variable "db_connection_name" {
  description = "The connection name of the Cloud SQL instance in the format PROJECT_ID:REGION:INSTANCE_NAME"
  type        = string
}
