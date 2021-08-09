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
    make_request     = var.make_request
    region           = local.region
    method           = var.method
    service          = var.service
    host             = var.host
    path             = var.path
    query_parameters = var.query_parameters
    headers          = var.headers
    body             = var.body_base64 != null ? var.body_base64 : base64encode(var.body)
  })
}

locals {
  result = jsondecode(data.aws_lambda_invocation.sign.result)
}
