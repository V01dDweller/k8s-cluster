BOX_IMAGE="ubuntu/jammy64"
NODE_COUNT=2

Vagrant.configure("2") do |config|
  config.vm.define "k8s-master" do |subconfig|
    subconfig.vm.box = BOX_IMAGE
    subconfig.vbguest.auto_update = false
    subconfig.vm.hostname = "k8s-master"
    subconfig.vm.network "private_network", ip: "192.168.56.10"
  end

  (1..NODE_COUNT).each do |i|
    config.vm.define "k8s-node-#{i}" do |subconfig|
      subconfig.vm.box = BOX_IMAGE
      subconfig.vbguest.auto_update = false
      subconfig.vm.hostname = "k8s-node-#{i}"
      subconfig.vm.network "private_network", ip: "192.168.56.#{i + 10}"
    end
  end
  # config.vm.provision "shell", path: "bootstrap.sh"
  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = "2048"
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
    vb.customize ["modifyvm", :id, "--vram", 33]
  end
end
