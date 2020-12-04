### AWS Variables  ###

variable "private_key_path"{
  default = []
}

variable "profile" {
  default = []
}

variable "region" {
  description = "Select region (1:eu-west-1, 2:eu-west-3, 3:eu-central-1, 4:us-east-1, 5:us-east-2, 6:us-west-1, 7:us-west-2, 8:ap-southeast-1, 9:ap-southeast-2, 10:sa-east-1 )"
}

variable "function_timeout" {
  default = 15
}

variable "aws_region" {
  description = "Provide the desired region"
    default = {
      "1" = "eu-west-1"
      "2" = "eu-west-3"
      "3" = "eu-central-1"
      "4" = "us-east-1"
      "5" = "us-east-2"
      "6" = "us-west-1"
      "7" = "us-west-2"
      "8" = "ap-southeast-1"
      "9" = "ap-southeast-2"
      "10" = "sa-east-1"
    }
}


## AMI ##
data "aws_ami" "latest-phantom" {
  most_recent = true
  owners      = ["679593333241"] # This is the owner id of Splunk

  filter {
    name   = "name"
    values = ["Splunk Phantom 4.8 Patch 1-80ad187b-5f54-4327-9047-fb6fb36e7019-ami-03944dae408c1a3d6.4"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

variable "instance_type" {
  default = []
}

variable "key_name" {
  default = []
}

### VO_Phantom Variables ###

variable "victoropsurl" {
    default = {}
}

variable "voapiid" {
    default = {}
}

variable "voapikey" {
    default = {}
}

variable "phantomdeeplinkurl" {
    default = {}
}

variable "phantombaseurl" {
    default = {}
}

variable "lambda_function_url" {
    default = "https://raw.githubusercontent.com/geoffhigginbottom/vo-phantom-functions/main/lambda_function.py"
}

variable "phantom_url" {
    default = "https://raw.githubusercontent.com/geoffhigginbottom/vo-phantom-functions/main/phantom.py"
}

variable "victorops_url" {
    default = "https://raw.githubusercontent.com/geoffhigginbottom/vo-phantom-functions/main/victorops.py"
}
