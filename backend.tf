backend "s3" {
    bucket         	   = "mycomponents-tfstate"
    key              	   = "state/terraform.tfstate"
    region         	   = "eu-central-1"
    encrypt        	   = true
    dynamodb_table = "mycomponents_tf_lockid"
  }
}
