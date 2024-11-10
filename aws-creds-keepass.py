#!/usr/bin/env python3

# result=$(env python3 <<EOF
# # Pythonowy kod wieloliniowy
# x = $x
# y = 5
# print(x * y)
# EOF
# )
# aws creds retreiver form keepass

import argparse
import configparser
import os
import subprocess
import json

from rich import print_json
import sys

def get_aws_profile(profile: str):
    home = os.getenv("HOME")
    config = configparser.ConfigParser()
    config.read(f'{home}/.aws/config')

    profile_key = f'profile {profile}'
    if profile_key not in config:
        raise ValueError(f"Profile {profile} not found in {home}/.aws/config")

    profile_dict = {key: value for key, value in config[profile_key].items()}
    return profile_dict


parser = argparse.ArgumentParser(description='Retrieve AWS credentials from Keepass.')
parser.add_argument('profile_name', type=str, help='The name of the AWS profile')
args = parser.parse_args()
profile_name = args.profile_name
#profile_data = get_aws_profile(profile_name)
#print(profile_data)


def get_keepass_credentials(profile: str):
    command = [
        "keepassxc-cli", "show", "-k", os.path.expanduser("~/.keepass/rasp.key"),
        "--no-password", "-s", os.path.expanduser("~/workspace/keepass/rasp.kdbx"), f"aws/{profile}"
    ]
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"Error retrieving credentials for profile {profile}: {result.stderr}")

    data_json = subprocess.run(["yq", "-o=json"], input=result.stdout, capture_output=True, text=True).stdout
    data_json = json.loads(data_json)
    return {
        "AccessKeyId": data_json.get("UserName"),
        "SecretAccessKey": data_json.get("Password")
    }

keepass_credentials = get_keepass_credentials(profile_name)
keepass_credentials["Version"] = 1

if not 'AccessKeyId' in keepass_credentials or not 'SecretAccessKey' in keepass_credentials:
    raise RuntimeError("Missing AccessKeyId or SecretAccessKey in credentials")

print("Retrieved credentials successfully", file=sys.stderr)
print_json(data=keepass_credentials)


#AWS_ACCESS_KEY_ID=$(echo $data_json | jq -r '.UserName')
#         AWS_SECRET_ACCESS_KEY=$(echo $data_json | jq -r '.Password')
#         echo "{"
#         echo "  \"Version\": 1,"
#         echo "  \"AccessKeyId\": \"$AWS_ACCESS_KEY_ID\","
#         echo "  \"SecretAccessKey\": \"$AWS_SECRET_ACCESS_KEY\""
#         echo "}"

# source ~/.bash_functions

# profile=$1
# data_json=$(aws-profile-json $profile) || errcode=$?
# external_id=$(echo $data_json | jq -r '.external_id')
#     #if [ "$external_id" == "keepassxc" ]; then

# # z tym config nie dziala
# #>&2 ">>> keepassxc-cli show -k ~/.keepass/rasp.key --no-password -s ~/workspace/keepass/rasp.kdbx aws/$profile"

#         data_json=$(keepassxc-cli show -k ~/.keepass/rasp.key --no-password -s ~/workspace/keepass/rasp.kdbx aws/$profile | yq -o=json)
#         if [ "$?" != "0" ] || [ "$data_json" == "null" ]; then
#             echo "ERROR keepassxc aws/$profile"
#             return 1
#         fi
#         AWS_ACCESS_KEY_ID=$(echo $data_json | jq -r '.UserName')
#         AWS_SECRET_ACCESS_KEY=$(echo $data_json | jq -r '.Password')
#         echo "{"
#         echo "  \"Version\": 1,"
#         echo "  \"AccessKeyId\": \"$AWS_ACCESS_KEY_ID\","
#         echo "  \"SecretAccessKey\": \"$AWS_SECRET_ACCESS_KEY\""
#         echo "}"
#     #fi
