#!/bin/bash


# Przesunięcie aktywnego okna w lewą dolną część ekranu
xdotool getactivewindow windowmove 0 0

# Ustawienie szerokości ekranu na 70% (przyjmując, że ekran ma rozdzielczość 1920x1080)
screen_width=1920
left_width=$((screen_width * 70 / 100))

# Zmiana rozmiaru aktywnego okna
xdotool getactivewindow windowsize $left_width 100%
