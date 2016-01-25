'''
Created on 24.01.2016

@author: Andreas
'''
from phad.Plugin import Plugin
from phad.Device import Device
from phad.dpt.dptvalues import dpt_1_000

class SimpleDevicePlugin(Plugin):
    '''
    classdocs
    '''


    def __init__(self):
        '''
        Constructor
        '''
        Plugin.__init__(self, "SimpleDevicePlugin")
        
    def initialize(self):
        device = Device(self, '1/1/1', dpt_1_000)
        self.registerDevice(device)
    
    def execute(self):
        print("Executing SimpleDevicePlugin!")