# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  #config.hostmanager.enabled = true 
  #config.hostmanager.manage_host = true
  
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.vm.define "postgre" do |postgre|
  	
	postgre.vm.box = "ubuntu/focal64"
  	postgre.vm.network "private_network", ip: "192.168.56.101"
  	postgre.vm.synced_folder ".", "/vagrant_data"
  	postgre.vm.provider "virtualbox" do |vb|
    		# Display the VirtualBox GUI when booting the machine
#    		vb.gui = true
  
    		# Customize the amount of memory on the VM:
		vb.memory = "2048"
  	end
	postgre.vm.provision "shell", path: "psql.sh"
  end
  config.vm.define "odoo" do |odoo|
  	
	odoo.vm.box = "ubuntu/focal64"
  	odoo.vm.network "private_network", ip: "192.168.56.100"
  	odoo.vm.synced_folder ".", "/vagrant_data"
  	odoo.vm.provider "virtualbox" do |vb|
    		# Display the VirtualBox GUI when booting the machine
#    		vb.gui = true
  
    		# Customize the amount of memory on the VM:
		vb.memory = "2048"
  	end
	odoo.vm.provision "shell", path: "odoo.sh"
  end
  config.vm.define "nginx" do |nginx|
  	
	nginx.vm.box = "ubuntu/focal64"
  	nginx.vm.network "private_network", ip: "192.168.56.102"
	nginx.vm.network "forwarded_port", guest: 80, host: 80
  	nginx.vm.synced_folder ".", "/vagrant_data"
  	nginx.vm.provider "virtualbox" do |vb|
    		# Display the VirtualBox GUI when booting the machine
#    		vb.gui = true
  
    		# Customize the amount of memory on the VM:
		vb.memory = "2048"
  	end
	nginx.vm.provision "shell", path: "nginx.sh"
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  

end
