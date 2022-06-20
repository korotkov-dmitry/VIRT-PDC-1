terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "netology-storage"
    region     = "ru-central1"
    key        = "terraform.tfstate"
    access_key = "..."
    secret_key = "..."

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  token     = "${var.YC_TOKEN}"
  cloud_id  = "${var.YC_CLOUD_ID}"
  folder_id = "${var.YC_FOLDER_ID}"
  zone      = "ru-central1-a"
}

resource "yandex_vpc_network" "default" {
  name = "net-${terraform.workspace}"

}

resource "yandex_vpc_subnet" "default" {
  name = "subnet-${terraform.workspace}"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.default.id}"
  v4_cidr_blocks = ["192.168.101.0/24"]
}

module "news" {
  source = "./instance"
  instance_count = local.news_instance_count[terraform.workspace]

  subnet_id     = "${yandex_vpc_subnet.default.id}"
  folder_id     = "${var.YC_FOLDER_ID}"
  image         = "centos-7"
  name          = "new"
  users         = "centos"
  cores         = local.news_cores[terraform.workspace]
  nat           = "true"
  memory        = "2"
  }

locals {
  news_cores = {
    stage = 2
    prod = 2
  }
  news_instance_count = {
    stage = 1
    prod = 2
  }
}
