resource "aws_instance" "phantom" {
  ami                     = data.aws_ami.latest-phantom.id
  instance_type           = var.instance_type
  key_name                = var.key_name
  vpc_security_group_ids  = [aws_security_group.splunk_phantom.id]

  tags = {
    Name = "Phantom"
  }

  connection {
    host = self.public_ip
    type = "ssh"
    user = "ubuntu"
    private_key = file(var.private_key_path)
    agent = "true"
  }
}

# output "Phantom_Instances" {
#   value =  formatlist(
#     "%s: %s", 
#     aws_instance.phantom.tags.Name,
#     aws_instance.phantom.public_ip,
#   )
# }

output "Phantom_Instance_Deployed" {
  value =  "Allow 15 mins for Phantom to install, then go to the following URL and login with listed credentials"
}

output "Phantom_UI" {
  value =  "https://${aws_instance.phantom.public_ip}"
}

output "Phantom_UI_Username" {
  value =  "admin"
}

output "Phantom_UI_Password" {
  value =  aws_instance.phantom.id
}