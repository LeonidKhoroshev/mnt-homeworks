
###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

###vm vars

variable "platform_id" {
  type        = string
  default     = "standard-v3"
}

variable "image_id" {
  type        = string
  default     = "fd8gvgtf1t3sbtt4opo6"
}

variable "security_group_example" {
  type        = string
  default     = "enpst7elmqdtqj1j5e16"
}

variable "each_vm" {
  type = list(object({  name=string, cpu=number, ram=number, disk=number,preemptible=bool,core_fraction=number }))
  default = [{
    name="clickhouse"
    cpu=2
    ram=4
    disk=10
    preemptible=true
    core_fraction=20
    },
    {
    name="vector"
    cpu=2
    ram=4
    disk=10
    preemptible=true
    core_fraction=20
    },
    {
    name="lighthouse"
    cpu=2
    ram=4
    disk=10
    preemptible=true
    core_fraction=20
    }]
  }

#inventory vars

variable "public_key" {
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCgT8Ny1LD7hTjTan3NOKzgpZ9FEJC7+G7Zfm+bs+9bXZhQ/B6gwjJh0VI6RsVo2wZKsosIc2DZogA+NlWbefQfiC5RKtt/iZMEofBHkhCgxUEHdUEqUkaC7AFfkr4ozrYPKlQOCBbc6S4xJewUmNliXJLrHuv6RZ5TKoIgiKRwaOVT7JqUAnLWyw43+FSpzHUfefLVzaIOVIQV4SEEyl3d/2Cl5gJ/R7sulPomaRwejPi8LG+VZaoF9Wh2JlpCEU7Vm1WKhZ2jd//LlGKoVnqMWlNtSdXVw5B6XZEpCIQfES9DNrlWDyEACFSeSkus30f1Qpe1ZqyIqSnqVgpcANVz root@localhost.localdomain"
}
