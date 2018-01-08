#!/bin/bash
#Monitor Script
#Monitor the IP, port, URL, restart script, item name on the host
#Author: chen
#Time: 2017.10

. /etc/profile 
cd `dirname $0`
#defining argument
date=$(date '+%Y-%m-%d')
time=$(date '+%H:%M:%S')
workdir=/root/script/monitorservice
logdir=${workdir}/log
check_http=$workdir/check_http
servicelist=$workdir/monitortask.list
tmpfile=${workdir}/tmp_file
reval="$?"
user=`id -un`
if [ ! -d ${logdir} ]; then
    mkdir -p ${logdir}
    chown $user ${logdir}
    chmod -R 755 ${logdir}
fi
checktime=$(cat ${servicelist} |grep -v grep |grep "checktime" |awk -v FS="=" '{print $2}')

#Defining the sendmessage function
sendmessage()
{   #Calling sendmessage scripe
    sh /root/script/info_takeok.sh "$*" > /dev/null 2>&1
}

#Defining the check service
checkservice()
{
    #Cycle detection three times
    i=1
    while ((i<=3))
    do 
        #Check_http's -N means only output header information.
        ${check_http} -H $1 -p $2 -u $3  -c $4 -N    
        #check up sleep 3 Seconds
        sleep 3
        let i++
    done
  
}

#Define the function of the main inspection service
main_monitor()
{
    #The comment line and blank line in the filter service list
    sed -e 's/^\#.*$//g' -e '/^$/d' ${servicelist} >${tmpfile}

    rerurn_head_file=${logdir}/returnfile.txt
    if [ -s ${rerurn_head_file} ]; then
        rm -rf ${rerurn_head_file}
    fi

    #Start line by line check
    echo -e "\n\n"
    echo -e "\033[32mStarting checking,current time ${date} ${time}.....\033[0m" >>${logdir}/main_monitor_${date}.log
    #start.......
    while read serline
    do
        #field separator
        IFS="|"

        #Combinatorial array
        array=($serline)
        ip=${array[0]}
        port=${array[1]}
        urlname=${array[2]}
        restart_script=${array[3]}
        project_name=${array[4]}
    
        #all checkservice function
        checkservice ${ip} ${port} ${urlname} ${checktime} >> ${rerurn_head_file}
        #Insert item name temporarily
        sed -i "s/^HTTP/${project_name}\ &/g" ${rerurn_head_file}
        #Defineing return strings
        definestr="${project_name} HTTP OK"
        #Get URL header return information
        res_tr=`grep -o -P "[[:alnum:]]+?.*\ HTTP\ [a-zA-Z0-9]+" ${rerurn_head_file} |egrep "${project_name}" |tail -1`
        #Determine the header information characters returned by URL
        if [ "${res_tr}" == "${definestr}" ]
        then
            echo -e "\033[32m${ip}:${port} 项目:${project_name} URL=${urlname}  is OK\033[0m"
        else
            echo "URL anomaly detected"
            echo -e "\033[31m${ip}:${port} 项目:${project_name} URL=${urlname} is unavailable or exception, Please detecting or restarting applications!\033[0m"
            #Calling Restart Script to Restart the application"
            echo -e "\033[34m++++++++++++++++++\033[1m"
            countport=$(netstat  -ntlp |grep ${port} |wc -l)
            if [ -x ${restart_script} ]; then
                /bin/bash ${restart_script}
            else
               chmod a+x ${restart_script} 
               /bin/bash ${restart_script}
            fi
            echo -e "\033[34m++++++++++++++++++\033[0m"
            sleep 8

            #Re test 
            logfile=${logdir}/tmp.txt
            > $logfile
            #Loop chekct tow times
            checkservice ${ip} ${port} ${urlname} ${checktime} >>$logfile
            #Insert item name temporarily
            sed -i "s/^HTTP/${project_name}\ &/g" ${logfile}
            #Defineing return strings
            unset okstr
            unset restr
            okstr="$project_name HTTP OK"
            #Get URL header return information
            restr=`grep -o -P "[[:alnum:]]+?.*\ HTTP\ [a-zA-Z0-9]+" ${logfile} | grep "${project_name}"|  sed -n '$p'`
            #If the HTTP OK is returned in the header information..., the Tomcat succeeds in restarting the application,
            if [ "${restr}" = "${okstr}" ]
            then
                #Sending messages to system manager
	        message="${ip}:${port} 项目:${project_name} URL=${urlname} is  unavailability or exception,,The application has been restarted successfully!"
                echo -e "\033[32m${message}\033[0m"
                sendmessage "$message" 
            else 
                #Otherwise, the failure to restart Tomcat is indicated
      	        message="${ip}:${port} 项目:${project_name} URL=${urlname} is unavailability or exception,The application has been restarted failed,Please check!"
	        echo -e "\033[31m${message}\033[0m"
	        sendmessage "${message}"
            fi
        fi
	sleep 2
  done < ${tmpfile}
  
  #Delete temporary files
  for flog in `find ${logdir} -name '*.txt' -or -name '*.log' -mtime +3`
  do 
      if [ -s $glog ]
      then 
          rm -rf $flog 
      fi 
  done  
	
} 
main_monitor>>${logdir}/main_monitor_${date}.log
if [ $? -eq 0 ]
then
    echo -e "\n"
    echo -e "\033[35mService detection completed! present time ${date} ${time}.\033[0m\n\n\n" >>${logdir}/main_monitor_${date}.log
    echo -e "\n\n\n"
fi
