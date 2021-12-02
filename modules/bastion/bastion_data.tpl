#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
ip_node01="${ip_node01}"
ip_node02="${ip_node02}"
echo "$ip_node01 node01"  >> /etc/hosts;
echo "$ip_node02 node02"  >> /etc/hosts;
echo [gluster]  >> /home/ubuntu/hosts;
echo "$ip_node01"  >> /home/ubuntu/hosts;
echo "$ip_node02"  >> /home/ubuntu/hosts;
sudo apt-get update
sudo apt-get install -y git ansible mysql-client

mkdir /home/ubuntu/roles
sudo ansible-galaxy install geerlingguy.glusterfs --roles-path=/home/ubuntu/roles
cat <<EOF > /home/ubuntu/gluster.sh
#!/bin/bash
export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -u ubuntu --private-key /home/ubuntu/aws-test.pem  -i /home/ubuntu/hosts /home/ubuntu/gluster.yml --extra-vars "ip_node=${ip_node01}"
EOF
chmod +x /home/ubuntu/gluster.sh
sudo /home/ubuntu/gluster.sh
