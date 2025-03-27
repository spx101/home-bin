#!/bin/bash

ACION=$1
ENDPOINT=vpn-corp.ringieraxelspringer.pl
HIDREPORTER=/usr/libexec/openconnect/hipreport.sh
export WEBKIT_DISABLE_COMPOSITING_MODE=1

sudo systemctl stop rasp-vpn.service
#set -x
ENV_FILE="/home/lg/.rasp-vpn.env"

cleanup() {
    echo "Czyszczenie... Usuwanie pliku: $ENV_FILE"
    rm -f "$ENV_FILE"
}
trap cleanup EXIT


echo "RASP_ENDPOINT=$ENDPOINT" > $ENV_FILE
echo "HIDREPORTER=$HIDREPORTER" >> $ENV_FILE

$HOME/bin/rasp-vpn &
gp-saml-gui -q $ENDPOINT | grep "=" >> $ENV_FILE
/bin/killall rasp-vpn

sed -i 's/USER=/RASP_USER=/g' $ENV_FILE

echo "saved: $ENV_FILE"
source $ENV_FILE

echo "systemctl start rasp-vpn.service"
sudo systemctl start rasp-vpn.service

echo "Success"

#rm $ENV_FILE

if [ "$ACTION" == "install" ]; then

cat > /etc/systemd/system/rasp-vpn.service <<EOF
[Unit]
Description=RASP VPN client
After=network.target

[Service]
Environment=PIDFILE=/run/rasp-vpn.pid
EnvironmentFile=/home/lg/.rasp-vpn.env
Type=simple
PIDFile=$PIDFILE
ExecStart=/home/lg/bin/rasp-vpn-launch.sh
ExecStop=/usr/bin/kill -INT $MAINPID
ExecReload=/bin/kill -USR2 $MAINPID
KillSignal=SIGINT
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF


cat > /etc/openconnect/rasp-vpn.conf <<EOF
protocol=gp
useragent="PAN GlobalProtect"
user=
passwd-on-stdin
os=linux-64
usergroup=portal:prelogin-cookie
csd-wrapper=$HIDREPORTER
EOF

fi
