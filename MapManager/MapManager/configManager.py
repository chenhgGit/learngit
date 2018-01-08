# ~*~ coding: gbk ~*~

"""
  * Hicard database Map manager
  * This script app config API
  * Creater: Ran Yi
"""

import configparser

class configAPI(object):
    """ App config API """

    def __init__(self, fileName):
        self.fileName = fileName

    def __call__(self, section = None, option = None, value = None, delete = None):
        configObj = configparser.ConfigParser()
        configObj.read(self.fileName)
        if delete:
            if section and option:
                if configObj.has_section(section) and configObj.has_option(option):
                    configObj.remove_option(section, option)
                    configObj.write(open(self.fileName, "w"))
                    return True
            elif section:
                if configObj.has_section(section):
                    configObj.remove_section(section)
                    configObj.write(open(self.fileName, "w"))
                    return True
            return False
        if section and option and value:
            if not configObj.has_section(section):
                configObj.add_section(section)
            configObj.set(section, option, value)
            # save config file
            configObj.write(open(self.fileName, "w"))
            return True
        elif section and option:
            if configObj.has_section(section) \
               and configObj.has_option(section, option):
                return configObj.get(section, option)
            return False
        elif section:
            if configObj.has_section(section):
                return configObj.options(section)
            return False
        else:
            return configObj.sections()
