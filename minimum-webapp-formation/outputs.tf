output "container_service_url" {
  description = "URL of the Lightsail container service"
  value       = aws_lightsail_container_service.app.url
}

output "database_endpoint" {
  description = "Endpoint of the Lightsail database"
  value       = aws_lightsail_database.main.master_endpoint_address
}

output "s3_bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.storage.id
}