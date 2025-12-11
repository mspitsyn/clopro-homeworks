## main.tf

// Создание сети
resource "yandex_vpc_network" "network" {
  name = var.vpc_network_name
}

// Создание подсети
resource "yandex_vpc_subnet" "public" {
  name           = var.public_subnet
  zone           = var.default_zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = var.public_cidr
}

