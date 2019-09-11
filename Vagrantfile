$provision = <<END
sed -i "/^127.0.0.1.*$HOSTNAME/d" /etc/hosts
for i in 1 2 3; do echo "11.11.11.1$i pcs$i" >> /etc/hosts ; done

echo "sudo -i" > /home/vagrant/.bashrc
yum clean all && yum makecache fast 
#yum -y update
yum -y install epel-release

# Docker-CE with Swarm
#bash /vagrant/scripts/docker.sh

# Pacemaker
bash /vagrant/scripts/pacemaker.sh

# DRBD
#bash /vagrant/scripts/drbd.sh

END

Vagrant.configure(2) do |config|

  config.vm.provider "virtualbox" do |vb|
    vb.customize ['storagectl', :id, '--name', 'scsi', '--add', 'scsi', '--controller', 'LSILogic']
  end

  (1..3).each do |i|
    config.vm.define "pcs#{i}" do |pcs|
       pcs.vm.box = "centos/7"
       pcs.vm.hostname = "pcs#{i}"
       pcs.vm.network "private_network", ip: "11.11.11.1#{i}"

       pcs.vm.provider :virtualbox do |c|
         c.customize ["modifyvm", :id, "--memory", "2048"]
         c.customize ["modifyvm", :id, "--cpus", "2"]
         c.customize ["modifyvm", :id, "--name", "pcs#{i}"]

         disk = "pcs#{i}.vdi"
         unless File.exist?(disk)
           c.customize ['createhd', '--filename', "pcs#{i}.vdi", '--variant', 'Standard', '--size', 8000]
         end

         c.customize ['storageattach', :id, '--storagectl', 'scsi', '--port', 0, '--device', 0, '--type', 'hdd', '--medium', "pcs#{i}.vdi"]
       end
    end
  end       

  config.vm.provision "shell", run: "once", inline: $provision

end
