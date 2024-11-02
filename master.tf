### Server creation with one linked primary ip (ipv4)
resource "hcloud_primary_ip" "master_node_public_ip" {
  name          = "primary_ip_test"
  datacenter    = "fsn1-dc14"
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = true
}

data "template_file" "master-node-config" {
  template  = file("${path.module}/cloud-init.yaml")
  vars      = {
    local_ssh_public_key = file("${path.module}/.ssh/local_rsa.pub")
    worker_ssh_public_key = tls_private_key.worker-ssh-key.public_key_openssh
    hcloud_token = var.hcloud_token
    hcloud_network = hcloud_network.private_network.id
    public_ip = tostring(hcloud_primary_ip.master_node_public_ip.ip_address)
  }
}

resource "hcloud_server" "master-node" {
  name        = "master-node"
  image       = "ubuntu-24.04"
  server_type = "cx22"
  location    = "fsn1"
  public_net {
    ipv4 = hcloud_primary_ip.master_node_public_ip.id
    ipv4_enabled = true
    ipv6_enabled = true
  }
  network {
    network_id = hcloud_network.private_network.id
    # IP Used by the master node, needs to be static
    # Here the worker nodes will use 10.0.1.1 to communicate with the master node
    ip         = "10.0.1.1"
  }

  # If we don't specify this, Terraform will create the resources in parallel
  # We want this node to be created after the private network is created
  depends_on = [hcloud_network_subnet.private_network_subnet]
}

output "master_node_public_ip" {
  value = tostring(hcloud_primary_ip.master_node_public_ip.ip_address)
}
