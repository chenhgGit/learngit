#!/bin/sh
source /etc/profile

#统一调用发信息脚本

#版本
#2013-03-07

#添加、修改、删除短信接收人，修改tellist变量即可
tellist="13822202671"

#today=$(date "+%y%m%d %H%M%S")
today=$(date "+%Y-%m-%d %H:%M:%S")

before="你好。${today}"
after="回复TD退订"

#infodata=$1
infodata="$(echo -n "${before} $1 $after." | iconv -f gbk -t utf-8)" \
          || infodata="$(echo -n "${before}" | iconv -f gbk -t utf-8 ;echo -n " $1 "; echo -n "$after." | iconv -f gbk -t utf-8)"

telnum=$(echo $tellist | tr ',' ' ' | wc -w)

for telno in $tellist  
{

        #curl "http://61.145.116.141:8081/timersms/servlet/WebService?action=send&username=gzhk&password=123456&mobile=$telno&content=$infodata"

        curl "http://gateway.iems.net.cn/GsmsHttp?username=64564:admin&password=61789199&from=001&to=$telno&content=$infodata"
        
        # 说明:iMobiCount参数为号码个数（最大100个手机）,手机号码有几个，参数就写几，比如要发给5个手机，参数值就是5
        
        curl "http://112.91.147.37:7902/MWGate/wmgw.asmx/MongateCsSpSendSmsNew?userId=J20740&password=996638&pszMobis=$telno&pszMsg=$infodata&iMobiCount=${telnum}&pszSubPort=10657520300950320"
}

