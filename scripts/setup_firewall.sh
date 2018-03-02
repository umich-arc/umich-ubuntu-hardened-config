#!/bin/bash
#
# This script installs and sets up UFW for an Ubuntu or RHEL system
# NOTE - this script will not function on rhel7 due to the new firewalld daemon
#
# Get the system type
#
if [ -f /etc/debian_version ]; then
echo ‘This is an Ubuntu machine.’;
SYSTEM=ubuntu;
elif [ -f /etc/redhat-release ]; then
echo ‘This is a RHEL machine.’;
SYSTEM=rhel;
else
echo ‘Unrecognized system. Exiting script.’
exit;
fi

#
# Install UFW
#

# If your system is ubuntu, use apt-get to install uncomplicated firewall
if [ $SYSTEM = "ubuntu" ]; then
apt-get install ufw

# For RHEL, you have to install from source
elif [ $SYSTEM = "rhel" ]; then

# Make sure the service is not installed yet
if [ -d /lib/ufw ]; then
echo ‘UFW already installed. Setting up rules.’;

else
echo ‘UFW is not installed yet. Installing’;

# first make sure iptables is installed
yum install iptables;

# get latest version at https://launchpad.net/ufw
wget https://launchpad.net/ufw/0.33/0.33/+download/ufw-0.33.tar.gz

# extract and go to directory
tar -xvf ufw*.tar.gz;
cd ufw*;

# Install
python ./setup.py install;

# add UFW to the boot sequence
cp ./doc/initscript.example /etc/init.d/ufw;
chown root:root /etc/init.d/ufw;
chmod 755 /etc/init.d/ufw ;
ufw enable

# Clean
rm -rf ufw*.tar.gz;

fi
fi

# Setup UFW default rules
ufw default deny incoming
ufw default allow outgoing

#################################################################
# Keep in mind that any application listed below can be         #
# allowed by removing the '#' in front of the desired           #
# service. However, be advised that the application specific    #
# firewall rules open the application up to the entire Internet.#
#################################################################

# Add application specific firewall rules
#ufw allow sshd
#ufw allow www
#ufw allow http
#ufw allow https

#################################################################################################
# The list of networks below is taken from # http://www.itcom.itd.umich.edu/backbone/umnet/     #
#                                                                                               #
# Allow UM-specific IPv4 and IPv6 networks to ANY port or application on your system.           #
#################################################################################################

# IPv4
#ufw allow from 35.0.0.0/16;      # UM-Ann Arbor (Guest wired and wireless)
#ufw allow from 35.1.0.0/16;      # UM-Ann Arbor (UMnet Authenticated Wireless)
#ufw allow from 35.2.0.0/16;      # UM-Ann Arbor (UMnet Authenticated Wireless)
#ufw allow from 67.194.0.0/16;    # UM-Ann Arbor (UMnet and Residence Halls)
ufw allow from 141.211.0.0/16;   # UM-Ann Arbor (UMnet)
ufw allow from 141.212.0.0/16;   # UM-Ann Arbor (CoE)
ufw allow from 141.213.0.0/16;   # UM-Ann Arbor (CoE)
#ufw allow from 141.213.128.0/17; # UM-Ann Arbor (UMnet)
ufw allow from 141.214.0.0/16;   # UM-Ann Arbor (UMHS)
#ufw allow from 141.215.0.0/16;   # UM-Dearborn
#ufw allow from 141.216.0.0/16;   # UM-Flint
ufw allow from 192.12.80.0/24;   # U-M Backbone Interconnect (UMBIN - interconnects UMnet, UMHS, CoE, UM-Dearborn and Merit)
ufw allow from 192.231.253.0/24; # UM-Ann Arbor (UMnet NOC)
ufw allow from 198.108.8.0/21;   # UM-Ann Arbor (IP Telephony and Network Infrastructure)
#ufw allow from 198.108.200.0/22; # U-M Biological Station (Pellston, MI)
#ufw allow from 198.110.84.0/24;  # U-M Biological Station (Pellston, MI)
ufw allow from 198.111.224.0/22; # UM-Ann Arbor (ITS Comm Interoperability Lab)
ufw allow from 198.111.181.0/25; # UM-Ann Arbor (UMHS public-facing servers)
ufw allow from 207.75.144.0/20;  # UM-Ann Arbor (UMnet WAN-connected off-campus networks)

#IPv6
ufw allow from 2607:F018::/32      #UM-Ann Arbor
ufw allow from 2607:F018::/33      #UMnet Backbone
ufw allow from 2607:F018:8000::/34 #CoE Backbone
ufw allow from 2607:F018:C000::/35 #UMHS Backbone
ufw allow from 2607:F018:E000::/36 #Reserved/Special
ufw allow from 2607:F018:FFFE::/48 #ITS Comm Interoperability Lab
ufw allow from 2607:F018:FFFF::/48 #UMBIN

# Enable firewall logging
ufw logging on

# Turn on the firewall
ufw enable
