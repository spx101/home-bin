#!/usr/bin/env python3.11

import sys
import argparse
import csv
from typing import List

from rich import box, print
from rich.console import Console
from rich.table import Table

# global_box = box.DOUBLE
global_box = box.MARKDOWN
# global_box = box.ASCII_DOUBLE_HEAD
# global_box = box.SIMPLE


def read_csv_filename(filename):
    data = []
    # Otwarcie pliku CSV do odczytu
    with open(filename, newline="") as csvfile:
        reader = csv.reader(csvfile)
        headers = next(reader)  # Odczytanie nagłówka
        for row in reader:
            data.append(row)
    return headers, data


def print_table(title: str, headers: List[str], data: List[List[str]]):
    table = Table(
        title=title,
        box=global_box,
        show_lines=False,
        show_header=True,
        header_style="yellow",
        title_style="magenta",
    )
    for header in headers:
        table.add_column(header, style="magenta")

    for row in data:
        table.add_row(*row)

    console = Console()
    console.print(table)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=("The script print table from csv file"),
        add_help=True,
        epilog="be happy ;)",
        usage="",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    parser.add_argument(
        "-f", "--filename", dest="filename", help="filename in csv format", type=str
    )
    parser.add_argument(
        "--table", "-t", dest="show_table", help="show_table", action="store_true"
    )
    args = parser.parse_args()


    data = []
    headers = []
    if args.filename:
        headers, data = read_csv_filename(filename=args.filename)
    else:
        for line in sys.stdin:
            # Przetwarzanie danych (np. drukowanie ich)
            data.append(line.strip().split(","))

    print_table(args.filename, headers, data)
