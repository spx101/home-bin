#!/usr/bin/env python3

import sys
import re
import time
import os

raise Exception("do not run this script")


#print('sys.argv[0] =', sys.argv[0])
pathname = os.path.dirname(sys.argv[0])
#print('path =', pathname)
#print('full path =', os.path.abspath(pathname))

files = { 
  'constant':  "{}/constant.hosts".format(os.path.abspath(pathname)),
#  'skp': '/home/lg/workspace/svn_nk_produkcja/trunk/modules/bind/files/lvs-local/etc/bind/zones/skp.local', 
#  'opi': '/home/lg/workspace/svn_nk_produkcja/trunk/modules/bind/files/lvs-local/etc/bind/zones/opi.local',
  # 'nk':  '/home/lg/workspace/svn_nk_produkcja/trunk/modules/bind/files/lvs-local/etc/bind/zones/lvs.nasza-klasa.pl',
  # 'openstack':  "{}/openstack.hosts".format(os.path.abspath(pathname))
}

if not os.access('/etc/hosts', os.W_OK):
    print("ERROR: Brak uprawnienia do zapisu do pliku /etc/hosts")
    print("uruchom z uprawnieniami root: sudo bin/skp_import_hosts.py")
    sys.exit(1)

t1 = int(time.time())

hosts = open('/etc/hosts','r')
regex = r"([0-9.]+.[0-9]+.[0-9]+.[0-9]+)\s+([\w_-a-zA-Z0-0]+)"
hosts_arr = {}

#for line in hosts:
#    match = re.search(regex, line)
#    if match:
#       ip = match.group(1)
#       host   = match.group(2)
#       hosts_arr[host] = ip
#       #print("%s %s" % (ip, host))
#       #print(hosts_arr)

regex = r"([\w_-a-zA-Z0-0]+)\s*[0-9]*\s*[A-Z]*\s+([0-9.]+.[0-9]+.[0-9]+.[0-9]+)"

regex2 = r"([0-9.]+.[0-9]+.[0-9]+.[0-9]+)\s+([\w_-a-zA-Z0-0\.]+)"

ha = { 
    'skp': {}, 
    'opi': {}, 
    'nk': {}, 
    'openstack': {}, 
    'constant': {} 
} 

for key in files:
  fd = open(files[key],'r')
  for line in fd:
    match = re.search(regex, line)
    match2 = re.search(regex2, line)
    
    if match:
       host = match.group(1)
       ip   = match.group(2)       
       print("[{}] {} {}".format(key, host,ip))
       ha[key][host] = ip
       if host in hosts_arr:
         del hosts_arr[host]
    elif match2:
        # key constant
        host = match2.group(2)
        ip   = match2.group(1)
        ha[key][host] = ip
    else:
        print("ERROR niedopasowany {} {}".format(key, line))


#print("Write to /etc/hosts")
#sys.exit(1)

hosts_file = open('/etc/hosts','w')
#hosts_file.write("127.0.0.1 localhost\n")
#
# constant
#
#fd1 = open(files["constant"],'r')
#for line in fd1:
#  hosts_file.write(line)

#for key in hosts_arr:
#    hosts_file.write("%-16s  %s\n" % (key, hosts_arr[key]))

for key in files:
  hosts_file.write("############# %s #################\n" % (key))
  for k in ha[key]:
     hosts_file.write("%-16s  %s\n" % (ha[key][k], k))

sys.exit(0)
