/**
 * ## Usage
 *
 * This example is used by the `TestTerraformSimpleExample` test in `test/terrafrom_aws_simple_test.go`.
 *
 * ## Terraform Version
 *
 * This test was created for Terraform 1.0.11.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

#
# S3
#

module "s3_bucket_source" {
  source  = "dod-iac/s3-bucket/aws"
  version = "1.2.0"

  name = format("test-src-%s", var.test_name)
  notifications = [{
    id = format("test-queue-%s", var.test_name)
    queue_arn = format(
      "arn:%s:sqs:%s:%s:test-queue-%s",
      data.aws_partition.current.partition,
      data.aws_region.current.name,
      data.aws_caller_identity.current.account_id,
      var.test_name
    )
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = ""
    filter_suffix = ""
  }]
  tags = var.tags
}

#
# EventBridge Rule
#

data "aws_iam_policy_document" "events_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_target_role_cron_test" {
  statement {
    sid = "SendMessages"
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
    ]
    effect    = "Allow"
    resources = [module.sqs_queue.arn]
  }
}

resource "aws_iam_role" "cloudwatch_target_role_test" {
  name               = format("test-events-target-role-%s", var.test_name)
  description        = "Role allowing CloudWatch Events to send events to the SQS queue"
  assume_role_policy = data.aws_iam_policy_document.events_assume_role_policy.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "cloudwatch_target_role_test_policy" {
  name   = format("%s-policy", aws_iam_role.cloudwatch_target_role_test.name)
  role   = aws_iam_role.cloudwatch_target_role_test.name
  policy = data.aws_iam_policy_document.cloudwatch_target_role_cron_test.json
}

resource "aws_cloudwatch_event_rule" "test" {
  is_enabled          = true
  name                = format("test-%s", var.test_name)
  description         = "Send event every minute"
  schedule_expression = "cron(0* * * * ? *)"
  tags                = var.tags
}

#
# SQS Policy
#

module "sqs_policy_document" {
  source = "../../"

  s3_buckets_send = [module.s3_bucket_source.arn]
  queue_arn = format(
    "arn:%s:sqs:%s:%s:test-queue-%s",
    data.aws_partition.current.partition,
    data.aws_region.current.name,
    data.aws_caller_identity.current.account_id,
    var.test_name
  )
  eventbridge_rules_send = [
    aws_cloudwatch_event_rule.test.arn
  ]
}

#
# SQS Queue
#

module "sqs_queue" {
  source  = "dod-iac/sqs-queue/aws"
  version = "1.0.4"

  name   = format("test-queue-%s", var.test_name)
  policy = module.sqs_policy_document.json
}

#
# Event Bridge Target
#

resource "aws_cloudwatch_event_target" "test" {
  target_id = format("test-%s", var.test_name)

  arn  = module.sqs_queue.arn
  rule = aws_cloudwatch_event_rule.test.name
}
