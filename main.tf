### AWS Auth Configuration ###
provider "aws" {
  profile    = var.profile
  region     = lookup(var.aws_region, var.region)
}
