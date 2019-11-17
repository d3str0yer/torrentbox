#! /bin/bash
#
# ---------------------------------------------------------------------------------
#	torrentbox install script rev1
#
#
#	Copyright (c) 2019 d3str0yer
#   github.com/d3str0yer
#	d3str0yer999 at protonmail.com
#	This file is part of "torrentbox" which is released under the MIT license.
# ---------------------------------------------------------------------------------

###################################################################################
############################ functions ############################################

header() {
clear
printf "${color_red}"
figlet -f slant Torrentbox
printf "${color_default}"
}

#function to check/install and print what has installed
license() {
echo ""
echo "Copyright (c) 2019 d3str0yer"
echo
echo "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:"
echo
echo "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software."
echo
echo "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
echo
echo -n "I've read the licensing agreement and agree with it. (Y/N)"
while read -r -n 1 -s answer; do
  if [[ $answer = [YyNn] ]]; then
    [[ $answer = [Yy] ]]
    [[ $answer = [Nn] ]] && echo && echo "installation canceled :(" && exit 1 
    break
  fi
done

#disclaimer
header
echo
echo "Disclaimer: Using torrents to down- and upload copyright protected material is in most countries against the law."
echo
echo -n "I've read the and disclaimer and want to start the install process (Y/N)"
while read -r -n 1 -s answer; do
  if [[ $answer = [YyNn] ]]; then
    [[ $answer = [Yy] ]]
    [[ $answer = [Nn] ]] && echo && echo -e "installation canceled :(" && exit 1 
    break
  fi
done
echo
}

mode1() {
packages=("openvpn" "qbittorrent-nox" "fail2ban" "tree" "samba" "samba-common-bin" "vnstat" "vnstati" "lighttpd")
}

mode2() {
packages=("qbittorrent-nox" "fail2ban" "tree" "samba" "samba-common-bin" "vnstat" "vnstati" "lighttpd")
}

installer() {
dpkg -s "${packages[aPackages]}" > /dev/null 2>&1 || apt-get install ${packages[aPackages]} -y > /dev/null 2>&1 ; echo "Package ${packages[$aPackages]} installed"
}

###################################################################################
############################ main #################################################

#define colors
color_red="\e[31m"
color_green="\e[92m"
color_default="\e[0m"

#check for root priviliges
if ! [ $(id -u) = 0 ]; then
   echo -e "${color_red}I don't work without permissions. Start me again with sudo.${color_default}"
   exit 1
fi

#hello there
echo "starting script..."
#figlet is used to display the logo, check if it's there, if not install it
dpkg -s figlet > /dev/null 2>&1 || apt-get install figlet -y > /dev/null 2>&1
header
license

#setting variables for installation, otherwise the installation will not continue due to a popup asking for user input
header
echo
echo "setting installation variables"
echo "samba-common samba-common/workgroup string  WORKGROUP" | debconf-set-selections
echo "samba-common samba-common/dhcp boolean true" | debconf-set-selections
echo "samba-common samba-common/do_debconf boolean true" | debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections

#updating and upgrading system 
echo "updating and upgrading system"
echo "(this will take a while on a new installation)"
apt-get update > /dev/null 2>&1
apt-get upgrade -y > /dev/null 2>&1
echo

#select installation mode
header
echo "Please select the desired installation mode."
echo "1: standard installation with OpenVPN and iptables"
echo -n "2: minimal installation without OpenVPN and iptables"
while read -r -n 1 -s mode; do
  if [[ $mode = [12] ]]; then
    [[ $mode = [1] ]] && clear && echo && mode1
    [[ $mode = [2] ]] && clear && echo && mode2
    break
  fi
done

#installing packages
header
echo "Starting installation"
echo
aPackages=`expr ${#packages[@]} - 1`
while [ $aPackages -le ${#packages[@]} -a $aPackages -ge 0 ] ; do
  installer ${#packages[$aPackages]}
  aPackages=`expr $aPackages - 1`
done

#optional installs
echo
echo -n "Would you like to install speedtest-cli? (command line speedtest) (Y/N)"
while read -r -n 1 -s answer; do
  if [[ $answer = [YyNn] ]]; then
    [[ $answer = [Yy] ]] && echo && apt-get install speedtest-cli -y >/dev/null 2>&1 && echo "Package speedtest-cli installed" && echo
    [[ $answer = [Nn] ]] && echo && echo "Package speedtest-cli not installed" && echo
    break
  fi
done
echo -n "Would you like to install netdata? (performance monitoring webinterface)(Y/N)"
while read -r -n 1 -s answer; do
  if [[ $answer = [YyNn] ]]; then
    [[ $answer = [Yy] ]] && netdatainstalled=1 && echo && echo -e "${color_red}this installation will take a couple minutes${color_default}" && echo "installing packages required for netdata" && apt-get install zlib1g-dev uuid-dev libuv1-dev liblz4-dev libjudy-dev libssl-dev libmnl-dev gcc make git autoconf autoconf-archive autogen automake pkg-config curl python -y >/dev/null 2>&1 && echo "installing netdata" && cd ~ && git clone https://github.com/netdata/netdata.git --depth=100 -q && cd netdata && ./netdata-installer.sh && echo && echo "${color_red}DO NOT DELETE THE NETDATA FOLDER AFTER INSTALLATION, THIS WILL BREAK NETDATA!.${color_default}"  && cd ~/torrentbox && sleep 5
    [[ $answer = [Nn] ]] && echo && echo "not installing netdata" && sleep 2
    break
  fi
done

#installation is now finished. configuration follows.

#change pw for pi
header
echo
echo -e "${color_default}If this is a new installation, it is highly suggested that you change the password of the user \"pi\"."
echo -n "Would you like to change the password now? (Y/N)"
while read -r -n 1 -s answer; do
  if [[ $answer = [YyNn] ]]; then
    [[ $answer = [Yy] ]] && echo && passwd pi && echo
    [[ $answer = [Nn] ]] && echo && echo -e "${color_red}Password for user \"pi\" not changed!${color_default}" && echo
    break
  fi
done

#change pw for root
if [ $mode -eq 1 ] ; then
  echo "In order to upload your OpenVPN configuration files you will need to log into FTP as \"root\". If you haven't set a password for root yet, you must chose one now."
  echo -n "Would you like to change the password now? (Y/N)"
  while read -r -n 1 -s answer; do
    if [[ $answer = [YyNn] ]]; then
      [[ $answer = [Yy] ]] && echo && passwd root && echo
      [[ $answer = [Nn] ]] && echo && echo -e "${color_red}Password for user \"root\" not changed!${color_default}" && echo
      break
    fi
  done
fi

#select if hdd+usb or just hdd, also gets the correct welcome script in place
echo "In order to create folders for torrents and temporary storage, please select your setup:"
echo "1: HDD for storage + USB stick to cache downloads"
echo -n "2: HDD only"
while read -r -n 1 -s storage; do
  if [[ $storage = [12] ]]; then
    echo
    echo "creating folders..."
    [[ $storage = [1] ]] && mkdir /mnt/downloading && mkdir -p /mnt/hdd/{completed,torrentfiles,watching} && cp files/welcome1.sh ~/welcome.sh
    [[ $storage = [2] ]] && mkdir -p /mnt/hdd/{downloading,completed,torrentfiles,watching} && cp files/welcome2.sh ~/welcome.sh
    break
  fi
done
chmod 755 ~/welcome.sh
chown pi:pi ~/welcome.sh
tree /mnt --noreport
echo
echo "Setting up MOTD..."
echo "/home/pi/welcome.sh" >> /etc/profile
echo "" > /etc/motd

#changing hostname
echo
echo "Changing Hostname to \"torrentbox\"..."
echo "torrentbox" > /etc/hostname

#configuration of fail2ban
echo
echo "Configuring fail2ban..."
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i "s/#ignoreip = 127.0.0.1\/8 ::1/ignoreip = 127.0.0.1\/8 ::1 10.0.0.0\/8 172.16.0.0\/12 192.168.0.0\/16/" /etc/fail2ban/jail.local
sed -i "s/bantime  = 10m/bantime = 21600/" /etc/fail2ban/jail.local
sed -i "s/findtime  = 10m/findtime = 21600/" /etc/fail2ban/jail.local
sed -i "s/maxretry = 5/maxretry = 3/" /etc/fail2ban/jail.local
/etc/init.d/fail2ban restart >/dev/null 2>&1

#configuration of ssh
echo
echo "Configuring SSH..."
sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config
service ssh restart >/dev/null 2>&1

#config swapfile
echo
echo "Increasing Swapfile..."
dphys-swapfile swapoff >/dev/null 2>&1
sed -i "s/CONF_SWAPSIZE=100/CONF_SWAPSIZE=1000/" /etc/dphys-swapfile
dphys-swapfile swapon >/dev/null 2>&1

#samba config
echo
echo "Setting up SMB Server..."
echo "[Torrents]" >> /etc/samba/smb.conf
echo "Comment = Samba Share for Torrents" >> /etc/samba/smb.conf
echo "Path = /mnt" >> /etc/samba/smb.conf
echo "Browseable = yes" >> /etc/samba/smb.conf
echo "Writeable = Yes" >> /etc/samba/smb.conf
echo "read only = no" >> /etc/samba/smb.conf
echo "only guest = no" >> /etc/samba/smb.conf
echo "create mask = 0777" >> /etc/samba/smb.conf
echo "directory mask = 0777" >> /etc/samba/smb.conf
echo "Public = no" >> /etc/samba/smb.conf
echo -e "Please set a Password for the Network Share:"
smbpasswd -a pi
systemctl restart smbd > /dev/null 2>&1
chmod -R 757 /mnt

#qbittorrent stuff
echo
echo "Creating User for qBittorrent..."
useradd -p $(openssl passwd -1 supersecretpasswordforqbittorrent) -d /home/qbtuser -m -c "qbittorrent user" -s /bin/bash qbtuser
sudo su -c "mkdir -p ~/.config/qBittorrent" qbtuser
usermod -s /usr/sbin/nologin qbtuser
#qbittorrent configuration
echo
echo "Configuring qBittorrent.conf"
if [ $storage -eq 1 ] ; then
  mv files/qBittorrent1.conf /home/qbtuser/.config/qBittorrent/qBittorrent.conf
else
  mv files/qBittorrent2.conf /home/qbtuser/.config/qBittorrent/qBittorrent.conf
fi
chown qbtuser:qbtuser /home/qbtuser/.config/qBittorrent/qBittorrent.conf
#creating qbittorrent service
echo
echo "Setting up qbittorrent Service..."
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
systemctl disable qbittorrent
sudo chown -R qbtuser:qbtuser /mnt/

#delayed start of qbittorrent, if it starts automatically it'll be faster than the hdd spinning up and end up erroring out
echo "setting up delay for qbittorrent..."
sed -i "s/exit 0//" /etc/rc.local
echo "sleep 7" >> /etc/rc.local
echo "service qbittorrent start" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local

#cronjobs for restarting openvpn every 6 hours and create vnstati pictures every 5 minutes
echo "setting up cronjobs..."
echo "0 */6 * * * sudo service openvpn restart >/dev/null 2>&1" >> cronjob
echo "*/5 * * * * nice /home/pi/torrentbox/files/vnstati.sh >/dev/null 2>&1" >> cronjob
crontab cronjob

#if seedbox with vpn was selected
if [ $mode -eq 1 ] ; then
  #adding openvpn to autostart
  echo "set openvpn to autostart..."
  sed -i "s/#AUTOSTART=\"all\"/AUTOSTART=\"openvpn\"/" /etc/default/openvpn
  #asking user to upload openvpn configuration files
  echo "Now use WinSCP to connect to your Raspberry Pi as user \"root\" and paste your Openvpn certificates and configuration files into /etc/openvpn"
  read -n 1 -s -r -p "Press any key to continue"
  #iptables firewall config
  echo
  echo "installing iptables-persistent..."
  apt-get install iptables-persistent -y > /dev/null 2>&1
  #change sysctl.conf to disable ipv6
  echo "disabling ipv6..."
  echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
  echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf
  echo "net.ipv6.conf.default.disable_ipv6=1" >> /etc/sysctl.conf
  echo "net.ipv6.conf.lo.disable_ipv6=1" >> /etc/sysctl.conf
  echo "net.ipv6.conf.eth0.disable_ipv6=1" >> /etc/sysctl.conf
  #echo "creating iptables..."
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
  echo "saving iptables..."
  netfilter-persistent save > /dev/null 2>&1
  systemctl enable netfilter-persistent > /dev/null 2>&1
fi

echo "setting up vnstat..."
sed -i "s/Interface \"eth0\"/Interface \"tun0\"/" /etc/vnstat.conf

#web landing page with bookmarks
if [ $netdatainstalled -eq 1 ] ; then
  mv files/html/index1.html files/html/index.html
  rm files/html/index2.html
else
  mv files/html/index2.html files/html/index.html
  rm files/html/index1.htlm
fi
cp -R files/html /var/html

#goodbye
rm -r ~/torrentbox

#todo: end of installation message, short tutorial, mounting samba share on windows
echo "##############################################################################"
echo "end of script $0"
echo "##############################################################################"
exit 0