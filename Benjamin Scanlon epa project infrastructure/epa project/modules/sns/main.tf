# sns_topic

resource "aws_sns_topic" "alerts" {
  name              = "${var.environment}-${var.sns_topic_name}"
  kms_master_key_id = "alias/aws/sns"
  tags = {
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "email_alerts_subscription" {
  for_each  = toset(var.sns_subscriptions)
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = each.key
}