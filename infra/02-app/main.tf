provider "google" {
  project = var.project_id
  region  = var.region_primary
}

resource "google_vpc_access_connector" "connector_primary" {
  name          = "vpc-connector-eu1"
  region        = var.region_primary
  ip_cidr_range = "10.89.0.0/28"
  network       = "default"

   # Optional: Specify min and max instances
  min_instances = 2
  max_instances = 3
  
}

resource "google_vpc_access_connector" "connector_secondary" {
  name          = "vpc-connector-us1"
  region        = var.region_secondary
  ip_cidr_range = "10.90.0.0/28"  # Use a different CIDR range to avoid conflicts
  network       = "default"
  
  min_instances = 2
  max_instances = 3
}

resource "google_cloud_run_service" "service_primary" {
  name     = "petclinic-dev"
  location = var.region_primary

  template {
    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector_primary.name
        "run.googleapis.com/vpc-access-egress"    = "all-traffic"
        "run.googleapis.com/cloudsql-instances"   = "xebia-petclinic-dev:europe-west1:petclinic-dev-db"
      }
    }
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

  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }
}

resource "google_cloud_run_service" "service_secondary" {
  name     = "petclinic-dev"
  location = var.region_secondary

  template {
    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector_secondary.name
        "run.googleapis.com/vpc-access-egress"    = "all-traffic"
        "run.googleapis.com/cloudsql-instances"   = "xebia-petclinic-dev:europe-west1:petclinic-dev-db"
      }
    }
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


  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }
}

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
/*resource "google_compute_backend_service" "backend" {
  name        = "cloud-run-backend"
  protocol    = "HTTP"
  timeout_sec = 30

  backend {
    group = google_compute_region_network_endpoint_group.neg_primary.id
  }

  backend {
    group = google_compute_region_network_endpoint_group.neg_secondary.id
  }
}*/

# -----------------------------
# URL Map
# -----------------------------
resource "google_compute_url_map" "url_map" {
  name            = "cloud-run-url-map"
  //default_service = google_compute_backend_service.backend.id
  default_service = google_compute_backend_service.backend_eu.id

  # Create a host rule to direct to the path matcher
  host_rule {
    hosts        = ["*"]
    path_matcher = "region-matcher"
  }

  # Path matcher contains the route rules
  path_matcher {
    name            = "region-matcher"
    default_service = google_compute_backend_service.backend_eu.id
    
    # Route for US-based traffic to US backend
    route_rules {
      priority = 1
      match_rules {
        prefix_match = "/"
        header_matches {
          header_name = "X-Client-Region"
          exact_match = "US"
        }
      }
      service = google_compute_backend_service.backend_us.id
    }

    # Route for EU-based traffic to EU backend
    route_rules {
      priority = 2
      match_rules {
        prefix_match = "/"
        header_matches {
          header_name = "X-Client-Region"
          exact_match = "EU"
        }
      }
      service = google_compute_backend_service.backend_eu.id
    }
  }
}

# Separate Backend Service for US Region
resource "google_compute_backend_service" "backend_us" {
  name        = "cloud-run-backend-us"
  protocol    = "HTTP"
  timeout_sec = 30

  backend {
    group = google_compute_region_network_endpoint_group.neg_primary.id
  }

}

# Separate Backend Service for EU Region
resource "google_compute_backend_service" "backend_eu" {
  name        = "cloud-run-backend-eu"
  protocol    = "HTTP"
  timeout_sec = 30

  backend {
    group = google_compute_region_network_endpoint_group.neg_secondary.id
  }

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

/*resource "google_service_account" "petclinic_service_account" {
  account_id   = "petclinic-sa"
  display_name = "PetClinic Service Account"
}*/

/*resource "google_project_iam_member" "secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.petclinic_service_account.email}"
}*/

# Allow unauthenticated public access for the primary service
resource "google_cloud_run_service_iam_member" "public_invoker_primary" {
  location = google_cloud_run_service.service_primary.location
  project  = var.project_id
  service  = google_cloud_run_service.service_primary.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Allow unauthenticated public access for the secondary service
resource "google_cloud_run_service_iam_member" "public_invoker_secondary" {
  location = google_cloud_run_service.service_secondary.location
  project  = var.project_id
  service  = google_cloud_run_service.service_secondary.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
