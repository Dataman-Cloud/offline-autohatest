#!/usr/bin/env python
#-*-coding:utf-8-*-

import argparse
import os
import requests
import json

server = ""
token = ""
rolename = ""

def getArgs():
    parse=argparse.ArgumentParser()
    parse.add_argument('--server',type=str,default="",required=True,help="borgsphere url,example: http://127.0.0.1:5013")
    parse.add_argument('--token',type=str,default="", required=True,help="borgsphere token")
    parse.add_argument('--rolename',type=str,default="",required=True,help="role name,example：owner")
    return parse.parse_args()

def get_roleid_by_name(rolename):
    url = "%s/v1/roles" %server
    headers = {'Authorization': token}
    r = requests.get(url, headers)
    roles = json.loads(r.text)["data"]
    roleID = 0
    for role in roles:
	if role['role'] == rolename:
	    roleID = role['id']			
    
    if roleID == 0 :
	print "Get role id error"
	os._exit(1)
    print roleID

if __name__=='__main__':
    args=getArgs()
    server = args.server
    token = args.token
    rolename = args.rolename
    get_roleid_by_name(rolename)	

    
    


