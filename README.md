<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Usage

Creates a SQS policy document for use as a policy for a SQS queue.

```hcl
module "sqs_policy_document" {
  source = "dod-iac/sqs-policy-document/aws"

  s3_buckets_send  = [module.s3_bucket_source.arn]
  receivers = [module.lambda_function_receive.arn]
}

module "sqs_queue" {
  source = "dod-iac/sqs-queue"

  name = format("app-%s-%s", var.application, var.environment)
  policy = module.sqs_policy_document.json
}

```

## Testing

Run all terratest tests using the `terratest` script.  If using `aws-vault`, you could use `aws-vault exec $AWS_PROFILE -- terratest`.  The `AWS_DEFAULT_REGION` environment variable is required by the tests.  Use `TT_SKIP_DESTROY=1` to not destroy the infrastructure created during the tests.  Use `TT_VERBOSE=1` to log all tests as they are run.  Use `TT_TIMEOUT` to set the timeout for the tests, with the value being in the Go format, e.g., 15m.  Use `TT_TEST_NAME` to run a specific test by name.

## Terraform Version

Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to main branch.

Terraform 0.11 and 0.12 are not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_account_alias.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_account_alias) | data source |
| [aws_iam_policy_document.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eventbridge_rules_send"></a> [eventbridge\_rules\_send](#input\_eventbridge\_rules\_send) | The ARNs of the AWS EventBridge rules that can send events into the queue.  Use ["*"] to allow all rules in the current account. | `list(string)` | `[]` | no |
| <a name="input_queue_arn"></a> [queue\_arn](#input\_queue\_arn) | The ARN of the AWS SQS queue. | `string` | n/a | yes |
| <a name="input_receivers"></a> [receivers](#input\_receivers) | List of AWS principals that can receive messages from the SQS queue. | `list(string)` | `[]` | no |
| <a name="input_s3_buckets_send"></a> [s3\_buckets\_send](#input\_s3\_buckets\_send) | The ARNs of the AWS S3 buckets that can send S3 event notifications into the queue. Use ["*"] to allow all buckets in the current account. | `list(string)` | `[]` | no |
| <a name="input_senders"></a> [senders](#input\_senders) | List of AWS principals that can send messages into the SQS queue. | `list(string)` | `[]` | no |
| <a name="input_sns_topics_send"></a> [sns\_topics\_send](#input\_sns\_topics\_send) | The ARNs of the AWS SNS topics that can send SNS messages into the queue. Use ["*"] to allow all SNS topics in the current account. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_json"></a> [json](#output\_json) | The rendered JSON of the policy document. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
