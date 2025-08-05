terraform {
  source = "git::https://github.com/KaribuLab/terraform-aws-function.git?ref=v0.5.1"
}

locals {
  serverless    = read_terragrunt_config(find_in_parent_folders("serverless.hcl"))
  function_name = "${local.serverless.locals.service_name}-lambda-${local.serverless.locals.stage}"
  common_tags   = local.serverless.locals.common_tags
  base_path     = "${local.serverless.locals.parameter_path}/${local.serverless.locals.stage}"
}

include {
  path = find_in_parent_folders()
}

dependency log {
  config_path = "${get_parent_terragrunt_dir()}/aws/cloudwatch"
  mock_outputs = {
    log_arn = "log_arn"
  }
}

dependency parameters {
  config_path = "${get_parent_terragrunt_dir()}/aws/parameter"
  mock_outputs = {
    parameters = {
      "/clr/ivr/test/infra/subnet1"             = "subnet-00000000000000000"
      "/clr/ivr/test/infra/subnet2"             = "subnet-00000000000000000"
      "/clr/ivr/test/infra/sg1"                 = "sgr-00000000000000000"
      "/clr/ivr/test/infra/circuitbreaker-arn"  = "arn:aws:dynamodb:us-east-1:000000000000:table/clr-ivr-circuit-breaker-test"
      "/clr/ivr/prod/infra/subnet1"             = "subnet-00000000000000000"
      "/clr/ivr/prod/infra/subnet2"             = "subnet-00000000000000000"
      "/clr/ivr/prod/infra/sg1"                 = "sgr-00000000000000000"
      "/clr/ivr/prod/infra/circuitbreaker-arn"  = "arn:aws:dynamodb:us-east-1:000000000000:table/clr-ivr-circuit-breaker-prod"
    }
  }
}

inputs = {
  function_name = local.function_name
  iam_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "${dependency.log.outputs.log_arn}:*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
        ],
        "Resource" : [
          dependency.parameters.outputs.parameters["${local.base_path}/infra/circuitbreaker-arn"],
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParametersByPath"
        ],
        "Resource" : [
          "arn:aws:ssm:*:*:parameter${local.base_path}/common",
          "arn:aws:ssm:*:*:parameter${local.base_path}/{{.Inputs.module|toLowerCase}}"
        ]
      }
    ]
  })
  environment_variables = {
    PARAMETER_BASE_PATH = local.serverless.locals.parameter_path
    AWS_STAGE           = local.serverless.locals.stage
  }
  runtime       = "nodejs20.x"
  handler       = "src/entrypoint.handler"
  bucket        = local.serverless.locals.service_bucket
  file_location = "${get_parent_terragrunt_dir()}/build"
  zip_location  = "${get_parent_terragrunt_dir()}/dist"
  zip_name      = "${local.function_name}.zip"
  vpc_config = {
    subnet_ids = [
      dependency.parameters.outputs.parameters["${local.base_path}/infra/subnet1"],
      dependency.parameters.outputs.parameters["${local.base_path}/infra/subnet2"]
    ]
    security_group_ids = [
      dependency.parameters.outputs.parameters["${local.base_path}/infra/sg1"],
      dependency.parameters.outputs.parameters["${local.base_path}/infra/sg2"]
    ]
  }
  common_tags = merge(local.common_tags, {
    Name = local.function_name
  })
}
