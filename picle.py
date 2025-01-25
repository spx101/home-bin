#!/usr/bin/env python3

import pickle
import sys

if len(sys.argv) != 2:
    print("Użycie: python3 read_pickle.py <ścieżka_do_pliku>")
    sys.exit(1)

filename = sys.argv[1]

try:
    with open(filename, 'rb') as f:
        data = pickle.load(f)
        print(data)
except Exception as e:
    print(f"Nie udało się odczytać pliku: {e}")
