#!/bin/bash

apt-get -y update 
apt-get install -y g++ make python-pexpect autotools-dev autoconf automake
mv /tmp/vpl-jail-system-2.7.1 /opt/vpl-jail-system-2.7.1
cd /opt/vpl-jail-system-2.7.1
autoreconf -ivf
#autoreconf -f -i
./install-vpl-sh
