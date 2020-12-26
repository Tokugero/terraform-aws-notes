# Pull the latest Amazon Linx 2 AMI ID
data "aws_ami" "AL2" {
  most_recent   = true
  owners        = [ "823765613917" ]
  filter {
      name = "name"
      values = [ "Amazon Linux 2*" ]
  }
}

# Pull the "default" VPC 
data "aws_vpc" "default" {
    filter {
        name    = "tag:Name"
        values  = ["default"]
    }
}

# Get all subnets out of the "default" VPC
data "aws_subnet_ids" "default" {
    vpc_id      = data.aws_vpc.default.id
}
