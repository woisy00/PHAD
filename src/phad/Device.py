'''
Created on 16.01.2016

@author: Andreas
'''
from phad.Observable import Observable

class Device(Observable):
    '''
    classdocs
    '''

    def __init__(self, plugin, address, dptid):
        """ Create a new Device
            @param address: the address of the device
            @type address: string
            
            @param dptid: the KNX datapointid of this device
            @type dptid: string in format \d.\d+
        """
        super(Device, self).__init__()
        self.__plugin = plugin
        self.__address = address
        self.__dpt = dptid #phad.dpt.dptvalues.getDPT(dptid)
        self.__value = None
        

    def getPlugin(self):
        return self.__plugin
    
    def getAddress(self):
        return self.__address
    
    def getDPT(self):
        return self.__dpt
    
    def getValue(self):
        return self.__value
    
    def setValue(self, value):
        oldValue = self.__value;
        self.__value = value
        self.fireValueChanged(oldValue, value)
        