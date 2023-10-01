terraform {
 backend "s3" {
    bucket         	   = "angular-abi"
    key              	   = "state/terraform.tfstate"
    region         	   = "us-east-1"
    encrypt        	   = true
    #dynamodb_table = "angular-db"
  }
}
