#!/bin/bash 
z=$1
export hostname=`hostname`
export osname=`uname -o`
export intip=`hostname -I | awk '{print $1}'`
export exip=`curl -s ifconfig.me/ip_addr`
export users=`users|wc -w`
loadav=`cat /proc/loadavg`
memfree=`cat /proc/meminfo | grep MemFree`
memtotal=`cat /proc/meminfo | grep MemTotal`
swaptotal=`cat /proc/meminfo | grep SwapTotal`
swapfree=`cat /proc/meminfo | grep SwapFree`
uptime=`uptime -p`
openports=`nmap localhost | sed '1,5d;$d'`
#update=`apt-get update`
#upgrade=`apt-get upgrade`
nmap=/bin/nmap
name=/bin/uname
if [ -e $nmap ] && [ -e $name ];then
  echo "all files exists"
else
  echo "u need to instal $nmap and $name"
  exit 1
fi


funcCheckconnect () {
  export connect=`ping -c 1 8.8.8.8`
  if ping -c 1 8.8.8.8 2>&1> /dev/null;then
    echo "Yes"
  else
    echo "No"
  fi
}

check=$( funcCheckconnect)
if [ "$z" = "human" ];then
  echo "Internet connectivity: $check"
  echo "Hostname: $hostname"
  echo "OS Name: $osname"
  echo "Internal ip: $intip"
  echo "External ip: $exip"
  echo "Number of logged users: $users"
  echo "$memtotal"
  echo "$memfree"
  echo "$swaptotal"
  echo "$swapfree"
  echo "Load average: $loadav"
  echo -e "Open ports:\n$openports"
  echo "Uptime: $uptime"
  echo `date`
elif [ "$z" = "" ]; then
  totalmem=`grep -Eo '[0-9]{0,9}' <<< $memtotal`
  port=`echo -e "$openports"`

  listports=()
  for x in $port
  do
   # echo $x
    listports+=($x)
   # echo $listports
  done
  
 # echo ${listports[@]}
  opnport=${listports[@]}
  finalport=`grep -Eo '[0-9]{0,9}' <<< $opnport`
  #echo $finalport
  listports2=()
  for i in $finalport
  do
    listports2+=($i)
  done
  opnport2=${listports2[@]}
  #echo $opnport2
  date=`date`
  JSON_STRING=$( jq -n \
                  --arg conn "$check" \
                  --arg host "$hostname" \
                  --arg os "$osname" \
                  --arg locip "$intip" \
                  --arg wanip "$exip" \
                  --arg user "$users" \
                  --arg load "$loadav" \
                  --arg ports "$opnport2" \
                  --arg up "$uptime" \
                  --arg today "$date" \
                  --arg totalRAM "$totalmem" \
                  '{Internet_connectivity: $conn, hostname: $host, osname: $os, local_ip: $locip, External_ip: $wanip, Number_of_logged_users: $user, Load_average: $load, Open_ports: $ports, Uptime: $up,Total_Memory_kB: $totalRAM, Date: $today}' )
  path=/home/fou/logs
  if [ -d ${path} ]; then
    echo "$JSON_STRING" >>$path/log.json
  else
     mkdir -p $path
     echo "$JSON_STRING" >>$path/log.json


  fi

  
else 
  echo "incorrect key"
  exit 1
fi
