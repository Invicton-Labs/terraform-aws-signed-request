locals {
  wait_for_apply = var.force_wait_for_apply ? uuid() : null
  region         = var.region != null ? var.region : data.aws_region.current.name
}

data "aws_region" "current" {}

data "aws_lambda_invocation" "sign" {
  depends_on = [
    var.request_signer_module,
    local.wait_for_apply
  ]
  function_name = local.wait_for_apply == null ? var.request_signer_module.invicton_labs_lambda_signer_arn : var.request_signer_module.invicton_labs_lambda_signer_arn
  input = jsonencode({
    make_request                       = var.make_request
    region                             = local.region
    method                             = var.method
    service                            = var.service
    host                               = var.host
    path                               = var.path
    query_parameters                   = var.query_parameters
    headers                            = var.headers
    body                               = var.body_base64 != null ? var.body_base64 : (var.body != null ? base64encode(var.body) : null)
    retries_connect                    = var.retries_connect
    retries_read                       = var.retries_read
    retries_redirect                   = var.retries_redirect
    retries_status                     = var.retries_status
    retries_other                      = var.retries_other
    retries_backoff_factor             = var.retries_backoff_factor
    retries_raise_on_redirect          = var.retries_raise_on_redirect
    retries_raise_on_status            = var.retries_raise_on_status
    retries_status_forcelist           = var.retries_status_forcelist
    retries_respect_retry_after_header = var.retries_respect_retry_after_header
  })
}

locals {
  result            = jsondecode(data.aws_lambda_invocation.sign.result)
  response_body_raw = var.make_request ? (local.result.response.body_is_utf_8 ? base64decode(local.result.response.body_base64) : null) : null
}
