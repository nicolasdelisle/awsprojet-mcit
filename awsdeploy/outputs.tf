output "alb_dns_name" {
  value = aws_lb.myalb.dns_name
}

output "web_instance_ids" {
  value = aws_instance.web_tier[*].id
}

output "db_endpoint" {
  value = aws_db_instance.the_db.endpoint
}
