#!/bin/bash

bin/lxc_create_backup.sh | grep container | awk '{print $2}' | while read c;do bin/lxc_create_backup.sh $c ; done
