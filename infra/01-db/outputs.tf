output "cloudsql_instance_name" {
  value = google_sql_database_instance.primary.name
}

output "cloudsql_instance_connection_name" {
  value = google_sql_database_instance.primary.connection_name
}

output "cloudsql_read_replica_connection_name" {
  value = google_sql_database_instance.read_replica.connection_name
}