#!/bin/bash -
. /etc/profile
LANG=zh_CN.UTF-8
time1=`date +%Y-%m-%d`
time2=`date +%Y%m%d`
dir=$(cd `dirname $0`; pwd)
cd $dir
###去重以及格式化原始文件
sed -i  's/[*,X]/x/g'  $dir/xx.txt && awk -F@ '{for(i=1;i<=16;i++)printf $i""FS;print""}' $dir/xx.txt|sort |uniq >$dir/xx.tmp

awk -F'@' '{print $10,$14}' $dir/xx.tmp|sort |uniq -d >$dir/repeat.tmp
awk -F'@' '{print $10,$14}' $dir/xx.tmp|sort |uniq -u >$dir/no_repeat.tmp
>$dir/card_bin.sql
####处理同时有2磁和3磁的卡
#>$dir/shuangci.sql
>$dir/repeat.txt
>$dir/repeat.txt-bak
>$dir/newreck.bd_cardbin.sql
echo "INSERT INTO \`card_bin\` (bank_inst_code,bank_name,card_name,card_func,trk_flag,trk1_startpos,trk1_len,trk2_startpos,trk2_len,trk3_startpos,trk3_len,acct_startpos,acct_len,acct_acct,acct_trkno,issue_startpos,issue_len,issue_data,issue_trkno,card_type,cardbin_seq,cardbin_date,cardbin_ver) VALUES ('01000001','Hi-Card','企业E卡','3','11',NULL,NULL,2,37,2,104,2,18,'978881xxxxxxxxxxxx',2,2,6,'978881',2,'0',32529,'2016-02-26','20130225');" | tee $dir/card_bin.sql > /dev/null
echo "insert into newreck.bd_cardbin (issue_data, card_type) values ('978881','0');" | tee  $dir/newreck.bd_cardbin.sql > /dev/null
while read line ;do
   echo $line>>$dir/repeat.txt-bak
   a=`echo $line|awk '{print $1}'`
   b=`echo $line|awk '{print $2}'`
   grep -w $a $dir/xx.tmp|grep -w $b>>$dir/repeat.txt
   bank_inst_code=$( grep -w $a $dir/xx.tmp|grep -w $b|sort|head -n1|awk -F'@' '{print $1}'|grep -Eo '[0-9]+')
   bank_name=$( grep -w $a $dir/xx.tmp|grep -w $b|sort|head -n1|awk -F'@' '{print $1}'|awk '{print $1}')
   card_name=$( grep -w $a $dir/xx.tmp|grep -w $b|sort|head -n1|awk -F'@' '{print $2}')
   card_func=3
   trk_flag=11
   trk2_startpos=$( grep -w $a $dir/xx.tmp|grep -w $b|sort|head -n1|awk -F'@' '{print $6}')
   trk2_len=$( grep -w $a $dir/xx.tmp|grep -w $b|sort|head -n1|awk -F'@' '{print $7}')
   trk3_startpos=$( grep -w $a $dir/xx.tmp|grep -w $b|sort -rn|head -n1|awk -F'@' '{print $6}')
   trk3_len=$( grep -w $a $dir/xx.tmp|grep -w $b|sort -rn|head -n1|awk -F'@' '{print $7}')
   acct_startpos=$( grep -w $a $dir/xx.tmp|grep -w $b|sort|head -n1|awk -F'@' '{print $8}')
   acct_len=$( grep -w $a $dir/xx.tmp|grep -w $b|sort|head -n1|awk -F'@' '{print $9}')
   acct_acct=$( grep -w $a $dir/xx.tmp|grep -w $b|sort|head -n1|awk -F'@' '{print $10}')
   acct_trkno=$( grep -w $a $dir/xx.tmp|grep -w $b|sort|head -n1|awk -F'@' '{print $11}')
   issue_startpos=$( grep -w $a $dir/xx.tmp|grep -w $b|sort|head -n1|awk -F'@' '{print $12}')
   issue_len=$( grep -w $a $dir/xx.tmp|grep -w $b|sort|head -n1|awk -F'@' '{print $13}')
   issue_data=$( grep -w $a $dir/xx.tmp|grep -w $b|sort|head -n1|awk -F'@' '{print $14}')
   issue_trkno=$( grep -w $a $dir/xx.tmp|grep -w $b|sort|head -n1|awk -F'@' '{print $15}') 
   aa=$( grep -w $a $dir/xx.tmp|grep -w $b|sort|head -n1|awk -F'@' '{print $16}')
   case "x$aa" in
	"x借记卡")
		NEWRECK_CARD_TYPE=0;;
	"x预付费卡")
		NEWRECK_CARD_TYPE=3;;
	"x准贷记卡")
		NEWRECK_CARD_TYPE=2;;
	"x贷记卡")
		NEWRECK_CARD_TYPE=1;;
   esac
   /bin/echo "insert into newreck.bd_cardbin (issue_data, card_type) values ('${issue_data}','${NEWRECK_CARD_TYPE}');" >> $dir/newreck.bd_cardbin.sql
   if [ "$aa" = "借记卡" ]|| [ "$aa" = "预付费卡" ];then
	card_type="0"
   fi
   if [ "$aa" = "准贷记卡" ];then
        card_type="1"
   fi
   if [ "$aa" = "贷记卡" ];then
        card_type="2"
   fi
   #cardbin_seq:auto_increment
   cardbin_date=`date +%Y-%m-%d`
   cardbin_ver=`date +%Y%m%d`
   echo "insert into card_bin(\`bank_inst_code\`,\`bank_name\`,\`card_name\`,\`card_func\`,\`trk_flag\`,\`trk2_startpos\`,\`trk2_len\`,\`trk3_startpos\`,\`trk3_len\`,\`acct_startpos\`,\`acct_len\`,\`acct_acct\`,\`acct_trkno\`,\`issue_startpos\`,\`issue_len\`,\`issue_data\`,\`issue_trkno\`,\`card_type\`,\`cardbin_date\`,\`cardbin_ver\`)values(\""$bank_inst_code"\",\""$bank_name"\",\""$card_name"\",\""$card_func"\",\""$trk_flag"\",\""$trk2_startpos"\",\""$trk2_len"\",\""$trk3_startpos"\",\""$trk3_len"\",\""$acct_startpos"\",\""$acct_len"\",\""$acct_acct"\",\""$acct_trkno"\",\""$issue_startpos"\",\""$issue_len"\",\""$issue_data"\",\""$issue_trkno"\",\""$card_type"\",\""$cardbin_date"\",\""$cardbin_ver"\");">>$dir/card_bin.sql
done<$dir/repeat.tmp

####处理单磁卡
#>$dir/danci.sql
>$dir/no_repeat.txt
>$dir/no_repeat.txt-bak
while read line ;do
   echo $line>>$dir/no_repeat.txt-bak
   a=`echo $line|awk '{print $1}'`
   b=`echo $line|awk '{print $2}'`
   grep -w $a $dir/xx.tmp|grep -w $b>>$dir/no_repeat.txt
   bank_inst_code=$( grep -w $a $dir/xx.tmp|grep -w $b|awk -F'@' '{print $1}'|grep -Eo '[0-9]+')
   bank_name=$( grep -w $a $dir/xx.tmp|grep -w $b|awk -F'@' '{print $1}'|awk '{print $1}')
   card_name=$( grep -w $a $dir/xx.tmp|grep -w $b|awk -F'@' '{print $2}')
   card_func=3
   trk_flag=10
   trk2_startpos=$( grep -w $a $dir/xx.tmp|grep -w $b|awk -F'@' '{print $6}')
   trk2_len=$( grep -w $a $dir/xx.tmp|grep -w $b|awk -F'@' '{print $7}')
   acct_startpos=$( grep -w $a $dir/xx.tmp|grep -w $b|awk -F'@' '{print $8}')
   acct_len=$( grep -w $a $dir/xx.tmp|grep -w $b|awk -F'@' '{print $9}')
   acct_acct=$( grep -w $a $dir/xx.tmp|grep -w $b|awk -F'@' '{print $10}')
   acct_trkno=$( grep -w $a $dir/xx.tmp|grep -w $b|awk -F'@' '{print $11}')
   issue_startpos=$( grep -w $a $dir/xx.tmp|grep -w $b|awk -F'@' '{print $12}')
   issue_len=$( grep -w $a $dir/xx.tmp|grep -w $b|awk -F'@' '{print $13}')
   issue_data=$( grep -w $a $dir/xx.tmp|grep -w $b|awk -F'@' '{print $14}')
   issue_trkno=$( grep -w $a $dir/xx.tmp|grep -w $b|awk -F'@' '{print $15}') 
   aa=$( grep -w $a $dir/xx.tmp|grep -w $b|awk -F'@' '{print $16}')
   case "x$aa" in
        "x借记卡")
                NEWRECK_CARD_TYPE=0;;
        "x预付费卡")
                NEWRECK_CARD_TYPE=3;;
        "x准贷记卡")
                NEWRECK_CARD_TYPE=2;;
        "x贷记卡")
                NEWRECK_CARD_TYPE=1;;
   esac
   /bin/echo "insert into newreck.bd_cardbin (issue_data, card_type) values ('${issue_data}','${NEWRECK_CARD_TYPE}');" >> $dir/newreck.bd_cardbin.sql
   if [ "$aa" = "借记卡" ]|| [ "$aa" = "预付费卡" ];then
        card_type="0"
   fi
   if [ "$aa" = "准贷记卡" ];then
        card_type="1"
   fi
   if [ "$aa" = "贷记卡" ];then
        card_type="2"
   fi
   #cardbin_seq:auto_increment
   cardbin_date=`date +%Y-%m-%d`
   cardbin_ver=`date +%Y%m%d`
   echo "insert into card_bin(\`bank_inst_code\`,\`bank_name\`,\`card_name\`,\`card_func\`,\`trk_flag\`,\`trk2_startpos\`,\`trk2_len\`,\`acct_startpos\`,\`acct_len\`,\`acct_acct\`,\`acct_trkno\`,\`issue_startpos\`,\`issue_len\`,\`issue_data\`,\`issue_trkno\`,\`card_type\`,\`cardbin_date\`,\`cardbin_ver\`)values(\""$bank_inst_code"\",\""$bank_name"\",\""$card_name"\",\""$card_func"\",\""$trk_flag"\",\""$trk2_startpos"\",\""$trk2_len"\",\""$acct_startpos"\",\""$acct_len"\",\""$acct_acct"\",\""$acct_trkno"\",\""$issue_startpos"\",\""$issue_len"\",\""$issue_data"\",\""$issue_trkno"\",\""$card_type"\",\""$cardbin_date"\",\""$cardbin_ver"\");">>$dir/card_bin.sql
done<$dir/no_repeat.tmp

###添加汇卡card_bin
  echo "INSERT INTO card_bin(\`bank_inst_code\`,\`bank_name\`,\`card_name\`,\`card_func\`,\`trk_flag\`,\`trk2_startpos\`,\`trk2_len\`,\`trk3_startpos\`,\`trk3_len\`,\`acct_startpos\`,\`acct_len\`,\`acct_acct\`,\`acct_trkno\`,\`issue_startpos\`,\`issue_len\`,\`issue_data\`,\`issue_trkno\`,\`card_type\`,\`cardbin_date\`,\`cardbin_ver\`) VALUES ('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'922280xxxxxxxxxxxxx',2,2,6,'922280',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'628880xxxxxxxxxxxxx',2,2,6,'628880',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'123450xxxxxxxxxxxx',2,2,6,'123450',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,14,'928882xxxxxxxx',2,2,6,'928882',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'510000xxxxxxxxxxxx',2,2,6,'510000',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'628882xxxxxxxxxxxx',2,2,6,'628882',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'899260xxxxxxxxxxxx',2,2,6,'899260',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'921282xxxxxxxxxxxx',2,2,6,'921282',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'921280xxxxxxxxxxxx',2,2,6,'921280',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'922999xxxxxxxxxxxx',2,2,6,'922999',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'926869xxxxxxxxxxxx',2,2,6,'926869',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'926889xxxxxxxxxxxx',2,2,6,'926889',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'928760xxxxxxxxxxxx',2,2,6,'928760',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'958880xxxxxxxxxxxx',2,2,6,'958880',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'966889xxxxxxxxxxxx',2,2,6,'966889',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'968880xxxxxxxxxxxx',2,2,6,'968880',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'968889xxxxxxxxxxxx',2,2,6,'968889',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'978880xxxxxxxxxxxx',2,2,6,'978880',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'928891xxxxxxxxxxxx',2,2,6,'928891',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'998880xxxxxxxxxxxx',2,2,6,'998880',2,'0','2014-10-09','20130225'),('01000001','Hi-Card','企业E卡','3','11',2,37,2,104,2,18,'528880xxxxxxxxxxxx',2,2,6,'528880',2,'0','2014-10-09','20130225');">>$dir/card_bin.sql

  echo "INSERT INTO card_bin(\`bank_inst_code\`,\`bank_name\`,\`card_name\`,\`card_func\`,\`trk_flag\`,\`trk2_startpos\`,\`trk2_len\`,\`trk3_startpos\`,\`trk3_len\`,\`acct_startpos\`,\`acct_len\`,\`acct_acct\`,\`acct_trkno\`,\`issue_startpos\`,\`issue_len\`,\`issue_data\`,\`issue_trkno\`,\`card_type\`,\`cardbin_date\`,\`cardbin_ver\`) VALUES('20110308','广东汇卡商务服务有限公司','企业E卡','3','11',2,37,2,104,2,18,'92888xxxxxxxxxxxxx',2,2,5,'92888',2,'0','2014-10-09','20130225');">>$dir/card_bin.sql

#                                   适用范围  磁道信息             主帐号                            发卡行标识
#发卡行名称及机构代码	卡名         ATM@POS  磁道 起始字节 长度   起始字节  长度  主帐号  读取磁道  起始字节  长度  取值  读取磁道   卡种  
####中国银行(01040000)@ 中银威士信用卡@(@√)@ (2@2@37)@            (2@16@409671xxxxxxxxxx@2)@        (2@6@409671@2)@                  贷记卡@@
#0-???? 借记卡 @1-???? 准贷记卡 @2-???? 贷记卡"
