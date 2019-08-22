$provision = <<ENDOFSCRIPT
echo "33.33.33.11 pcs1" >> /etc/hosts
echo "33.33.33.12 pcs2" >> /etc/hosts
echo "33.33.33.13 pcs3" >> /etc/hosts

yum -y update && yum makecache fast && yum -y install epel-release

# docker
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y install docker-ce && sudo systemctl enable docker --now
[[ $HOSTNAME = 'pcs1' ]] && docker swarm init --advertise-addr 33.33.33.11

ENDOFSCRIPT

Vagrant.configure(2) do |config|
    config.vm.define "pcs1" do |pcs1|
        pcs1.vm.box = "centos/7"
        pcs1.vm.hostname = "pcs1"
        pcs1.vm.network "private_network", ip: "33.33.33.11"

        pcs1.vm.provider :virtualbox do |pcs1|
            pcs1.customize ["modifyvm", :id, "--memory", "1024"]
            pcs1.customize ["modifyvm", :id, "--cpus", "1"]
            pcs1.customize ["modifyvm", :id, "--name", "pcs1"]

            pcs1.customize ['storagectl', :id, '--name', 'scsi', '--add', 'scsi', '--controller', 'LSILogic']
            pcs1.customize ['createhd', '--filename', "pcs1.vdi", '--variant', 'Standard', '--size', 8000]
            pcs1.customize ['storageattach', :id,  '--storagectl', 'scsi', '--port', 0, '--device', 0, '--type', 'hdd', '--medium', "pcs1.vdi"]
        end
    end

    config.vm.define "pcs2" do |pcs2|
        pcs2.vm.box = "centos/7"
        pcs2.vm.hostname = "pcs2"
        pcs2.vm.network "private_network", ip: "33.33.33.12"

        config.vm.provider :virtualbox do |pcs2|
            pcs2.customize ["modifyvm", :id, "--memory", "1024"]
            pcs2.customize ["modifyvm", :id, "--cpus", "1"]
            pcs2.customize ["modifyvm", :id, "--name", "pcs2"]
            
            pcs2.customize ['storagectl', :id, '--name', 'scsi', '--add', 'scsi', '--controller', 'LSILogic']
            pcs2.customize ['createhd', '--filename', "pcs2.vdi", '--variant', 'Standard', '--size', 8000]
            pcs2.customize ['storageattach', :id,  '--storagectl', 'scsi', '--port', 0, '--device', 0, '--type', 'hdd', '--medium', "pcs2.vdi"]
        end
    end

    config.vm.define "pcs3" do |pcs3|
        pcs3.vm.box = "centos/7"
        pcs3.vm.hostname = "pcs3"
        pcs3.vm.network "private_network", ip: "33.33.33.13"

        config.vm.provider :virtualbox do |pcs3|
            pcs3.customize ["modifyvm", :id, "--memory", "1024"]
            pcs3.customize ["modifyvm", :id, "--cpus", "1"]
            pcs3.customize ["modifyvm", :id, "--name", "pcs3"]

            pcs3.customize ['storagectl', :id, '--name', 'scsi', '--add', 'scsi', '--controller', 'LSILogic']
            pcs3.customize ['createhd', '--filename', "pcs3.vdi", '--variant', 'Standard', '--size', 8000]
            pcs3.customize ['storageattach', :id,  '--storagectl', 'scsi', '--port', 0, '--device', 0, '--type', 'hdd', '--medium', "pcs3.vdi"]
        end
    end

    config.vm.provision "shell", run: "once", inline: $provision
end
