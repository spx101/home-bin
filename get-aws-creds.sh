#!/bin/bash

logger "get-aws-creds.sh $1"
gpg -d ~/.aws/credentials-$1.asc
