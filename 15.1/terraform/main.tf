# main.tf

resource "yandex_vpc_network" "network" {
  name = var.vpc_network_name
}
