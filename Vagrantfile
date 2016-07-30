VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.define "kuber-master" do |master|
    master.vm.box = "fedora/23-cloud-base"
    master.vm.network "private_network", ip: "192.168.50.130"
    master.ssh.insert_key = false
    master.vm.hostname = "kuber-master"
  end
  config.vm.define "kuber-slave" do |slave|
    slave.vm.box = "fedora/23-cloud-base"
    slave.vm.network "private_network", ip: "192.168.50.131"
    slave.ssh.insert_key = false
    slave.vm.hostname = "kuber-slave"
  end
end
