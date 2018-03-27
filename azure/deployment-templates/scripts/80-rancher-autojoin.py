#!/usr/bin/python2

import getopt
import os
import sys
from time import sleep

import requests


# usage help message
def usage(msg=None):
        if msg is not None:
                print msg
                print
        print "Usage: new_host [--url=<RANCHER_URL> --key=<RANCHER_ACCESS_KEY> --secret=<RANCHER_SECRET_KEY>]"
        print
        print "Adds this host to Rancher using the credentials supplied or defined as environment vars"

# get credentials form args or env
rancher_url = os.environ.get("RANCHER_URL", None)
rancher_key = os.environ.get("RANCHER_ACCESS_KEY", None)
rancher_secret = os.environ.get("RANCHER_SECRET_KEY", None)

opts, args = getopt.getopt(sys.argv[1:], "hu:k:s:", ["help", "url=", "key=", "secret="])
for o, a in opts:
        if o in ("-h", "--help"):
                usage()
                sys.exit(1)
        elif o in ("-u", "--url"):
                rancher_url = a
        elif o in ("-k", "--key"):
                rancher_key = a
        elif o in ("-s", "--secret"):
                rancher_secret = a

if rancher_url is None:
        usage("Rancher URL not specified")
        sys.exit(1)
if rancher_key is None:
        usage("Rancher key not specified")
        sys.exit(1)
if rancher_secret is None:
        usage("Rancher secret not specified")
        sys.exit(1)

# split url to protocol and host
rancher_protocol, rancher_host = rancher_url.split("://")

# get environment we're in
base_url = "%s://%s:%s@%s/v1/" % (rancher_protocol, rancher_key, rancher_secret, rancher_host)
response = requests.get(base_url + "projects")
data = response.json()
rancher_environment = data['data'][0]['name']
print "rancher_environment is %s" % rancher_environment

# now ask for a new registration key and wait until it becomes active
response = requests.post(base_url + "registrationtokens", json={})
data = response.json()
key_active = False
while not key_active:
        url = base_url + "registrationtokens/" + data['id']
        print url
        if data['state'] == 'active':
                key_active = True
                command = data['command']
        else:
                sleep(0.1)
                data = requests.get(url).json()

index = command.find('--privileged')
output_command = command[:index] + ' -e CATTLE_AGENT_IP=`ifconfig eth0 | grep "inet addr" | cut -d \':\' -f 2 | cut -d \' \' -f 1` ' + command[index:]

print output_command
os.system(output_command)
