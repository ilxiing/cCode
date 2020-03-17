#!/bin/bash
db_date = $2
db_name = gmall

# sqoop 导入命令
import_data(){
	/opt/module/sqoop/bin/sqoop import
	--connect jdbc:mysql://hadoop103:3306/db_name
	--username root
	--password 123456
	--target-dir /original_data/db_name/db/$1/$db_date
	--delete-target_dir
	--nums-mappers 1
	--fields-terminated-by "\t"
	--query "$2" 'and $CONDITIONS;'
}

# 导入商品表
import_sku_info(){
	import_data() "sku_info" "select 
	id, 
	sku_id, 
	spu_name, 
	weight, 
	category3_id, 
	create_time 
	from sku_info where 1=1"
}

# 导入用户表
import_user_info(){
	import_data() "user_info" "select 
	id, 
	name, 
	birthday, 
	email, 
	create_time 
	from user_info where 1=1"
}


# 导入订单表 新增及变化的
import_order_info(){
	import_data() "order_info" "select
	id,
	total_amount,
	order_status,
	user_id,
	payment_way,
	create_time
	from order_info where 
	(DATE_FORMAT(create_time,'%Y-%m-%d')='$db_date' or DATE_FORMAT(operate_time,'%Y-%m-%d')='$db_date')"
}


case $1 in
	"sku_info")
		import_sku_info
;;
	"user_indo")
		import_user_info
;;
	"order_info")
		import_order_info
;;
	"all")
		import_sku_info
		import_user_info
		import_order_info
;;
esac
