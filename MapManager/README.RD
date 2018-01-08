# MapManager server
# LOCALIP:LOCALPORT --> REMOTEIP:REMOTEPORT

# START PROJECT (product)
# /home/python-3.6.1/bin/uwsgi  -s /tmp/uwsgi.sock -w managerUwsgi:MMApp --workers 2 --threads 10 --master --daemonize /tmp/log.log
# need nginx support

# START PROJECT (development)
# python3.6 managerDebug.py

# Windows create service on `services.msc`
# sc create MapManagerService type= own start= auto error= critical binPath= "C:\python\bin\uwsgi  -s C:\sockpath.sock --chdir C:\apppath -w managerUwsgi:MMApp --workers 2 --threads 10 --master --daemonize C:\log.log" DisplayName= 端口映射管理中心
# start service `net start MapManagerService`
