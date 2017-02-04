#nom du client
client_name="user"

echo "Installation of the packages..."
apt-get -y install ssh sudo vim rsync wget fail2ban 1> /dev/null
echo "Done. "

#ssh config
echo "SSH-key..."
#mv id_rsa.pub /home/$client_name/.ssh/authorized_keys
echo " Added correctly."

#modif root
root_pass=$(date +%s | sha256sum | base64 | head -c 32 | tail -c 10)
passwd root $root_pass

#creation user
pass=$(date +%s | sha256sum | base64 | head -c 32 | tail -c 10)
useradd -m $client_name
echo "$client_name:$pass" | chpasswd
echo "pass = $pass
user = $client_name"

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
echo "PS1=\"\[\033[38;5;8m\][\[$(tput sgr0)\]\[\033[38;5;2m\]\u\[$(tput sgr0)\]\[\033[38;5;8m\]:\[$(tput sgr0)\]\[\033[38;5;117m\]\h\[$(tput sgr0)\]\[\033[38;5;8m\]-\[$(tput sgr0)\]\[\033[38;5;205m\]\W\[$(tput sgr0)\]\[\033[38;5;8m\]]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;7m\]\A\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;208m\]>\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\"" >> /home/$client_name/.bashrc

#MOTD
echo "MOTD download..."
apt-get -y install linuxlogo 1> /dev/null
mv /etc/motd /etc/motd.old
rm /etc/motd.old
linuxlogo -L 16 -f -u -y > /etc/motd
echo "Done."


#mail
touch ~/.mail.txt~
ip_adress=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
mac_adress=$(ifconfig | grep -i HWaddr | tail -c 20)

echo "To: v.tarlowski@gmail.com                                                                                                                                                                                                                                                                                           
Subject: Information about your Account                                                                                                                                                                                                                                                                                   
From: assistancePXE@gmail.com                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
Hello,                                                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                                                          
First, thanks you to choice our PXE serveur.                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                                          
You can read below your account Information for use your computer.                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                        
-adress IP = $ip_adress                                                                                                                                                                                                                                                                                                   
-adress MAC = $mac_adress                                                                                                                                                                                                                                                                                                 
-login = $client_name                                                                                                                                                                                                                                                                                                     
-password = $pass                                                                                                                                                                                                                                                                                                         
-Root password = $root_pass                                                                                                                                                                                                                                                                                                                         
-                                                                                                                                                                                                                                                                                                                         
-                                                                                                                                                                                                                                                                                                                        
-                                                                                                                                                                                                                                                                                                                        
-                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                      
See you soon.                                                                                                                                                                                                                                                                                                              
" > ~/.mail.txt~

sendmail -vt < ~/.mail.txt~
