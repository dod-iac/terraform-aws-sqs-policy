variable "queue_arn" {
  type        = string
  description = "The ARN of the AWS SQS queue."
}

variable "eventbridge_rules_send" {
  type        = list(string)
  description = "The ARNs of the AWS EventBridge rules that can send events into the queue.  Use [\"*\"] to allow all rules in the current account."
  default     = []
}

variable "s3_buckets_send" {
  type        = list(string)
  description = "The ARNs of the AWS S3 buckets that can send S3 event notifications into the queue. Use [\"*\"] to allow all buckets in the current account."
  default     = []
}

variable "sns_topics_send" {
  type        = list(string)
  description = "The ARNs of the AWS SNS topics that can send SNS messages into the queue. Use [\"*\"] to allow all SNS topics in the current account."
  default     = []
}

variable "receivers" {
  type        = list(string)
  description = "List of AWS principals that can receive messages from the SQS queue."
  default     = []
}

variable "senders" {
  type        = list(string)
  description = "List of AWS principals that can send messages into the SQS queue."
  default     = []
}
