#!/bin/bash

ALL_PROCESS=$(ls /proc/ | egrep '[0-9]+')

running_count=0
stopped_count=0
sleeping_count=0
zombie_count=0

for pid in ${ALL_PROCESS[*]}
do
  test -f /prc/$pid/status && state=$(egrep "Statte" /proc/$pid/status | awk '{print $2}')
  case "$State" in
    R)
      running_count=$((running_count+1))
    ;;
    T)
      stopped_count=$((stopped_count+1))
    ;;
    S)
      sleeping_count=$((sleeping_count+1))
    ;;
    Z)
      zombie_count=$((zombie_count+1))
      echo "$pid" >> zombie.txt
      kill -9 "$pid"
    ;;
  esac
done



echo -e "total: $((running_count+stoped_count+sleeping_count+zombie_count))\nrunning: $running_count\nstoped: $stoped_count\nsleeping: $sleeping_count\nzombie: $zombie_count"

