# ~*~ coding: gbk ~*~

"""
  * Hicard database Map manager
  * This script server command console API
  * Creater: Ran Yi
"""

__doc__ = """
    from serverCmd import winconAPI
    winconsole = winconAPI()
    # show all map message
    showResult = winconsole("show")

    # check rule exist
    if not winconsole("check", ["2.2.2.2", "23"]): # if exist and return True
        pass

    # exec update
    winconsole("update", {"old":["1.1.1.1", "22", "2.2.2.2", "33"],
                                                "new":["2.2.2.2", "23", "4.4.4.4", "44"]}
                        )

    # exec delete
    winconsole("delete", ["2.2.2.2", "23"])

    # exec addition
    winconsole("add", ["1.1.1.1", "22", "2.2.2.2", "33"])
"""

from subprocess import check_output

# Excption for this file
class operateError(Exception): pass

class notResult(Exception): pass

class srcNotFind(Exception): pass

class cmdFormatError(Exception): pass

class ruleAlreadyExist(Exception): pass

class cmdExecuteError(Exception): pass

class winconAPI(object):
    """ Windows server console API  """

    def __init__(self):
        pass

    def decode(self, char):
        """ Decode charcter """

        try:
            return char.decode("utf8")
        except:
            return char.decode("gbk")

    def checkRule(self, cmd):
        """
          * Check rule exist
          * return True if rule already exist
          * and else return False
          * except "cmdFormatError", cmd format error
        """

        if cmd and isinstance(cmd, list) and len(cmd) == 2:
            try:
                if cmd in [ x[:2] for x in self.__call__("show") ]:
                    return True
            except:
                pass
        return False

    def __call__(self, operate, cmd = None):
        """
          * operate, "show" is output map message on current time
          *          "update" is execute command for argument(cmd)
          *                      and cmd is list [localip, localport, remoteip, remoteport]
          *          "delete" is execute delete command
          *                      and cmd is list [localip, localport]
          * cmd, cmd
          *
          * except operateError             # all, operate must in ["show", "add", "update", "delete", "checkRule"]
          * except notResult                # "show" operate, and no result in exec cmd
          * except srcNotFind               # "delete" operate, and not find old rule
          * except cmdFormatError           # "update" operate and delete and checkRule,
          *                                    and exec command(argv cmd) format error
          * except ruleAlreadyExist         # "add" operate, and rule already exist
          * except cmdExecuteError          # all operate, and server execute command error
        """

        if operate == "show":
            _cmd = "netsh interface portproxy show all"
            try:
                _cmdResult = self.decode(check_output(_cmd, shell = True))
            except:
                raise cmdExecuteError
            if _cmdResult:
                _availData = _cmdResult[_cmdResult.find("---\r\n") + 5:]
                _allMap = [ x for x in [ _x.split() for _x in _availData.split("\r\n") if _x ] ]
                return _allMap
            else:
                raise notResult
        elif operate == "update":
            if cmd and isinstance(cmd, dict) and \
               isinstance(cmd.get("old", None), list) and \
               isinstance(cmd.get("new", None), list) and \
               len(cmd["old"]) + 2 == len(cmd["new"])    == 4:
                if self.checkRule([cmd["new"][1], cmd["new"][2]]):
                    raise ruleAlreadyExist
                self.__call__("delete", cmd["old"])
                _cmd = "netsh interface portproxy add v4tov4 listenaddress={0} listenport={1} connectaddress={2} \
                        connectport={3} protocol=tcp".format(*cmd["new"])
                try:
                    check_output(_cmd, shell = True)
                except:
                    raise cmdExecuteError
            else:
                raise cmdFormatError
        elif operate == "delete":
            if cmd and isinstance(cmd, list) and len(cmd) == 2:
                if self.checkRule(cmd):
                    _cmd = "netsh interface portproxy delete v4tov4 listenaddress={0} listenport={1}".format(*cmd)
                    try:
                        check_output(_cmd, shell = True)
                    except:
                        raise cmdExecuteError
                else:
                    raise srcNotFind
            else:
                raise cmdFormatError
        elif operate == "add":
            if cmd and isinstance(cmd, list) and len(cmd) == 4:
                if not self.checkRule(cmd[:2]):
                    _cmd = "netsh interface portproxy add v4tov4 listenaddress={0} listenport={1} connectaddress={2} \
                            connectport={3} protocol=tcp".format(*cmd)
                    try:
                        check_output(_cmd, shell = True)
                    except:
                        raise cmdExecuteError
                else:
                    raise ruleAlreadyExist
            else:
                raise cmdFormatError
        else:
            raise operateError
