'''
Created on 16.01.2016

@author: Andreas
'''

class Observable(object):
    '''
    classdocs
    '''


    def __init__(self):
        '''
        Constructor
        '''
        self.__listeners = []
    
    def addChangeListener(self, changeListener):
        self.__listeners.append(changeListener)
        
    def removeChangeListener(self, changeListener):
        if changeListener in self.__listeners:
            self.__listeners.remove(changeListener)
            
    def fireValueChanged(self, name, oldValue, newValue):
        for l in self.__listeners:
            l.valueChanged(name, oldValue, newValue)