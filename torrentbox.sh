#! /bin/bash

# preparation: sudo chmod 744 torrentbox.sh #
#############################################

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
echo -e "${DEF}Copyright (c) 2019 d3str0yer"
echo "This file is part of \"torrentbox\" which is released under
the MIT license."
echo

#disclaimer
echo "Disclaimer: Using torrents to down- and upload copyright
protected material is in most countries against the law.
This script automatically installs a VPN client (OpenVPN)
and modifies various system settings to block traffic not
going through OpenVPN as well as IPv6 in general."
echo
echo "I've read the disclaimer and want to start the install
process (Y/N)"
while read -r -n 1 -s answer; do
  if [[ $answer = [YyNn] ]]; then
    [[ $answer = [Yy] ]]
    [[ $answer = [Nn] ]] && echo && echo -e "${RED}installation canceled :(" && exit 1 
    break
  fi
done
echo

echo 

./installer.sh

./config.sh

echo "The script has finished installation. 

exit 0
