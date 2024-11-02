k3s Hetzner Terraform
===========

How to build a kubernetes cluster in [Hetzner Cloud](https://www.hetzner.com/cloud). 

Hetzner is a good cloud provider in Europe, this project show us how build a kubernetes cluster in Hetzner Cloud, using [k3s](https://k3s.io/), [cloud-init](https://cloudinit.readthedocs.io/en/latest/) and [Terraform](https://www.terraform.io/).

## Requirements.

- A Hetzner Cloud account.

## Required Packages

- Terraform > 0.13.x
- Make

## Steps

1. Setup your Hetzner Cloud API Key. you must setup this in your Hetzner account following [this  indications](https://docs.hetzner.cloud/#getting-started)
   * copy `.tfvars.def` to `.tfvars` and replace `<your token here>` by the created Hetzner token
2. Create a ssh file on the `.ssh` folder of this repository with the following names:
   * `local_rsa.pub`: your public ssh key used to access the cluster

## Running Terraform
* `make plan`: run terraform plan with variables
* `make apply`: run terraform apply with variables
* `make copyKubeConfig`: copy k8s config from master node to local ~/.kube/hetzner-config
* `make destroy`: run terraform destroy with variables

## Copy cluster to config file
After installing kubectl, you need to copy the kubeconfig file from the master node to your local machine.
You can do this by running the following command on your local machine:

```
 scp -i ~/.ssh/id_rsa cluster@<master_node_public_ip>:/etc/rancher/k3s/k3s.yaml ~/.kube/hetzner-config.yaml && sed -i 's 127.0.0.1 <master_node_public_ip> g'  ~/.kube/hetzner-config.yaml
```

Make sure that the IP in ~/.kube/config is the public IP of the master node, not `127.0.0.1`.

If you have a $HOME/.kube/config file, and it's not already listed in your KUBECONFIG environment variable, append it to your KUBECONFIG environment variable now.

```bashs
export KUBECONFIG=${KUBECONFIG}:${HOME}/.kube/hetzner-config.yaml
```

## Check if everything is running
```
$ kubectl get nodes
NAME            STATUS   ROLES                  AGE     VERSION
master-node     Ready    control-plane,master   7m51s   v1.30.5+k3s1
worker-node-0   Ready    <none>                 7m16s   v1.30.5+k3s1
```
