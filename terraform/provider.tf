provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      System      = "SystemName"
      Environemnt = "dev"
    }
  }
}

# 大阪リージョンを利用する場合
provider "aws" {
  region = "ap-northeast-3"
  alias  = "ap-northeast-3"
  default_tags {
    tags = {
      System      = "SystemName"
      Environemnt = "dev"
    }
  }
}

# US East (N. Virginia) リージョンを利用する場合
provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
  default_tags {
    tags = {
      System      = "SystemName"
      Environemnt = "dev"
    }
  }
}

# AWS Cloud Control API プロバイダーを利用する場合
provider "awscc" {
  region = "ap-northeast-1"
}

