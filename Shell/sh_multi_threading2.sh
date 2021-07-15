#!/bin/bash

file_name=$1
start_month=$2
end_month=$3
start_date="${start_month}01"
end_date="${end_month}01"

trap "exec 200>&- ; exec 200<&- ; exit 0" 2

mkfifo fifo_file
exec 200<>fifo_file
rm -rf fifo_file

# 执行并发数
for ((n = 1; n <= 2; n++)); do
    echo >&200
done

while [ "$start_date" -le "$end_date" ]; do
    read -u200
    {
        run_month=$(date -d "$start_date" +%Y%m)
        echo "run_month=${run_month}"
        # echo " sh /home/deployop/etlscript/execution_engine/autocode/dml/iml/init/dwd_int.sh ${file_name} ${run_month}"
        echo >&200
    } &

    start_date=$(date -d "${start_date} +1 month" +%Y%m%d)
    echo "updated_start_date=${start_date}"
done

wait

exec 200>&-
exec 200<&-
