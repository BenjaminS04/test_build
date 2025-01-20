variable "environment" {
  description = "environment of deployment, will be added to topic name"
}

variable "sns_topic_name" {
  description = "name for the sns topic"
}

variable "sns_subscriptions" {
  description = "List of email addresses to subscribe to the SNS topic"
  type        = list(string)
}