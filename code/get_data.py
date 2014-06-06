# -*- coding: utf-8 -*-
"""
Spyder Editor

This temporary script file is located here:
C:\Users\ANDREW\.spyder2\.temp.py
"""




##################################
## FOR REAL ######################
##################################    

runfile('C:/Users/ANDREW/Dropbox/wmata/python-wmata.py')
runfile('C:/Users/ANDREW/Dropbox/wmata/wmata_functions.py')
import datetime
import time
import json 
api = Wmata('x42rp9qg6jjjydn2u8ng8stx')
    
stopid = '1003043'
buspred=api.bus_prediction(stopid)

write2text('C:/Users/ANDREW/Dropbox/wmata/bus64_12mar2014_7am.txt', freq=10, mins=60*24*5)
    
################################
## SCRATCH #####################
################################




    
    
    


