## This provision is for lab-testing a pre-provisioned two-node drbd cluster
##### (without corosync/pacemaker)

Suitable for testing administrative purposes like online resizing.
Both nodes having two additional 7G disks attached, while only 5G is allocated via LVM

```
vagrant up
vagrant ssh pcs1 -c 'sudo su -'
vagrant ssh pcs2 -c 'sudo su -'
```

#### How to resize a DRBD volume online (r0 must be in Connected state)

###### on both nodes with before/after check:
```
drbdadm status
vgs --noheadings drbd ; lvs --noheadings drbd
lvresize -l +100%FREE /dev/drbd/data
vgs --noheadings drbd ; lvs --noheadings drbd
```
###### on primary node, check if synced and Connected:
```
cat /proc/drbd
drbdadm status
```
###### 1) resize drbd backing device and watch the syncing
###### on secondary:
```
while true; do drbdadm status; done
```
###### on primary:
```
drbdadm resize r0 ; watch cat /proc/drbd
```
###### 2) resize drbd backing device and watch the syncing
###### on primary:
```
umount /mnt || umount -lf /mnt ; sleep 3
e2fsck -f /dev/drbd1
resize2fs /dev/drbd1
```

#### Manual switch of primary (what's usually done by corosync):

###### on primary, now becomes secondary:
```
umount /mnt || umount -lf /mnt ; sleep 3
drbdadm secondary r0
```
###### on secondary, now becomes primary:
```
drbdadm primary r0
mount /dev/drbd1 /mnt
```
