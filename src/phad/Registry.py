'''
Created on 19.01.2016

@author: Andreas
'''
from inspect import isclass
import logging

from pluginloader import PluginLoader

from phad.Plugin import Plugin


class DeviceRegistry(object):
    '''
    classdocs
    '''

    def __init__(self):
        '''
        Constructor
        '''
        self.__devices = {}
        self.__logger = logging.getLogger("DeviceRegistry")
    
    def registerDevice(self, device):
        self.__logger.debug("Registering device: %s" % device.getAddress())
        self.__devices[device.getAddress()] = device
        
    
    def getDevice(self, address):
        return self.__devices[address]


class PluginRegistry(object):
    """
    """
    
    def __init__(self, deviceRegistry):
        """
        """
        self.__deviceRegistry = deviceRegistry
        self.__logger = logging.getLogger("PluginRegistry")
        self.__pluginsloader = PluginLoader()
        self.__plugins = []
        
    def __isPlugin(self, name, clazz):
        #print ("Checking %s (%s)" % (name, clazz)) 
        return isclass(clazz) and issubclass(clazz, Plugin) and clazz != Plugin
    
    def getPlugins(self):
        return self.__plugins
    
    def initialize(self, directory):
        self.__pluginsloader.load_directory(directory, onlyif=self.__isPlugin, 
                                            context={'deviceRegistry': self.__deviceRegistry})
        for name, plugin in self.__pluginsloader.plugins.iteritems():
            self.__logger.debug("Loading plugin: %s" % name)
            inst = plugin()
            inst.setDeviceRegistry(self.__deviceRegistry)
            self.__plugins.append(inst)
    