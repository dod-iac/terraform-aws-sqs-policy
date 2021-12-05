/**
 * ## Usage
 *
 * Creates a SQS policy document for use as a policy for a SQS queue.
 *
 * ```hcl
 * module "sqs_policy_document" {
 *   source = "dod-iac/sqs-policy-document/aws"
 *
 *   s3_buckets_send  = [module.s3_bucket_source.arn]
 *   receivers = [module.lambda_function_receive.arn]
 * }
 *
 * module "sqs_queue" {
 *   source = "dod-iac/sqs-queue"
 *
 *   name = format("app-%s-%s", var.application, var.environment)
 *   policy = module.sqs_policy_document.json
 * }
 *
 * ```
 *
 * ## Testing
 *
 * Run all terratest tests using the `terratest` script.  If using `aws-vault`, you could use `aws-vault exec $AWS_PROFILE -- terratest`.  The `AWS_DEFAULT_REGION` environment variable is required by the tests.  Use `TT_SKIP_DESTROY=1` to not destroy the infrastructure created during the tests.  Use `TT_VERBOSE=1` to log all tests as they are run.  Use `TT_TIMEOUT` to set the timeout for the tests, with the value being in the Go format, e.g., 15m.  Use `TT_TEST_NAME` to run a specific test by name.
 *
 * ## Terraform Version
 *
 * Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to main branch.
 *
 * Terraform 0.11 and 0.12 are not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_caller_identity" "current" {}

data "aws_iam_account_alias" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "main" {
  policy_id = "queue-policy"

  #
  # AllowS3EventNotifications
  #

  dynamic "statement" {
    for_each = length(var.s3_buckets_send) > 0 ? [1] : []
    content {
      sid = "AllowS3EventNotifications"
      actions = [
        "sqs:SendMessage"
      ]
      effect    = "Allow"
      resources = [var.queue_arn]
      principals {
        type        = "AWS"
        identifiers = ["*"]
      }
      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [data.aws_caller_identity.current.account_id]
      }
      condition {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values   = var.s3_buckets_send
      }
    }
  }

  #
  # AllowEventBridgeRules
  #

  dynamic "statement" {
    for_each = length(var.eventbridge_rules_send) > 0 ? [1] : []
    content {
      sid = "AllowEventBridgeRules"
      actions = [
        "sqs:SendMessage"
      ]
      effect    = "Allow"
      resources = [var.queue_arn]
      principals {
        type        = "Service"
        identifiers = ["events.amazonaws.com"]
      }
      condition {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values = !contains(var.eventbridge_rules_send, "*") ? var.eventbridge_rules_send : [format(
          "arn:%s:events:%s:%s:rule/*",
          data.aws_partition.current.partition,
          data.aws_region.current.name,
          data.aws_caller_identity.current.account_id,
        )]
      }
    }
  }

  #
  # GetQueueAttributes
  #

  dynamic "statement" {
    for_each = length(distinct(flatten([var.receivers, var.senders]))) > 0 ? [1] : []
    content {
      sid = "GetQueueAttributes"
      actions = [
        "sqs:GetQueueAttributes",
      ]
      effect    = "Allow"
      resources = [var.queue_arn]
      principals {
        type        = "AWS"
        identifiers = distinct(flatten([var.receivers, var.senders]))
      }
    }
  }

  #
  # ReceiveMessage
  #

  dynamic "statement" {
    for_each = length(var.receivers) > 0 ? [1] : []
    content {
      sid = "ReceiveMessage"
      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage"
      ]
      effect    = "Allow"
      resources = [var.queue_arn]
      principals {
        type        = "AWS"
        identifiers = var.receivers
      }
    }
  }

  #
  # SendMessage
  #

  dynamic "statement" {
    for_each = length(var.senders) > 0 ? [1] : []
    content {
      sid = "SendMessage"
      actions = [
        "sqs:SendMessage",
      ]
      effect    = "Allow"
      resources = [var.queue_arn]
      principals {
        type        = "AWS"
        identifiers = var.senders
      }
    }
  }

}
