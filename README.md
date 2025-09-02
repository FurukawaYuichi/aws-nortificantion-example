# aws-nortificantion-example

# 説明
AWSのSSOユーザーがデータのコピー等をした時にSlackやメールへ通知するためのサンプルコードとなります。
まずは、terraformで作成しています。


### CDKのセットアップ手順
1. Node.jsのインストール
	- [公式ダウンロードページ](https://nodejs.org/ja/download/) からインストールしてください。
	- macOSの場合はHomebrewでも可能です：
	  ```bash
	  brew install node
	  ```
2. 必要パッケージのインストール
	```bash
	cd cdk
	npm install
	```
3. 変数の設定
	`cdk/cdk.json` の `context` 部分でSlackやメールアドレスを設定してください。
	```json
	{
	  "slackWorkspaceId": "your-slack-workspace-id",
	  "slackChannelId": "your-slack-channel-id",
	  "mailAddress": "your-mail-address"
	}
	```
4. CDK bootstrap（初回のみ）
	- CDKで初めてAWS環境にデプロイする場合は、bootstrapが必要です。
	```bash
	npx cdk bootstrap
	```
	- これにより、CDK用のS3バケットやIAMロールがAWSに作成されます。
5. テンプレートの確認
	```bash
	npx cdk synth
	```
6. 差分の確認
	```bash
	npx cdk diff
	```
7. デプロイ
	```bash
	npx cdk deploy
	```
8. 削除（不要時）
	```bash
	npx cdk destroy
	```

> 注意: bootstrapで作成されたリソース（CDKToolkitスタック）は不要になった場合、AWS CloudFormationから手動で削除できます。
7. 削除（不要時）
	```bash
	npx cdk destroy
	```

CDKを使うことで、TypeScriptでAWSリソースの管理・自動化が可能です。


## Terraformによる構築について
Terraformを使ってAWSの通知システムを構築する手順です。

### Terraformのセットアップ手順
1. Terraformのインストール
	- [公式インストールガイド](https://developer.hashicorp.com/terraform/install) を参照してください。
2. S3バケットの準備
	- tfstate管理用のS3バケットを作成してください。
3. Slackまたはメールアドレスの準備
	- 通知先となるSlackワークスペース・チャンネル、またはメールアドレスを用意してください。
4. リポジトリのクローン
	```bash
	git clone https://github.com/yuichifurukawa/aws-notificantion-example.git
	cd aws-notificantion-example
	```
5. バケットの設定
	- `terraform/terraform.tf` の該当箇所にS3バケット名を設定してください。
6. Slack及びメールアドレスの設定
	- `terraform/notifications.tf` の該当箇所にSlackやメールアドレスを設定してください。
7. 初期化
	```bash
	cd terraform
	terraform init
	```
8. 差分の確認
	```bash
	terraform plan
	```
9. デプロイ
	```bash
	terraform apply
	```
10. 削除（不要時）
	```bash
	terraform destroy
	```
