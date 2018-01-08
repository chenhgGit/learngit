#!/usr/bin/python3.6
# ~*~ coding: gbk ~*~

"""
  * Hicard database Map manager
  * This script app service manager
  * Start Method as python + flask, and development mode
  * Creater: Ran Yi
"""

import os
import sys
from flask_session import Session
from MapManager import MMApp, configFile

# change dir to this file dir
os.chdir(os.path.dirname(os.path.realpath(sys.argv[0])))

# set key
# MMApp.secret_key = os.urandom(24)
MMApp.secret_key = b'\xff\x08\x9d\xc0\x95\xcd\xfe\x10)\x02>\xf3\xc4mQj\xb45(c\x1b{\xed\xd5'
print(repr("App secret key: %s"%(MMApp.secret_key)))

# set session method and filesystem
MMApp.config['SESSION_TYPE'] = "filesystem"
# app.config['SESSION_FILE_DIR'] = tempfile.gettempdir()
MMApp.config['SESSION_FILE_DIR'] = "C:\\MapManager\\MapManager\\session"
Session(MMApp)

# get start var
starting = {}
for _x in configFile("appRunConfig"):
    starting[_x] = configFile("appRunConfig", _x)

# optimize option
starting["port"] = int(starting["port"])     # port, str --> integer
starting["debug"] = True if starting["debug"].upper() == "ON" \
                         else False                             # debug, str --> boolean

# enable thread process
starting['threaded'] = True

# start server
MMApp.run(**starting)
