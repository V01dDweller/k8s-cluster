#! /bin/env bash

# Vagrant can use this script to bootstrap each VM immediately after creation.
# However, since the virtual machines are created sequentially, this is
# inefficient. Instead, it is better to update the collection of VMs with an
# Ansible playbook.

set -Eeuo pipefail
apt update
apt -y upgrade
apt -y autoremove
