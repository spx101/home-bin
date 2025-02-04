#!/usr/bin/env python3

import yaml
from tabulate import tabulate

# Load the YAML file
with open("cloud-image-mirror-map.yaml", "r") as file:
    data = yaml.safe_load(file)

# Prepare the table data
table_data = []
for image in data["images"]:
    for tag in image["tags"]:
        table_data.append([image["source"], image["name"], tag["name"]])

# Print the table
print(tabulate(table_data, headers=["Source", "Name", "Tag"]))
