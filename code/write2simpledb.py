# -*- coding: utf-8 -*-
"""
Created on Fri Oct 31 15:45:41 2014

@author: abrooks
"""
import os

os.chdir('C:/Users/abrooks/Documents/github/nextbus')
runfile('code/python-wmata.py')
import datetime
import time
import json 



## open access to WMATA API
api = Wmata('x42rp9qg6jjjydn2u8ng8stx')
stopid = '1003043' ## testing
buspred=api.bus_prediction(stopid) ## testing

## open access to EC2.  User ID and secret key are saved on computer
file = open('aws_private_keys.txt', 'r')
awsKeys = file.read()

import boto.sdb
conn = boto.sdb.connect_to_region(
'us-east-1',
aws_access_key_id=awsKeys.split(',')[0],
aws_secret_access_key=awsKeys.split(',')[1]
)

dom = conn.get_domain('wmata2') ## domain to add to

items = buspred['Predictions'][1]
dom.batch_put_attributes(items)



def api2simpledb(buspred):
    bb = buspred['Predictions']
    preds = len(bb)
    if(preds>0):
        for i in range(0,preds):
            
        
    
    
    def extractPred(buspred):
    now = datetime.datetime.now()
    preds = len(buspred.items()[1][1])
    v=[]
    if(preds>0):
        for b in range(0, preds): 
            v1=now
            v2=buspred['Predictions'][b]['Minutes']
            v3=buspred['Predictions'][b]['VehicleID']
            v4=buspred['Predictions'][b]['DirectionText']
            v5=buspred['Predictions'][b]['RouteID']
            v6=buspred['Predictions'][b]['TripID']
            v.insert(b, [v1,v2,v3,v4,v5,v6])
    return v