# Terraform AWS Signed Request

This module creates an AWS v4 signed request. It is intended to be used in conjunction with the [Invicton-Labs/request-signer/aws](https://registry.terraform.io/modules/Invicton-Labs/request-signer/aws/latest) module.

By default, this module only creates the signed request, but does not execute it. Using the `make_request` input parameter, you can optionally execute the request and return the response as well.

## Basic Usage

```
module "request_signer" {
  source = "Invicton-Labs/request-signer/aws"

  // Create a role with admin permissions so the Lambda can sign any request
  lambda_role_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}

module "signed_request" {
  source                = "Invicton-Labs/signed-request/aws"

  // Pass in the module we just created
  request_signer_module = module.request_signer

  // Parameters for the request. See the documentation for this module for details.
  method                = "GET"
  service               = "ec2"
  headers               = {}
  query_parameters = {
    Action  = "DescribeRegions",
    Version = "2013-10-15",
  }
}

output "signed_request_url" {
    value = module.signed_request.request_url
}
output "signed_request_headers" {
    value = module.signed_request.request_headers
}
```

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

signed_request_headers = {
  "Authorization" = "AWS4-HMAC-SHA256 Credential=.../20210809/us-east-1/ec2/aws4_request, SignedHeaders=content-length;host;x-amz-date;x-amz-security-token, Signature=..."
  "Content-Length" = "0"
  "X-Amz-Date" = "20210809T193725Z"
  "X-Amz-Security-Token" = "..."
}
signed_request_url = "https://ec2.us-east-1.amazonaws.com?Action=DescribeRegions&Version=2013-10-15"
```

## Request Execution

```
module "signed_request" {
  source                = "Invicton-Labs/signed-request/aws"

  request_signer_module = module.request_signer

  // Parameters for the request. See the documentation for this module for details.
  method                = "GET"
  service               = "ec2"
  headers               = {}
  query_parameters = {
    Action  = "DescribeRegions",
    Version = "2013-10-15",
  }

  // Tell the module to actually execute the request
  make_request = true
}

// Output the response body object, which is an internally parsed version of the response XML
output "response_body_object" {
  value = module.signed_request.response_body_object
}
```

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

response_body_object = {
  "DescribeRegionsResponse" = {
    "$content" = null
    "$namespace" = "http://ec2.amazonaws.com/doc/2013-10-15/"
    "regionInfo" = {
      "$content" = null
      "$namespace" = "http://ec2.amazonaws.com/doc/2013-10-15/"
      "item" = [
        {
          "$content" = null
          "$namespace" = "http://ec2.amazonaws.com/doc/2013-10-15/"
          "regionEndpoint" = {
            "$content" = "ec2.eu-north-1.amazonaws.com"
            "$namespace" = "http://ec2.amazonaws.com/doc/2013-10-15/"
          }
          "regionName" = {
            "$content" = "eu-north-1"
            "$namespace" = "http://ec2.amazonaws.com/doc/2013-10-15/"
          }
        },
        {
          "$content" = null
          "$namespace" = "http://ec2.amazonaws.com/doc/2013-10-15/"
          "regionEndpoint" = {
            "$content" = "ec2.ap-south-1.amazonaws.com"
            "$namespace" = "http://ec2.amazonaws.com/doc/2013-10-15/"
          }
          "regionName" = {
            "$content" = "ap-south-1"
            "$namespace" = "http://ec2.amazonaws.com/doc/2013-10-15/"
          }
        },
        ...
      ]
    }
    "requestId" = {
      "$content" = "d1912109-816a-47b9-ba05-c79ba6922c43"
      "$namespace" = "http://ec2.amazonaws.com/doc/2013-10-15/"
    }
  }
}
```
