
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}

resource "yandex_compute_instance" "vm" {
  for_each             = { for vm in var.each_vm: index(var.each_vm,vm)=> vm }
  name                 = each.value.name
  platform_id          = var.platform_id

resources {
    cores              = each.value.cpu
    memory             = each.value.ram
    core_fraction      = each.value.core_fraction
  }

scheduling_policy {
    preemptible        = each.value.preemptible
  }

network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = true
  }

  boot_disk {
    initialize_params {
      image_id         = var.image_id
      size             = each.value.disk
    }
  }
   metadata = {
    user-data = "${file("./meta.yml")}"
  }
}

resource "local_file" "hosts_cfg" {
  filename = "./inventory/hosts.cfg"
  content = templatefile("./inventory/hosts.tftpl", { webservers = yandex_compute_instance.vm })
}
