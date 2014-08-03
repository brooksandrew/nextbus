# -*- coding: utf-8 -*-
"""
Spyder Editor

This temporary script file is located here:
C:\Users\ANDREW\.spyder2\.temp.py
"""

###############################
## initializing file path
###############################
import os
os.chdir('/Users/ajb/Documents/github/nextbus/')

##################################
## FOR REAL ######################
##################################    

runfile('code/python-wmata.py')
runfile('code/wmata_functions.py')
import datetime
import time
import json 
api = Wmata('x42rp9qg6jjjydn2u8ng8stx')
    
stopid = '1003043'
buspred=api.bus_prediction(stopid)

write2text('data/bus64_1Aug2014.txt', freq=10, mins=60*24)
    
################################
## SCRATCH #####################
################################




    
    
    


