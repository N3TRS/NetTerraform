variable "project_name" {
  type    = string
  default = "omnicode"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "sku_name" {
  type    = string
  default = "B1"
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "apps_config" {
  type = map(object({
    type         = string
    version      = string
    docker_image = optional(string)
  }))

}
