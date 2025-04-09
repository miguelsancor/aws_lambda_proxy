output "api_url" {
  description = "URL pública de tu API HTTP"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}
