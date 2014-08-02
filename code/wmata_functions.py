# -*- coding: utf-8 -*-
"""
Created on Sun Mar 09 22:56:20 2014

@author: ANDREW
"""

###############################
## initializing file path
###############################
import os
os.chdir('/Users/ajb/Documents/github/nextbus/')


###############################
## parses JSON bus prediction times 
###############################
import json
import datetime
import time
import datetime
def extractPred(buspred):
    now = datetime.datetime.now()
    preds = len(buspred.items()[1][1])
    v=[]
    if(preds>0):
        for b in range(2): 
            v1=now
            v2=buspred['Predictions'][b]['Minutes']
            v3=buspred['Predictions'][b]['VehicleID']
            v4=buspred['Predictions'][b]['DirectionText']
            v5=buspred['Predictions'][b]['RouteID']
            v6=buspred['Predictions'][b]['TripID']
            v.insert(b, [v1,v2,v3,v4,v5,v6])
    return v
 
 
if(1==0):
    runfile('python-wmata.py')
    api = Wmata('x42rp9qg6jjjydn2u8ng8stx')
    stopid = '1003043'
    stopid = '18383'
    
    buspred=api.bus_prediction(stopid)
    extractPred(buspred)    
    
    a=api.bus_prediction(stopid)
    a.items()
    a.items()[0]
    a.items()[1]
    a.items()[1][0]
    size(a.items()[1][1])
    a.items()[1][1][0]
    a.items()[1][1][1]
    a.items()[1][1][0]['Minutes']
    a.items()[1][1][1]['Minutes']
    a['StopName']
    a['Predictions'][1]['Minutes']
    a['Predictions'][1]['Minutes']
    a['Predictions'][1]['TripID']

import csv
import datetime
import time
def write2text(filename, freq=10, mins=10, stopid='1003043'):
    with open(filename, 'wb') as outcsv:   
        writer = csv.writer(outcsv, delimiter='|', lineterminator='\n') 
        writer.writerow(['time', 'Minutes', 'VehicleID', 'DirectionText', 'RouteID', 'TripID'])
        stime = datetime.datetime.now()
        while datetime.datetime.now() < stime + datetime.timedelta(minutes=mins):
            try:
                time.sleep(freq)
                buspred=api.bus_prediction(stopid)         
                tmp = extractPred(buspred)   
                NumOfLists = sum(isinstance(i, list) for i in tmp)
                print buspred
                print('numOfLists', NumOfLists)
                if(NumOfLists>1):
                    for i in tmp:
                        writer.writerow([i[0], i[1], i[2], i[3], i[4], i[5]])
                        print([i[0], i[1], i[2], i[3], i[4], i[5]])
                elif(len(tmp)==5): 
                    writer.writerow([tmp[0], tmp[1], tmp[2], tmp[3], tmp[4], tmp[5]])
                else:
                    writer.writerow([datetime.datetime.now(), 'NA', 'NA', 'NA', 'NA', 'NA', 'NA'])
            except:
                print [datetime.datetime.now(), 'some error...']
                pass
        outcsv.close()

if(1==0):
    runfile('python-wmata.py')
    api = Wmata('x42rp9qg6jjjydn2u8ng8stx')
    stopid = '1003043'
    buspred=api.bus_prediction(stopid)
    write2text('data/bus64_test.txt', freq=1, mins=.5)
    
    