terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = "${var.YC_TOKEN}"
  cloud_id  = "${var.YC_CLOUD_ID}"
  folder_id = "${var.YC_FOLDER_ID}"
  zone      = "ru-central1-a"
}

resource "yandex_vpc_network" "default" {
  name = "net"
}

resource "yandex_vpc_subnet" "default" {
  name = "subnet"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.default.id}"
  v4_cidr_blocks = ["192.168.101.0/24"]
}

resource "yandex_compute_instance" "vm" {
  name = "vm-from-custom-image"

  resources {
    cores  = 2
    memory = 2
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.default.id}"
  }

  boot_disk {
    initialize_params {
      image_id = "fd8mn5e1cksb3s1pcq12"
    }
  }
}
