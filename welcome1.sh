#!/bin/sh
# dynamische MOTD
clear
echo ""
# Aufruf in /etc/profile (letzte Zeile)
# Datum & Uhrzeit
DATUM=`date +"%A, %e %B %Y"`
# Hostname
HOSTNAME=`hostname -f`
# letzter Login
LAST1=`last -2 -a | awk 'NR==2{print $3}'`    # Wochentag
LAST2=`last -2 -a | awk 'NR==2{print $5}'`    # Tag
LAST3=`last -2 -a | awk 'NR==2{print $4}'`    # Monat
LAST4=`last -2 -a | awk 'NR==2{print $6}'`    # Uhrzeit
LAST5=`last -2 -a | awk 'NR==2{print $10}'`    # Remote-Computer
# Uptime
UP0=`cut -d. -f1 /proc/uptime`
UP1=$(($UP0/86400))        # Tage
UP2=$(($UP0/3600%24))        # Stunden
UP3=$(($UP0/60%60))        # Minuten
UP4=$(($UP0%60))        # Sekunden
# Durchschnittliche Auslasung
LOAD1=`cat /proc/loadavg | awk '{print $1}'`    # Letzte Minute
LOAD2=`cat /proc/loadavg | awk '{print $2}'`    # Letzte 5 Minuten
LOAD3=`cat /proc/loadavg | awk '{print $3}'`    # Letzte 15 Minuten
# Temperatur
TEMP=`vcgencmd measure_temp | cut -c "6-9"`
# Speicherbelegung
DISK1=`df -h | grep 'dev/root' | awk '{print $2}'`    # Gesamtspeicher
DISK2=`df -h | grep 'dev/root' | awk '{print $3}'`    # Belegt
DISK3=`df -h | grep 'dev/root' | awk '{print $4}'`    # Frei
# Arbeitsspeicher
RAM1=`free -h --si | grep 'Mem' | awk '{print $2}'`    # Total
RAM2=`free -h --si | grep 'Mem' | awk '{print $3}'`    # Used
RAM3=`free -h --si | grep 'Mem' | awk '{print $4}'`    # Free
RAM4=`free -h --si | grep 'Swap' | awk '{print $3}'`    # Swap used
echo "\033[1;32m   .~~.   .~~.    \033[1;36m$DATUM
\033[1;32m  '. \ ' ' / .'   
\033[1;31m   .~ .~~~..~.    \033[0;37mHostname......: \033[1;33m$HOSTNAME
\033[1;31m  : .~.'~'.~. :   \033[0;37mLetzter Login.: $LAST1, $LAST2 $LAST3 $LAST4 von $LAST5
\033[1;31m ~ (   ) (   ) ~  \033[0;37mUptime........: $UP1 Tage, $UP2:$UP3 Stunden
\033[1;31m( : '~'.~.'~' : ) \033[0;37mØ Auslastung..: $LOAD1 (1 Min.) | $LOAD2 (5 Min.) | $LOAD3 (15 Min.)
\033[1;31m ~ .~ (   ) ~. ~  \033[0;37mTemperatur....: $TEMP °C
\033[1;31m  (  : '~' :  )   \033[0;37mSpeicher......: Gesamt: $DISK1 | Belegt: $DISK2 | Frei: $DISK3
\033[1;31m   '~ .~~~. ~'    \033[0;37mRAM (MB)......: Gesamt: $RAM1 | Belegt: $RAM2 | Frei: $RAM3 | Swap: $RAM4
\033[1;31m       '~'        \033[0;37m\033[1;35m$IP_LAN\033[0;37m
\033[m"
