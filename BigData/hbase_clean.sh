#!/bin/bash
#-----------------------------------------------------------------------------
#
# Name: c'c_hbase_tb_clean.sh
# Description:
# This scripts is a common shell for clean hbasetable
# include PRACTISE_CC_HM_SttlDt_provcd, PRACTISE_CC_BR_SttlDt, ERR_CDR_CC_SttlDt_provcd, PRE_SUB_CC_SttlDt.
#-----------------------------------------------------------------------------
# Usage: cc_hbase_tb_clean.sh
#-----------------------------------------------------------------------------
################################ set env var #################################
# execution time
begin_time=$(date +%s)
# the name of shell script
ProcNm=`basename $0`
# the number of params are given for shell script
ParaNm=$#
# param SttlDt, To reminder user to input in case SttlDt is not provided
SttlDt=$1
[[ $ParaNm < 1 ]] && echo "请输入月份YYYYMM：" && read SttlDt
# validate SttlDt
if echo $SttlDt | egrep "^[0-9]{4}((0[1-9]{1})|(1[0-2]{1}))$" > /dev/null 2>&1
  then :;
else
  echo "请提供正确的月份参数，格式：YYYYMM";
  exit 1;
fi;
# 部署路径
TESE_HOME=/opt/moudle
TESE_APPID=cc
today=$(date "+%Y-%m-%d")
# 日志文件
LogFile=$TESE_HOME/$TESE_APPID/var/log/cc_hbase_tb_clean.log.$today

##############################################################################
#
#----------------------------- main flows ------------------------------------
#
############################### check env var ################################
if [ "$TESE_HOME" = "" ]
then
  echo "TESE_HOME not defined!"
  exit 1
fi
if [ "$TESE_APPID" = "" ]
then
  echo "TESE_APPID not defined!"
  exit 1
fi

############################## initial log file  ##############################
. ilogger.sh
lgInit  "" "" "csbss" "volte" $ProcNm $ProcNm
if [ "$?" -ne "0" ]; then
    echo "Init log file failed!"
    exit 1
fi 

############################## if exist  ######################################
if_exist()
{
    if [ $1 -ne 0 ]; then
        file_log 0 1 "删除表 $2 成功" "" "" >> $LogFile
    else
        file_log 0 1 "删除表 $2 失败" "" "" >> $LogFile
    fi
}

############################### clean table #################################
provcd_array=("100" "220" "311" "351" "471" "240" "431" "451" "210" "250" "571" "551" "591" "791" "531" "371" "270" "731" "200" "771" "898" "280" "851" "871" "891" "290" "931" "971" "951" "991" "230")
# echo "clean table start !!"
file_log 0 1 "删除清理$SttlDt表" "" "" >> $LogFile
file_log 0 1 "cLean table start!!" "" "" >> $LogFile
echo -e "disable_all 'cchb:.*"$SttlDt".*'\ny" | hbase shell 
echo -e "drop_all 'cchb:.*"$SttlDt".*'\ny" | hbase shell

echo "clean table done !!"
file_log 0 1 "cLean table done!!" "" "" >> $LogFile

end_time=$(date +%s)
cost_time=$(($end_time - $begin_time))
echo "清理表花费时间 $cost_time s"
file_log 0 1 "清理表花费时间 $cost_time s" "" "" >> $LogFile


# 判断表是否删除成功
echo '判断表是否删除成功'
for provcd in ${provcd_array[@]}
do  
    PRACTISE_CC_HM_PROVCD="cchb:PRACTISE_CC_HM_"$SttlDt"_"$provcd""
    echo "exists '$PRACTISE_CC_HM_PROVCD'" | hbase shell | grep 'does exist'
    if_exist $? $PRACTISE_CC_HM_PROVCD
done

PRACTISE_CC_BR="cchb:PRACTISE_CC_BR_$SttlDt"
echo "exists '$PRACTISE_CC_BR'" | hbase shell | grep 'does exist'
if_exist $? $PRACTISE_CC_BR

for provcd in ${provcd_array[@]}
do  
    ERR_CDR_CC_PROVCD="cchb:ERR_CDR_CC_"$SttlDt"_"$provcd""
    echo "exists '$ERR_CDR_CC_PROVCD'" | hbase shell | grep 'does exist'
    if_exist $? $ERR_CDR_CC_PROVCD
done

PRE_MERGE_SUB_CC="cchb:PRE_SUB_CC_$SttlDt"
echo "exists '$PRE_MERGE_SUB_CC'" | hbase shell | grep 'does exist'
if_exist $? $PRE_MERGE_SUB_CC

end_time2=$(date +%s)
cost_time2=$(($end_time2 - $begin_time))
echo "花费总时长 $cost_time2 s"
file_log 0 1 "花费总时长 $cost_time2 s" "" "" >> $LogFile







