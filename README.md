![](files/logo.jpg)
# Installation Script for a Raspberry Pi Seedbox

# IF YOU FIND THIS BY CHANCE, DO NOT USE, STILL IN DEVELOPMENT!

## Usage
This Script will install mutliple programs and configure them. After installation, you'll have a private seedbox running the following programs:
* qbittorrent-nox (accessible through the web interface)
* OpenVPN
* Pseudo Killswitch with IPtables
* fail2ban (intrusion prevention software)
* samba (network share to access your files from other devices in the network)
* lighttpd (webserver to display network statistics)
* vnstat/vnstati (to create said network statistics)
* motd script to display uptime, storage space, etc.
* optionals
  * speedtest-cli (speedtest, duh)
  * netdata (performance monitoring webinterface)

## Pre-requisites
* Clean install of the latest version of Raspbian (headless)
* External HDD to keep your files, suggested: secondary device as a buffer for downloads, e.g. USB stick
* VPN subscription (Provider must support OpenVPN)

## Installation of Raspbian

1. Download the latest version of Raspbian, install it on your SD card
2. In the boot folder, create a new file called ssh, no file extension and no content
3. Connect your Raspberry via ethernet to your Router (using the inbuilt wifi is not suggested)

## Pre-Install OpenVPN configuration

1. Search for your Providers OpenVPN files and download them
2. Create a new file called login.conf, in the first line add your username and in the second your password (username and password supplied by VPN Provider)
3. If the OpenVPN files contain multiple .ovpn files, delete all but the one server(-hub) you want to connect to and rename it to openvpn.conf
4. Change the following lines:
  * "auth-user-pass" to "auth-user-pass /etc/openvpn/login.conf"
  * "ca ca.crt" to "ca /etc/openvpn/ca.crt"
  * "cert client.crt" to "cert /etc/openvpn/client.crt"
  * "key client.key" to "key /etc/openvpn/client.key"

## Pre-Install Harddrive configuration

__Warning: This will delete ALL data on your harddrives.__

_Skip if you already have formatted storage devices or want to use a NAS_

Connect to your Raspberry Pi through SSH as user "pi" with the password "raspberry"

```sh
sudo fdisk /dev/sda
```

1. Press O and press Enter (creates a new table)
2. Press N and press Enter (creates a new partition)
3. Press P and press Enter (makes a primary partition)
4. Then press 1 and press Enter (creates it as the 1st partition)
5. Finally, press W (this will write any changes to disk)

```sh
sudo mkfs.ext4 /dev/sda1
```

_Repeat these steps for /dev/sdb if you use a second storage device (suggested)_

## Permanentely mounting Harddrives

```sh
sudo nano /etc/fstab
```
```bash
#device        mountpoint             fstype    options  dump   fsck

/dev/sda1    /mnt/stick    ext4    defaults,nofail,uid=1001,gid=1001    0    1
/dev/sdb1    /mnt/hdd    ext4    defaults,nofail,uid=1001,gid=1001    0    1
```
_Press CTRL+X, Y, ENTER to save the file_

(change sda1 and sdb1 depending on which is the stick and which is the hdd, find out which is which with the command lsusb)

You can do this step after the installation, or during, or before.

## Start the Installation

Connect to your Raspberry Pi through SSH as user "pi" with the password "raspberry"

```sh
sudo apt install git -y
git clone https://github.com/d3str0yer/torrentbox.git -q
cd torrentbox
sudo chmod u+x ./torrentbox.sh
sudo ./torrentbox.sh
```

## Usage

### Samba Network Share

* After installation you'll be able to mount the /mnt folder through Samba on your Windows Computer
* Open Explorer, right-click anywhere and click "Add Network Location"
* Click "Next" until you get to the "Specifiy the location of your website" prompt.
* Enter "\\torrentbox\torrents" and finish the wizzard.
* The username for the share is "pi" and the password is the password you specified during installation.

### Torrentbox Web Interface and Network Statistics

* You can access the Web Interface through your Browser by opening [http://torrentbox](http://torrentbox).
* From there you can access netdata (if you installed it), qBittorrent, and your network statistics.
* Depending on your setup, this might not be possible or you need to add your router specific domain suffix, like .local or .lan
* If that doens't work either you can add the Torrentbox to your hostfile, which is located under C:\Windows\System32\Drivers\etc\hosts.

### qBittorrent

* Follow the link in the Web Interface, or open [http://torrentbox:8080](http://torrentbox:8080).
* The default username for qBittorrent is "admin" and the password is "adminadmin".
* You can add new torrents either through the Web Interface, or by placing your .torrent files in the folder /mnt/hdd/watching
* __When manually restarting the Torrentbox make sure you pause all torrents, otherwise qBittorrent will perform a recheck on every file. This can take a very long time.__




## FAQ

> qBittorrent is no longer up/downloading
```sh
sudo service openvpn restart
```
This usually fixes it, as VPN servers can crash and restarting the service will connect you to a new server. If it still doesn't work:
```sh
sudo service openvpn stop
sudo openvpn /etc/openvpn/openvpn.conf
```
Read what the console outputs, if you get errors concerning certificates just redo the steps from "Pre-Install OpenVPN configuration" and upload them to /etc/openvpn.

_ask questions and I'll add them here_
