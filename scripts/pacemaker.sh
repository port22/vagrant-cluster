#!/bin/bash

mkdir -p /etc/corosync
cp -Rfv /vagrant/scripts/corosync.conf /etc/corosync/corosync.conf

setenforce 0
sed -i 's/^SELINUX=/SELINUX=disabled/g' /etc/selinux/config

systemctl disable firewalld --now
systemctl stop firewalld 

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
