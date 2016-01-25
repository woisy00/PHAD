'''
Created on 16.01.2016

@author: Andreas
'''

class ChangeListener(object):
    '''
    classdocs
    '''

    def valueChanged(self, name, oldValue, newValue):
        raise NotImplementedError( "Should have implemented this" )
        