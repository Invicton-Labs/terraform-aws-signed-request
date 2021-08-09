variable "request_signer_module" {
  description = "An `Invicton-Labs/request-signer/aws` module (https://registry.terraform.io/modules/Invicton-Labs/request-signer/aws). Pass the entire module in as this parameter (e.g. `request_signer_module = module.request-signer`)."
  type = object({
    invicton_labs_lambda_signer_arn = string
  })
}

variable "force_wait_for_apply" {
  description = "Whether to force this module to wait for apply-time to create the signed request. Otherwise, it will run during plan-time if possible (i.e. if all inputs are known during plan time)."
  type        = bool
  default     = false
}

variable "make_request" {
  description = "Whether to actually make the signed HTTP request. If this is `false` (default), it will just generate and return the signature, but will not actually make the request."
  type = bool
  default = false
}

variable "region" {
  description = "The region to sign the request for. Defaults to the region that the Terraform provider is configured in."
  type        = string
  default     = null
}

variable "method" {
  description = "The HTTP method to use for the request."
  type        = string
  validation {
    condition     = contains(["GET", "POST", "PUT", "HEAD", "DELETE", "OPTIONS"], var.method)
    error_message = "The `method` parameter must be a valid HTTP method (GET, POST, PUT, HEAD, DELETE, OPTIONS)."
  }
}
variable "service" {
  description = "The name of the AWS service to target for the request, as specified in the endpoint for the service (e.g. 'ec2' in 'ec2.amazonaws.com')."
  type        = string
}

variable "host" {
  description = "The specific host endpoint to make the request against (overrides the default endpoint for the specified service)."
  type        = string
  default     = null
  validation {
    condition     = var.host == null ? true : substr(var.host, 0, 9) == "https://"
    error_message = "The `host` parameter must begin with `https://`."
  }
  validation {
    condition     = var.host == null ? true : length(regexall("/", var.host)) == 0
    error_message = "The `host` parameter must not contain a URL path. Only the host (domain) should be provided."
  }
  validation {
    condition     = var.host == null ? true : length(regexall("\\?", var.host)) == 0
    error_message = "The `host` parameter must not contain query parameters. Only the host (domain) should be provided."
  }
}

variable "path" {
  description = "The URL path (not including the host) to make the request against."
  type        = string
  default     = ""
  validation {
    condition     = length(regexall("\\?", var.path)) == 0
    error_message = "The `path` parameter must not contain query parameters. Only the path should be provided."
  }
}

variable "query_parameters" {
  description = "Query parameters to include in the request."
  type        = map(string)
  default     = {}
  validation {
    condition = !contains([
      for k, v in var.query_parameters :
      lower(k)
    ], lower("X-Amz-Security-Token"))
    error_message = "The `query_parameters` parameter may not contain a key named `X-Amz-Security-Token`."
  }
  validation {
    condition = !contains([
      for k, v in var.query_parameters :
      lower(k)
    ], lower("X-Amz-Date"))
    error_message = "The `query_parameters` parameter may not contain a key named `X-Amz-Date`."
  }
  validation {
    condition = !contains([
      for k, v in var.query_parameters :
      lower(k)
    ], lower("Authorization"))
    error_message = "The `query_parameters` parameter may not contain a key named `Authorization`."
  }
  validation {
    condition = !contains([
      for k, v in var.query_parameters :
      lower(k)
    ], lower("X-Amz-Algorithm"))
    error_message = "The `query_parameters` parameter may not contain a key named `X-Amz-Algorithm`."
  }
  validation {
    condition = !contains([
      for k, v in var.query_parameters :
      lower(k)
    ], lower("X-Amz-Credential"))
    error_message = "The `query_parameters` parameter may not contain a key named `X-Amz-Credential`."
  }
  validation {
    condition = !contains([
      for k, v in var.query_parameters :
      lower(k)
    ], lower("X-Amz-SignedHeaders"))
    error_message = "The `query_parameters` parameter may not contain a key named `X-Amz-SignedHeaders`."
  }
  validation {
    condition = !contains([
      for k, v in var.query_parameters :
      lower(k)
    ], lower("X-Amz-Signature"))
    error_message = "The `query_parameters` parameter may not contain a key named `X-Amz-Signature`."
  }
}

variable "headers" {
  description = "Headers to include in the request. Certain headers that are automatically generated for signing will override provided headers with the same key."
  type        = map(string)
  default     = {}
  validation {
    condition = !contains([
      for k, v in var.headers :
      lower(k)
    ], lower("X-Amz-Security-Token"))
    error_message = "The `headers` parameter may not contain a key named `X-Amz-Security-Token`."
  }
  validation {
    condition = !contains([
      for k, v in var.headers :
      lower(k)
    ], lower("X-Amz-Date"))
    error_message = "The `headers` parameter may not contain a key named `X-Amz-Date`."
  }
  validation {
    condition = !contains([
      for k, v in var.headers :
      lower(k)
    ], lower("Authorization"))
    error_message = "The `headers` parameter may not contain a key named `Authorization`."
  }
  validation {
    condition = !contains([
      for k, v in var.headers :
      lower(k)
    ], lower("X-Amz-Algorithm"))
    error_message = "The `headers` parameter may not contain a key named `X-Amz-Algorithm`."
  }
  validation {
    condition = !contains([
      for k, v in var.headers :
      lower(k)
    ], lower("X-Amz-Credential"))
    error_message = "The `headers` parameter may not contain a key named `X-Amz-Credential`."
  }
  validation {
    condition = !contains([
      for k, v in var.headers :
      lower(k)
    ], lower("X-Amz-SignedHeaders"))
    error_message = "The `headers` parameter may not contain a key named `X-Amz-SignedHeaders`."
  }
  validation {
    condition = !contains([
      for k, v in var.headers :
      lower(k)
    ], lower("X-Amz-Signature"))
    error_message = "The `headers` parameter may not contain a key named `X-Amz-Signature`."
  }
  validation {
    condition = !contains([
      for k, v in var.headers :
      lower(k)
    ], lower("Content-Length"))
    error_message = "The `headers` parameter may not contain a key named `Content-Length` (this header will be set dynamically based on the body size)."
  }
}

variable "body" {
  description = "The body content to send in the request. Must consist entirely of valid UTF-8 characters. Will be used as-is when signing. Conflicts with the `body_base64` input parameter."
  type        = string
  default     = null
}

variable "body_base64" {
  description = "The base64-encoded body to send in the request. Will be decoded prior to signing. Conflicts with the `body` input parameter."
  type        = string
  default     = null
}

module "assert_body_present" {
  source        = "Invicton-Labs/assertion/null"
  version       = "0.2.1"
  condition     = var.body != null || var.body_base64 != null
  error_message = "Either the `body` or `body_base64` input parameter must be provided."
}
module "assert_single_body" {
  source        = "Invicton-Labs/assertion/null"
  version       = "0.2.1"
  condition     = var.body == null || var.body_base64 == null
  error_message = "The `body` and `body_base64` input parameters cannot both be provided."
}
