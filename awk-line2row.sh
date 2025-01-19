#!/bin/sh

awk '{for(i=0;i<=NF;i++){print i": "$i}}'
