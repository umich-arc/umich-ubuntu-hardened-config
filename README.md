# University of Michigan Hardened Ubuntu Configuration

## About
This repository contains necessary configurations to create a secured Ubuntu image for use as a server or a workstation.

## How to use

1. Remove outdated package
```
sudo -i apt-get update apt-get autoremove apt-get clean UNUSCONF=$(dpkg -l|grep "^rc"|awk '{print $2}') apt-get remove --purge $UNUSCONF NEWKERNEL=$(uname -r|sed 's/-*[a-z]//g'|sed 's/-386//g') ADDKERNEL="linux-(image|headers|ubuntu-modules|restricted-modules)" METAKERNEL="linux-(image|headers|restricted-modules)-(generic|i386|server|common|rt|xen)" UNUSKERNELS=$(dpkg -l|awk '{print $2}'|grep -E $ADDKERNEL |grep -vE $METAKERNEL|grep -v $NEWKERNEL) apt-get remove --purge $UNUSKERNELS update-grub
```

2. Remove outdated appstream for GUI desktop install from Xubuntu
```
apt-get remove appstream
apt-get purge
rm /var/crash/*
#Add appstream
apt-get update 
apt-get install appstream/xenial-backports
apt-get install gnome-software
```

3. Run updates
```
sudo apt-get update
sudo apt-get dist-upgrade
```

4. Install OpenSSH-Server
```
sudo apt-get install openssh-server
```

5. Install SSH Keys
```
ssh-keygen -t rsa -b 2048
```

6. Download and run CIS-CAT Scan Script
```
sudo apt-get install default-jdk
sudo apt-get install unzip
wget <<URL_TO_CIS-CAT_TOOL>>
Unzip <<file>>.zip
cd cis-cat-full/
sudo bash CIS-CAT.sh
```

7. Download and run Remediation script, then reboot
```
wget <<URL_TO_REMEDIATION_SCRIPT>>
sudo bash CIS_Debian_Linux_8_Benchmark_v1.0.0-shell.sh
sudo reboot
```
8. Re-run CIS-CAT Scan script
```
sudo bash cis-cat-full/CIS-CAT.sh
```

9. Install python 2.7
```
sudo apt-get install build-essential
```

10. Install latest version of ansible (uses Ansible Inc’s PPA)
```
sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible
sudo apt-get install git
```

11. Run Ansible CIS Hardening
Create `requirements.yml`:
```
- src: https://github.com/florianutz/Ubuntu1604-CIS.git
```

12. Pull down playbook info from Ansible Galaxy
```
ansible-galaxy install -p roles -r requirements.yml
```

13. Create playbook to call ansible role:
```
- name: Harden Server
  remote_user: ubuntu
  hosts: all
  become: true

  roles:
    - Ubuntu1604-CIS
```

14. Edit tasks/section6.yml to set shadow & gshadow group to shadow instead of root

15. Edit section for sudoers file, comment out (6.2.6)
```
sudo nano /etc/sudoers
```

16. Run the playbook
```
ansible-playbook -K -i localhost, --key-file <<path to ssh key>> <<path to playbook.yml>>
```

17. Configure NTP
```
sudo apt-get install ntp
sudo nano /etc/ntp.conf
  #add pool ntp.itd.umich.edu to the top of the NTP pool list
sudo service ntp restart
```

18. Install UFW and apply UM firewall rules
Download setup_firewall from https://sites.google.com/a/umich.edu/engin-infosec/home/tools-docs
```
apt-get install ufw
wget https://github.com/arc-ts/umich-ubuntu-hardened-config/blob/master/scripts/setup_firewall.sh
sudo bash ./setup_firewall
```

19. Disable root login via SSH
```
sudo nano /etc/ssh/sshd_config
```
locate and verify that PermitRootLogin no
```  
service sshd stop
service sshd start
```

20. Configure SSH Banner Referencing SPG 601.07
```
export DEPT_NAME=”Your Department”
cat <<__EOT__ > /etc/issue.net
******************************************************************************************
* This is $DEPT_NAME at the University of Michigan.
* You must be authorized to use these resources. Unauthorized or criminal use
* is prohibited. By your use of these resources, you agree to abide by
* "Responsible Use of Information Resources (SPG 601.07),"in addition to all
* relevant state and federal laws.
* http://spg.umich.edu/policy/601.07
******************************************************************************************
__EOT__su
```

21. Edit /etc/ssh/sshd_config and uncomment the line that says #Banner /etc/issue.net
```
sudo /etc/ssh/sshd_config
sudo service ssh reload
```

22. Create Service Account on Xubuntu machine
```
sudo adduser -u [uid# < 1000] <managementuser>
```
23. Generate ssh key on management machine for that user
```
ssh-keygen -t rsa -b 4096
```
24. Copy Public Key over
```
scp ~/.ssh/id_rsa.pub <managementuser>@<host>:~/.ssh/authorized_keys
```
25. Edit public key on Xubuntu machine to restrict to specific IP(s)
`vi ~/.ssh/authorized_keys`
	prepend (e.g.) 
	`from="127.0.0.1,127.0.0.2"`
	before the key

26. Restrict SSH to only allow for key access to `<managementuser>`
```
sudo vi /etc/ssh/sshd_config
	#Add a lines similar to
	Match User <managementuser>
		PasswordAuthentication no
 ```
27. Allow Management User to run sudo w/o password
```
	if grep <managementuser> /etc/sudoers > /dev/null
then
    echo "Account already in file:"
    echo "`grep <managementuser> /etc/sudoers`"
else
    cat "<managementuser> ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
fi
```
## To-Do List
* Create preseed file
