output "db_host" {
  description = "El host de la base de datos"
  value       = aws_db_instance.main.address
}
