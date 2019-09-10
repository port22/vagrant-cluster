sed -i 's/enforcing/permissive/g' /etc/selinux/config
setenforce 0

cat > /etc/yum.repos.d/mysql.repo <<EOF
[mysql-tools-community]
name=MySQL Tools Community
baseurl=http://repo.mysql.com/yum/mysql-tools-community/el/7/x86_64/
enabled=1
gpgcheck=0
[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/x86_64/
enabled=1
gpgcheck=0
EOF
yum clean all ; yum makecache fast
yum -y install mysql-shell mysql-router mysql-community-server mysql-community-libs
mkdir -p /var/log/mysql /var/lib/mysql/{data,binlog,relaylog,tmp}
chown -R mysql:mysql /var/lib/mysql /var/log/mysql

cat >>/etc/security/limits.conf <<EOF
* soft nofile 65534
* hard nofile 65534
EOF

curl -o /etc/my.cnf https://raw.githubusercontent.com/port22/vagrant-cluster/master/my.cnf
echo "server-id = ${HOSTNAME#inno}" >> /etc/my.cnf

case $HOSTNAME in
  inno1)
    echo 'report_host = "33.33.33.11"' >> /etc/my.cnf
    echo 'loose-group_replication_group_seeds = "33.33.33.13:13306,33.33.33.12:13306"' >> /etc/my.cnf
  ;;
  inno2)
    echo 'report_host = "33.33.33.12"' >> /etc/my.cnf
    echo 'loose-group_replication_group_seeds = "33.33.33.11:13306,33.33.33.13:13306"' >> /etc/my.cnf
  ;;
  inno3)
    echo 'report_host = "33.33.33.13"' >> /etc/my.cnf
    echo 'loose-group_replication_group_seeds = "33.33.33.11:13306,33.33.33.12:13306"' >> /etc/my.cnf
  ;;
esac
systemctl enable mysqld
systemctl start mysqld ; sleep 5

tmppw=$(grep "temporary password" /var/log/mysql/error.log|rev|cut -f1 -d' '|rev)
mysql --connect-expired-password -uroot -p${tmppw} -N -B -e "\
  ALTER USER 'root'@'localhost' IDENTIFIED BY 'InNo101_##'; \
  GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'InNo101_##'; \
  GRANT ALL PRIVILEGES ON mysql_innodb_cluster_metadata.* TO root@'%' WITH GRANT OPTION; \
  GRANT RELOAD, SHUTDOWN, PROCESS, FILE, SUPER, REPLICATION SLAVE, REPLICATION CLIENT, CREATE USER ON *.* TO root@'%' WITH GRANT OPTION; \
  GRANT SELECT ON *.* TO root@'%' WITH GRANT OPTION; \
  FLUSH PRIVILEGES; RESET MASTER; "

cat > /root/.my.cnf <<EOF
[client]
password='InNo101_##'
EOF

echo "sudo -i" >>/home/vagrant/.bashrc
