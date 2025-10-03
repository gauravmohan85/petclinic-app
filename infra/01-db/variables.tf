variable "project_id" {
  description = "The GCP project ID."
  type        = string
  default = "xebia-petclinic-dev"
}

variable "db_instance_name" {
  description = "The name of the CloudSQL PostgreSQL instance."
  type        = string
  default = "petclinic-dbserver"
}

variable "db_user" {
  description = "The database user for the CloudSQL instance."
  type        = string
  default = "petclinic"
}

variable "db_password" {
  description = "The password for the database user."
  type        = string
  sensitive   = true
  default = "petclinic"
}

variable "db_region" {
  description = "The primary region for the CloudSQL instance."
  type        = string
  default     = "europe-west1"
}

variable "read_replica_region" {
  description = "The region for the read replica of the CloudSQL instance."
  type        = string
  default     = "us-west1"
}