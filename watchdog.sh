#!/bin/bash

# https://unix.stackexchange.com/questions/324213/pass-through-pipe-with-timeout

# Beside this here a very simple watchdog.sh shell script. 
# You can test it interactively in console. 
# Just type ./watchdog.sh. It will duplicate everything you type then 
# and stop if you don't type something for 5 seconds.

# first arg is timeout (default: 5)
T="${1:-5}"
PID=$$

exec tee >(bash -c '
while true ; do
    bytes=$(timeout '$T' cat | wc -c)
    if ! [ "$bytes" -gt 0 ] ;then
            break
    fi
done
## add something like "killall process1", for now we just kill this tee command
kill -9 '$PID)
