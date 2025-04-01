#!/bin/bash
# Skrypt dodający routingi w zależności od lokalizacji

# Przykładowo, sprawdzamy adres IP serwera (zmienna środowiskowa ifconfig_remote ustawiana przez OpenVPN)
case "$ifconfig_remote" in
  "192.168.1.1")
    # Dodaj trasę dla lokalizacji 1
    ip route add 10.0.0.0/24 via 192.168.1.1
    ;;
  "192.168.2.1")
    # Dodaj trasę dla lokalizacji 2
    ip route add 10.1.0.0/24 via 192.168.2.1
    ;;
  *)
    echo "Nieznana lokalizacja: $ifconfig_remote"
    ;;
esac

exit 0


#curl ifconfig.io/ip
