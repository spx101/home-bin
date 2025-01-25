#!/bin/bash


sudo rm -f /opt/sdk/python_v3.9
sudo rm -f /opt/sdk/python_v3.11
sudo rm -f /opt/sdk/python_v3.12

sudo ln -s /opt/python/3.9.21 /opt/sdk/python_v3.9 
sudo ln -s /opt/python/3.11.11 /opt/sdk/python_v3.11 
sudo ln -s /opt/python/3.12.8 /opt/sdk/python_v3.12

#cd /opt/sdk/python_v3.9 && python3 -m venv .
#cd /opt/sdk/python_v3.11 && python3 -m venv .
#cd /opt/sdk/python_v3.12 && python3 -m venv .

#echo "installed versions in /opt/sdk/"
/opt/sdk/python_v3.9/bin/python3 --version
/opt/sdk/python_v3.11/bin/python3 --version
/opt/sdk/python_v3.12/bin/python3 --version


