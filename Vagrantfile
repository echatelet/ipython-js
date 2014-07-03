Vagrant::Config.run do |config|

  # Use the precise32 box
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  # Uncomment the following line to allow for symlinks
  # in the app folder. This will not work on Windows, and will
  # not work with Vagrant providers other than VirtualBox
  config.vm.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/app", "1"]
  config.vm.customize ["modifyvm", :id, "--memory", 2048]

  # Install dependencies
  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "nodejs"
    chef.json = {
      "nodejs" => {
        "version" => "0.10.22"
        # uncomment the following line to force
	# recent versions (> 0.8.5) to be built from
	# the source code
	# , "from_source" => true
      }
    }
  end

  config.vm.provision :shell, :inline => "sudo apt-get install -y build-essential --no-install-recommends"
  config.vm.provision :shell, :inline => "sudo apt-get update --fix-missing"
  config.vm.provision :shell, :inline => "sudo apt-get install -y ruby1.9.1-dev --no-install-recommends"
  config.vm.provision :shell, :inline => "sudo apt-get install -y ruby1.9.3 --no-install-recommends"
  config.vm.provision :shell, :inline => "sudo gem install cf"
end
