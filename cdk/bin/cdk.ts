#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { NotificationStack } from '../lib/notification-stack';

const app = new cdk.App();
new NotificationStack(app, 'NotificationStack', {
  slackWorkspaceId: process.env.SLACK_WORKSPACE_ID,
  slackChannelId: process.env.SLACK_CHANNEL_ID,
  mailAddress: process.env.MAIL_ADDRESS,
});
