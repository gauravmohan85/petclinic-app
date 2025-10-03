variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
  default = "xebia-petclinic-dev"
}

variable "repository_name" {
  description = "The name of the Artifact Registry repository."
  type        = string
}

variable "artifact_registry_location" {
  description = "The location of the Artifact Registry (e.g., europe-west1, us-west1)."
  type        = string
}

variable "image_name" {
  description = "The name of the Docker image in the Artifact Registry."
  type        = string
}

variable "image_tag" {
  description = "The tag of the Docker image to deploy."
  type        = string
  default     = "latest"
}

variable "service_name_prefix" {
  description = "The prefix for the Cloud Run service name."
  type        = string
}

variable "default_region" {
  description = "The default region for the provider."
  type        = string
  default     = "europe-west1"
}