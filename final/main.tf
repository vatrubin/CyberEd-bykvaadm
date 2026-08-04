terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
  required_version = ">= 0.13"
}

variable "yandex_zone" {
  default = "ru-central1-a"
}

variable "image_id" {
  default = "fd850143bafeg93veh8l"
}

provider "yandex" {
  zone = var.yandex_zone
}

locals {
  servers = {
    nginx = {
      cores  = 2
      memory = 1
    }
    app-1 = {
      cores  = 2
      memory = 1
    }
    app-2 = {
      cores  = 2
      memory = 1
    }
    redis = {
      cores  = 2
      memory = 1
    }
    postgres = {
      cores  = 2
      memory = 2
    }
  }
}

resource "yandex_compute_disk" "boot-disk" {
  for_each = local.servers

  name     = "${each.key}-boot-disk"
  type     = "network-hdd"
  zone     = var.yandex_zone
  size     = "15"
  image_id = var.image_id
}

resource "yandex_compute_instance" "vm" {
  for_each = local.servers

  name = each.key

  resources {
    cores         = each.value.cores
    memory        = each.value.memory
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk[each.key].id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data = file("../meta.txt")
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = var.yandex_zone
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_addresses" {
  value = {
    for name, vm in yandex_compute_instance.vm : name => vm.network_interface.0.ip_address
  }
}

output "external_ip_addresses" {
  value = {
    for name, vm in yandex_compute_instance.vm : name => vm.network_interface.0.nat_ip_address
  }
}

resource "local_file" "hosts" {
  content = templatefile("${path.module}/hosts.tftpl", {
    nginx_ip            = yandex_compute_instance.vm["nginx"].network_interface.0.nat_ip_address
    nginx_private_ip    = yandex_compute_instance.vm["nginx"].network_interface.0.ip_address
    app_1_ip            = yandex_compute_instance.vm["app-1"].network_interface.0.nat_ip_address
    app_1_private_ip    = yandex_compute_instance.vm["app-1"].network_interface.0.ip_address
    app_2_ip            = yandex_compute_instance.vm["app-2"].network_interface.0.nat_ip_address
    app_2_private_ip    = yandex_compute_instance.vm["app-2"].network_interface.0.ip_address
    redis_ip            = yandex_compute_instance.vm["redis"].network_interface.0.nat_ip_address
    redis_private_ip    = yandex_compute_instance.vm["redis"].network_interface.0.ip_address
    postgres_ip         = yandex_compute_instance.vm["postgres"].network_interface.0.nat_ip_address
    postgres_private_ip = yandex_compute_instance.vm["postgres"].network_interface.0.ip_address
  })
  filename = "ansible/hosts"
}
