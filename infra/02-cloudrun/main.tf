provider "google" {
  project = var.project_id
  region  = var.default_region
}

# Cloud Run Service for us-west1
resource "google_cloud_run_service" "us_west1" {
  name     = "${var.service_name_prefix}-us-west1"
  location = "us-west1"

  template {
    spec {
      containers {
        image = "${var.artifact_registry_location}-docker.pkg.dev/${var.project_id}/${var.repository_name}/${var.image_name}:${var.image_tag}"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Cloud Run Service for europe-west1
resource "google_cloud_run_service" "europe_west1" {
  name     = "${var.service_name_prefix}-europe-west1"
  location = "europe-west1"

  template {
    spec {
      containers {
        image = "${var.artifact_registry_location}-docker.pkg.dev/${var.project_id}/${var.repository_name}/${var.image_name}:${var.image_tag}"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}