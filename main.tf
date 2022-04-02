provider "aws" {
  access_key = "AKIA4W3WWPHNYFNREBEK"
  secret_key = "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"
  region     = "us-east-2"
}

resource "aws_instance" "etechapp" {
  ami           = "ami-0b9ecb12083282d75"
  instance_type = "t2.micro"
  tag = {
  Name = "etechdevops2"
  }
}
