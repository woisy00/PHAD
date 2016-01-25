#!/usr/bin/python
'''
Created on 16.01.2016

@author: Andreas
'''
from ConfigParser import SafeConfigParser
import argparse
from logging import StreamHandler
import logging
from logging.handlers import TimedRotatingFileHandler
import os
import time

from apscheduler.schedulers.background import BackgroundScheduler

from phad.Registry import DeviceRegistry, PluginRegistry


def setupLogging(logfile, debug):
    logging.root.addHandler(_MyHandler(logfile))
    if debug:
        consoleHandler = StreamHandler()
        consoleHandler.setFormatter(logging.Formatter("%(asctime)s %(name)s@%(thread)d:\n %(message)s"))
        logging.root.setLevel(logging.DEBUG)
        logging.root.addHandler(consoleHandler)
    else:
        logging.root.setLevel(logging.INFO)
    
class _MyHandler(TimedRotatingFileHandler):
    
    def __init__(self, filename=None):
        TimedRotatingFileHandler.__init__(self, filename, when='midnight', backupCount=3)
        self.setFormatter(logging.Formatter("%(asctime)s %(name)s@%(thread)d:\n %(message)s"))
        


class PHAD(object):
        
    def __init__(self, config):
        self.__logger = logging.getLogger('PHAD')
        self.__devices = DeviceRegistry()
        self.__plugins = PluginRegistry(self.__devices)
        self.__scheduler = BackgroundScheduler()
        self.__config = SafeConfigParser()
        self.__config.read(config)
        
    
    def getPlugins(self):
        return self.__plugins.getPlugins()
    
    def initialize(self):
        # initialize plugin registry
        self.__plugins.initialize(self.__config.get('PHAD', 'plugin_dir'))
        # schedule plugin execution
        for plugin in self.getPlugins():
#             if self.__config.has_section(inst.getName()):
#                 inst.setConfig(self.__config.)
            plugin.initialize()
            self.__scheduler.add_job(plugin.execute, 'interval', 
                              seconds=plugin.getCycleTime())
            
    def execute(self):
        self.__scheduler.start()
        print('Press Ctrl+{0} to exit'.format('Break' if os.name == 'nt' else 'C'))

        try:
            # This is here to simulate application activity (which keeps the main thread alive).
            while True:
                time.sleep(2)
        except (KeyboardInterrupt, SystemExit):
            # Not strictly necessary if daemonic mode is enabled but should be done if possible
            self.__scheduler.shutdown()        

def main():
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('-c', default='/etc/phad/phad.conf', dest='config', metavar="FILE", help='the phad configuration file')
    parser.add_argument('-d', action="store_false", dest="debug", default=True, help='turns on debugging')
    
    args = parser.parse_args()
    setupLogging("phad.log", args.debug)
    
    phad = PHAD(args.config);
    phad.initialize()
    phad.execute()

if __name__ == '__main__':
    main()