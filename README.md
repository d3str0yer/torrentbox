# torrentbox
> Installation Script for a Raspberry Pi Seedbox

## Usage
This Script will install mutliple programs and configure them. After installation you'll have a private seedbox, running the following programs:
* qbittorrent-nox (accessible through the webinterface)
* OpenVPN
* fail2ban (intrusion prevention software)
* samba (network share to access your files from other devices in the network)
* lighttpd (webserver to display network statistics)
* vnstat/vnstati (to create said network statistics)
* optionals
  * speedtest-cli (speedtest, duh)
  * netdata (performance monitoring webinterface)

## Prerequisites
* Clean install of the latest version of Raspbian (headless)
* External HDD to keep your files, suggested: secondary device as a buffer, e.g. USB stick
* VPN subscription (Provider must support OpenVPN)

## 
  
  * Search for your Providers OpenVPN files and download them
  * Create a new file called login.conf, in the first line add your username and in the second your password
  * If the OpenVPN files contain multiple .ovpn delete all but the one server hub you want to connect to and rename it to openvpn.ovpn
