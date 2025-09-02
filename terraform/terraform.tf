terraform {

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    awscc = {
      source = "hashicorp/awscc"
    }
  }

  # TODO: S3バケットとkeyは適宜変更してください
  backend "s3" {
    bucket = "your-tfstate-bucket-name"
    key     = "your-project/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}
