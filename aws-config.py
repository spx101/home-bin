#!/usr/bin/env python3

import argparse
import configparser
import os

from rich import print_json


def list_aws_profiles():
    home = os.getenv("HOME")
    config = configparser.ConfigParser()
    config.read(f'{home}/.aws/config')

    profiles = [section.replace('profile ', '') for section in config.sections() if section.startswith('profile ')]
    return profiles

def get_aws_profile(profile: str):
    home = os.getenv("HOME")
    config = configparser.ConfigParser()
    config.read(f'{home}/.aws/config')

    profile_key = f'profile {profile}'
    if profile_key not in config:
        output = {"error":  f"Profile {profile} not found in {home}/.aws/config"}
        print(output)
        exit(1)

    profile_dict = {key: value for key, value in config[profile_key].items()}
    return profile_dict


parser = argparse.ArgumentParser(description='Retrieve AWS credentials from Keepass.')
parser.add_argument('profile_name', type=str, nargs='?', default=None, help='The name of the AWS profile')
args = parser.parse_args()
profile_name = args.profile_name

if not profile_name:
    print_json(data=list_aws_profiles())
else:
    profile_data = get_aws_profile(profile_name)
    print_json(data=profile_data)
