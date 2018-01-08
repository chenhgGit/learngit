#!/usr/bin/env python3.6
# ~*~ coding: gbk ~*~

"""
  * Hicard database Map manager
  * This script app manager
  * Creater: Ran Yi
"""

import os, sys, re
from flask import json
from flask import Flask
from flask import request
# from .serverCmd import winconAPI
from flask import render_template
from .getLocalIp import getLocalIp
# from flask_session import Session
from subprocess import check_output
from .configManager import configAPI
from .configUpdate import updateConfig
from flask import redirect, url_for, session

# get config full path
def getFullPath(path):
    return os.path.join(os.path.realpath(os.path.dirname(sys.argv[0])), path)

# get config file
configFile = configAPI(getFullPath("MapManager/config/MapManagerConfig.conf"))
userAuthConfig = configAPI(getFullPath("MapManager/config/userConfig.conf"))
serverListConfig = configAPI(getFullPath("MapManager/config/serverList.conf"))

# get windows server console
# winconsole = winconAPI()

# get windows server command and config API
wsacAPI = updateConfig(serverListConfig)

# easy config operate
conconsole = updateConfig(serverListConfig)

# get title for PAGE and init default object
defaultElement = {}
for _x in configFile("pageTemplate"):
    defaultElement[_x] = configFile("pageTemplate", _x)

# get init server var
_initVar = { "import_name" : __name__ }
for _x in configFile("appConfig"):
    _initVar[_x] = configFile("appConfig", _x)

MMApp = Flask(**_initVar)

@MMApp.route("/login", methods = ["POST"])
def login():
    """ login page """

    _user = session.get("authUser", None)
    if _user:
        return redirect("/" + _user)
    if request.method == "POST":
        try:
            jsonData = json.loads([ data for data in dict(request.form).keys() ][0])
        except Exception as _e:
            MMApp.logger.warn("客户端地址： [%s]， 登录表单数据无效 [%s]， 异常信息 [%s]" %
                             (request.remote_addr, request.form, _e))
            return "数据格式错误！"

        _loginUser = jsonData.get("userAuth", None)
        _loginPass = jsonData.get("passAuth", None)
        if (userAuthConfig(_loginUser, "password") == _loginPass != False):
            MMApp.logger.debug("用户：[%s]， 客户端地址： [%s]， 登录成功！"%(_loginUser, request.remote_addr))
            session["authUser"] = _loginUser
            if session["authUser"] == "admin":
                session["SYSTEM"] = True
            else:
                session["SYSTEM"] = False
            return "success"
        else:
            MMApp.logger.warn("用户： [%s]， 客户端地址： [%s]， 登录系统失败，用户名或者密码错误！" % 
                             (_loginUser, request.remote_addr))
            return "用户名或者密码错误！"
    # return "错误的请求！"

@MMApp.route("/logout")
def logout():
    """ logout page """

    if session.get("authUser", None):
        del session["authUser"]
    return redirect("/")

# Filter invalid form data
ipRegExp = re.compile("^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$")  # IP verify
portRegExp = re.compile("^[0-9]{1,5}$")                                    # PORT verify
mapNameRegExp = re.compile("[\[\]\(\)&%\'\"]")                             # MODULE NAME verify

@MMApp.route("/operate", methods = ["POST"])
def operate():
    """ operate server """

    if session.get("authUser", None) != "admin":
        return "抱歉！您无权操作服务器！"

    if request.method == "POST":
        try:
            jsonData = json.loads([ data for data in dict(request.form).keys() ][0])
        except Exception as _e:
            MMApp.logger.warn("客户端地址： [%s]， 操作JSON数据无效 [%s]， 异常信息 [%s]" %
                             (request.remote_addr, request.form, _e))
            return "数据格式错误！"

        # check JSON old and new data
        _oldData = jsonData.get("operateJsonOld", "")
        _newData = jsonData.get("operateJsonNew", "")
        oldCheck = False; newCheck = False     # init state check

        try:
            if ipRegExp.search(_oldData[1]) and portRegExp.search(_oldData[2]):
                oldCheck = True
        except:
            pass

        try:    
            if ipRegExp.search(_newData[1]) and portRegExp.search(_newData[2]) and \
               ipRegExp.search(_newData[3]) and portRegExp.search(_newData[4]) and \
               _newData[5] in ["启用", "禁用"]:
                newCheck = True
        except:
            pass

        _operate = jsonData["operate"]

        if _operate == "update":                                 # 更新服务器转发规则
            if not oldCheck:
                return "原始信息有误，请先执行《配置更新》！"
            if not newCheck:
                return "数据有误，请更正后再试！"
            if not _newData[0]:
                return "[管理名称]不能为空！"
            elif mapNameRegExp.search(_oldData[0]) or mapNameRegExp.search(_newData[0]):
                return "[管理名称]不能带有这些符号：" + mapNameRegExp.pattern
            return wsacAPI.update(_oldData, _newData)
            
        elif _operate == "delete":                               # 删除服务器转发规则
            if not oldCheck:
                return "数据格式错误，无法进行操作！"
            return wsacAPI.delete(_oldData)

        elif _operate == "add":                                  # 添加服务器转发规则
            if not newCheck:
                return "数据有误，请更正后再试！"
            if not _newData[0]:
                return "[管理名称]不能为空！"
            elif mapNameRegExp.search(_newData[0]):
                return "[管理名称]不能带有这些符号：" + mapNameRegExp.pattern
            return wsacAPI.add(_newData)

        elif _operate == "refreshConfig":                        # 手动同步服务器规则到本地数据库
            return wsacAPI.sync()

        elif _operate == "restartIPHELPER":                      # 重启IPHELPER服务
            try:
                try:
                    check_output("net stop iphlpsvc", shell = True)         # stop Ip Helper Service
                except:
                    pass
                check_output("net start iphlpsvc", shell = True)            # start Ip Helper Service
                return "success"
            except Exception as _e:
                return "重启失败，" + str(_e)

@MMApp.route("/")
@MMApp.route("/<username>")
def index(username = None):
    """ index page """

    _user = session.get("authUser", None)
    if _user:
        if _user != username:
            return redirect("/" + _user)
        # 获取用户模块列表
        _userModule = []
        _userModuleAll = userAuthConfig(_user, "module")

        # 获取服务器映射列表
        allSvrList = serverListConfig()

        if _userModuleAll.upper() == "ALL" or _user == "admin":
            _userModule = [ x for x in allSvrList if x.strip() ]
        else:
            for _umx in [ _x.strip() for _x in _userModuleAll.split(",") ]:
                if _umx and _umx not in _userModule:
                    for _svrMapList in allSvrList:
                        if re.compile("^" + _umx + "$").search(_svrMapList):
                            _userModule.append(_svrMapList)

        if _userModule:
            # 获取该用户所有模块
            _allModuleInfo = {}
            for _aminfox in _userModule:
                _allModuleInfo[_aminfox] = {}
                for _moption in serverListConfig(_aminfox):
                    _allModuleInfo[_aminfox][_moption] = serverListConfig(_aminfox, _moption)
            if _allModuleInfo:
                return render_template(
                           "index.html",
                           **defaultElement,
                           user = _user,
                           SYSTEM = session["SYSTEM"],
                           userModule = _allModuleInfo,
                           localIpList = getLocalIp()
                       )
        return render_template(
                   "index.html",
                   **defaultElement,
                   user = _user,
                   SYSTEM = session["SYSTEM"],
                   userModule = False
               )
    else:
        return render_template("index.html", **defaultElement)
