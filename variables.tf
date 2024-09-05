variable "tools" {
  default = {
    ci = {
      instance_type        = "t3.small"
      policy_resource_list = ["ec2:DescribeInstances"]
    }
  }
}

variable "zone_id" {
  default = "Z04907431HM3OFWU2B8S0"
}
