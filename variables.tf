### AWS Variables  ###

variable "key_name" {
  default = []
}

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
