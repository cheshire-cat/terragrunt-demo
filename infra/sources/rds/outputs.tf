output "db_endpoint" {
  description = "The Endpoint of RDS DB Instance"
  value       = "${module.rds.this_db_instance_endpoint}"
}

output "db_name" {
  value       = "${module.rds.this_db_instance_name}"
}

output "db_username" {
  value       = "${module.rds.this_db_instance_username}"
  sensitive   = true
}

output "db_password" {
  value       = "${module.rds.this_db_instance_password}"
  sensitive   = true
}
