resource "aws_instance" "terraform" {
    ami = "ami-0220d79f3f480ecf5"
    instance_type = lookup(var.instance_type, terraform.workspace)
    vpc_security_group_ids = ["sg-0b5241d2e8e23d98e"]

    tags = {
      Name = "terraform-${terraform.workspace}"

    }
}
