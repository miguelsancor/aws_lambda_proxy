provider "aws" {
  region = var.region
}

# Rol de ejecución para Lambdas
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Permisos para logs en CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda hello
resource "aws_lambda_function" "hello_lambda" {
  function_name    = "helloLambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  filename         = "${path.module}/lambda/index.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/index.zip")
}

# Lambda hola1
resource "aws_lambda_function" "hola1_lambda" {
  function_name    = "hola1Lambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "hola1.handler"
  runtime          = "nodejs18.x"
  filename         = "${path.module}/lambda/hola1.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/hola1.zip")
}

# Lambda hola2
resource "aws_lambda_function" "hola2_lambda" {
  function_name    = "hola2Lambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "hola2.handler"
  runtime          = "nodejs18.x"
  filename         = "${path.module}/lambda/hola2.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/hola2.zip")
}

# Lambda Authorizer
resource "aws_lambda_function" "authorizer_lambda" {
  function_name    = "authorizerLambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "authorizer.handler"
  runtime          = "nodejs18.x"
  filename         = "${path.module}/lambda/authorizer.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/authorizer.zip")
}

# Permisos para API Gateway
resource "aws_lambda_permission" "allow_apigw_hello" {
  statement_id  = "AllowInvokeHello"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_apigw_hola1" {
  statement_id  = "AllowInvokeHola1"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hola1_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_apigw_hola2" {
  statement_id  = "AllowInvokeHola2"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hola2_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_authorizer" {
  statement_id  = "AllowInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "http-api"
  protocol_type = "HTTP"
}

# Integraciones
resource "aws_apigatewayv2_integration" "integration_hello" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.hello_lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "integration_hola1" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.hola1_lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "integration_hola2" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.hola2_lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Authorizer
resource "aws_apigatewayv2_authorizer" "lambda_auth" {
  name                             = "lambda-auth"
  api_id                           = aws_apigatewayv2_api.http_api.id
  authorizer_type                  = "REQUEST"
  authorizer_uri                   = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.authorizer_lambda.arn}/invocations"
  identity_sources                 = ["$request.header.authorization"]
  authorizer_payload_format_version = "2.0"
  enable_simple_responses          = true
}

# Rutas protegidas
resource "aws_apigatewayv2_route" "route_hello" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "GET /hello"
  target             = "integrations/${aws_apigatewayv2_integration.integration_hello.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_auth.id
  authorization_type = "CUSTOM"
}

resource "aws_apigatewayv2_route" "route_hola1" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "GET /hola1"
  target             = "integrations/${aws_apigatewayv2_integration.integration_hola1.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_auth.id
  authorization_type = "CUSTOM"
}

resource "aws_apigatewayv2_route" "route_hola2" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "GET /hola2"
  target             = "integrations/${aws_apigatewayv2_integration.integration_hola2.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_auth.id
  authorization_type = "CUSTOM"
}

# Etapa por defecto
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

##############################################################
# PERSONALIZACIÓN OPCIONAL DE DOMINIO (comentado por defecto)
# Si el cliente quiere usar un dominio propio como
# https://api.midominio.com/hola1 en lugar del de AWS.
##############################################################

# resource "aws_acm_certificate" "custom_cert" {
#   domain_name       = "api.midominio.com"  # <-- Reemplazar con el dominio real
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_apigatewayv2_domain_name" "custom_domain" {
#   domain_name = "api.midominio.com"  # <-- Reemplazar con el dominio real
#   domain_name_configuration {
#     certificate_arn = aws_acm_certificate.custom_cert.arn
#     endpoint_type   = "REGIONAL"
#     security_policy = "TLS_1_2"
#   }
# }

# resource "aws_apigatewayv2_api_mapping" "custom_mapping" {
#   api_id      = aws_apigatewayv2_api.http_api.id
#   domain_name = aws_apigatewayv2_domain_name.custom_domain.domain_name
#   stage       = aws_apigatewayv2_stage.default.name
# }

# OPCIONAL: Si el dominio está en Route 53, agregar este registro:
# resource "aws_route53_record" "custom_record" {
#   zone_id = "TU_ZONE_ID"
#   name    = "api.midominio.com"
#   type    = "A"

#   alias {
#     name                   = aws_apigatewayv2_domain_name.custom_domain.domain_name_configuration[0].target_domain_name
#     zone_id                = aws_apigatewayv2_domain_name.custom_domain.domain_name_configuration[0].hosted_zone_id
#     evaluate_target_health = false
#   }
# }

##############################################################
# FIN DEL BLOQUE DE DOMINIO PERSONALIZADO
##############################################################
