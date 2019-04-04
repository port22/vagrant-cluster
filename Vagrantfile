$provision = <<ENDOFSCRIPT
#yum -y update
yum makecache fast
yum -y install epel-release
#yum -y install http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

# docker
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y install docker-ce
sudo systemctl start docker
sudo systemctl enable docker

case $HOSTNAME in
 c1) true
  docker swarm init --advertise-addr 11.11.11.11
 ;;
esac
ENDOFSCRIPT

Vagrant.configure(2) do |config|
    config.vm.define "c1" do |c1|
        c1.vm.box = "centos/7"
        c1.vm.hostname = "c1"
        c1.vm.network "private_network", ip: "11.11.11.11"

        c1.vm.provider :virtualbox do |c1|
            c1.customize ["modifyvm", :id, "--memory", "1024"]
            c1.customize ["modifyvm", :id, "--cpus", "1"]
            c1.customize ["modifyvm", :id, "--name", "c1"]
    
#           c1.customize ['storagectl', :id, '--name', 'scsi', '--add', 'scsi', '--controller', 'LSILogic']
#           c1.customize ['createhd', '--filename', "1.vdi", '--variant', 'Standard', '--size', 8000]
#           c1.customize ['storageattach', :id,  '--storagectl', 'scsi', '--port', 0, '--device', 0, '--type', 'hdd', '--medium', "1.vdi"]
        end
    end

    config.vm.define "c2" do |c2|
        c2.vm.box = "centos/7"
        c2.vm.hostname = "c2"
        c2.vm.network "private_network", ip: "11.11.11.12"

        config.vm.provider :virtualbox do |c2|
            c2.customize ["modifyvm", :id, "--memory", "1024"]
            c2.customize ["modifyvm", :id, "--cpus", "1"]
            c2.customize ["modifyvm", :id, "--name", "c2"]

#            c2.customize ['storagectl', :id, '--name', 'scsi', '--add', 'scsi', '--controller', 'LSILogic']
#            c2.customize ['createhd', '--filename', "2.vdi", '--variant', 'Standard', '--size', 8000]
#            c2.customize ['storageattach', :id,  '--storagectl', 'scsi', '--port', 0, '--device', 0, '--type', 'hdd', '--medium', "2.vdi"]
        end
    end

    config.vm.define "c3" do |c3|
        c3.vm.box = "centos/7"
        c3.vm.hostname = "c3"
        c3.vm.network "private_network", ip: "11.11.11.13"

        config.vm.provider :virtualbox do |c3|
            c3.customize ["modifyvm", :id, "--memory", "1024"]
            c3.customize ["modifyvm", :id, "--cpus", "1"]
            c3.customize ["modifyvm", :id, "--name", "c3"]

#            c3.customize ['storagectl', :id, '--name', 'scsi', '--add', 'scsi', '--controller', 'LSILogic']
#            c3.customize ['createhd', '--filename', "3.vdi", '--variant', 'Standard', '--size', 8000]
#            c3.customize ['storageattach', :id,  '--storagectl', 'scsi', '--port', 0, '--device', 0, '--type', 'hdd', '--medium', "3.vdi"]
        end
    end

    config.vm.provision "shell", run: "once", inline: $provision
end
