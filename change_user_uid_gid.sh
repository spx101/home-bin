#!/bin/bash

# get current uid gid

uid_old=$(id -u)
gid_old=$(id -g)

uid_old=1000
gid_old=1000


uid_new=7313
gid_new=7313

usermod -u $uid_new lg

groupmod -g $gid_new lg

find / -group $gid_old -exec chgrp -h lg {} \;
find / -user $uid_old -exec chown -h lg {} \;


