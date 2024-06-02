# k8s-cluster

Use this project to create a 3-node Kubernetes cluster using Vagrant,
VirtualBox and Ansible. Follow the instructions below to:

1. Create 3x Ubuntu 22.04 (Jammy) virtual machines
1. Install `kubeadmin` on the host
1. Install `containerd` on each node
1. Configure one virtual machine as the master
1. Configure the remaining two virtual machines as worker nodes
1. Install a CNI plugin (Cilium)

A Vagrantfile is provided to automate creating the virtual machines with
Vagrant, and an Ansible playbook is provided to do everything else.

Based on [Kubernetes Official Documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

### Issues

- 2024-06-01: The cluster seems to be working but there are some
  `CrashLoopBackoff` errors for cilium and kube-proxy pods that need
  investigation.

### Files

```txt
.
├── README.md               # You are here
├── Vagrantfile
├── ansible.cfg
├── bootstrap.sh
├── hosts
│   └── vagrant
│       ├── group_vars
│       │   └── all.yml
│       └── hosts
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
│   │   └── tasks
│   │       ├── main.yml
│   │       └── ubuntu22.yml
│   ├── hosts_update
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

It's clunky, but Windows users must clone this project twice. Once in a
PowerShell, and again in a WSL2 instance. PowerShell must be used to run
`vagrant` commands as Vagrant will not work in WSL2. Ansible does not support
Windows and must be run in a WSL2 instance.

1. In a PowerShell, clone this project to the Desktop or the directory of your
choice.

1. Open a PowerShell and CD to the project directory, e.g.:

```txt
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

PS C:\Users\V01dDweller> cd .\Desktop\k8s-cluster\
PS C:\Users\V01dDweller\Desktop\k8s-cluster>
```

1. Issue the `vagrant up` command to create three virtual machines.

1. Switch to a WSL2 instance and clone the project again.

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
==> k8s-master: Checking if box 'ubuntu/jammy64' version '20240319.0.0' is up to date...
==> k8s-master: Setting the name of the VM: k8s-project_k8s-master_1717332532832_98069
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
    k8s-master: /vagrant => C:/Users/lucan/Desktop/k8s-project
==> k8s-node-1: Importing base box 'ubuntu/jammy64'...
==> k8s-node-1: Matching MAC address for NAT networking...
==> k8s-node-1: Checking if box 'ubuntu/jammy64' version '20240319.0.0' is up to date...
==> k8s-node-1: Setting the name of the VM: k8s-project_k8s-node-1_1717332588859_8420
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
    k8s-node-1: /vagrant => C:/Users/lucan/Desktop/k8s-project
==> k8s-node-2: Importing base box 'ubuntu/jammy64'...
==> k8s-node-2: Matching MAC address for NAT networking...
==> k8s-node-2: Checking if box 'ubuntu/jammy64' version '20240319.0.0' is up to date...
==> k8s-node-2: Setting the name of the VM: k8s-project_k8s-node-2_1717332654639_98271
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
    k8s-node-2: /vagrant => C:/Users/lucan/Desktop/k8s-project
```

</details>

<details>
<summary>Sample output: Ansible</summary>

```txt
bash-5.1$ ansible-playbook k8s_install.yml

PLAY [Install kubectl locally] *******************************************************************************

TASK [Retrieving kubectl latest stable version] **************************************************************
ok: [localhost]

TASK [Displaying kubectl latest stable version] **************************************************************
ok: [localhost] =>
  msg: Lastest kubectl version is v1.30.1

TASK [Downloading /usr/local/bin/kubectl v1.30.1] ************************************************************
ok: [localhost]

PLAY [Installing Containerd, Docker and Kubernetes tools] ****************************************************

TASK [hosts_update : Checking hostname] **********************************************************************
ok: [k8s-node-2]
ok: [k8s-master]
ok: [k8s-node-1]

TASK [hosts_update : Displaying my_hosname] ******************************************************************
ok: [k8s-master] =>
  my_hostname.stdout: k8s-master
ok: [k8s-node-1] =>
  my_hostname.stdout: k8s-node-1
ok: [k8s-node-2] =>
  my_hostname.stdout: k8s-node-2

TASK [hosts_update : Update /etc/hosts] **********************************************************************
changed: [k8s-node-2]
changed: [k8s-master]
changed: [k8s-node-1]

TASK [ipv6_disable : Gathering facts] ************************************************************************
ok: [k8s-node-2]
ok: [k8s-node-1]
ok: [k8s-master]

TASK [ipv6_disable : Disabling IPv6 in Ubuntu 22.04] *********************************************************
included: /home/ksimpson/Documents/projects/k8s-cluster/roles/ipv6_disable/tasks/ubuntu22.yml for k8s-master, k8s-node-1, k8s-node-2

TASK [ipv6_disable : Updating /etc/default/grub] *************************************************************
changed: [k8s-master]
changed: [k8s-node-1]
changed: [k8s-node-2]

TASK [ipv6_disable : Removing ip6 lines from /etc/hosts] *****************************************************
ok: [k8s-master] => (item=ip6)
ok: [k8s-node-1] => (item=ip6)
ok: [k8s-node-2] => (item=ip6)
ok: [k8s-node-1] => (item=IPv6)
ok: [k8s-master] => (item=IPv6)
ok: [k8s-node-2] => (item=IPv6)

TASK [ipv6_disable : Flushing handlers for immediate reboot] *************************************************

TASK [ipv6_disable : Flushing handlers for immediate reboot] *************************************************

TASK [ipv6_disable : Flushing handlers for immediate reboot] *************************************************

RUNNING HANDLER [ipv6_disable : Update grub.cfg] *************************************************************
changed: [k8s-master]
changed: [k8s-node-2]
changed: [k8s-node-1]

RUNNING HANDLER [ipv6_disable : IPv6 Reboot] *****************************************************************
changed: [k8s-master]
changed: [k8s-node-2]
changed: [k8s-node-1]

TASK [containerd_install : Gathering facts] ******************************************************************
ok: [k8s-node-1]
ok: [k8s-node-2]
ok: [k8s-master]

TASK [containerd_install : Installing dependencies] **********************************************************
ok: [k8s-master]
ok: [k8s-node-1]
ok: [k8s-node-2]

TASK [containerd_install : Installing containerd] ************************************************************
changed: [k8s-master]
changed: [k8s-node-1]
changed: [k8s-node-2]

TASK [containerd_install : Creating /etc/modules-load.d/containerd.conf] *************************************
changed: [k8s-master]
changed: [k8s-node-1]
changed: [k8s-node-2]

TASK [containerd_install : Creating  /etc/containerd] ********************************************************
changed: [k8s-master]
changed: [k8s-node-1]
changed: [k8s-node-2]

TASK [containerd_install : Updating /etc/containerd/config.toml] *********************************************
changed: [k8s-node-1]
changed: [k8s-node-2]
changed: [k8s-master]

TASK [containerd_install : Enabling and restarting containerd] ***********************************************
ok: [k8s-node-2]
ok: [k8s-master]
ok: [k8s-node-1]

TASK [containerd_install : Flushing handlers now to restart containerd] **************************************

TASK [containerd_install : Flushing handlers now to restart containerd] **************************************

TASK [containerd_install : Flushing handlers now to restart containerd] **************************************

RUNNING HANDLER [containerd_install : Restart containerd] ****************************************************
changed: [k8s-node-2]
changed: [k8s-master]
changed: [k8s-node-1]

RUNNING HANDLER [Issue modprobe overlay] *********************************************************************
ok: [k8s-master]
ok: [k8s-node-1]
ok: [k8s-node-2]

TASK [Setting time zone Americas/New_York] *******************************************************************
changed: [k8s-node-2]
changed: [k8s-master]
changed: [k8s-node-1]

TASK [Adding Kubernetes signing key] *************************************************************************
changed: [k8s-master]
changed: [k8s-node-2]
changed: [k8s-node-1]

TASK [Adding Kubernetes repository] **************************************************************************
changed: [k8s-node-2]
changed: [k8s-master]
changed: [k8s-node-1]

TASK [Setting kubernetes_packages fact] **********************************************************************
ok: [k8s-master]
ok: [k8s-node-1]
ok: [k8s-node-2]

TASK [Installing kubeadm kubelet and kubectl] ****************************************************************
changed: [k8s-node-2]
changed: [k8s-master]
changed: [k8s-node-1]

TASK [Issuing apt-mark hold on kubeadm kubelet and kubectl] **************************************************
changed: [k8s-master] => (item=Holding kubelet package)
changed: [k8s-node-2] => (item=Holding kubelet package)
changed: [k8s-node-1] => (item=Holding kubelet package)
changed: [k8s-node-2] => (item=Holding kubeadm package)
changed: [k8s-master] => (item=Holding kubeadm package)
changed: [k8s-node-1] => (item=Holding kubeadm package)
changed: [k8s-node-2] => (item=Holding kubectl package)
changed: [k8s-master] => (item=Holding kubectl package)
changed: [k8s-node-1] => (item=Holding kubectl package)

TASK [Creating /etc/sysctl.d/kubernetes.conf] ****************************************************************
changed: [k8s-master]
changed: [k8s-node-2]
changed: [k8s-node-1]

RUNNING HANDLER [Reload sysctl] ******************************************************************************
ok: [k8s-node-2]
ok: [k8s-master]
ok: [k8s-node-1]

PLAY [Configure the master] **********************************************************************************

TASK [Creating /etc/default/kubelet] *************************************************************************
changed: [k8s-master]

TASK [Flushing handlers now to create /etc/systemd/system/kubelet.service.d/10-kubeadm.conf] *****************

RUNNING HANDLER [Restart kubelet] ****************************************************************************
changed: [k8s-master]

TASK [Saving the master hostname from the inventory] *********************************************************
ok: [k8s-master]

TASK [Who's da master?] **************************************************************************************
ok: [k8s-master] =>
  msg: The master is 192.168.56.10

TASK [Initializing the cluster via kubeadmin (this may take some time)] **************************************
changed: [k8s-master]

TASK [Displaying kubeadm init output] ************************************************************************
ok: [k8s-master] =>
  msg: |-
    [init] Using Kubernetes version: v1.30.1
    [preflight] Running pre-flight checks
    [preflight] Pulling images required for setting up a Kubernetes cluster
    [preflight] This might take a minute or two, depending on the speed of your internet connection
    [preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
    [certs] Using certificateDir folder "/etc/kubernetes/pki"
    [certs] Generating "ca" certificate and key
    [certs] Generating "apiserver" certificate and key
    [certs] apiserver serving cert is signed for DNS names [k8s-master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.56.10]
    [certs] Generating "apiserver-kubelet-client" certificate and key
    [certs] Generating "front-proxy-ca" certificate and key
    [certs] Generating "front-proxy-client" certificate and key
    [certs] Generating "etcd/ca" certificate and key
    [certs] Generating "etcd/server" certificate and key
    [certs] etcd/server serving cert is signed for DNS names [k8s-master localhost] and IPs [192.168.56.10 127.0.0.1 ::1]
    [certs] Generating "etcd/peer" certificate and key
    [certs] etcd/peer serving cert is signed for DNS names [k8s-master localhost] and IPs [192.168.56.10 127.0.0.1 ::1]
    [certs] Generating "etcd/healthcheck-client" certificate and key
    [certs] Generating "apiserver-etcd-client" certificate and key
    [certs] Generating "sa" key and public key
    [kubeconfig] Using kubeconfig folder "/etc/kubernetes"
    [kubeconfig] Writing "admin.conf" kubeconfig file
    [kubeconfig] Writing "super-admin.conf" kubeconfig file
    [kubeconfig] Writing "kubelet.conf" kubeconfig file
    [kubeconfig] Writing "controller-manager.conf" kubeconfig file
    [kubeconfig] Writing "scheduler.conf" kubeconfig file
    [etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
    [control-plane] Using manifest folder "/etc/kubernetes/manifests"
    [control-plane] Creating static Pod manifest for "kube-apiserver"
    [control-plane] Creating static Pod manifest for "kube-controller-manager"
    [control-plane] Creating static Pod manifest for "kube-scheduler"
    [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
    [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
    [kubelet-start] Starting the kubelet
    [wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests"
    [kubelet-check] Waiting for a healthy kubelet. This can take up to 4m0s
    [kubelet-check] The kubelet is healthy after 1.502513892s
    [api-check] Waiting for a healthy API server. This can take up to 4m0s
    [api-check] The API server is healthy after 18.502948286s
    [upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
    [kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
    [upload-certs] Skipping phase. Please see --upload-certs
    [mark-control-plane] Marking the node k8s-master as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
    [mark-control-plane] Marking the node k8s-master as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]
    [bootstrap-token] Using token: eqzxpx.gkcl0r9glcqwedfs
    [bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
    [bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
    [bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
    [bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
    [bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
    [bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
    [kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
    [addons] Applied essential addon: CoreDNS
    [addons] Applied essential addon: kube-proxy

    Your Kubernetes control-plane has initialized successfully!

    To start using your cluster, you need to run the following as a regular user:

      mkdir -p $HOME/.kube
      sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
      sudo chown $(id -u):$(id -g) $HOME/.kube/config

    Alternatively, if you are the root user, you can run:

      export KUBECONFIG=/etc/kubernetes/admin.conf

    You should now deploy a pod network to the cluster.
    Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
      https://kubernetes.io/docs/concepts/cluster-administration/addons/

    You can now join any number of control-plane nodes by copying certificate authorities
    and service account keys on each node and then running the following as root:

      kubeadm join 192.168.56.10:6443 --token eqzxpx.gkcl0r9glcqwedfs \
            --discovery-token-ca-cert-hash sha256:ab9a0cca95f00c410046ae7468b1839d4e18ce5c5616a946b2af09eab0495b3e \
            --control-plane

    Then you can join any number of worker nodes by running the following on each as root:

    kubeadm join 192.168.56.10:6443 --token eqzxpx.gkcl0r9glcqwedfs \
            --discovery-token-ca-cert-hash sha256:ab9a0cca95f00c410046ae7468b1839d4e18ce5c5616a946b2af09eab0495b3e

TASK [Creating $HOME/.kube] **********************************************************************************
changed: [k8s-master]

TASK [Creating $HOME/.kube admin.conf] ***********************************************************************
changed: [k8s-master]

TASK [Installing the Cilium CLI] *****************************************************************************
changed: [k8s-master]

TASK [Displaying cilium cli install output] ******************************************************************
ok: [k8s-master] =>
  msg: |-
    cilium-linux-amd64.tar.gz: OK
    cilium

TASK [Installing Cilium] *************************************************************************************
changed: [k8s-master]

TASK [Getting cluster status] ********************************************************************************
ok: [k8s-master]

TASK [Displaying cluster info] *******************************************************************************
ok: [k8s-master] =>
  msg: |-
    [0;32mKubernetes control plane[0m is running at [0;33mhttps://192.168.56.10:6443[0m
    [0;32mCoreDNS[0m is running at [0;33mhttps://192.168.56.10:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy[0m

    To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
    NAME         STATUS     ROLES           AGE   VERSION
    k8s-master   NotReady   control-plane   12s   v1.30.1

PLAY [Configure the nodes] ***********************************************************************************

TASK [Retrieving master name and ip from inventory] **********************************************************
ok: [k8s-node-1 -> localhost]

TASK [Retrieving the join command] ***************************************************************************
ok: [k8s-node-1 -> k8s-master(192.168.56.10)]

TASK [Saving the tokens] *************************************************************************************
ok: [k8s-node-1]

TASK [Disabling apparmor service] ****************************************************************************
changed: [k8s-node-2]
changed: [k8s-node-1]

TASK [Joining nodes to cluster] ******************************************************************************
changed: [k8s-node-2]
changed: [k8s-node-1]

TASK [Displaying node status] ********************************************************************************
ok: [k8s-node-1] =>
  msg: |-
    [preflight] Running pre-flight checks
    [preflight] Reading configuration from the cluster...
    [preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
    [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
    [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
    [kubelet-start] Starting the kubelet
    [kubelet-check] Waiting for a healthy kubelet. This can take up to 4m0s
    [kubelet-check] The kubelet is healthy after 1.503584949s
    [kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap

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
    [kubelet-check] Waiting for a healthy kubelet. This can take up to 4m0s
    [kubelet-check] The kubelet is healthy after 1.003133346s
    [kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap

    This node has joined the cluster:
    * Certificate signing request was sent to apiserver and a response was received.
    * The Kubelet was informed of the new secure connection details.

    Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

PLAY RECAP ***************************************************************************************************
k8s-master                 : ok=39   changed=22   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
k8s-node-1                 : ok=32   changed=17   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
k8s-node-2                 : ok=29   changed=17   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

</details>

[modeline]: # ( vim: set number textwidth=78 colorcolumn=80 foldcolumn=2  nowrap: )
