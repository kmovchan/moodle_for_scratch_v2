#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

ip_node01="${ip_node01}"
ip_node02="${ip_node02}"
echo "$ip_node01 node01"  >> /etc/hosts;
echo "$ip_node02 node02"  >> /etc/hosts;


###### Mount EFS
if [ ! -d /mnt/efs ]; then
  mkdir /mnt/efs
fi

cat /var/www/html/moodle/config.php | sed -e  "s|^\$CFG->dbhost.*|\$CFG->dbhost    = '${db_host}';|" -e "s|^\$CFG->dbpass.*|\$CFG->dbpass    = '${db_password}';|" -e "s|^\$CFG->wwwroot.*|\$CFG->wwwroot   = 'http://${wwwroot}';|" -e "s|^\$CFG->dataroot.*|\$CFG->dataroot  = '${dataroot}';|" -e "s|^\$CFG->session_redis_host.*|\$CFG->session_redis_host  = '${redis}';|" > /var/www/html/moodle/config2.php
cp /var/www/html/moodle/config2.php /var/www/html/moodle/config.php
chown www-data:www-data /var/www/html/moodle/config.php

####GlusterFS
mount -t glusterfs node01:/vol_replica /mnt/efs -o backupvolfile-server=node02

if [ ! -d /mnt/efs/html ]; then
  mkdir /mnt/efs/html
fi

#### Moving Moodledate to efs storage
if [ -d /var/www/html/moodledata ]; then
   mv /var/www/html/moodledata /mnt/efs/html
fi