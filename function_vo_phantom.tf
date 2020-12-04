### Lambda Function Code
## Terafrom generates the lambda function from a zip file which is pulled down 
## from a separate repo defined in varibales.tf in root folder
resource "null_resource" "lambda_function_file" {
  provisioner "local-exec" {
    command = "curl -o lambda_function.py ${var.lambda_function_url}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm lambda_function.py"
  }
}

resource "null_resource" "phantom_file" {
  provisioner "local-exec" {
    command = "curl -o phantom.py ${var.phantom_url}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm phantom.py"
  }
}

resource "null_resource" "victorops_file" {
  provisioner "local-exec" {
    command = "curl -o victorops.py ${var.victorops_url}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm victorops.py"
  }
}

resource "null_resource" "lambda_function_zip" {
  provisioner "local-exec" {
    command = "zip lambda_function.zip lambda_function.py phantom.py victorops.py "
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm lambda_function.zip"
  }
  depends_on   = [null_resource.victorops_file]
}

### Create Lambda Function ###
resource "aws_lambda_function" "vo_phantom" {
  filename      = "lambda_function.zip"
  function_name = "vo_phantom"
  role          = aws_iam_role.vo_phantom_lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  timeout       = var.function_timeout

  environment {
    variables = {
      VICTOROPSURL        = var.victoropsurl
      VOAPIID             = var.voapiid
      VOAPIKEY            = var.voapikey
      PHANTOMDEEPLINKURL  = var.phantomdeeplinkurl
      PHANTOMBASEURL      = var.phantombaseurl
    }
  }
}

### API Gateway Proxy ###
## Imports id's from the API gateway created by api_gateway.tf
## The special path_part value "{proxy+}" activates proxy behavior, 
## which means that this resource will match any request path
resource "aws_api_gateway_resource" "vo_phantom_proxy" {
  rest_api_id = aws_api_gateway_rest_api.vo_phantom.id
  parent_id   = aws_api_gateway_rest_api.vo_phantom.root_resource_id
  path_part   = "{vo_phantom_proxy+}"
}

### API Gateway Method ###
## Uses a http_method of "ANY", which allows any request method to be used.
## Working in conjunction with the proxy+ setting above means that all 
## incoming requests will match this resource
resource "aws_api_gateway_method" "vo_phantom_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.vo_phantom.id
  resource_id   = aws_api_gateway_resource.vo_phantom_proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

### API Routing to Lambda ###
## Specifes that requests to method are sent to the Lambda Function
resource "aws_api_gateway_integration" "vo_phantom" {
  rest_api_id = aws_api_gateway_rest_api.vo_phantom.id
  resource_id = aws_api_gateway_method.vo_phantom_proxy.resource_id
  http_method = aws_api_gateway_method.vo_phantom_proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.vo_phantom.invoke_arn
}

### API Routing for proxy_root###
## The AWS_PROXY integration type causes API gateway to call into the API of another AWS service.
## In this case, it will call the AWS Lambda API to create an "invocation" of the Lambda function.
## Unfortunately the proxy resource cannot match an empty path at the root of the API. 
## To handle that, a similar configuration must be applied to the root resource that is built in to the REST API object:
resource "aws_api_gateway_method" "vo_phantom_proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.vo_phantom.id
  resource_id   = aws_api_gateway_rest_api.vo_phantom.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "vo_phantom_root" {
  rest_api_id = aws_api_gateway_rest_api.vo_phantom.id
  resource_id = aws_api_gateway_method.vo_phantom_proxy_root.resource_id
  http_method = aws_api_gateway_method.vo_phantom_proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.vo_phantom.invoke_arn
}

### Activate and expose API Gateway ###
## Create an API Gateway "deployment" in order to activate the configuration and 
## expose the API at a URL that can be used for testing.
resource "aws_api_gateway_deployment" "vo_phantom" {
  depends_on = [
    aws_api_gateway_integration.vo_phantom,
    aws_api_gateway_integration.vo_phantom_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.vo_phantom.id
  stage_name  = "default"
}

### Grant Lambda Access to API Gateway ###
## By default an AWS services does not have access to another service, 
## until access is explicitly granted.
resource "aws_lambda_permission" "vo_phantom_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.vo_phantom.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.vo_phantom.execution_arn}/*/*"
}

# ### Debugging Outputs ###
# output "vo_phantom_arns" {
#   value =  formatlist(
#     "%s, %s", 
#     aws_lambda_function.vo_phantom.function_name,
#     aws_lambda_function.vo_phantom.arn
#   )
# }
