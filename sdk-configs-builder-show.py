#!/usr/bin/env python3

import json
import os
import argparse

def load_json(file_path):
    with open(file_path, 'r') as file:
        return json.load(file)

def main(args):
    lifetimes_path = os.path.join('config', 'lifetimes', f'{args.sdk_type}.json')
    versions_path = os.path.join('config', 'versions', f'{args.sdk_type}.json')

    versions_data = load_json(versions_path)
    lifetimes_data = load_json(lifetimes_path)

    print(f"--- SDK type: {args.sdk_type} ---")
    headers = ['family', 'version', 'distributions', 'isEnabled', 'endOfLifeDate', 'endOfSupportDate']
    print(" ".join(f"{header[:20]:<20}" for header in headers))

    for version in versions_data:
        lifetime = next((lt for lt in lifetimes_data if lt['family'] == version['family']), None)
        if lifetime is None:
            raise ValueError(f"No lifetime found for family {version['family']}")

        version.update(lifetime)
        row = [
            version['family'],
            version['version'],
            ','.join(version['distributions']),
            str(version['isEnabled']),
            version['endOfLifeDate'],
            version['endOfSupportDate']
        ]
        print(" ".join(f"{col[:20]:<20}" for col in row))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Show SDK configurations.')
    parser.add_argument("-s",
                        "--sdk-type",
                        dest='sdk_type',
                        choices=['python', 'node', 'jvm', 'php-fcgi'],
                        required=False,
                        default='python',
                        help='Type of SDK')
    args = parser.parse_args()
    main(args)
