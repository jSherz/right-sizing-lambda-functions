resource "aws_xray_sampling_rule" "this" {
  rule_name      = "right-size-lambda-functions"
  fixed_rate     = 1 # 100%
  host           = "*"
  http_method    = "*"
  priority       = 1000
  reservoir_size = 10
  resource_arn   = "*"
  service_name   = "right-size-lambda-functions"
  service_type   = "*"
  url_path       = "*"
  version        = 1
}

module "files" {
  source = "./modules/s3-bucket"

  name           = "${var.prefix}-files-${data.aws_caller_identity.this.account_id}-${data.aws_region.this.name}"
  events_enabled = true
}

data "aws_iam_policy_document" "file_processor" {
  statement {
    sid    = "AllowHandlingFiles"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:DeleteObject",
    ]
    resources = [
      module.files.arn,
      "${module.files.arn}/*",
    ]
  }
}

module "small_lambda" {
  source = "./modules/lambda-function"

  name              = "${var.prefix}-small-lambda"
  description       = "The smallest file processing Lambda."
  entrypoint        = "../lambda/src/handlers/file-processor/index.ts"
  working_directory = "../lambda"
  iam_policy        = data.aws_iam_policy_document.file_processor.json

  memory_size = 256

  event_rule_arns = {
    small-files = module.small_files.arn
  }
}

module "medium_lambda" {
  source = "./modules/lambda-function"

  name              = "${var.prefix}-medium-lambda"
  description       = "The medium sized file processing Lambda."
  entrypoint        = "../lambda/src/handlers/file-processor/index.ts"
  working_directory = "../lambda"
  iam_policy        = data.aws_iam_policy_document.file_processor.json

  memory_size = 1024

  event_rule_arns = {
    medium-files = module.medium_files.arn
  }
}

module "large_lambda" {
  source = "./modules/lambda-function"

  name              = "${var.prefix}-large-lambda"
  description       = "The largest file processing Lambda."
  entrypoint        = "../lambda/src/handlers/file-processor/index.ts"
  working_directory = "../lambda"
  iam_policy        = data.aws_iam_policy_document.file_processor.json

  memory_size = 4096

  event_rule_arns = {
    large-files = module.large_files.arn
  }
}

locals {
  one_kilobyte = 1000 # bytes

  one_megabyte = local.one_kilobyte * 1000 # bytes
}

module "small_files" {
  source = "./modules/lambda-function-eventbridge-event"

  name                = "${var.prefix}-small-files"
  description         = "Processes small files."
  lambda_function_arn = module.small_lambda.arn

  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail-type" : ["Object Created"],
    "detail" : {
      "bucket" : {
        "name" : [module.files.name],
      },
      "object" : {
        "size" : [
          {
            "numeric" : [">", 0, "<=", 100 * local.one_kilobyte]
          }
        ],
      },
    },
  })
}


module "medium_files" {
  source = "./modules/lambda-function-eventbridge-event"

  name                = "${var.prefix}-medium-files"
  description         = "Processes medium sized files."
  lambda_function_arn = module.medium_lambda.arn

  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail-type" : ["Object Created"],
    "detail" : {
      "bucket" : {
        "name" : [module.files.name],
      },
      "object" : {
        "size" : [
          {
            "numeric" : [">", 100 * local.one_kilobyte, "<=", 25 * local.one_megabyte]
          }
        ],
      },
    },
  })
}


module "large_files" {
  source = "./modules/lambda-function-eventbridge-event"

  name                = "${var.prefix}-large-files"
  description         = "Processes large files."
  lambda_function_arn = module.large_lambda.arn

  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail-type" : ["Object Created"],
    "detail" : {
      "bucket" : {
        "name" : [module.files.name],
      },
      "object" : {
        "size" : [
          {
            "numeric" : [">", 25 * local.one_megabyte]
          }
        ],
      },
    },
  })
}
