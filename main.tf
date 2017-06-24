resource "openstack_compute_keypair_v2" "terraform" {
  name       = "terraform"
  public_key = "${file("${var.ssh_key_file}.pub")}"
}

resource "openstack_networking_network_v2" "terraform" {
  name           = "terraform"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "terraform" {
  name            = "terraform"
  network_id      = "${openstack_networking_network_v2.terraform.id}"
  cidr            = "10.0.0.0/24"
  ip_version      = 4
  dns_nameservers = ["114.114.114.114"]
}

resource "openstack_networking_network_v2" "br-mgmt" {
  name           = "br-mgmt"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "br-mgmt-sub" {
  name            = "172.29.236.0"
  network_id      = "${openstack_networking_network_v2.br-mgmt.id}"
  cidr            = "172.29.236.0/22"
  ip_version      = 4
  dns_nameservers = ["114.114.114.114"]
  enable_dhcp = "false"
}
resource "openstack_networking_port_v2" "port_1" {
  name           = "port_1"
  network_id     = "${openstack_networking_network_v2.br-mgmt.id}"
  admin_state_up = "true"
  security_group_ids = []
  fixed_ip { 
  ip_address = "172.29.236.100"
  subnet_id = "${openstack_networking_subnet_v2.br-mgmt-sub.id}"

}
  value_specs {
  port_security_enabled = "false"
}
}

resource "openstack_networking_router_v2" "terraform" {
  name             = "terraform"
  admin_state_up   = "true"
  external_gateway = "${var.external_gateway}"
}

resource "openstack_networking_router_interface_v2" "terraform" {
  router_id = "${openstack_networking_router_v2.terraform.id}"
  subnet_id = "${openstack_networking_subnet_v2.terraform.id}"
}

resource "openstack_compute_secgroup_v2" "terraform" {
  name        = "terraform"
  description = "Security group for the Terraform example instances"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_networking_floatingip_v2" "terraform" {
  pool       = "${var.pool}"
  depends_on = ["openstack_networking_router_interface_v2.terraform"]
}

resource "openstack_compute_instance_v2" "instance_1" {
  name            = "swift"
  image_name      = "${var.image}"
  flavor_name     = "${var.flavor}"
  key_pair        = "${openstack_compute_keypair_v2.terraform.name}"
  security_groups = ["${openstack_compute_secgroup_v2.terraform.name}"]

  network {
    uuid = "${openstack_networking_network_v2.terraform.id}"
  }

  network {
    port = "${openstack_networking_port_v2.port_1.id}"
  }


  user_data = "${file( "cloud-init.yaml")}"


}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = "${openstack_networking_floatingip_v2.terraform.address}"
  instance_id = "${openstack_compute_instance_v2.instance_1.id}"
  fixed_ip    = "${openstack_compute_instance_v2.instance_1.network.0.fixed_ip_v4}"

}


resource "openstack_blockstorage_volume_v2" "volume_1" {
  region      = "RegionOne"
  name        = "swift_volume_1"
  description = "swift volume 1" 
  size        = 20
  volume_type = "RBD"
}
resource "openstack_blockstorage_volume_v2" "volume_2" {
  region      = "RegionOne"
  name        = "swift_volume_2"
  description = "swift volume 2" 
  size        = 20
  volume_type = "RBD"
}
resource "openstack_blockstorage_volume_v2" "volume_3" {
  region      = "RegionOne"
  name        = "swift_volume_3"
  description = "swift volume 3" 
  size        = 20
  volume_type = "RBD"
}
resource "openstack_compute_volume_attach_v2" "va_1" {
  instance_id = "${openstack_compute_instance_v2.instance_1.id}"
  volume_id   = "${openstack_blockstorage_volume_v2.volume_1.id}"
}
resource "openstack_compute_volume_attach_v2" "va_2" {
  instance_id = "${openstack_compute_instance_v2.instance_1.id}"
  volume_id   = "${openstack_blockstorage_volume_v2.volume_2.id}"
}
resource "openstack_compute_volume_attach_v2" "va_3" {
  instance_id = "${openstack_compute_instance_v2.instance_1.id}"
  volume_id   = "${openstack_blockstorage_volume_v2.volume_3.id}"
}

