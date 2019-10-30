## Mysql 导入 csv 文件遇到的问题
### 1.整理 csv 文件
    a. 问题：文件中没有分隔符，列与列之间间隔的空格不一致；文件中有很多空行；
    b. 解决办法：用shell指令去除空格并添加逗号分隔符，用shell指令去除空行：
    cat 201810to201908-og_audit.csv | tr -s '[:blank:]' ',' > og_file.csv
    sed -i '/^[[:space:]]*$/d' og_file.csv

### 2. 实际工作中数据迁移有可能某列是不需要，这时我们需要去除某列
    可以基于列号来去除某列：
    去除第二列：
    $ cut -d, -f2 --complement temp.csv > done.csv
    去除多列：
    $ cut -d, -f2-4,7-9 --complement temp.csv > done.csv

### 3. 导入csv文件需要转换某些字段的类型：
    reference：http://www.mysqltutorial.org/import-csv-file-mysql-table/
    Transform data while importing
    
    导入语句：
    LOAD DATA INFILE 'd:/sttl_monthly.csv'
    INTO TABLE sttl_monthly
    FIELDS TERMINATED BY ',' ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    (@month,hm_cd,vstd_cd,chg,count,chg_dur,sttl_chg_dur)
    SET month = DATE_FORMAT(@month, "%Y%m");
    
    表中的字段列出来，在需要转换类型@字段，然后set字段中用mysql方法进行转换
    
### 4. 导入的过程中出现了字段超出表字段范围：
    Out of range value for 'chg' at row 121918;
    问题定位：表中chg字段的类型是int，查询int的取值范围是：-2147483648 and 2147483647
    导入的数据中该值是3199080506  超过了int的范围，所以该字段需要改成bigint类型

## 5. ERROR 1290（HY000):The mysql server is running with the secure -file -priv
    解决方案：使用 show variables like ‘%secure%’ 查看当前值，如果没有 secure-fire-priv这一项或者这一项指定了可导入的文件路径，则需要在安装 mysql
    路径下找到my.ini 文件，在 [mysqlid]中加入secure-file-priv=‘’；或者将需要导入的文件放在 secure-fire-priv指定的文件路径下。
### 6. 如果是远程连接数据库，导入导出可能报错：找不到文件
    需要在导入语句中加入 LOCAL 关键字，如果指定 LOCAL 关键字，从客户主机读文件，如果没有指定，导入的文件必须在服务器上。
### 7. ERROR: lost connection to MYSQL server during query.
    我遇到的错误原因是导入的csv文件名和导入语句中的文件名不一致。




