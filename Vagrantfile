Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "centos/7"
  config.vm.provider "virtualbox" do |v|
	  v.memory = 1024
	  v.cpus = 2
  end
  #config.vm.synced_folder "./search_engine_env", "/usr/share/search_engine_env",create:true,owner: "vagrant", group: "vagrant", mount_options: ["dmode=770", "fmode=440"]
  config.vm.provision "shell", path: "./provision.sh"
end