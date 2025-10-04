provider "google" {
  project = var.project_id
  region  = var.region_primary
}

# -----------------------------
# Cloud Run Services
# -----------------------------
resource "google_cloud_run_service" "service_primary" {
  name     = "petclinic-dev-europe-west1"
  location = var.region_primary

  template {
    spec {
      containers {
        image = var.service_image
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service" "service_secondary" {
  name     = "petclinic-dev-us-west1"
  location = var.region_secondary

  template {
    spec {
      containers {
        image = var.service_image
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# -----------------------------
# Serverless NEGs
# -----------------------------
resource "google_compute_region_network_endpoint_group" "neg_primary" {
  name                  = "neg-us"
  network_endpoint_type = "SERVERLESS"
  region                = var.region_primary

  cloud_run {
    service = google_cloud_run_service.service_primary.name
  }
}

resource "google_compute_region_network_endpoint_group" "neg_secondary" {
  name                  = "neg-eu"
  network_endpoint_type = "SERVERLESS"
  region                = var.region_secondary

  cloud_run {
    service = google_cloud_run_service.service_secondary.name
  }
}

# -----------------------------
# Backend Service
# -----------------------------
resource "google_compute_backend_service" "backend" {
  name        = "cloud-run-backend"
  protocol    = "HTTP"
  timeout_sec = 30

  backend {
    group = google_compute_region_network_endpoint_group.neg_primary.id
  }

  backend {
    group = google_compute_region_network_endpoint_group.neg_secondary.id
  }
}

# -----------------------------
# URL Map
# -----------------------------
resource "google_compute_url_map" "url_map" {
  name            = "cloud-run-url-map"
  default_service = google_compute_backend_service.backend.id
}

# -----------------------------
# Target HTTP Proxy
# -----------------------------
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "cloud-run-http-proxy"
  url_map = google_compute_url_map.url_map.id
}

# -----------------------------
# Global Forwarding Rule
# -----------------------------
resource "google_compute_global_forwarding_rule" "http_forwarding" {
  name                  = "cloud-run-fw"
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.http_proxy.id
  load_balancing_scheme = "EXTERNAL"
}
