#! /bin/bash
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

#copyright and license
#Copyright (c) 2019 d3str0yer
#This file is part of "torrentbox" which is released under the
#MIT license.

#check for root
echo
echo -e "${DEF}checking for root"
if ! [ $(id -u) = 0 ]; then
   echo 
   echo -e "${RED}I don't work without permissions. Start me again with sudo."
   exit 1
fi
echo -e "root ${RED}[OK]${DEF}"

# >/dev/null 2>&1
# later put in

#update+upgrade
echo
echo -e "${DEF}updating system..."
apt-get update
echo -e "update ${RED}[DONE]${DEF}"
echo
echo "upgrading system..."
apt-get upgrade -y
echo -e "upgrade ${RED}[DONE]${DEF}"
echo

#install openvpn
echo "installing openvpn..."
apt-get install openvpn -y
echo -e "openvpn ${RED}[INSTALLED]${DEF}"
echo

#install qbittorrent-nox
echo "installing qbittorrent-nox..."
apt-get install qbittorrent-nox -y
echo -e "qbittorrent-nox ${RED}[INSTALLED]${DEF}"
echo

#install fail2ban and tree, just for a visual thing
echo "installing tree fail2ban..."
apt-get install fail2ban -y
echo -e "fail2ban ${RED}[INSTALLED]${DEF}"
echo

#install samba, 3 echo lines to surpress the popup
echo "samba-common samba-common/workgroup string  WORKGROUP" | debconf-set-selections
echo "samba-common samba-common/dhcp boolean true" | debconf-set-selections
echo "samba-common samba-common/do_debconf boolean true" | debconf-set-selections
echo "installing samba..."
apt-get install samba samba-common-bin -y
echo -e "samba ${RED}[INSTALLED]${DEF}"
echo

#install vnstat
echo "installing vnstat..."
apt-get install vnstat vnstati -y
echo -e "vnstat ${RED}[INSTALLED]${DEF}"
echo

#install lighttpd
echo "installing lighttpd..."
apt-get install lighttpd -y
echo -e "lighttpd ${RED}[INSTALLED]${DEF}"
echo

#install speedtest
echo "Would you like to install speedtest-cli?"
echo "(speedtest-cli is a command line interface for testing internet
bandwidth using speedtest.net) (Y/N)"
while read -r -n 1 -s answer; do
  if [[ $answer = [YyNn] ]]; then
    [[ $answer = [Yy] ]] && echo && echo "installing speedtest-cli..." && apt-get install speedtest-cli -y >/dev/null 2>&1 && echo -e "speedtest-cli ${RED}[INSTALLED]${DEF}"
    [[ $answer = [Nn] ]] && echo && echo -e "${RED}not installing speedtest-cli${DEF}"
    break
  fi
done
echo

#install netdata?
echo "Would you like to install netdata?"
echo "(Netdata is a extremely optimized Linux utility that provides real-time (per second) performance monitoring for Linux systems, applications, SNMP devices, etc. and shows full interactive charts that absolutely render all collected values over the web browser to analyze them.) (Y/N)"
while read -r -n 1 -s answer; do
  if [[ $answer = [YyNn] ]]; then
    [[ $answer = [Yy] ]] && echo && echo "installing packages required for netdata..." && apt-get install zlib1g-dev uuid-dev libuv1-dev liblz4-dev libjudy-dev libssl-dev libmnl-dev gcc make git autoconf autoconf-archive autogen automake pkg-config curl python -y >/dev/null 2>&1 && echo -e "required packages ${RED}[INSTALLED]${DEF}" && echo && echo "installing netdata..." && echo "dev git clone" && git clone https://github.com/netdata/netdata.git --depth=100 -q && echo "dev cd" && cd netdata && echo "dev execute script" &&./netdata-installer.sh && echo && echo "DO NOT DELETE THE NETDATA FOLDER AFTER INSTALLATION, THIS WILL BREAK IT."
    [[ $answer = [Nn] ]] && echo && echo -e "${RED}not installing netdata${DEF}"
    break
  fi
done

exit 0
