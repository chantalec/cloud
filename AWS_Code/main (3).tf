provider "aws" {
  region     = "us-east-1"
  access_key = "HIDDEN"
  secret_key = "HIDDEN"
}

data "aws_ssm_parameter" "this" {
  name = "/aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

resource "aws_instance" "my-firstSever" {
  ami = data.aws_ssm_parameter.this.value
  instance_type = "t2.micro"
  tags = {
    Name = "myec2"
  }
}
