#!/bin/bash

_install() {
yum -y install http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
yum -y install lvm2 kmod-drbd84 drbd84-utils
echo "drbd">>/etc/modules-load.d/drbd.conf
depmod -a && modprobe drbd

cat >/etc/drbd.d/r0.res <<EOF
resource r0 {
  device    /dev/drbd0;
  disk      /dev/mapper/drbd-data;
  meta-disk internal;
  on pcs1 { address 11.11.11.11:7789; }
  on pcs2 { address 11.11.11.12:7789; }
}
EOF

pvcreate /dev/sdb
vgcreate drbd /dev/sdb
lvcreate --name data --size 5G drbd

drbdadm create-md r0 && drbdadm up r0
}

case $HOSTNAME in 
  pcs1)
    _install 
    drbdadm primary --force r0
    mkfs.ext4 /dev/drbd0  
  ;;
  pcs2)
    _install
  ;;
esac
