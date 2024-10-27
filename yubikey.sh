#!/bin/bash
#
#
# /etc/udev/rules.d/99-usb-device.rules
# SUBSYSTEM=="usb", ATTR{idVendor}=="1050", ATTR{idProduct}=="0407", ACTION=="add", RUN+="/home/lg/bin/yubikey.sh"
# SUBSYSTEM=="usb", ENV{PRODUCT}=="1050/407/543", ACTION=="remove", RUN+="/home/lg/bin/yubikey.sh"
#
# sudo udevadm control --reload-rules ; sudo udevadm trigger
#
#
LOGFILE="/tmp/yubikey.log"
#echo "----------------------------" >> $LOGFILE

if [ "$PRODUCT" != "1050/407/543" ]; then
    exit 0
fi

log() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> $LOGFILE
}

# log "$0: Yubikey USB device"
# log "$@"
# log "action: $ACTION"
# log "devname: $DEVNAME"
# log "id_vendow: $ID_VENDOR"
# log "id_model: $ID_MODEL"
# log "ID_MODEL_FROM_DATABASE: $ID_MODEL_FROM_DATABASE"
# env >> $LOGFILE


if [[ "$ACTION" == "add" ]]; then
    log "run when $ACTION"
    rm -f /tmp/yubikey-lock-sessions 2>/dev/null
    systemctl restart pcscd
    #sleep 0.2
    #gpg-card -- verify
fi

if [[ "$ACTION" == "remove" ]]; then
    if [ ! -f /tmp/yubikey-lock-sessions ]; then
        log "lock-sessions run when $ACTION"
        touch /tmp/yubikey-lock-sessions
        loginctl lock-sessions
    fi
fi
