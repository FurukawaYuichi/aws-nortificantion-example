import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as sns from 'aws-cdk-lib/aws-sns';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as chatbot from 'aws-cdk-lib/aws-chatbot';
import * as subscriptions from 'aws-cdk-lib/aws-sns-subscriptions';

interface NotificationStackProps extends cdk.StackProps {
  slackWorkspaceId?: string;
  slackChannelId?: string;
  mailAddress?: string;
}

export class NotificationStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: NotificationStackProps) {
    super(scope, id, props);

    // SNS Topic
    const topic = new sns.Topic(this, 'NotificationTopic', {
      topicName: 'notification-topic',
    });


    // SNS Email Subscription (optional)
    if (props.mailAddress) {
      topic.addSubscription(new subscriptions.EmailSubscription(props.mailAddress));
    }

    // IAM Role for Chatbot
    const chatbotRole = new iam.Role(this, 'ChatbotRole', {
      assumedBy: new iam.ServicePrincipal('chatbot.amazonaws.com'),
      roleName: 'chatbot-notification-role',
    });

    // IAM Policy for Chatbot
    const chatbotPolicy = new iam.Policy(this, 'ChatbotPolicy', {
      policyName: 'chatbot-notification-policy',
      statements: [
        new iam.PolicyStatement({
          effect: iam.Effect.ALLOW,
          actions: ['logs:*', 'cloudwatch:*'],
          resources: ['*'],
        }),
      ],
    });
    chatbotPolicy.attachToRole(chatbotRole);

    // Chatbot Slack Channel Configuration (optional)
    if (props.slackWorkspaceId && props.slackChannelId) {
      new chatbot.CfnSlackChannelConfiguration(this, 'SlackChannelConfig', {
        configurationName: 'notification-configuration',
        iamRoleArn: chatbotRole.roleArn,
        slackChannelId: props.slackChannelId,
        slackWorkspaceId: props.slackWorkspaceId,
        snsTopicArns: [topic.topicArn],
        loggingLevel: 'INFO',
      });
    }

    // EventBridgeルールの追加
    // notification-eventbridge.tsのコンストラクトを利用
    // accountIdはStack.of(this).accountで取得
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const { NotificationEventBridge } = require('./notification-eventbridge');
    new NotificationEventBridge(this, 'SensitiveEventBridge', {
      snsTopic: topic,
      accountId: cdk.Stack.of(this).account,
    });
  }
}
