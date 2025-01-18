#!/bin/bash

uptime=$(uptime -s | awk '{print $2}' | awk -F":" '{printf $2 % 10 * 60 + $3}')
sleep $uptime
architecture=$(uname -a)
physical_cpu_count=$(grep "physical id" /proc/cpuinfo | wc -l)
virtual_cpu_count=$(grep "^processor" /proc/cpuinfo | wc -l)
used_ram=$(free --mega | awk '$1 == "Mem:" {print $3}')
total_ram=$(free --mega | awk '$1 == "Mem:" {print $2}')
ram_usage_percent=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')
total_disk_space=$(df -BG | grep '^/dev/' | grep -v '/boot' | awk '{ft += $2} END {print ft}')
used_disk_space=$(df -BM | grep '^/dev/' | grep -v '/boot' | awk '{ut += $3} END {print ut}')
disk_usage_percent=$(df -BM | grep '^/dev/' | grep -v '/boot' | awk '{ut += $3} {ft += $2} END {printf("%d"), ut/ft*100}')
cpu_usage=$(top -bn1 | grep '^%Cpu' | cut -c 9- | xargs | awk '{printf("%.1f%%"), $1 + $3}')
last_boot=$(who -b | awk '{print $3, $4}')
formatted_date=$(date -d "$last_boot" +"%Y-%m-%d %H:%M")
lvm_status=$(if [ $(lsblk | grep "lvm" | wc -l) -eq 0 ]; then echo no; else echo yes; fi)
active_tcp_connections=$(ss -Ht state established | wc -l)
logged_in_users=$(users | wc -w)
ip=$(hostname -I)
mac=$(ip link | grep "ether" | awk '{print $2}')
sudo_count=$(journalctl -q _COMM=sudo | grep COMMAND | wc -l)

wall "    #Architecture:    $architecture
    #CPU physical:    $physical_cpu_count
    #vCPU:    $virtual_cpu_count
    #Memory Usage: $used_ram/${total_ram}MB ($ram_usage_percent%)
    #Disk Usage: $used_disk_space/${total_disk_space}Gb ($disk_usage_percent%)
    #CPU load: $cpu_usage
    #Last boot: $formatted_date
    #LVM use: $lvm_status
    #Connections TCP: $active_tcp_connections ESTABLISHED
    #User log: $logged_in_users
    #Network: IP $ip ($mac)
    #Sudo: $sudo_count cmd"
