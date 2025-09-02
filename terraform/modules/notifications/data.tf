data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Chatbot向けAssume Roleポリシー
data "aws_iam_policy_document" "chatbot_assume_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["chatbot.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Chatbotのロギングのための設定
data "aws_iam_policy_document" "chatbot_policy" {
  statement {
    sid    = "AllowCloudWatchLogsAndMetrics"
    effect = "Allow"
    actions = [
      "logs:*",
      "cloudwatch:*"
    ]
    resources = [
      "*",
    ]
  }
}

# SNSトピックのポリシー
data "aws_iam_policy_document" "chatbot_sns_policy" {
  statement {
    sid    = "event"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.notification.arn]

    condition {
      test     = "ArnEquals"
      variable = "AWS:SourceArn"
      values = [
        # 送信元のEventBridgeルールのARNを指定
        aws_cloudwatch_event_rule.access_sensitive_data.arn,
      ]

    }
  }
}
