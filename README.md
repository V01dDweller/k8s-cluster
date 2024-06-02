
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

Based on [Kubernetes Official Documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

### Issues

* 2024-05-19: The cluster no longer works due to breaking changes in
  Kubernetes 1.30.1. The cluster was created using Kubernetes 1.22.0.

* Flannel and proxy pods keep restarting:

```
vagrant@k8s-master:~$ kubectl get pods -A
NAMESPACE      NAME                                 READY   STATUS             RESTARTS        AGE
kube-flannel   kube-flannel-ds-4qvh6                1/1     Running            0               18m
kube-flannel   kube-flannel-ds-6v6hc                0/1     CrashLoopBackOff   6 (116s ago)    18m
kube-flannel   kube-flannel-ds-p6dgm                1/1     Running            6 (5m56s ago)   18m
kube-system    coredns-5d78c9869d-g6cgv             1/1     Running            0               18m
kube-system    coredns-5d78c9869d-kxmcp             1/1     Running            0               18m
kube-system    etcd-k8s-master                      1/1     Running            0               19m
kube-system    kube-apiserver-k8s-master            1/1     Running            0               19m
kube-system    kube-controller-manager-k8s-master   1/1     Running            0               19m
kube-system    kube-proxy-86gj4                     0/1     CrashLoopBackOff   6 (37s ago)     18m
kube-system    kube-proxy-bhv7f                     0/1     CrashLoopBackOff   7 (115s ago)    18m
kube-system    kube-proxy-d8np8                     1/1     Running            0               18m
kube-system    kube-scheduler-k8s-master            1/1     Running            0               19m
```
* Docker service fails to start

```
vagrant@k8s-master:/var/log$ sudo systemctl status docker
× docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: failed (Result: exit-code) since Mon 2023-05-29 14:40:50 EDT; 16min ago
TriggeredBy: × docker.socket
       Docs: https://docs.docker.com
    Process: 8273 ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock (code=exited, status=1/FAILURE)
   Main PID: 8273 (code=exited, status=1/FAILURE)
        CPU: 87ms

May 29 14:40:48 k8s-master systemd[1]: docker.service: Main process exited, code=exited, status=1/FAILURE
May 29 14:40:48 k8s-master systemd[1]: docker.service: Failed with result 'exit-code'.
May 29 14:40:48 k8s-master systemd[1]: Failed to start Docker Application Container Engine.
May 29 14:40:50 k8s-master systemd[1]: docker.service: Scheduled restart job, restart counter is at 3.
May 29 14:40:50 k8s-master systemd[1]: Stopped Docker Application Container Engine.
May 29 14:40:50 k8s-master systemd[1]: docker.service: Start request repeated too quickly.
May 29 14:40:50 k8s-master systemd[1]: docker.service: Failed with result 'exit-code'.
May 29 14:40:50 k8s-master systemd[1]: Failed to start Docker Application Container Engine.
```

### Files

```txt
├── README.md               # You are here
├── Vagrantfile
├── ansible.cfg
├── bootstrap.sh
├── hosts
│   ├── hosts.j2
│   └── vagrant
│       ├── group_vars
│       │   └── all.yml
│       └── hosts
├── hosts_render.yml
├── k8s_install.yml
├── roles
│   ├── containerd_install
│   │   ├── README.md
│   │   ├── handlers
│   │   │   └── main.yml
│   │   ├── meta
│   │   │   └── main.yml
│   │   └── tasks
│   │       └── main.yml
│   ├── docker_install
│   │   ├── files
│   │   │   └── daemon.json
│   │   ├── handlers
│   │   │   └── main.yml
│   │   ├── meta
│   │   └── tasks
│   │       ├── main.yml
│   │       └── ubuntu22.yml
│   ├── hosts_update
│   │   ├── meta
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── templates
│   │       └── hosts.j2
│   └── ipv6_disable
│       ├── files
│       │   └── grub
│       ├── handlers
│       │   └── main.yml
│       ├── meta
│       │   └── main.yml
│       └── tasks
│           ├── main.yml
│           └── ubuntu22.yml
├── test_hosts
└── vagrant_update.sh
```

### References

* [How to Install Kubernetes Cluster on Ubuntu 22.04](https://www.linuxtechi.com/install-kubernetes-on-ubuntu-22-04/)
* [How to Install Kubernetes on Ubuntu 20.04](https://phoenixnap.com/kb/install-kubernetes-on-ubuntu)

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
created by step 1. The `.vagrant` directory contains ssh keys for each virtual
machine. Ansible defaults to ssh connections and will use these keys.

1. Finally, run the playbook

```sh
ansible-playbook k8s_install.yml
```

<details>
<summary>Sample output: Vagrant</summary>

```txt
PS C:\Users\V01dDweller\Desktop\k8s-project> vagrant up
Bringing machine 'k8s-master' up with 'virtualbox' provider...
Bringing machine 'k8s-node-1' up with 'virtualbox' provider...
Bringing machine 'k8s-node-2' up with 'virtualbox' provider...
==> k8s-master: Importing base box 'ubuntu/jammy64'...
==> k8s-master: Matching MAC address for NAT networking...
==> k8s-master: Checking if box 'ubuntu/jammy64' version '20230110.0.0' is up to date...
==> k8s-master: A newer version of the box 'ubuntu/jammy64' for provider 'virtualbox' is
==> k8s-master: available! You currently have version '20230110.0.0'. The latest is version
==> k8s-master: '20230428.0.0'. Run `vagrant box update` to update.
==> k8s-master: Setting the name of the VM: k8s-project_k8s-master_1682883735965_32537
==> k8s-master: Clearing any previously set network interfaces...
==> k8s-master: Preparing network interfaces based on configuration...
    k8s-master: Adapter 1: nat
    k8s-master: Adapter 2: hostonly
==> k8s-master: Forwarding ports...
    k8s-master: 22 (guest) => 2222 (host) (adapter 1)
==> k8s-master: Running 'pre-boot' VM customizations...
==> k8s-master: Booting VM...
==> k8s-master: Waiting for machine to boot. This may take a few minutes...
    k8s-master: SSH address: 127.0.0.1:2222
    k8s-master: SSH username: vagrant
    k8s-master: SSH auth method: private key
    k8s-master: Warning: Connection reset. Retrying...
    k8s-master:
    k8s-master: Vagrant insecure key detected. Vagrant will automatically replace
    k8s-master: this with a newly generated keypair for better security.
    k8s-master:
    k8s-master: Inserting generated public key within guest...
==> k8s-master: Machine booted and ready!
==> k8s-master: Checking for guest additions in VM...
    k8s-master: The guest additions on this VM do not match the installed version of
    k8s-master: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-master: prevent things such as shared folders from working properly. If you see
    k8s-master: shared folder errors, please make sure the guest additions within the
    k8s-master: virtual machine match the version of VirtualBox you have installed on
    k8s-master: your host and reload your VM.
    k8s-master:
    k8s-master: Guest Additions Version: 6.0.0 r127566
    k8s-master: VirtualBox Version: 7.0
==> k8s-master: Setting hostname...
==> k8s-master: Configuring and enabling network interfaces...
==> k8s-master: Mounting shared folders...
    k8s-master: /vagrant => C:/Users/V01dDweller/Desktop/k8s-project
==> k8s-node-1: Importing base box 'ubuntu/jammy64'...
==> k8s-node-1: Matching MAC address for NAT networking...
==> k8s-node-1: Checking if box 'ubuntu/jammy64' version '20230110.0.0' is up to date...
==> k8s-node-1: Setting the name of the VM: k8s-project_k8s-node-1_1682883786257_94054
==> k8s-node-1: Fixed port collision for 22 => 2222. Now on port 2200.
==> k8s-node-1: Clearing any previously set network interfaces...
==> k8s-node-1: Preparing network interfaces based on configuration...
    k8s-node-1: Adapter 1: nat
    k8s-node-1: Adapter 2: hostonly
==> k8s-node-1: Forwarding ports...
    k8s-node-1: 22 (guest) => 2200 (host) (adapter 1)
==> k8s-node-1: Running 'pre-boot' VM customizations...
==> k8s-node-1: Booting VM...
==> k8s-node-1: Waiting for machine to boot. This may take a few minutes...
    k8s-node-1: SSH address: 127.0.0.1:2200
    k8s-node-1: SSH username: vagrant
    k8s-node-1: SSH auth method: private key
    k8s-node-1: Warning: Connection aborted. Retrying...
    k8s-node-1: Warning: Connection reset. Retrying...
    k8s-node-1:
    k8s-node-1: Vagrant insecure key detected. Vagrant will automatically replace
    k8s-node-1: this with a newly generated keypair for better security.
    k8s-node-1:
    k8s-node-1: Inserting generated public key within guest...
==> k8s-node-1: Machine booted and ready!
==> k8s-node-1: Checking for guest additions in VM...
    k8s-node-1: The guest additions on this VM do not match the installed version of
    k8s-node-1: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-node-1: prevent things such as shared folders from working properly. If you see
    k8s-node-1: shared folder errors, please make sure the guest additions within the
    k8s-node-1: virtual machine match the version of VirtualBox you have installed on
    k8s-node-1: your host and reload your VM.
    k8s-node-1:
    k8s-node-1: Guest Additions Version: 6.0.0 r127566
    k8s-node-1: VirtualBox Version: 7.0
==> k8s-node-1: Setting hostname...
==> k8s-node-1: Configuring and enabling network interfaces...
==> k8s-node-1: Mounting shared folders...
    k8s-node-1: /vagrant => C:/Users/V01dDweller/Desktop/k8s-project
==> k8s-node-2: Importing base box 'ubuntu/jammy64'...
==> k8s-node-2: Matching MAC address for NAT networking...
==> k8s-node-2: Checking if box 'ubuntu/jammy64' version '20230110.0.0' is up to date...
==> k8s-node-2: Setting the name of the VM: k8s-project_k8s-node-2_1682883833830_2328
==> k8s-node-2: Fixed port collision for 22 => 2222. Now on port 2201.
==> k8s-node-2: Clearing any previously set network interfaces...
==> k8s-node-2: Preparing network interfaces based on configuration...
    k8s-node-2: Adapter 1: nat
    k8s-node-2: Adapter 2: hostonly
==> k8s-node-2: Forwarding ports...
    k8s-node-2: 22 (guest) => 2201 (host) (adapter 1)
==> k8s-node-2: Running 'pre-boot' VM customizations...
==> k8s-node-2: Booting VM...
==> k8s-node-2: Waiting for machine to boot. This may take a few minutes...
    k8s-node-2: SSH address: 127.0.0.1:2201
    k8s-node-2: SSH username: vagrant
    k8s-node-2: SSH auth method: private key
    k8s-node-2:
    k8s-node-2: Vagrant insecure key detected. Vagrant will automatically replace
    k8s-node-2: this with a newly generated keypair for better security.
    k8s-node-2:
    k8s-node-2: Inserting generated public key within guest...
==> k8s-node-2: Machine booted and ready!
==> k8s-node-2: Checking for guest additions in VM...
    k8s-node-2: The guest additions on this VM do not match the installed version of
    k8s-node-2: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-node-2: prevent things such as shared folders from working properly. If you see
    k8s-node-2: shared folder errors, please make sure the guest additions within the
    k8s-node-2: virtual machine match the version of VirtualBox you have installed on
    k8s-node-2: your host and reload your VM.
    k8s-node-2:
    k8s-node-2: Guest Additions Version: 6.0.0 r127566
    k8s-node-2: VirtualBox Version: 7.0
==> k8s-node-2: Setting hostname...
==> k8s-node-2: Configuring and enabling network interfaces...
==> k8s-node-2: Mounting shared folders...
    k8s-node-2: /vagrant => C:/Users/V01dDweller/Desktop/k8s-project
PS C:\Users\V01dDweller\Desktop\k8s-project> vagrant box update
==> k8s-node-2: Checking for updates to 'ubuntu/jammy64'
    k8s-node-2: Latest installed version: 20230110.0.0
    k8s-node-2: Version constraints:
    k8s-node-2: Provider: virtualbox
==> k8s-node-2: Updating 'ubuntu/jammy64' with provider 'virtualbox' from version
==> k8s-node-2: '20230110.0.0' to '20230428.0.0'...
==> k8s-node-2: Loading metadata for box 'https://vagrantcloud.com/ubuntu/jammy64'
==> k8s-node-2: Adding box 'ubuntu/jammy64' (v20230428.0.0) for provider: virtualbox
    k8s-node-2: Downloading: https://vagrantcloud.com/ubuntu/boxes/jammy64/versions/20230428.0.0/providers/virtualbox.box
Download redirected to host: cloud-images.ubuntu.com
    k8s-node-2:
==> k8s-node-2: Successfully added box 'ubuntu/jammy64' (v20230428.0.0) for 'virtualbox'!
PS C:\Users\V01dDweller\Desktop\k8s-project> vagrant destroy --force
==> k8s-node-2: Forcing shutdown of VM...
==> k8s-node-2: Destroying VM and associated drives...
==> k8s-node-1: Forcing shutdown of VM...
==> k8s-node-1: Destroying VM and associated drives...
==> k8s-master: Forcing shutdown of VM...
==> k8s-master: Destroying VM and associated drives...
PS C:\Users\V01dDweller\Desktop\k8s-project> vagrant up
Bringing machine 'k8s-master' up with 'virtualbox' provider...
Bringing machine 'k8s-node-1' up with 'virtualbox' provider...
Bringing machine 'k8s-node-2' up with 'virtualbox' provider...
==> k8s-master: Importing base box 'ubuntu/jammy64'...
==> k8s-master: Matching MAC address for NAT networking...
==> k8s-master: Checking if box 'ubuntu/jammy64' version '20230428.0.0' is up to date...
==> k8s-master: Setting the name of the VM: k8s-project_k8s-master_1682886271647_79209
==> k8s-master: Clearing any previously set network interfaces...
==> k8s-master: Preparing network interfaces based on configuration...
    k8s-master: Adapter 1: nat
    k8s-master: Adapter 2: hostonly
==> k8s-master: Forwarding ports...
    k8s-master: 22 (guest) => 2222 (host) (adapter 1)
==> k8s-master: Running 'pre-boot' VM customizations...
==> k8s-master: Booting VM...
==> k8s-master: Waiting for machine to boot. This may take a few minutes...
    k8s-master: SSH address: 127.0.0.1:2222
    k8s-master: SSH username: vagrant
    k8s-master: SSH auth method: private key
    k8s-master: Warning: Connection aborted. Retrying...
    k8s-master: Warning: Connection reset. Retrying...
    k8s-master:
    k8s-master: Vagrant insecure key detected. Vagrant will automatically replace
    k8s-master: this with a newly generated keypair for better security.
    k8s-master:
    k8s-master: Inserting generated public key within guest...
==> k8s-master: Machine booted and ready!
==> k8s-master: Checking for guest additions in VM...
    k8s-master: The guest additions on this VM do not match the installed version of
    k8s-master: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-master: prevent things such as shared folders from working properly. If you see
    k8s-master: shared folder errors, please make sure the guest additions within the
    k8s-master: virtual machine match the version of VirtualBox you have installed on
    k8s-master: your host and reload your VM.
    k8s-master:
    k8s-master: Guest Additions Version: 6.0.0 r127566
    k8s-master: VirtualBox Version: 7.0
==> k8s-master: Setting hostname...
==> k8s-master: Configuring and enabling network interfaces...
==> k8s-master: Mounting shared folders...
    k8s-master: /vagrant => C:/Users/V01dDweller/Desktop/k8s-project
==> k8s-node-1: Importing base box 'ubuntu/jammy64'...
==> k8s-node-1: Matching MAC address for NAT networking...
==> k8s-node-1: Checking if box 'ubuntu/jammy64' version '20230428.0.0' is up to date...
==> k8s-node-1: Setting the name of the VM: k8s-project_k8s-node-1_1682886318808_8852
==> k8s-node-1: Fixed port collision for 22 => 2222. Now on port 2200.
==> k8s-node-1: Clearing any previously set network interfaces...
==> k8s-node-1: Preparing network interfaces based on configuration...
    k8s-node-1: Adapter 1: nat
    k8s-node-1: Adapter 2: hostonly
==> k8s-node-1: Forwarding ports...
    k8s-node-1: 22 (guest) => 2200 (host) (adapter 1)
==> k8s-node-1: Running 'pre-boot' VM customizations...
==> k8s-node-1: Booting VM...
==> k8s-node-1: Waiting for machine to boot. This may take a few minutes...
    k8s-node-1: SSH address: 127.0.0.1:2200
    k8s-node-1: SSH username: vagrant
    k8s-node-1: SSH auth method: private key
    k8s-node-1:
    k8s-node-1: Vagrant insecure key detected. Vagrant will automatically replace
    k8s-node-1: this with a newly generated keypair for better security.
    k8s-node-1:
    k8s-node-1: Inserting generated public key within guest...
==> k8s-node-1: Machine booted and ready!
==> k8s-node-1: Checking for guest additions in VM...
    k8s-node-1: The guest additions on this VM do not match the installed version of
    k8s-node-1: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-node-1: prevent things such as shared folders from working properly. If you see
    k8s-node-1: shared folder errors, please make sure the guest additions within the
    k8s-node-1: virtual machine match the version of VirtualBox you have installed on
    k8s-node-1: your host and reload your VM.
    k8s-node-1:
    k8s-node-1: Guest Additions Version: 6.0.0 r127566
    k8s-node-1: VirtualBox Version: 7.0
==> k8s-node-1: Setting hostname...
==> k8s-node-1: Configuring and enabling network interfaces...
==> k8s-node-1: Mounting shared folders...
    k8s-node-1: /vagrant => C:/Users/V01dDweller/Desktop/k8s-project
==> k8s-node-2: Importing base box 'ubuntu/jammy64'...
==> k8s-node-2: Matching MAC address for NAT networking...
==> k8s-node-2: Checking if box 'ubuntu/jammy64' version '20230428.0.0' is up to date...
==> k8s-node-2: Setting the name of the VM: k8s-project_k8s-node-2_1682886370597_42975
==> k8s-node-2: Fixed port collision for 22 => 2222. Now on port 2201.
==> k8s-node-2: Clearing any previously set network interfaces...
==> k8s-node-2: Preparing network interfaces based on configuration...
    k8s-node-2: Adapter 1: nat
    k8s-node-2: Adapter 2: hostonly
==> k8s-node-2: Forwarding ports...
    k8s-node-2: 22 (guest) => 2201 (host) (adapter 1)
==> k8s-node-2: Running 'pre-boot' VM customizations...
==> k8s-node-2: Booting VM...
==> k8s-node-2: Waiting for machine to boot. This may take a few minutes...
    k8s-node-2: SSH address: 127.0.0.1:2201
    k8s-node-2: SSH username: vagrant
    k8s-node-2: SSH auth method: private key
    k8s-node-2: Warning: Connection reset. Retrying...
    k8s-node-2: Warning: Connection aborted. Retrying...
    k8s-node-2:
    k8s-node-2: Vagrant insecure key detected. Vagrant will automatically replace
    k8s-node-2: this with a newly generated keypair for better security.
    k8s-node-2:
    k8s-node-2: Inserting generated public key within guest...
==> k8s-node-2: Machine booted and ready!
==> k8s-node-2: Checking for guest additions in VM...
    k8s-node-2: The guest additions on this VM do not match the installed version of
    k8s-node-2: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-node-2: prevent things such as shared folders from working properly. If you see
    k8s-node-2: shared folder errors, please make sure the guest additions within the
    k8s-node-2: virtual machine match the version of VirtualBox you have installed on
    k8s-node-2: your host and reload your VM.
    k8s-node-2:
    k8s-node-2: Guest Additions Version: 6.0.0 r127566
    k8s-node-2: VirtualBox Version: 7.0
==> k8s-node-2: Setting hostname...
==> k8s-node-2: Configuring and enabling network interfaces...
==> k8s-node-2: Mounting shared folders...
    k8s-node-2: /vagrant => C:/Users/V01dDweller/Desktop/k8s-project
PS C:\Users\V01dDweller\Desktop\k8s-project> vagrant destroy --force
==> k8s-node-2: Forcing shutdown of VM...
==> k8s-node-2: Destroying VM and associated drives...
==> k8s-node-1: Forcing shutdown of VM...
==> k8s-node-1: Destroying VM and associated drives...
==> k8s-master: Forcing shutdown of VM...
==> k8s-master: Destroying VM and associated drives...
PS C:\Users\V01dDweller\Desktop\k8s-project> vagrant up
Bringing machine 'k8s-master' up with 'virtualbox' provider...
Bringing machine 'k8s-node-1' up with 'virtualbox' provider...
Bringing machine 'k8s-node-2' up with 'virtualbox' provider...
==> k8s-master: Importing base box 'ubuntu/jammy64'...
==> k8s-master: Matching MAC address for NAT networking...
==> k8s-master: Checking if box 'ubuntu/jammy64' version '20230428.0.0' is up to date...
==> k8s-master: Setting the name of the VM: k8s-project_k8s-master_1682886677320_64880
==> k8s-master: Clearing any previously set network interfaces...
==> k8s-master: Preparing network interfaces based on configuration...
    k8s-master: Adapter 1: nat
    k8s-master: Adapter 2: hostonly
==> k8s-master: Forwarding ports...
    k8s-master: 22 (guest) => 2222 (host) (adapter 1)
==> k8s-master: Running 'pre-boot' VM customizations...
==> k8s-master: Booting VM...
==> k8s-master: Waiting for machine to boot. This may take a few minutes...
    k8s-master: SSH address: 127.0.0.1:2222
    k8s-master: SSH username: vagrant
    k8s-master: SSH auth method: private key
    k8s-master: Warning: Connection reset. Retrying...
    k8s-master: Warning: Connection aborted. Retrying...
    k8s-master:
    k8s-master: Vagrant insecure key detected. Vagrant will automatically replace
    k8s-master: this with a newly generated keypair for better security.
    k8s-master:
    k8s-master: Inserting generated public key within guest...
==> k8s-master: Machine booted and ready!
==> k8s-master: Checking for guest additions in VM...
    k8s-master: The guest additions on this VM do not match the installed version of
    k8s-master: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-master: prevent things such as shared folders from working properly. If you see
    k8s-master: shared folder errors, please make sure the guest additions within the
    k8s-master: virtual machine match the version of VirtualBox you have installed on
    k8s-master: your host and reload your VM.
    k8s-master:
    k8s-master: Guest Additions Version: 6.0.0 r127566
    k8s-master: VirtualBox Version: 7.0
==> k8s-master: Setting hostname...
==> k8s-master: Configuring and enabling network interfaces...
==> k8s-master: Mounting shared folders...
    k8s-master: /vagrant => C:/Users/V01dDweller/Desktop/k8s-project
==> k8s-node-1: Importing base box 'ubuntu/jammy64'...
==> k8s-node-1: Matching MAC address for NAT networking...
==> k8s-node-1: Checking if box 'ubuntu/jammy64' version '20230428.0.0' is up to date...
==> k8s-node-1: Setting the name of the VM: k8s-project_k8s-node-1_1682886730752_2311
==> k8s-node-1: Fixed port collision for 22 => 2222. Now on port 2200.
==> k8s-node-1: Clearing any previously set network interfaces...
==> k8s-node-1: Preparing network interfaces based on configuration...
    k8s-node-1: Adapter 1: nat
    k8s-node-1: Adapter 2: hostonly
==> k8s-node-1: Forwarding ports...
    k8s-node-1: 22 (guest) => 2200 (host) (adapter 1)
==> k8s-node-1: Running 'pre-boot' VM customizations...
==> k8s-node-1: Booting VM...
==> k8s-node-1: Waiting for machine to boot. This may take a few minutes...
    k8s-node-1: SSH address: 127.0.0.1:2200
    k8s-node-1: SSH username: vagrant
    k8s-node-1: SSH auth method: private key
    k8s-node-1: Warning: Connection reset. Retrying...
    k8s-node-1: Warning: Connection aborted. Retrying...
    k8s-node-1:
    k8s-node-1: Vagrant insecure key detected. Vagrant will automatically replace
    k8s-node-1: this with a newly generated keypair for better security.
    k8s-node-1:
    k8s-node-1: Inserting generated public key within guest...
==> k8s-node-1: Machine booted and ready!
==> k8s-node-1: Checking for guest additions in VM...
    k8s-node-1: The guest additions on this VM do not match the installed version of
    k8s-node-1: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-node-1: prevent things such as shared folders from working properly. If you see
    k8s-node-1: shared folder errors, please make sure the guest additions within the
    k8s-node-1: virtual machine match the version of VirtualBox you have installed on
    k8s-node-1: your host and reload your VM.
    k8s-node-1:
    k8s-node-1: Guest Additions Version: 6.0.0 r127566
    k8s-node-1: VirtualBox Version: 7.0
==> k8s-node-1: Setting hostname...
==> k8s-node-1: Configuring and enabling network interfaces...
==> k8s-node-1: Mounting shared folders...
    k8s-node-1: /vagrant => C:/Users/V01dDweller/Desktop/k8s-project
==> k8s-node-2: Importing base box 'ubuntu/jammy64'...
==> k8s-node-2: Matching MAC address for NAT networking...
==> k8s-node-2: Checking if box 'ubuntu/jammy64' version '20230428.0.0' is up to date...
==> k8s-node-2: Setting the name of the VM: k8s-project_k8s-node-2_1682886785332_21447
==> k8s-node-2: Fixed port collision for 22 => 2222. Now on port 2201.
==> k8s-node-2: Clearing any previously set network interfaces...
==> k8s-node-2: Preparing network interfaces based on configuration...
    k8s-node-2: Adapter 1: nat
    k8s-node-2: Adapter 2: hostonly
==> k8s-node-2: Forwarding ports...
    k8s-node-2: 22 (guest) => 2201 (host) (adapter 1)
==> k8s-node-2: Running 'pre-boot' VM customizations...
==> k8s-node-2: Booting VM...
==> k8s-node-2: Waiting for machine to boot. This may take a few minutes...
    k8s-node-2: SSH address: 127.0.0.1:2201
    k8s-node-2: SSH username: vagrant
    k8s-node-2: SSH auth method: private key
    k8s-node-2:
    k8s-node-2: Vagrant insecure key detected. Vagrant will automatically replace
    k8s-node-2: this with a newly generated keypair for better security.
    k8s-node-2:
    k8s-node-2: Inserting generated public key within guest...
==> k8s-node-2: Machine booted and ready!
==> k8s-node-2: Checking for guest additions in VM...
    k8s-node-2: The guest additions on this VM do not match the installed version of
    k8s-node-2: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-node-2: prevent things such as shared folders from working properly. If you see
    k8s-node-2: shared folder errors, please make sure the guest additions within the
    k8s-node-2: virtual machine match the version of VirtualBox you have installed on
    k8s-node-2: your host and reload your VM.
    k8s-node-2:
    k8s-node-2: Guest Additions Version: 6.0.0 r127566
    k8s-node-2: VirtualBox Version: 7.0
==> k8s-node-2: Setting hostname...
==> k8s-node-2: Configuring and enabling network interfaces...
==> k8s-node-2: Mounting shared folders...
    k8s-node-2: /vagrant => C:/Users/V01dDweller/Desktop/k8s-project
PS C:\Users\V01dDweller\Desktop\k8s-project> vagrant destroy --force
==> k8s-node-2: Forcing shutdown of VM...
==> k8s-node-2: Destroying VM and associated drives...
==> k8s-node-1: Forcing shutdown of VM...
==> k8s-node-1: Destroying VM and associated drives...
==> k8s-master: Forcing shutdown of VM...
==> k8s-master: Destroying VM and associated drives...
PS C:\Users\V01dDweller\Desktop\k8s-project> vagrant validate
Vagrantfile validated successfully.
PS C:\Users\V01dDweller\Desktop\k8s-project> vagrant up
Bringing machine 'k8s-master' up with 'virtualbox' provider...
Bringing machine 'k8s-node-1' up with 'virtualbox' provider...
Bringing machine 'k8s-node-2' up with 'virtualbox' provider...
==> k8s-master: Importing base box 'ubuntu/jammy64'...
==> k8s-master: Matching MAC address for NAT networking...
==> k8s-master: Checking if box 'ubuntu/jammy64' version '20230428.0.0' is up to date...
==> k8s-master: Setting the name of the VM: k8s-project_k8s-master_1682886916752_86915
==> k8s-master: Clearing any previously set network interfaces...
==> k8s-master: Preparing network interfaces based on configuration...
    k8s-master: Adapter 1: nat
    k8s-master: Adapter 2: hostonly
==> k8s-master: Forwarding ports...
    k8s-master: 22 (guest) => 2222 (host) (adapter 1)
==> k8s-master: Running 'pre-boot' VM customizations...
==> k8s-master: Booting VM...
==> k8s-master: Waiting for machine to boot. This may take a few minutes...
    k8s-master: SSH address: 127.0.0.1:2222
    k8s-master: SSH username: vagrant
    k8s-master: SSH auth method: private key
    k8s-master: Warning: Connection reset. Retrying...
    k8s-master: Warning: Connection aborted. Retrying...
    k8s-master:
    k8s-master: Vagrant insecure key detected. Vagrant will automatically replace
    k8s-master: this with a newly generated keypair for better security.
    k8s-master:
    k8s-master: Inserting generated public key within guest...
==> k8s-master: Machine booted and ready!
==> k8s-master: Checking for guest additions in VM...
    k8s-master: The guest additions on this VM do not match the installed version of
    k8s-master: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-master: prevent things such as shared folders from working properly. If you see
    k8s-master: shared folder errors, please make sure the guest additions within the
    k8s-master: virtual machine match the version of VirtualBox you have installed on
    k8s-master: your host and reload your VM.
    k8s-master:
    k8s-master: Guest Additions Version: 6.0.0 r127566
    k8s-master: VirtualBox Version: 7.0
==> k8s-master: Setting hostname...
==> k8s-master: Configuring and enabling network interfaces...
==> k8s-master: Mounting shared folders...
    k8s-master: /vagrant => C:/Users/V01dDweller/Desktop/k8s-project
==> k8s-node-1: Importing base box 'ubuntu/jammy64'...
==> k8s-node-1: Matching MAC address for NAT networking...
==> k8s-node-1: Checking if box 'ubuntu/jammy64' version '20230428.0.0' is up to date...
==> k8s-node-1: Setting the name of the VM: k8s-project_k8s-node-1_1682886971831_75365
==> k8s-node-1: Fixed port collision for 22 => 2222. Now on port 2200.
==> k8s-node-1: Clearing any previously set network interfaces...
==> k8s-node-1: Preparing network interfaces based on configuration...
    k8s-node-1: Adapter 1: nat
    k8s-node-1: Adapter 2: hostonly
==> k8s-node-1: Forwarding ports...
    k8s-node-1: 22 (guest) => 2200 (host) (adapter 1)
==> k8s-node-1: Running 'pre-boot' VM customizations...
==> k8s-node-1: Booting VM...
==> k8s-node-1: Waiting for machine to boot. This may take a few minutes...
    k8s-node-1: SSH address: 127.0.0.1:2200
    k8s-node-1: SSH username: vagrant
    k8s-node-1: SSH auth method: private key
    k8s-node-1: Warning: Connection reset. Retrying...
    k8s-node-1: Warning: Connection aborted. Retrying...
    k8s-node-1:
    k8s-node-1: Vagrant insecure key detected. Vagrant will automatically replace
    k8s-node-1: this with a newly generated keypair for better security.
    k8s-node-1:
    k8s-node-1: Inserting generated public key within guest...
==> k8s-node-1: Machine booted and ready!
==> k8s-node-1: Checking for guest additions in VM...
    k8s-node-1: The guest additions on this VM do not match the installed version of
    k8s-node-1: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-node-1: prevent things such as shared folders from working properly. If you see
    k8s-node-1: shared folder errors, please make sure the guest additions within the
    k8s-node-1: virtual machine match the version of VirtualBox you have installed on
    k8s-node-1: your host and reload your VM.
    k8s-node-1:
    k8s-node-1: Guest Additions Version: 6.0.0 r127566
    k8s-node-1: VirtualBox Version: 7.0
==> k8s-node-1: Setting hostname...
==> k8s-node-1: Configuring and enabling network interfaces...
==> k8s-node-1: Mounting shared folders...
    k8s-node-1: /vagrant => C:/Users/V01dDweller/Desktop/k8s-project
==> k8s-node-2: Importing base box 'ubuntu/jammy64'...
==> k8s-node-2: Matching MAC address for NAT networking...
==> k8s-node-2: Checking if box 'ubuntu/jammy64' version '20230428.0.0' is up to date...
==> k8s-node-2: Setting the name of the VM: k8s-project_k8s-node-2_1682887027099_17724
==> k8s-node-2: Fixed port collision for 22 => 2222. Now on port 2201.
==> k8s-node-2: Clearing any previously set network interfaces...
==> k8s-node-2: Preparing network interfaces based on configuration...
    k8s-node-2: Adapter 1: nat
    k8s-node-2: Adapter 2: hostonly
==> k8s-node-2: Forwarding ports...
    k8s-node-2: 22 (guest) => 2201 (host) (adapter 1)
==> k8s-node-2: Running 'pre-boot' VM customizations...
==> k8s-node-2: Booting VM...
==> k8s-node-2: Waiting for machine to boot. This may take a few minutes...
    k8s-node-2: SSH address: 127.0.0.1:2201
    k8s-node-2: SSH username: vagrant
    k8s-node-2: SSH auth method: private key
    k8s-node-2: Warning: Connection reset. Retrying...
    k8s-node-2: Warning: Connection aborted. Retrying...
    k8s-node-2:
    k8s-node-2: Vagrant insecure key detected. Vagrant will automatically replace
    k8s-node-2: this with a newly generated keypair for better security.
    k8s-node-2:
    k8s-node-2: Inserting generated public key within guest...
==> k8s-node-2: Machine booted and ready!
==> k8s-node-2: Checking for guest additions in VM...
    k8s-node-2: The guest additions on this VM do not match the installed version of
    k8s-node-2: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-node-2: prevent things such as shared folders from working properly. If you see
    k8s-node-2: shared folder errors, please make sure the guest additions within the
    k8s-node-2: virtual machine match the version of VirtualBox you have installed on
    k8s-node-2: your host and reload your VM.
    k8s-node-2:
    k8s-node-2: Guest Additions Version: 6.0.0 r127566
    k8s-node-2: VirtualBox Version: 7.0
==> k8s-node-2: Setting hostname...
==> k8s-node-2: Configuring and enabling network interfaces...
==> k8s-node-2: Mounting shared folders...
    k8s-node-2: /vagrant => C:/Users/V01dDweller/Desktop/k8s-project
PS C:\Users\V01dDweller\Desktop\k8s-project> vagrant reload
==> k8s-master: Attempting graceful shutdown of VM...
==> k8s-master: Checking if box 'ubuntu/jammy64' version '20230428.0.0' is up to date...
==> k8s-master: Clearing any previously set forwarded ports...
==> k8s-master: Clearing any previously set network interfaces...
==> k8s-master: Preparing network interfaces based on configuration...
    k8s-master: Adapter 1: nat
    k8s-master: Adapter 2: hostonly
==> k8s-master: Forwarding ports...
    k8s-master: 22 (guest) => 2222 (host) (adapter 1)
==> k8s-master: Running 'pre-boot' VM customizations...
==> k8s-master: Booting VM...
==> k8s-master: Waiting for machine to boot. This may take a few minutes...
    k8s-master: SSH address: 127.0.0.1:2222
    k8s-master: SSH username: vagrant
    k8s-master: SSH auth method: private key
    k8s-master: Warning: Connection reset. Retrying...
    k8s-master: Warning: Connection aborted. Retrying...
    k8s-master: Warning: Connection reset. Retrying...
    k8s-master: Warning: Connection aborted. Retrying...
==> k8s-master: Machine booted and ready!
==> k8s-master: Checking for guest additions in VM...
    k8s-master: The guest additions on this VM do not match the installed version of
    k8s-master: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-master: prevent things such as shared folders from working properly. If you see
    k8s-master: shared folder errors, please make sure the guest additions within the
    k8s-master: virtual machine match the version of VirtualBox you have installed on
    k8s-master: your host and reload your VM.
    k8s-master:
    k8s-master: Guest Additions Version: 6.0.0 r127566
    k8s-master: VirtualBox Version: 7.0
==> k8s-master: Setting hostname...
==> k8s-master: Configuring and enabling network interfaces...
==> k8s-master: Mounting shared folders...
    k8s-master: /vagrant => C:/Users/V01dDweller/Desktop/k8s-project
==> k8s-master: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> k8s-master: flag to force provisioning. Provisioners marked to run always will still run.
==> k8s-node-1: Attempting graceful shutdown of VM...
==> k8s-node-1: Checking if box 'ubuntu/jammy64' version '20230428.0.0' is up to date...
==> k8s-node-1: Clearing any previously set forwarded ports...
==> k8s-node-1: Fixed port collision for 22 => 2222. Now on port 2200.
==> k8s-node-1: Clearing any previously set network interfaces...
==> k8s-node-1: Preparing network interfaces based on configuration...
    k8s-node-1: Adapter 1: nat
    k8s-node-1: Adapter 2: hostonly
==> k8s-node-1: Forwarding ports...
    k8s-node-1: 22 (guest) => 2200 (host) (adapter 1)
==> k8s-node-1: Running 'pre-boot' VM customizations...
==> k8s-node-1: Booting VM...
==> k8s-node-1: Waiting for machine to boot. This may take a few minutes...
    k8s-node-1: SSH address: 127.0.0.1:2200
    k8s-node-1: SSH username: vagrant
    k8s-node-1: SSH auth method: private key
    k8s-node-1: Warning: Connection reset. Retrying...
    k8s-node-1: Warning: Connection aborted. Retrying...
    k8s-node-1: Warning: Connection reset. Retrying...
    k8s-node-1: Warning: Connection aborted. Retrying...
==> k8s-node-1: Machine booted and ready!
==> k8s-node-1: Checking for guest additions in VM...
    k8s-node-1: The guest additions on this VM do not match the installed version of
    k8s-node-1: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-node-1: prevent things such as shared folders from working properly. If you see
    k8s-node-1: shared folder errors, please make sure the guest additions within the
    k8s-node-1: virtual machine match the version of VirtualBox you have installed on
    k8s-node-1: your host and reload your VM.
    k8s-node-1:
    k8s-node-1: Guest Additions Version: 6.0.0 r127566
    k8s-node-1: VirtualBox Version: 7.0
==> k8s-node-1: Setting hostname...
==> k8s-node-1: Configuring and enabling network interfaces...
==> k8s-node-1: Mounting shared folders...
    k8s-node-1: /vagrant => C:/Users/V01dDweller/Desktop/k8s-project
==> k8s-node-1: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> k8s-node-1: flag to force provisioning. Provisioners marked to run always will still run.
==> k8s-node-2: Attempting graceful shutdown of VM...
==> k8s-node-2: Checking if box 'ubuntu/jammy64' version '20230428.0.0' is up to date...
==> k8s-node-2: Clearing any previously set forwarded ports...
==> k8s-node-2: Fixed port collision for 22 => 2222. Now on port 2201.
==> k8s-node-2: Clearing any previously set network interfaces...
==> k8s-node-2: Preparing network interfaces based on configuration...
    k8s-node-2: Adapter 1: nat
    k8s-node-2: Adapter 2: hostonly
==> k8s-node-2: Forwarding ports...
    k8s-node-2: 22 (guest) => 2201 (host) (adapter 1)
==> k8s-node-2: Running 'pre-boot' VM customizations...
==> k8s-node-2: Booting VM...
==> k8s-node-2: Waiting for machine to boot. This may take a few minutes...
    k8s-node-2: SSH address: 127.0.0.1:2201
    k8s-node-2: SSH username: vagrant
    k8s-node-2: SSH auth method: private key
    k8s-node-2: Warning: Connection reset. Retrying...
    k8s-node-2: Warning: Connection aborted. Retrying...
    k8s-node-2: Warning: Connection reset. Retrying...
==> k8s-node-2: Machine booted and ready!
==> k8s-node-2: Checking for guest additions in VM...
    k8s-node-2: The guest additions on this VM do not match the installed version of
    k8s-node-2: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-node-2: prevent things such as shared folders from working properly. If you see
    k8s-node-2: shared folder errors, please make sure the guest additions within the
    k8s-node-2: virtual machine match the version of VirtualBox you have installed on
    k8s-node-2: your host and reload your VM.
    k8s-node-2:
    k8s-node-2: Guest Additions Version: 6.0.0 r127566
    k8s-node-2: VirtualBox Version: 7.0
==> k8s-node-2: Setting hostname...
==> k8s-node-2: Configuring and enabling network interfaces...
==> k8s-node-2: Mounting shared folders...
    k8s-node-2: /vagrant => C:/Users/V01dDweller/Desktop/k8s-project
==> k8s-node-2: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> k8s-node-2: flag to force provisioning. Provisioners marked to run always will still run.
PS C:\Users\V01dDweller\Desktop\k8s-project> vagrant destroy --force
==> k8s-node-2: Forcing shutdown of VM...
==> k8s-node-2: Destroying VM and associated drives...
==> k8s-node-1: Forcing shutdown of VM...
==> k8s-node-1: Destroying VM and associated drives...
==> k8s-master: Forcing shutdown of VM...
==> k8s-master: Destroying VM and associated drives...
PS C:\Users\V01dDweller\Desktop\k8s-project> vagrant up
Bringing machine 'k8s-master' up with 'virtualbox' provider...
Bringing machine 'k8s-node-1' up with 'virtualbox' provider...
Bringing machine 'k8s-node-2' up with 'virtualbox' provider...
==> k8s-master: Importing base box 'ubuntu/jammy64'...
==> k8s-master: Matching MAC address for NAT networking...
==> k8s-master: Checking if box 'ubuntu/jammy64' version '20230428.0.0' is up to date...
==> k8s-master: Setting the name of the VM: k8s-project_k8s-master_1682904581049_36818
==> k8s-master: Clearing any previously set network interfaces...
==> k8s-master: Preparing network interfaces based on configuration...
    k8s-master: Adapter 1: nat
    k8s-master: Adapter 2: hostonly
==> k8s-master: Forwarding ports...
    k8s-master: 22 (guest) => 2222 (host) (adapter 1)
==> k8s-master: Running 'pre-boot' VM customizations...
==> k8s-master: Booting VM...
==> k8s-master: Waiting for machine to boot. This may take a few minutes...
    k8s-master: SSH address: 127.0.0.1:2222
    k8s-master: SSH username: vagrant
    k8s-master: SSH auth method: private key
    k8s-master: Warning: Connection reset. Retrying...
    k8s-master: Warning: Connection aborted. Retrying...
    k8s-master:
    k8s-master: Vagrant insecure key detected. Vagrant will automatically replace
    k8s-master: this with a newly generated keypair for better security.
    k8s-master:
    k8s-master: Inserting generated public key within guest...
==> k8s-master: Machine booted and ready!
==> k8s-master: Checking for guest additions in VM...
    k8s-master: The guest additions on this VM do not match the installed version of
    k8s-master: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-master: prevent things such as shared folders from working properly. If you see
    k8s-master: shared folder errors, please make sure the guest additions within the
    k8s-master: virtual machine match the version of VirtualBox you have installed on
    k8s-master: your host and reload your VM.
    k8s-master:
    k8s-master: Guest Additions Version: 6.0.0 r127566
    k8s-master: VirtualBox Version: 7.0
==> k8s-master: Setting hostname...
==> k8s-master: Configuring and enabling network interfaces...
==> k8s-master: Mounting shared folders...
    k8s-master: /vagrant => C:/Users/V01dDweller/Desktop/k8s-project
==> k8s-node-1: Importing base box 'ubuntu/jammy64'...
==> k8s-node-1: Matching MAC address for NAT networking...
==> k8s-node-1: Checking if box 'ubuntu/jammy64' version '20230428.0.0' is up to date...
==> k8s-node-1: Setting the name of the VM: k8s-project_k8s-node-1_1682904645554_35673
==> k8s-node-1: Fixed port collision for 22 => 2222. Now on port 2200.
==> k8s-node-1: Clearing any previously set network interfaces...
==> k8s-node-1: Preparing network interfaces based on configuration...
    k8s-node-1: Adapter 1: nat
    k8s-node-1: Adapter 2: hostonly
==> k8s-node-1: Forwarding ports...
    k8s-node-1: 22 (guest) => 2200 (host) (adapter 1)
==> k8s-node-1: Running 'pre-boot' VM customizations...
==> k8s-node-1: Booting VM...
==> k8s-node-1: Waiting for machine to boot. This may take a few minutes...
    k8s-node-1: SSH address: 127.0.0.1:2200
    k8s-node-1: SSH username: vagrant
    k8s-node-1: SSH auth method: private key
    k8s-node-1: Warning: Connection reset. Retrying...
    k8s-node-1:
    k8s-node-1: Vagrant insecure key detected. Vagrant will automatically replace
    k8s-node-1: this with a newly generated keypair for better security.
    k8s-node-1:
    k8s-node-1: Inserting generated public key within guest...
==> k8s-node-1: Machine booted and ready!
==> k8s-node-1: Checking for guest additions in VM...
    k8s-node-1: The guest additions on this VM do not match the installed version of
    k8s-node-1: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-node-1: prevent things such as shared folders from working properly. If you see
    k8s-node-1: shared folder errors, please make sure the guest additions within the
    k8s-node-1: virtual machine match the version of VirtualBox you have installed on
    k8s-node-1: your host and reload your VM.
    k8s-node-1:
    k8s-node-1: Guest Additions Version: 6.0.0 r127566
    k8s-node-1: VirtualBox Version: 7.0
==> k8s-node-1: Setting hostname...
==> k8s-node-1: Configuring and enabling network interfaces...
==> k8s-node-1: Mounting shared folders...
    k8s-node-1: /vagrant => C:/Users/V01dDweller/Desktop/k8s-project
==> k8s-node-2: Importing base box 'ubuntu/jammy64'...
==> k8s-node-2: Matching MAC address for NAT networking...
==> k8s-node-2: Checking if box 'ubuntu/jammy64' version '20230428.0.0' is up to date...
==> k8s-node-2: Setting the name of the VM: k8s-project_k8s-node-2_1682904715092_91884
==> k8s-node-2: Fixed port collision for 22 => 2222. Now on port 2201.
==> k8s-node-2: Clearing any previously set network interfaces...
==> k8s-node-2: Preparing network interfaces based on configuration...
    k8s-node-2: Adapter 1: nat
    k8s-node-2: Adapter 2: hostonly
==> k8s-node-2: Forwarding ports...
    k8s-node-2: 22 (guest) => 2201 (host) (adapter 1)
==> k8s-node-2: Running 'pre-boot' VM customizations...
==> k8s-node-2: Booting VM...
==> k8s-node-2: Waiting for machine to boot. This may take a few minutes...
    k8s-node-2: SSH address: 127.0.0.1:2201
    k8s-node-2: SSH username: vagrant
    k8s-node-2: SSH auth method: private key
    k8s-node-2:
    k8s-node-2: Vagrant insecure key detected. Vagrant will automatically replace
    k8s-node-2: this with a newly generated keypair for better security.
    k8s-node-2:
    k8s-node-2: Inserting generated public key within guest...
==> k8s-node-2: Machine booted and ready!
==> k8s-node-2: Checking for guest additions in VM...
    k8s-node-2: The guest additions on this VM do not match the installed version of
    k8s-node-2: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-node-2: prevent things such as shared folders from working properly. If you see
    k8s-node-2: shared folder errors, please make sure the guest additions within the
    k8s-node-2: virtual machine match the version of VirtualBox you have installed on
    k8s-node-2: your host and reload your VM.
    k8s-node-2:
    k8s-node-2: Guest Additions Version: 6.0.0 r127566
    k8s-node-2: VirtualBox Version: 7.0
==> k8s-node-2: Setting hostname...
==> k8s-node-2: Configuring and enabling network interfaces...
==> k8s-node-2: Mounting shared folders...
    k8s-node-2: /vagrant => C:/Users/V01dDweller/Desktop/k8s-project
```

</details>

<details>
<summary>Sample output: Ansible</summary>

```txt
bash-5.1$ ansible-playbook k8s_install.yml

PLAY [Install kubectl locally] *************************************************************************

TASK [Retrieving kubectl latest stable version] ********************************************************
ok: [localhost]

TASK [Displaying kubectl latest stable version] ********************************************************
ok: [localhost] =>
  msg: Lastest kubectl version is v1.27.1

TASK [Downloading /usr/local/bin/kubectl v1.27.1] ******************************************************
ok: [localhost]

PLAY [Installing Docker] *******************************************************************************

TASK [docker_install : Gathering facts] ****************************************************************
ok: [k8s-node-2]
ok: [k8s-master]
ok: [k8s-node-1]

TASK [docker_install : Installing dependencies] ********************************************************
ok: [k8s-node-2]
ok: [k8s-master]
ok: [k8s-node-1]

TASK [docker_install : Adding GPG key for Docker apt repo] *********************************************
changed: [k8s-node-2]
changed: [k8s-node-1]
changed: [k8s-master]

TASK [docker_install : Adding Docker apt repo] *********************************************************
changed: [k8s-node-2]
changed: [k8s-master]
changed: [k8s-node-1]

TASK [docker_install : Updating apt cache] *************************************************************
ok: [k8s-node-2]
ok: [k8s-master]
ok: [k8s-node-1]

TASK [docker_install : Installing Docker CE] ***********************************************************
changed: [k8s-node-1]
changed: [k8s-master]
changed: [k8s-node-2]

TASK [docker_install : Adding vagrant to the docker group] *********************************************
changed: [k8s-node-2]
changed: [k8s-node-1]
changed: [k8s-master]

TASK [docker_install : Restarting Docker now] **********************************************************

TASK [docker_install : Restarting Docker now] **********************************************************

TASK [docker_install : Restarting Docker now] **********************************************************

RUNNING HANDLER [docker_install : Restart docker] ******************************************************
changed: [k8s-node-1]
changed: [k8s-node-2]
changed: [k8s-master]

TASK [Adding Kubernetes signing key] *******************************************************************
changed: [k8s-node-1]
changed: [k8s-master]
changed: [k8s-node-2]

TASK [Adding Kubernetes repository] ********************************************************************
changed: [k8s-master]
changed: [k8s-node-2]
changed: [k8s-node-1]

TASK [Setting kubernetes_packages fact] ****************************************************************
ok: [k8s-master]
ok: [k8s-node-1]
ok: [k8s-node-2]

TASK [Installing kubeadm kubelet and kubectl] **********************************************************
changed: [k8s-node-2]
changed: [k8s-master]
changed: [k8s-node-1]

TASK [Issuing apt-mark hold on kubeadm kubelet and kubectl] ********************************************
changed: [k8s-master] => (item=Holding kubelet package)
changed: [k8s-node-1] => (item=Holding kubelet package)
changed: [k8s-node-2] => (item=Holding kubelet package)
changed: [k8s-master] => (item=Holding kubeadm package)
changed: [k8s-node-2] => (item=Holding kubeadm package)
changed: [k8s-node-1] => (item=Holding kubeadm package)
changed: [k8s-master] => (item=Holding kubectl package)
changed: [k8s-node-2] => (item=Holding kubectl package)
changed: [k8s-node-1] => (item=Holding kubectl package)

TASK [Creating /etc/modules-load.d/containerd.conf] ****************************************************
changed: [k8s-master]
changed: [k8s-node-1]
changed: [k8s-node-2]

TASK [Creating /etc/sysctl.d/kubernetes.conf] **********************************************************
changed: [k8s-master]
changed: [k8s-node-2]
changed: [k8s-node-1]

RUNNING HANDLER [Issue modprobe overlay] ***************************************************************
ok: [k8s-node-2]
ok: [k8s-master]
ok: [k8s-node-1]

RUNNING HANDLER [Reload sysctl] ************************************************************************
ok: [k8s-master]
ok: [k8s-node-1]
ok: [k8s-node-2]

PLAY [Configure the master] ****************************************************************************

TASK [Creating /etc/default/kubelet] *******************************************************************
changed: [k8s-master]

TASK [Creating /etc/docker/daemon.json] ****************************************************************
changed: [k8s-master]

TASK [Updating /etc/systemd/system/kubelet.service.d/10-kubeadm.conf] **********************************
changed: [k8s-master]

TASK [Updating /etc/containerd/config.toml] ************************************************************
changed: [k8s-master]

TASK [Flushing handlers now to restart containerd] *****************************************************

RUNNING HANDLER [Restart kubelet] **********************************************************************
changed: [k8s-master]

RUNNING HANDLER [Restart docker] ***********************************************************************
changed: [k8s-master]

RUNNING HANDLER [Restart containerd] *******************************************************************
changed: [k8s-master]

TASK [Saving the master hostname from the inventory] ***************************************************
ok: [k8s-master]

TASK [Who's da master?] ********************************************************************************
ok: [k8s-master] =>
  msg: The master is k8s-master

TASK [Initializing the cluster via kubeadmin] **********************************************************
changed: [k8s-master]

TASK [Displaying kubeadm init output] ******************************************************************
ok: [k8s-master] =>
  msg:
  - '[init] Using Kubernetes version: v1.27.1'
  - '[preflight] Running pre-flight checks'
  - '[preflight] Pulling images required for setting up a Kubernetes cluster'
  - '[preflight] This might take a minute or two, depending on the speed of your internet connection'
  - '[preflight] You can also perform this action in beforehand using ''kubeadm config images pull'''
  - '[certs] Using certificateDir folder "/etc/kubernetes/pki"'
  - '[certs] Generating "ca" certificate and key'
  - '[certs] Generating "apiserver" certificate and key'
  - '[certs] apiserver serving cert is signed for DNS names [k8s-master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.56.10]'
  - '[certs] Generating "apiserver-kubelet-client" certificate and key'
  - '[certs] Generating "front-proxy-ca" certificate and key'
  - '[certs] Generating "front-proxy-client" certificate and key'
  - '[certs] Generating "etcd/ca" certificate and key'
  - '[certs] Generating "etcd/server" certificate and key'
  - '[certs] etcd/server serving cert is signed for DNS names [k8s-master localhost] and IPs [192.168.56.10 127.0.0.1 ::1]'
  - '[certs] Generating "etcd/peer" certificate and key'
  - '[certs] etcd/peer serving cert is signed for DNS names [k8s-master localhost] and IPs [192.168.56.10 127.0.0.1 ::1]'
  - '[certs] Generating "etcd/healthcheck-client" certificate and key'
  - '[certs] Generating "apiserver-etcd-client" certificate and key'
  - '[certs] Generating "sa" key and public key'
  - '[kubeconfig] Using kubeconfig folder "/etc/kubernetes"'
  - '[kubeconfig] Writing "admin.conf" kubeconfig file'
  - '[kubeconfig] Writing "kubelet.conf" kubeconfig file'
  - '[kubeconfig] Writing "controller-manager.conf" kubeconfig file'
  - '[kubeconfig] Writing "scheduler.conf" kubeconfig file'
  - '[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"'
  - '[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"'
  - '[kubelet-start] Starting the kubelet'
  - '[control-plane] Using manifest folder "/etc/kubernetes/manifests"'
  - '[control-plane] Creating static Pod manifest for "kube-apiserver"'
  - '[control-plane] Creating static Pod manifest for "kube-controller-manager"'
  - '[control-plane] Creating static Pod manifest for "kube-scheduler"'
  - '[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"'
  - '[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s'
  - '[apiclient] All control plane components are healthy after 12.505778 seconds'
  - '[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace'
  - '[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster'
  - '[upload-certs] Skipping phase. Please see --upload-certs'
  - '[mark-control-plane] Marking the node k8s-master as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]'
  - '[mark-control-plane] Marking the node k8s-master as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]'
  - '[bootstrap-token] Using token: 4k1e3k.mhsk6ehldxsavbe0'
  - '[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles'
  - '[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes'
  - '[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials'
  - '[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token'
  - '[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster'
  - '[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace'
  - '[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key'
  - '[addons] Applied essential addon: CoreDNS'
  - '[addons] Applied essential addon: kube-proxy'
  - ''
  - Your Kubernetes control-plane has initialized successfully!
  - ''
  - 'To start using your cluster, you need to run the following as a regular user:'
  - ''
  - '  mkdir -p $HOME/.kube'
  - '  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config'
  - '  sudo chown $(id -u):$(id -g) $HOME/.kube/config'
  - ''
  - 'Alternatively, if you are the root user, you can run:'
  - ''
  - '  export KUBECONFIG=/etc/kubernetes/admin.conf'
  - ''
  - You should now deploy a pod network to the cluster.
  - 'Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:'
  - '  https://kubernetes.io/docs/concepts/cluster-administration/addons/'
  - ''
  - You can now join any number of control-plane nodes by copying certificate authorities
  - 'and service account keys on each node and then running the following as root:'
  - ''
  - '  kubeadm join 192.168.56.10:6443 --token 4k1e3k.mhsk6ehldxsavbe0 \'
  - "\t--discovery-token-ca-cert-hash sha256:7cc9162a3adb231f48b9afe84cc0f67a8f2baff6ecf0102e5db6d14a8688f8d2 \\"
  - "\t--control-plane "
  - ''
  - 'Then you can join any number of worker nodes by running the following on each as root:'
  - ''
  - kubeadm join 192.168.56.10:6443 --token 4k1e3k.mhsk6ehldxsavbe0 \
  - "\t--discovery-token-ca-cert-hash sha256:7cc9162a3adb231f48b9afe84cc0f67a8f2baff6ecf0102e5db6d14a8688f8d2 "

TASK [Creating $HOME/.kube] ****************************************************************************
changed: [k8s-master]

TASK [Creating $HOME/.kube admin.conf] *****************************************************************
changed: [k8s-master]

TASK [Getting cluster status] **************************************************************************
ok: [k8s-master]

TASK [Displaying cluter info] **************************************************************************
ok: [k8s-master] =>
  msg: |-
    [0;32mKubernetes control plane[0m is running at [0;33mhttps://192.168.56.10:6443[0m
    [0;32mCoreDNS[0m is running at [0;33mhttps://192.168.56.10:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy[0m

    To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
    NAME         STATUS     ROLES           AGE   VERSION
    k8s-master   NotReady   control-plane   7s    v1.27.1

PLAY [Configure the nodes] *****************************************************************************

TASK [Retrieving master name and ip from inventory] ****************************************************
ok: [k8s-node-1 -> localhost]

TASK [Retrieving the join command] *********************************************************************
ok: [k8s-node-1 -> k8s-master(192.168.56.10)]

TASK [Saving the tokens] *******************************************************************************
ok: [k8s-node-1]

TASK [Disabling apparmor service] **********************************************************************
changed: [k8s-node-2]
changed: [k8s-node-1]

TASK [Updating /etc/containerd/config.toml] ************************************************************
changed: [k8s-node-2]
changed: [k8s-node-1]

TASK [Flushing handlers now to restart containerd] *****************************************************

TASK [Flushing handlers now to restart containerd] *****************************************************

RUNNING HANDLER [Restart containerd] *******************************************************************
changed: [k8s-node-1]
changed: [k8s-node-2]

TASK [Joining nodes to cluster] ************************************************************************
changed: [k8s-node-2]
changed: [k8s-node-1]

TASK [Displaying node status] **************************************************************************
ok: [k8s-node-1] =>
  msg: |-
    [preflight] Running pre-flight checks
    [preflight] Reading configuration from the cluster...
    [preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
    [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
    [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
    [kubelet-start] Starting the kubelet
    [kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

    This node has joined the cluster:
    * Certificate signing request was sent to apiserver and a response was received.
    * The Kubelet was informed of the new secure connection details.

    Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
ok: [k8s-node-2] =>
  msg: |-
    [preflight] Running pre-flight checks
    [preflight] Reading configuration from the cluster...
    [preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
    [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
    [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
    [kubelet-start] Starting the kubelet
    [kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

    This node has joined the cluster:
    * Certificate signing request was sent to apiserver and a response was received.
    * The Kubelet was informed of the new secure connection details.

    Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

PLAY RECAP *********************************************************************************************
k8s-master                 : ok=32   changed=21   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
k8s-node-1                 : ok=25   changed=15   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
k8s-node-2                 : ok=22   changed=15   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

</details>

[modeline]: # ( vim: set number textwidth=78 colorcolumn=80 foldcolumn=2  nowrap: )
