#!/bin/bash
#-------------------------------------------------------------------------
#
# Name: cc_hbase_tb_create.sh
# Description:
# This scripts is a common shell for creating month table, 
# include PRACTISE_CC__NEXTMONTH_provcd, PRACTISE_CC__NEXTMONTH, ERR_CDR_CC_NEXTMONTH_provcd, PRE_SUB_CC_NEXTMONTH.
#
#-----------------------------------------------------------------------------
# Usage: cc_hbase_tb_create.sh
#-----------------------------------------------------------------------------

################################# set env var ################################
# execution time
begin_time=$(date +%s)
# the name of shell script
ProcNm=`basename $0`
# the number of params are given for shell script
ParaNm=$#
# param NEXTMONTH, To reminder user to input in case NEXTMONTH is not provided
NEXTMONTH=$1
[[ $ParaNm < 1 ]] && echo "请输入月份YYYYMM：" && read NEXTMONTH
# validate NEXTMONTH
if echo $NEXTMONTH | egrep "^[0-9]{4}((0[1-9]{1})|(1[0-2]{1}))$" > /dev/null 2>&1
    then :;
else
    echo "请提供正确的月份参数，格式：YYYYMM"
    exit 1
fi
# deploy path
Test_HOME=/opt/module
TEST_APPID=cc
today=$(date "+%Y-%m-%d")
# log file
LogFile=$TEST_HOME/$TEST_APPID/var/log/cc_hbase_tb_create.log.$today

##############################################################################
#
#----------------------------  main flows ------------------------------------
#
################################# check env var ##############################
if [ "$TEST_HOME" = "" ]
then
    echo "TEST_HOME not defined!"
    exit 1
fi
if [ "$TEST_APPID" = "" ]
then
    echo "TEST_APPID not defined!"
    exit 1
fi

############################## initial log file  ##############################
. ilogger.sh
lgInit  "" "" "csbss" "xx" $ProcNm $ProcNm
if [ "$?" -ne "0" ]; then
    echo "Init log file failed!"
    exit 1
fi 

############################## if exist  ######################################
if_exist()
{
    if [ $1 -eq 0 ]; then
        file_log 0 1 "创建表 $2 成功" "" "" >> $LogFile
    else
        file_log 0 1 "创建表 $2 失败" "" "" >> $LogFile
    fi
}

############################### create table  #################################
# echo "create table start !!"
file_log 0 1 "创建$NEXTMONTH月表" "" "" >> $LogFile
file_log 0 1 "create table start!!" "" "" >> $LogFile
REGINSPLITINFO10="['001|', '002|', '003|', '004|', '005|', '006|', '007|', '008|', '009|', '010|']"
REGINSPLITINFO30="['001|', '002|', '003|', '004|', '005|', '006|', '007|', '008|', '009|', '010|', '011|', '012|', '013|', '014|', '015|', '016|', '017|', '018|', '019|', '020|', '021|', '022|', '023|', '024|', '025|', '026|', '027|', '028|', '029|', '030|']"
provcd_array=("100" "220" "311" "351" "471" "240" "431" "451" "210" "250" "571" "551" "591" "791" "531" "371" "270" "731" "200" "771" "898" "280" "851" "871" "891" "290" "931" "971" "951" "991" "230")

# delete createtables.txt if it's exist
[ -f createtables.txt ] && rm createtables.txt

# PRACTISE_CC__账期月_代码
for provcd in ${provcd_array[@]}
do  
    PRACTISE_CC__PROVCD="cchb:PRACTISE_CC__"$NEXTMONTH"_"$provcd""
    echo "create '$PRACTISE_CC__PROVCD', {NAME => 'cc', COMPRESSION => 'SNAPPY', VERSIONS => '1'}, {SPLITS => $REGINSPLITINFO30}" >> createtables.txt
done

# PRACTISE_CC__账期月
PRACTISE_CC_="cchb:PRACTISE_CC__$NEXTMONTH"
echo "create '$PRACTISE_CC_', {NAME => 'cc', COMPRESSION => 'SNAPPY',VERSIONS => '1'}, {SPLITS => $REGINSPLITINFO30}" >> createtables.txt

# ERR_CDR_CC_账期月_代码
for provcd in ${provcd_array[@]}
do
    ERR_CDR_CC_PROVCD="cchb:ERR_CDR_CC_"$NEXTMONTH"_"$provcd""
    echo "create '$ERR_CDR_CC_PROVCD', {NAME => 'cc', COMPRESSION => 'SNAPPY', VERSIONS => '1'}, {SPLITS => $REGINSPLITINFO10}" >> createtables.txt
done

# PRE_SUB_CC_NEXTMONTH
PRE_SUB_CC="cchb:PRE_SUB_CC_$NEXTMONTH"
echo "create '$PRE_SUB_CC', {NAME => 'sub', COMPRESSION => 'SNAPPY',VERSIONS => '1'}, {SPLITS => $REGINSPLITINFO10}" >> createtables.txt

echo "exit" >> createtables.txt

# excute 
hbase shell createtables.txt

# remove createtables.txt
rm createtables.txt

file_log 0 1 "create table done!!" "" "" >> $LogFile
end_time=$(date +%s)
cost_time=$(($end_time - $begin_time))
echo "创建表花费 $cost_time s"
file_log 0 1 "创建表花费 $cost_time s" "" "" >> $LogFile

# 判断表是否创建成功
echo '判断表是否创建成功'
file_log 0 1 "判断创建$NEXTMONTH月表是否成功" "" "" >> $LogFile
for provcd in ${provcd_array[@]}
do  
    PRACTISE_CC__PROVCD="cchb:PRACTISE_CC__"$NEXTMONTH"_"$provcd""
    echo "exists '$PRACTISE_CC__PROVCD'" | hbase shell | grep 'does exist'
    if_exist $? $PRACTISE_CC__PROVCD
done

PRACTISE_CC_="cchb:PRACTISE_CC__$NEXTMONTH"
echo "exists '$PRACTISE_CC_'" | hbase shell | grep 'does exist'
if_exist $? $PRACTISE_CC_

for provcd in ${provcd_array[@]}
do  
    ERR_CDR_CC_PROVCD="cchb:ERR_CDR_CC_"$NEXTMONTH"_"$provcd""
    echo "exists '$ERR_CDR_CC_PROVCD'" | hbase shell | grep 'does exist'
    if_exist $? $ERR_CDR_CC_PROVCD
done

PRE_MERGE_SUB_CC="cchb:PRE_SUB_CC_$NEXTMONTH"
echo "exists '$PRE_MERGE_SUB_CC'" | hbase shell | grep 'does exist'
if_exist $? $PRE_MERGE_SUB_CC

end_time2=$(date +%s)
cost_time2=$(($end_time2 - $begin_time))
echo "总花费时长 $cost_time2 s"
file_log 0 1 "总花费时长 $cost_time2 s" "" "" >> $LogFile