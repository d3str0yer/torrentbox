#! /bin/bash

#copyright and license
#Copyright (c) 2019 d3str0yer
#This file is part of "torrentbox" which is released under the
#MIT license.

#color definition
RED='\033[0;31m' #
DEF='\033[0m' # default color, use after something in red else everything is red..

#header
clear
echo -e "${RED}  ______                           __  __              "
echo -e "${RED} /_  __/___  _____________  ____  / /_/ /_  ____  _  __"
echo -e "${RED}  / / / __ \/ ___/ ___/ _ \/ __ \/ __/ __ \/ __ \| |/_/"
echo -e "${DEF} / / / /_/ / /  / /  /  __/ / / / /_/ /_/ / /_/ />  <  "
echo -e "${RED}/_/  \____/_/  /_/   \___/_/ /_/\__/_.___/\____/_/|_|  "
echo -e "${RED}                                                       "

#change pw for pi
echo
echo -e "${DEF}If this is a new installation it is highly suggested that
you change the password of the user pi"
echo
echo "Would you like to change the password now? (Y/N)"
while read -r -n 1 -s answer; do
  if [[ $answer = [YyNn] ]]; then
    [[ $answer = [Yy] ]] && passwd pi
    [[ $answer = [Nn] ]] && echo && echo -e "${RED}Password for user \"pi\" not changed!${DEF}" && echo
    break
  fi
done

#change pw for root
echo "This installer will change the root user to allow logging
in as root through FTP. If you haven't set a password for
root yet, you must chose one now."
echo
echo "Would you like to set a new password? (Y/N)"
while read -r -n 1 -s answer; do
  if [[ $answer = [YyNn] ]]; then
    [[ $answer = [Yy] ]] && passwd root
    [[ $answer = [Nn] ]] && echo && echo -e "${RED}Password for user \"root\" not changed!${DEF}" && echo
    break
  fi
done
echo

#changing hostname
echo "changing hostname to \"torrentbox\"..."
echo "torrentbox" > /etc/hostname

#configuration of fail2ban
echo "configuring fail2ban..."
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i "s/#ignoreip = 127.0.0.1\/8 ::1/ignoreip = 127.0.0.1\/8 ::1 10.0.0.0\/8 172.16.0.0\/12 192.168.0.0\/16/" /etc/fail2ban/jail.local
sed -i "s/bantime  = 10m/bantime = 21600/" /etc/fail2ban/jail.local
sed -i "s/findtime  = 10m/findtime = 21600/" /etc/fail2ban/jail.local
sed -i "s/maxretry = 5/maxretry = 3/" /etc/fail2ban/jail.local
/etc/init.d/fail2ban restart 2>&1 >> log.txt

#configuration of ssh
echo "configuring ssh..."
sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config
service ssh restart 2>&1 >> log.txt

#config swapfile
echo "increasing swapfile..."
dphys-swapfile swapoff 2>&1 >> log.txt
sed -i "s/CONF_SWAPSIZE=100/CONF_SWAPSIZE=1000/" /etc/dphys-swapfile
dphys-swapfile swapon 2>&1 >> log.txt

#create folders for mounting/keeping downloaded stuff
echo "creating folders..."
mkdir -p /mnt/downloading
mkdir -p /mnt/hdd/archived
mkdir /mnt/hdd/torrentfiles
mkdir /mnt/hdd/watching

#change sysctl.conf to disable ipv6
echo "disabling ipv6..."
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.eth0.disable_ipv6=1" >> /etc/sysctl.conf

#iptables firewall config
echo "ceating iptables..."
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -s 192.168.178.0/24 -j ACCEPT
iptables -A OUTPUT -d 192.168.178.0/24 -j ACCEPT
iptables -A INPUT -s 10.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -d 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -s 172.16.0.0/12 -j ACCEPT
iptables -A OUTPUT -d 172.16.0.0/12 -j ACCEPT
iptables -A OUTPUT -p udp --dport 443 -j ACCEPT
iptables -A INPUT -p udp --sport 443 -j ACCEPT
iptables -A OUTPUT -o tun+ -j ACCEPT
iptables -A INPUT -i tun+ -j ACCEPT
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
# to surpress the popup that the install will give
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
echo "installing iptables-persistent..."
apt-get install iptables-persistent -y 2>&1 >> log.txt
netfilter-persistent save
echo "saving iptables..."
systemctl enable netfilter-persistent

#create user for qbittorrent called qbtuser & setting up qbittorrent as a service
echo "creating user for qbittorrent..."
useradd -p $(openssl passwd -1 supersecretpasswordforqbittorrent) qbtuser
echo "setting up qbittorrent service..."
echo "[Unit]" >> /etc/systemd/system/qbittorrent.service
echo "Description=qBittorrent Daemon Service" >> /etc/systemd/system/qbittorrent.service
echo "After=network.target" >> /etc/systemd/system/qbittorrent.service
echo >> /etc/systemd/system/qbittorrent.service
echo "[Service]" >> /etc/systemd/system/qbittorrent.service
echo "User=qbtuser" >> /etc/systemd/system/qbittorrent.service
echo "ExecStart=/usr/bin/qbittorrent-nox" >> /etc/systemd/system/qbittorrent.service
echo "ExecStop=/usr/bin/killall -w qbittorrent-nox" >> /etc/systemd/system/qbittorrent.service
echo >> /etc/systemd/system/qbittorrent.service
echo "[Install]" >> /etc/systemd/system/qbittorrent.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/qbittorrent.service


echo -e "${RED}########################################################${DEF}"
echo -e "${RED}Please manually accept this prompt and then press CTRL+C${DEF}"
echo -e "${RED}########################################################${DEF}"
su -c "qbittorrent-nox" - qbtuser

usermod -s /usr/sbin/nologin qbtuser
chown -R qbtuser:qbtuser /mnt/
systemctl disable qbittorrent

echo "setting up smb server..."
echo "[Torrents]" >> /etc/samba/smb.conf
echo "Comment = Samba Share for Torrents" >> /etc/samba/smb.conf
echo "Path = /mnt" >> /etc/samba/smb.conf
echo "Browseable = yes" >> /etc/samba/smb.conf
echo "Writeable = Yes" >> /etc/samba/smb.conf
echo "only guest = no" >> /etc/samba/smb.conf
echo "create mask = 0777" >> /etc/samba/smb.conf
echo "directory mask = 0777" >> /etc/samba/smb.conf
echo "Public = yes" >> /etc/samba/smb.conf

echo -e "${RED}Please set a Password for the Network Share:${DEF}"
smbpasswd -a pi
systemctl restart smbd

echo "creating vnstati script..."
mkdir /var/www/html/vnstati
echo "vnstati -s -i tun0 -o /var/www/html/vnstati/summary.png" >> ~/torrentbox/vnstati.sh
echo "vnstati -h -i tun0 -o /var/www/html/vnstati/hourly.png" >> ~/torrentbox/vnstati.sh
echo "vnstati -d -i tun0 -o /var/www/html/vnstati/daily.png" >> ~/torrentbox/vnstati.sh
echo "vnstati -t -i tun0 -o /var/www/html/vnstati/top10.png" >> ~/torrentbox/vnstati.sh
echo "vnstati -m -i tun0 -o /var/www/html/vnstati/monthly.png" >> ~/torrentbox/vnstati.sh
chmod +x ~/torrentbox/vnstati.sh

echo "setting up vnstat..."
sed -i "s/Interface \"eth0\"/Interface \"tun0\"/" /etc/vnstat.conf
rm -rf /lib/vnstat
vnstat --create -i tun0

echo "setting up cronjobs..."
echo "0 */6 * * * sudo service openvpn restart >/dev/null 2>&1" >> cronjob
echo "*/5 * * * * nice /home/pi/vnstati.sh >/dev/null 2>&1" >> cronjob
crontab cronjob
rm cronjob

echo "set openvpn to autostart..."
sed -i "s/#AUTOSTART=\"all\"/AUTOSTART=\"openvpn\"/" /etc/default/openvpn

echo "setting up delay for qbittorrent..."
sed -i "s/exit 0//" /etc/rc.local
echo "sleep 7" >> /etc/rc.local #might need to be adapted depending on hdd speedup time
echo "service qbittorrent start" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local

echo "setting up motd..."
echo "/home/pi/welcome.sh" >> /etc/profile
echo "" >> /etc/motd
#############something with init.d/motd need to verify process
echo "MOTD will display your storage space, for this it needs to know how many devices you have attached. (Select 1 or 2)"
while read -r -n 1 -s answer; do
  if [[ $answer = [YyNn] ]]; then
    [[ $answer = [Yy] ]] 
    [[ $answer = [Nn] ]] && echo && echo -e "${RED}installation canceled :(" && exit 1 
    break
  fi
done
echo


# sed template: sed -i "s/ ORIG/ REPLACEMENT /" PATH

exit 0
