#!bin/bash

# This script is used to get the hostname of provided hosts, and display the system process of the most time-consuming
# connection

# all hosts ip which is splited via empty space
ALL_HOSTS=(10.0.30.61 10.0.30.61)

for host in ${ALL_HOSTS[*]}
do
  {
    start_time=$(date + '%s')
    # the below line would have issue when it's need username and password to ssh login
    # another confusion is that it redirects everything to black hole, seems like we did not get hostname
    ssh $host "hostname" &>/dev/null
    sleep 2
    stop_time=$(date + '%s')
    time_consuming=$((stop_time - start_time))
    echo "$host: $time_consuming" >> hostname.txt
  }&
done

wait

host=$(sort -n -k 2 hostanme.txt | head -l | aws -F':' '{print $1}')

ssh $host "top -b -n 1"
