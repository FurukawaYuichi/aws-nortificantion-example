# 危険な操作をしていると思われるイベントを検知してSlackに通知する
# SNSトピックの作成
# trivy:ignore:AVD-AWS-0095
resource "aws_sns_topic" "notification" {
  name = "notification-topic"
}

resource "aws_sns_topic_policy" "notification" {
  arn    = aws_sns_topic.notification.arn
  policy = data.aws_iam_policy_document.chatbot_sns_policy.json
}


resource "aws_sns_topic_subscription" "email_subscription" {
  count     = var.mail_address != "" ? 1 : 0 # メールアドレスが空でない場合のみ作成
  topic_arn = aws_sns_topic.notification.arn
  protocol  = "email"
  endpoint  = var.mail_address
}

# ChatbotのためのIAMロールとポリシー
resource "aws_iam_role" "chatbot_role" {
  #count              = var.slack_channel_id != "" && var.slack_workspace_id != "" ? 1 : 0 # Slackの情報が空でない場合のみ作成
  name               = "chatbot-notification-role"
  assume_role_policy = data.aws_iam_policy_document.chatbot_assume_policy.json
}

resource "aws_iam_policy" "chatbot_policy" {
  #count  = var.slack_channel_id != "" && var.slack_workspace_id != "" ? 1 : 0 # Slackの情報が空でない場合のみ作成
  name   = "chatbot-notification-policy"
  policy = data.aws_iam_policy_document.chatbot_policy.json
}

resource "aws_iam_role_policy_attachment" "chatbot_policy" {
  count      = var.slack_channel_id != "" && var.slack_workspace_id != "" ? 1 : 0 # Slackの情報が空でない場合のみ作成
  policy_arn = aws_iam_policy.chatbot_policy.arn
  role       = aws_iam_role.chatbot_role.name
}

# Chatbotの設定
resource "awscc_chatbot_slack_channel_configuration" "notification" {
  count              = var.slack_channel_id != "" && var.slack_workspace_id != "" ? 1 : 0 # Slackの情報が空でない場合のみ作成
  configuration_name = "notification-configuration"
  iam_role_arn       = aws_iam_role.chatbot_role.arn
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id
  sns_topic_arns     = [aws_sns_topic.notification.arn]
  logging_level      = "INFO"
  # SNSトピックのポリシーで制御しているため、ここではポリシーを指定しない
}

# 特定のAWSイベントを通知するためのEventBridgeルール
# SSOのユーザーでデータの複製と思われる操作をした時のイベントを通知するルール
resource "aws_cloudwatch_event_rule" "access_sensitive_data" {
  name        = "may-access-sesitive-data-events"
  description = "Actions that may have led to access to sensitive data."

  event_pattern = jsonencode({
    source = [
      "aws.s3",
      "ec2.amazonaws.com",
      "rds.amazonaws.com"
    ]
    detail-type = [
      "AWS API Call via CloudTrail",
    ]
    detail = {

      eventName = [
        "GetObject",
        "CreateSnapshot",
        "DeleteSnapshot",
        "CreateDBSnapshot",
        "DeleteDBSnapshot",
        "SharedSnapshotCopyInitiated",
        "SharedSnapshotVolumeCreated",
        "ModifySnapshotAttribute",
      "CopySnapshot"]
      userIdentity = {
        type = [
          "AssumedRole",
        ]
        arn = [{ "prefix" : "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/AWSReservedSSO" }]
      }
    }
  })
}

# EventBridgeルールとSNSトピックのターゲットを関連付け
resource "aws_cloudwatch_event_target" "access_sensitive_data" {
  rule      = aws_cloudwatch_event_rule.access_sensitive_data.name
  target_id = "send-to-sns"
  arn       = aws_sns_topic.notification.arn
}



/*
# EventBridgeルールの作成
resource "aws_cloudwatch_event_rule" "test" {
  name        = "CopySnapshotRule"
  description = "Trigger for CopySnapshot action by AWS SSO users"
  event_pattern = <<PATTERN
{
  "source": [
    "aws.s3",
    "ec2.amazonaws.com",
    "rds.amazonaws.com"
  ],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventName": [
      "GetObject",
      "CreateSnapshot",
      "DeleteSnapshot",
      "CreateDBSnapshot",
      "DeleteDBSnapshot",
      "SharedSnapshotCopyInitiated",
      "SharedSnapshotVolumeCreated",
      "ModifySnapshotAttribute",
      "CopySnapshot"
    ],
    "userIdentity": {
      "type": ["AssumedRole"],
      "arn": [{ "prefix": "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/AWSReservedSSO" }]
    }
  }
}
PATTERN
}

# EventBridgeルールとSNSトピックのターゲットを関連付け
resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.test.name
  arn       = aws_sns_topic.notification.arn
}
*/
