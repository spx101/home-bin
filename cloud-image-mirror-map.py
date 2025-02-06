#!/usr/bin/env python3

# k get pods -o yaml | grep image: | sort | uniq

import yaml
from tabulate import tabulate

# Load the YAML file
with open("cloud-image-mirror-map.yaml", "r") as file:
    data = yaml.safe_load(file)


# Prepare the table data
table_data = []
names = set()

print(f"registry: {data['registry']}")

for image in data["images"]:
    if image["name"] in names:
        raise ValueError(f"Duplicate image name found: {image['name']}")
    names.add(image["name"])
    for tag in image["tags"]:
        _source = f"{image['source']}:{tag['name']}"
        _name = f"{image['name']}:{tag['name']}"
        table_data.append([_source, _name, tag["name"]])

# Print the table
print(tabulate(table_data, headers=["Source", "Name", "Tag"]))
