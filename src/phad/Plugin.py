'''
Created on 16.01.2016

@author: Andreas
'''
class Plugin(object):
    '''
    classdocs
    '''

    def __init__(self, name, cycleTime=60):
        """
            Constructor
        """
        self.__name = name
        self.__cycleTime = cycleTime
        
    
    def setDeviceRegistry(self, deviceRegistry):
        self.__deviceRegistry = deviceRegistry
        
    def setConfig(self, config):
        self.__config = config
        
    def registerDevice(self, device):
        self.__deviceRegistry.registerDevice(device);
        
    def getDevice(self, address):
        return self.__deviceRegistry.getDevice(address)
    
    
    def getConfig(self):
        return self.__config
    
    def getName(self):
        return self.__name
    
    def getCycleTime(self):
        """ 
            Returns the cycle time in seconds.
        """
        return self.__cycleTime
    
    def setCycleTime(self, cycleTime):
        """
            Sets the plugins cycle time
            
            @param cycleTime: the plugins cycle time
            @type cycleTime: the cycle time in seconds
        """
        self.__cycleTime = cycleTime
    
    
    def initialize(self):
        """
           hook to initialize this plugin
        """
        pass
    
    def write(self, device, value):
        """
            Write the given value to the given device
        """
        pass
    
    def execute(self):
        """
            Execute this worker
        """
        pass        