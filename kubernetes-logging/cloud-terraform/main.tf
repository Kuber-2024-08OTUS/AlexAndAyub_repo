variable "terraform_token"{
  type = string
}

variable "terraform_cloud_id"{
  type = string
}

variable "terraform_folder_id"{
  type = string
}


terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.74.0"
}

provider "yandex" {
  token     = var.terraform_token
  cloud_id  = var.terraform_cloud_id
  folder_id = var.terraform_folder_id
}

