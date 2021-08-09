output "result" {
  value = jsondecode(data.aws_lambda_invocation.sign.result)
}

output "request_host" {
  description = "The host that was used to create and sign the request URL."
  value       = local.result.host
}

output "request_url" {
  description = "The complete request URL to use for the request."
  value       = local.result.url
}
