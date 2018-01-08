# ~*~ coding: gbk ~*~

"""
  * Hicard database Map manager
  * This script server update MapManager server list config file
  * Creater: Ran Yi
"""

# Import server command console package
from .serverCmd import *

class updateConfig(winconAPI):
    """ Update config file """

    def __init__(self, config):
        self.config = config

    def findName(self, checkList):
        """
          * find map manager name
          * argv(checkList) is list and [local ip, port]
          * return name
        """

        _matchList = [ _x for _x in self.config() if [ self.config(_x, "LOCALIP"), \
                       self.config(_x, "LOCALPORT") ] == checkList ]
        if len(_matchList) > 0:
            return _matchList[0]
        else:
            return ""

    def checkModuleNameExists(self, name):
        """
          * find module name on this database
          * return True and is exists on database
          * return False and not exists on database
        """

        if name in self.config():
            return True
        else:
            return False

    def checkConfigRule(self, checkList):
        """
          * check rule exist
          * return True if exist
          * argv(checkList) is list
        """

        if checkList in [ [ self.config(_ipinfo, "LOCALIP"), \
                            self.config(_ipinfo, "LOCALPORT") ] \
                            for _ipinfo in self.config() ]:
            return True
        else:
            return False

    def add(self, new):
        """
          * argv(new) format
          * ['MAPTITLE', '1.1.1.1', '22', '3.3.3.3', '33', '启用', 'user', 'pass']
        """

        # analyze list and change dict
        if len(new) != 8:
            return "数据格式错误！提交长度有误！"
        addManagerName = new[0]
        addInfo = {
                 "LOCALIP" : new[1],
                 "LOCALPORT" : new[2],
                 "REMOTEIP" : new[3],
                 "REMOTEPORT" : new[4],
                 "STATUS" : new[5],
                 "CONNUSER" : new[6],
                 "CONNPASS" : new[7]
        }
        if self.checkConfigRule([addInfo["LOCALIP"], addInfo["LOCALPORT"]]) \
           or self.checkModuleNameExists(addManagerName):
            return "指定条目已存在！"
        if addInfo["STATUS"] == "启用":
            # excute server command
            try:
                self.__call__("add", [addInfo["LOCALIP"], addInfo["LOCALPORT"], \
                               addInfo["REMOTEIP"], addInfo["REMOTEPORT"]])
            except ruleAlreadyExist:
                self.sync()
                return "指定条目已存在！已执行《配置同步》"
            except cmdExecuteError:
                return "服务器执行系统指令异常！"

        # write to config file
        for _x in addInfo.keys():
            self.config(addManagerName, _x, addInfo[_x])

        return "success"

    def delete(self, old):
        """
          * argv[old] format
          * ['汇卡数据库', '192.168.1.1', '90']
        """

        if len(old) != 3:
            return "数据格式错误！提交长度有误！"
        if not self.checkConfigRule([old[1], old[2]]):
            return "指定条目不存在！"
        # get rule name
        _ruleName = self.findName([old[1], old[2]])
        # excute server command
        if self.config(_ruleName, "STATUS") == "启用":
            try:
                self.__call__("delete", [old[1], old[2]])
            except cmdExecuteError:
                return "服务器执行系统指令异常！"
            except srcNotFind:
                self.sync()
                return "源地址未找到，已执行《配置同步》"

        # write to config file
        self.config(
            _ruleName,
            delete = True
        )

        return "success"

    def update(self, old, new):
        """
          * argv[old] format
          * ['汇卡数据库', '192.168.1.1', '90']
          * argv[new] format
          * ['汇卡数据库', '192.168.1.10', '90', '1.1.1.1', '11', '启用']
        """

        # Get module name
        _oldName = self.findName([old[1], old[2]])
        _newName = new[0]

        if not self.checkConfigRule([old[1], old[2]]):
            return "指定规则不存在，源地址不存在！"

        if self.checkConfigRule([new[1], new[2]]) \
           and _oldName != self.findName([new[1], new[2]]):
            return "指定规则已存在，目标地址端口已监听！"

        if self.findName([old[1], old[2]]) != new[0] \
           and self.checkModuleNameExists(new[0]):
            return "指定模块已存在\"%s\"" % new[0]

        # check new rule
        _newRule = [new[1],new[2],new[3],new[4]]
        _status = new[5]
        _srcStatus = self.config(_oldName, "STATUS")
        _checkRuleStatus = False
        for _name in self.config():
            if _newRule == [ self.config(_name, "LOCALIP"), self.config(_name, "LOCALPORT"), \
                             self.config(_name, "REMOTEIP"), self.config(_name, "REMOTEPORT") ]:
                if _status == _srcStatus:
                    _checkRuleStatus = True
                break

        # execute server command
        if not _checkRuleStatus:
            if _srcStatus == _status == "启用":
                try:
                    self.__call__("update", {"old":[old[1],old[2]],
                                             "new":_newRule})
                except cmdExecuteError:
                    return "服务器执行系统指令异常！"
                except srcNotFind:
                    self.sync()
                    return "源地址未找到，已执行《配置同步》"
                except ruleAlreadyExist:
                    return "目标地址已存在映射，请检查！"
            elif _srcStatus == "禁用" and _status == "启用":
                try:
                    self.__call__("add", _newRule)
                except ruleAlreadyExist:
                    self.sync()
                    return "指定条目已存在！已执行《配置同步》"
                except cmdExecuteError:
                    return "服务器执行系统指令异常！"
            elif _srcStatus == "启用" and _status == "禁用":
                try:
                    self.__call__("delete", [old[1], old[2]])
                except cmdExecuteError:
                    return "服务器执行系统指令异常！"
                except srcNotFind:
                    self.sync()
                    return "源地址未找到，已执行《配置同步》"


        # write to config file
        updateInfo = {
           "LOCALIP" : new[1],
           "LOCALPORT" : new[2],
           "REMOTEIP" : new[3],
           "REMOTEPORT" : new[4],
           "STATUS" : _status,
        }

        if _oldName != _newName:
            # check new module name
            if self.config(_newName) != False:
                return "模块名[%s]已存在！" % (_newName)
            # copy source data
            for _x in self.config(_oldName):
                self.config(_newName, _x, self.config(_oldName, _x))
            self.config(_oldName, delete = True)

        # update config
        for _x in updateInfo.keys():
            self.config(_newName, _x, updateInfo[_x])

        return "success"

    def sync(self):
        """
          * sync server map list to config file
          * return True if sync ok
        """

        try:
            _mapList = self.__call__("show")
        except cmdExecuteError:
            return "服务器执行系统指令异常！"
        except notResult:
            return "指令执行获取空列表！请检查指令执行是否正常！"

        # save all module
        _allModule = []

        for _x in _mapList:
            _name = self.findName([_x[0], _x[1]])
            if not _name:
                _subfix = 1
                while True:
                    _name = "未知模块" + str(_subfix)
                    if self.config(_name) == False:
                        break
                    _subfix += 1
            updateInfo = {
                "LOCALIP" : _x[0],
                "LOCALPORT" : _x[1],
                "REMOTEIP" : _x[2],
                "REMOTEPORT" : _x[3],
                "STATUS" : "启用",
            }
            for _ud in updateInfo.keys():
                self.config(_name, _ud, updateInfo[_ud])
            _allModule.append(_name)
        # delete config and server not find
        _deleteList = [ _x for _x in self.config() if _x not in _allModule and self.config(_x, "STATUS") != "禁用" ]
        for _x in _deleteList:
            self.config(_x, delete = True)
        return "success"
