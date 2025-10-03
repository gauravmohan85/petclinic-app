output "us_west1_service_url" {
  description = "The URL of the Cloud Run service in us-west1."
  value       = google_cloud_run_service.us_west1.status[0].url
}

output "europe_west1_service_url" {
  description = "The URL of the Cloud Run service in europe-west1."
  value       = google_cloud_run_service.europe_west1.status[0].url
}