#!/bin/bash

mkdir -p /etc/corosync
cat > /etc/corosync/corosync.conf <<EOF
totem {
    version: 2
    cluster_name: hacluster
    secauth: off
    transport: udpu
}

nodelist {
    node {
        ring0_addr: pcs1
        nodeid: 1
    }
    node {
        ring0_addr: pcs2
        nodeid: 2
    }
    node {
        ring0_addr: pcs3
        nodeid: 3
    }
}

quorum {
    provider: corosync_votequorum
}

logging {
    to_logfile: yes
    logfile: /var/log/corosync.log
    to_syslog: yes
}
EOF

yum install -y pacemaker pcs
systemctl enable pcsd --now
systemctl enable corosync --now
systemctl enable pacemaker --now

clusterpw=pacemaker
echo -n "hacluster:$clusterpw" | chpasswd

case $HOSTNAME in pcs3)
  pcs cluster auth -u hacluster -p $clusterpw --force pcs1 pcs2 pcs3
  pcs cluster setup --name cluster --force pcs1 pcs2 pcs3
  pcs cluster start --all
  pcs cluster enable --all
  pcs property set stonith-enabled=false
  pcs property set no-quorum-policy=ignore
  pcs resource create vip ocf:heartbeat:IPaddr2 ip=11.11.11.111 cidr_netmask=32 op monitor interval=1s
;; esac