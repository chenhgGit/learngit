# ~*~ coding: gbk ~*~

"""
  * Hicard database Map manager
  * This script server get ip address for local driver
  * Creater: Ran Yi
"""

import subprocess

def getLocalIp():
    """ Get local ip address for local driver """

    cmd = "ipconfig"
    try:
        result = subprocess.check_output(cmd, shell=True)
        try:
            result = result.decode("gbk")
        except:
            result = result.decode("utf8")

        return [ x.split(":")[1].strip() for x in result.split("\r\n") if x.find("IPv4 地址") != -1 ]
    except:
        return ["获取本地IP地址失败"]
