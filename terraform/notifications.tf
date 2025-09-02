module "set_notifications" {
  source = "./modules/notifications"
  # TODO: Slackへ送る場合は以下を設定してください
  slack_workspace_id = "your-slack-workspace-id"
  slack_channel_id   = "your-slack-channel-id"
  # TODO: メールで送る場合は以下を設定してください
  mail_address       = "your-mail-address"
}
