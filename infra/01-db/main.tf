provider "google" {
  project = var.project_id
  region  = var.db_region
}

resource "google_sql_database_instance" "primary" {
  name             = var.db_instance_name
  database_version = "POSTGRES_13"
  region           = var.db_region

  settings {
    tier = "db-f1-micro"

    ip_configuration {
    
      ipv4_enabled       = true
    }
  }

  deletion_protection = false
}

resource "google_sql_database_instance" "read_replica" {
  name             = "${var.db_instance_name}-replica"
  database_version = "POSTGRES_13"
  region           = var.read_replica_region
  master_instance_name = google_sql_database_instance.primary.name

  settings {
    tier = "db-f1-micro"

    ip_configuration {
     
      ipv4_enabled       = true
    }
  }
}

output "primary_instance_connection_name" {
  value = google_sql_database_instance.primary.connection_name
}

output "read_replica_connection_name" {
  value = google_sql_database_instance.read_replica.connection_name
}