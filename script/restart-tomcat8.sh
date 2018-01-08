#!/bin/bash -
#OrderServer restart script
source /etc/profile
export LANG=zh_CN.GB18030
TOMCAT_PATH="/usr/apache-tomcat-8.0.23/"
TOMCAT_WORK="${TOMCAT_PATH}work/Catalina"
cd ${TOMCAT_PATH}/webapps
deamon_user='root'
CHOWN_NGINX()
{
	/bin/echo  "Change Owner Permission:${deamon_user}"
	/bin/chown -R ${deamon_user}.${deamon_user} ${TOMCAT_PATH}
}
CHECK_PID()
{
	TOMCAT_PID=`/bin/ps -ef | /bin/grep ${TOMCAT_PATH} | /bin/grep -v "/bin/grep"| /bin/awk '{print($2)}'`
	TOMCAT_PID_STATUS=${TOMCAT_PID:=0}
}
CHECK_PID
if [ ! "${TOMCAT_PID_STATUS}" == "0" ]
then
	/bin/echo -n "Shutdown Tomcat"
	/bin/kill -9  $TOMCAT_PID_STATUS &> /dev/null
	CHECK_PID
	if [ "${TOMCAT_PID_STATUS}" == "0" ]
	then
		/usr/bin/printf "%30s\n" "[OK]"
	else
		/usr/bin/printf "%30s\n" "[FAILED]"
		exit 1

	fi
	if [ -e ${TOMCAT_WORK} ]
	then
		echo "Clear Cache"
		/bin/rm -rf ${TOMCAT_WORK} &> /dev/null
	fi
	CHOWN_NGINX
        /bin/sleep 3
	/bin/echo -n "Start Tomcat"
	su -s "/bin/bash" -c "/bin/sh ${TOMCAT_PATH}bin/startup.sh" ${deamon_user} &> /dev/null
	CHECK_PID
	if [ ! "${TOMCAT_PID_STATUS}" == "0" ]
	then
		/usr/bin/printf "%33s\n" "[OK]"
	else
		/usr/bin/printf "%33s\n" "[FAILED]"
		exit 1
	fi
else
	/bin/echo "NOT Tomcat PID"
	if [ -e ${TOMCAT_WORK} ]
	then
		/bin/echo "Clear Cache"
		/bin/rm -rf ${TOMCAT_WORK} &> /dev/null
	fi
	CHOWN_NGINX
	/bin/echo -n "Start Tomcat"
	su -s "/bin/bash" -c "/bin/sh ${TOMCAT_PATH}bin/startup.sh" ${deamon_user} &> /dev/null
	CHECK_PID
	if [ ! "${TOMCAT_PID_STATUS}" == "0" ]
	then
		/usr/bin/printf "%33s\n" "[OK]"
	else
		/usr/bin/printf "%33s\n" "[FAILED]"
		exit 1
	fi
fi
/bin/echo -n "Daemon User:"
/bin/ps -ef | /bin/grep ${TOMCAT_PATH} | /bin/grep -v "/bin/grep"| /bin/awk '{print($1)}'
