# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "preCICE"
  config.vm.box_check_update = false

  config.vm.provider "virtualbox" do |vb|
    # Name of the machine
    vb.name = "preCICE-VM"
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true
    # Number of cores
    vb.cpus = 2
    # Customize the amount of memory on the VM:
    vb.memory = "2048"
    # Video memory (the default may be too low for some applications)
    vb.customize ["modifyvm", :id, "--vram", "64"]
    # The default graphics controller is VboxSVGA. This seems to cause issues with auto-scaling.
    # VMSVGA seems to work better.
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
  end

  # The libvirt provider needs to be installed using "vagrant plugin install vagrant-libvirt"
  config.vm.provider :libvirt do |lv|
    lv.forward_ssh_port = true
    lv.title = "preCICE-VM"
    lv.cpus = 2
    lv.memory = 2048
  end
end
