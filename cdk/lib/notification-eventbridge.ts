import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as events from 'aws-cdk-lib/aws-events';
import * as targets from 'aws-cdk-lib/aws-events-targets';
import * as sns from 'aws-cdk-lib/aws-sns';

interface NotificationEventBridgeProps {
  snsTopic: sns.ITopic;
  accountId: string;
}

export class NotificationEventBridge extends Construct {
  constructor(scope: Construct, id: string, props: NotificationEventBridgeProps) {
    super(scope, id);

    const rule = new events.Rule(this, 'AccessSensitiveDataRule', {
      ruleName: 'may-access-sesitive-data-events',
      description: 'Actions that may have led to access to sensitive data.',
      eventPattern: {
        source: ['aws.s3', 'ec2.amazonaws.com', 'rds.amazonaws.com'],
        detailType: ['AWS API Call via CloudTrail'],
        detail: {
          eventName: [
            'GetObject',
            'CreateSnapshot',
            'DeleteSnapshot',
            'CreateDBSnapshot',
            'DeleteDBSnapshot',
            'SharedSnapshotCopyInitiated',
            'SharedSnapshotVolumeCreated',
            'ModifySnapshotAttribute',
            'CopySnapshot',
          ],
          userIdentity: {
            type: ['AssumedRole'],
            arn: [{ prefix: `arn:aws:sts::${props.accountId}:assumed-role/AWSReservedSSO` }],
          },
        },
      },
    });

    rule.addTarget(new targets.SnsTopic(props.snsTopic));
  }
}
