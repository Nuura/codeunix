# Customer's name
client_name="user"

# Customer's mail address
customer_mail="v.tarlowski@gmail.com"

# Installing packages
echo "Installation des packages"
apt-get -y install ssh sudo vim rsync wget fail2ban 1> /dev/null

# Changing root's password
root_pass=$(date +%s | sha256sum | head -c 32 | tail -c 10)
passwd root $root_pass

# ----------------------------------------- #
# Changing to static IP adress - 172.16.2.* #
# ----------------------------------------- #
#echo "auto eth0
#iface eth0 inet dhcp" >> /etc/network/interfaces;
#/etc/init.d/networking restart
ip_address=$(cat ip)
#ip_address=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
echo "# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth2
iface eth2 inet dhcp
auto eth0
iface eth0 inet static
     address $ip_address
     netmask 255.255.255.0
     network 172.16.2.0
     broadcast 172.16.2.255
     gateway 172.16.2.254" > /etc/network/interfaces
/etc/init.d/networking restart
# ----------------------------------------- #

# User creation
pass=$(date +%s | sha256sum | base64 | head -c 32 | tail -c 10)
useradd -m $client_name
echo "$client_name:$pass" | chpasswd
echo "pass = $pass
user = $client_name"

# SSH - Public keys configuration
echo "SSH-key..."

ssh_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCWKB5iVi5l+LOTpKhb/8gqdPcAY7TCb27igZybUwzaVM0ajJsfbBZ8ECX5fo94kyqcPy+ULeIHgTkta8DARvm52NN3OT9tNSpxIXnnyTfGkjnpl8mw+qmmpBxxc/ADE4STEZ9m2sEjlNgHTvWVRKExSWfP+WefKlrJT7cRL9aXZGxVsuE66IIQQzgtSXT51oSgUX9t2MCRHlY5h38L9SPHEqZqbrXe0QgUfTOJvQh/1U/SGFiHL/tm+N7kZvyz5fwg7cY85npSUkJjqdyxPR2QM0Qq7jeHajryeAeVZDt3FWK/iDK16VbydVNzZoLyiKyH+hmvEAuPhkWVwY7ofR0N root@bad"

mkdir /home/$client_name/.ssh
touch /home/$client_name/.ssh/authorized_keys
echo $ssh_key > /home/$client_name/.ssh/authorized_keys

echo "Added correctly."


#adresse mac
echo "Hostname configuration.."
addr=$(ifconfig | grep -i HWaddr | tail -c 8)
addr_n=${addr:0:2}${addr:3:2}
hostname_new=vps-$addr_n
echo $hostname_new > /etc/hostname
hosts_file=$(cat /etc/hosts)
hosts_file=${hosts_file/debian/$hostname_new}
echo $hosts_file > /etc/hosts
echo "Done."

###@ sudo
echo -e "user    ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo "User added to sudoers file."

#### prompt
echo "prompt is modifyng..."
prompt='export PS1="\[\033[38;5;28m\]\u\[$(tput sgr0)\]\[\033[38;5;7m\]:\[$(tput sgr0)\]\[\033[38;5;39m\]\h\[$(tput sgr0)\]\[\033[38;5;7m\]-\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;39m\]\W\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;7m\]]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;7m\]\A\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;214m\]>\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"'

echo $prompt >> /etc/skel/.bashrc
echo $prompt >> /etc/bash.bashrc

#MOTD
echo "MOTD download..."
apt-get -y install linuxlogo 1> /dev/null
mv /etc/motd /etc/motd.old
rm /etc/motd.old
linuxlogo -L 16 -f -u -y > /etc/motd
echo "Done."


#mail
touch ~/.mail.txt~
mac_adress=$(ifconfig | grep -i HWaddr | tail -c 20)

echo "To: $customer_mail
Subject: Information about your Debian Server
From: assistancePXE@gmail.com

Hello,

You can read below the informations of your new Debian Server:
- adress MAC = $mac_address
- login = $client_name
- password = $pass
- Root password = $root_pass
Thanks for using our service." > ~/.mail.txt~

sendmail -vt < ~/.mail.txt~
