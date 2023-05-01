
# k8s-cluster

Use this project to create a 3-node Kubernetes cluster using local VirtualBox
virtual machines and Ansible.

Using the project and the automation it contains, a user should be able to:

1. Create three Ubuntu 22.04 (Jammy) virtual machines
1. Install `kubeadmin` on the host
1. Install Docker on each virtual machine
1. Configure one virtual machine as the master
1. Configure the remaining two virtual machines as worker nodes

A Vagrantfile is provided to automate creating the virtual machines with
Vagrant, and an Ansible playbook is provided to do everything else.

## Requirements

- VirtualBox
- Vagrant
- Ansible (Windows users, use a WSL2 instance with Ansible installed)

## Usage

#### MacOS/Linux

1. Open a terminal and clone the project
1. CD into the project directory
1. Issue a `vagrant up` to create the virtual machines
1. Run the playbook, e.g. `ansible-playbook k8s_install.yml`

#### Windows
1. Clone this project to the Desktop

1. Open a PowerShell and CD to the project directory, e.g.:

```txt
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

PS C:\Users\V01dDweller> cd .\Desktop\k8s-cluster\
PS C:\Users\V01dDweller\Desktop\k8s-cluster>
```

1. Issue the `vagrant up` command to create three virtual machines

1. Switch to a WSL2 instance and clone the project (yes, clone it again)

1. CD to the project directory

1. Run the `./vagrant_update.sh` script to copy the `.vagrant` directory
created in step 2. The `.vagrant` directory contains ssh keys for each virtual
machine. Ansible defaults to ssh connections and will use these keys.

1. Finally, run the playbook

```sh
ansible-playbook k8s_install.yml
```

[modeline]: # ( vi: set number textwidth=78 colorcolumn=80 nowrap: )
