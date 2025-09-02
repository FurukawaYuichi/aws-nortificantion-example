variable "slack_workspace_id" {
  description = "The ID of the Slack workspace to send notifications to."
  type        = string
  default    = ""
}

variable "slack_channel_id" {
  description = "The ID of the Slack channel to send notifications to."
  type        = string
  default = ""
}

variable "mail_address" {
  description = "The email address to receive notifications."
  type        = string
  default = ""
}
