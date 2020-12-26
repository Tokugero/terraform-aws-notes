resource "aws_instance" "web" {
  ami           = "ami-0a36eb8fadc976275"
  instance_type = "t3.micro"

  tags = {
    Name        = "HelloWorld"
  }
}