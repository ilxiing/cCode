#!/bin/bash

# accept 2 params
start_sec=`date -d "$1" "+%s"`
end_sec=`date -d "$2" "+%s"`

# close file description 200
trap "exec 200>&- ; exec 200<&- ; exit 0" 2

# make a fifo file and bind it to file description 200
mkfifo fifo_file
exec 200<>fifo_file
rm -rf fifo_file

# 10 is like threading number
for ((n=1; n<=10; n++))
do
  echo >&200
done

start=`date "+%s"`

for ((i=start_sec; i<=end_sec; i+=86400))
do
  read -u200
  {
    day=$(date -d "@$i" "+%Y%m%d")
    # sh /path/run_task.sh
    echo success
    echo >&200
  }&
done

# wait for all task done
wait

end=`date "+%s"`

echo "TIME: `expr $end - $start`"

# unbinding file description 200
exec 200>&-
exec 200<&-
