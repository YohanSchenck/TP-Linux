#!/bin/bash

echo "Machine name : $(hostname)"

source /etc/os-release

echo "OS ${NAME} and kernel version is $(uname -r)"

echo "IP : $(ip a | grep 'inet ' | tail -n 1 | tr -s ' ' | cut -d' ' -f3)"

echo "RAM : $(free -h | grep Mem | tr -s ' ' | cut -d ' ' -f4) memory available on $(free -h | grep Mem | tr -s ' ' | cut -d ' ' -f2) total memory"

echo "Disk : $(df -h -l | grep /dev/mapper | tr -s ' ' | cut -d ' ' -f4) space left"

echo "Top 5 processes by RAM usage :"

echo "$(ps -eo command=,%mem= --sort=-%mem | head -n 5)" > top_processes

for i in $(seq 1 5)
do
        echo "  - $(sed -n ${i}p top_processes)"
done

echo "Listening ports :"

echo "$(ss -laputHen | tr -s ' ' | cut -d ' ' -f1)" > type_port

echo "$(ss -laputHen | tr -s ' ' | cut -d ' ' -f5 | tr -s ':' | rev |  cut -d ':' -f1 | rev)" > port_listening

echo "$(ss -laputHen |  cut -d '/' -f3 | cut -d ' ' -f1 | cut -d '.' -f1)" > processes

for i in $(seq 1 7)
do
        echo "  - $(sed -n ${i}p type_port) $(sed -n ${i}p port_listening) : $(sed -n ${i}p processes)"
done


curl --silent https://cataas.com/cat/says/hello%20world! -o cat

type_file=$(file cat | tr -s ' ' | cut -d ' ' -f2)

echo "Here is your random cat : ./cat.${type_file}"