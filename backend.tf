terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.18.0"
    }
  }
backend "s3" {
    bucket         	   = "mycomponents-tfstate"
    key              	   = "state/terraform.tfstate"
    region         	   = "eu-central-1"
    encrypt        	   = true
    dynamodb_table = "mycomponents_tf_lockid"
  }
}
