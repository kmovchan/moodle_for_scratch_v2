#!/bin/bash -eux

#sudo apt-get -y install software-properties-common
#sudo apt-add-repository ppa:ansible/ansible

sudo apt-get -y update
#sudo apt-get -y install ansible

sudo mv /tmp/vpl-jail-system /opt/vpl-jail-system
sudo cp /tmp/aws-test.pub /home/ubuntu/.ssh/authorized_keys
sudo chmod 600 /home/ubuntu/.ssh/authorized_keys
sudo chown -R ubuntu /home/ubuntu/.ssh
#echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
