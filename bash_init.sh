#nom du client
client_name="vk"

echo "Installation of the packages..."
apt-get -y install ssh sudo vim rsync wget fail2ban 1> /dev/null
echo "Done. "

#ssh config
echo "SSH-key..."
#mv id_rsa.pub /home/$client_name/.ssh/authorized_keys
echo " Added correctly."

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
echo "export PS1="\[\033[38;5;8m\][\[$(tput sgr0)\]\[\033[38;5;2m\]\u\[$(tput sgr0)\]\[\033[38;5;8m\]:\[$(tput sgr0)\]\[\033[38;5;117m\]\h\[$(tput sgr0)\]\[\033[38;5;8m\]-\[$(tput sgr0)\]\[\033[38;5;205m\]\W\[$(tput sgr0)\]\[\033[38;5;8m\]]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;7m\]\A\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;208m\]>\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"" >> /home/$client_name/.bashrc

#MOTD
echo "MOTD download..."
apt-get -y install linuxlogo 1> /dev/null
mv /etc/motd /etc/motd.old
rm /etc/motd.old
linuxlogo -L 16 -f -u -y > /etc/motd
echo "Done."
