terraform {
  required_version = ">1.3.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }
  }
  backend "s3" {
    bucket = "81s-locking-s3"
    key = "workspaces-s3-lock"
    region = "us-east-1"
    #use_lockfile = true
    dynamodb_table = "tf.statelock"
    
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}
