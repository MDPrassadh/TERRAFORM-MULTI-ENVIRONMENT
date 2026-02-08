variable "instances" {
  type = map
}

variable "zone_id" {
  default = "Z03935303DMMJM97SI3N5"
}

variable "domain_name" {
  default = "jioairlines.online"
}



variable "common_tags" {
  default = {
    project   = "expense"
    terraform = "true"
  }
}

variable "tags" {
  type = map(any)

}
variable "environment" {
  
}