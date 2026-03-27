provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "private-terraform-bucket" {
  bucket = "nicojarpa-private-terraform-bucket"

  tags = {
    Name = "Terraform"
  }
  lifecycle {
    prevent_destroy = false
    }
}

resource "aws_dynamodb_table" "dynamodb-table" {
    name = "terraform-state-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
      name = "LockID"
      type = "S"
    }
}