#!/bin/sh
source /etc/profile

#ͳһ���÷���Ϣ�ű�

#�汾
#2013-03-07

#��ӡ��޸ġ�ɾ�����Ž����ˣ��޸�tellist��������
tellist="13822202671"

#today=$(date "+%y%m%d %H%M%S")
today=$(date "+%Y-%m-%d %H:%M:%S")

before="��á�${today}"
after="�ظ�TD�˶�"

#infodata=$1
infodata="$(echo -n "${before} $1 $after." | iconv -f gbk -t utf-8)" \
          || infodata="$(echo -n "${before}" | iconv -f gbk -t utf-8 ;echo -n " $1 "; echo -n "$after." | iconv -f gbk -t utf-8)"

telnum=$(echo $tellist | tr ',' ' ' | wc -w)

for telno in $tellist  
{

        #curl "http://61.145.116.141:8081/timersms/servlet/WebService?action=send&username=gzhk&password=123456&mobile=$telno&content=$infodata"

        curl "http://gateway.iems.net.cn/GsmsHttp?username=64564:admin&password=61789199&from=001&to=$telno&content=$infodata"
        
        # ˵��:iMobiCount����Ϊ������������100���ֻ���,�ֻ������м�����������д��������Ҫ����5���ֻ�������ֵ����5
        
        curl "http://112.91.147.37:7902/MWGate/wmgw.asmx/MongateCsSpSendSmsNew?userId=J20740&password=996638&pszMobis=$telno&pszMsg=$infodata&iMobiCount=${telnum}&pszSubPort=10657520300950320"
}

