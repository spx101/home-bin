#!/bin/bash

set -e
set -x

OP_COMMAND='/usr/local/sbin/openconnect'
PIDFILE='/var/run/openconnect.pid'
LOGIN='lglowacki2'
PASSWORD_CMD="openssl aes-256-cbc -d -in /home/lg/.passwords/grupa.onet.enc -pbkdf2 -pass file:/home/lg/.ssh/secret-symetric.key"

$OP_COMMAND --version

#SECRET=$(echo 'GRATORKBIJEUEUCTIJHFCT22JA======' | base32 -d)
#TOKEN=$(oathtool --totp $(echo -n "$SECRET" | od -A n -t x1 --width=100 | sed 's/ *//g'))
TOKEN=$(sudo -u lg /home/lg/bin/token rasp-20201028.png -v)
# sudo -u root pwd > /dev/null
# echo $TOKEN
# echo $SECRET

#(echo -e "$(gpg -d ~/.passwords/grupa.onet.gpg)\n$TOKEN"; read -s) | sudo $OP_COMMAND --protocol=nc --useragent 'Mozilla/5.0 (Linux) Firefox' \
#	--csd-wrapper="/snap/tncc-script/current/tncc-script.py" \
#	--user="$LOGIN" \
#	--passwd-on-stdin \
#	--token-mode=totp --token-secret="$TOKEN"  \
#	--reconnect-timeout 5 \
#	https://vpn.ringieraxelspringer.pl/rasp_vpn \
###	--dump -vvv


setresolv() {
    ip=$1
    echo "setresolv $ip"
    resolvectl domain rasp ~onet ~dreamlab ~iaas ~ringieraxelspringer.pl ~nknet
    resolvectl dns rasp 10.82.254.53 10.174.12.10 10.173.136.93

    return

    interfaces="enp0s31f6 wlp2s0 enx106530b65be7 wwp0s20f0u2i12"
    for link in $interfaces; do
        ip link show $link 2>&1 >> /dev/null
        if [ "$?" == "0" ]; then
            echo "systemd-resolve $link $ip"
            systemd-resolve --set-dns=$ip --interface=$link
        fi
    done

}


# Start the VPN
start() {
	#set -x
    #setresolv "192.168.88.1"

    if [ -f $PIDFILE ]; then
        PID=$(cat $PIDFILE)
        stat /proc/${PID}/status > /dev/null
        if [ "$?" != "0" ]; then
            res=$(pgrep -lf openconnect | grep openconnect)
            if [ "$res" != "" ]; then
                pid_to_kill=$(echo $res|awk '{print $1}')
                for _pid in $pid_to_kill; do
                    echo "Kill process ${_pid}"
                    eval $(sudo kill -9 ${_pid})
                done
            fi
            rm -f $PIDFILE
        else
            echo "Openconnect is running ${PID}"
            exit 0
        fi
    fi
    echo "Starting VPN Connection"

#(echo -e "$(gpg -d ~/.passwords/grupa.onet.gpg)\n$TOKEN"; read -s) | sudo $OP_COMMAND --protocol=nc --useragent 'Mozilla/5.0 (Linux) Firefox' \
#(echo -e "$(gpg -d ~/.passwords/grupa.onet.gpg)\n$TOKEN") | $OP_COMMAND --protocol=nc --useragent 'Mozilla/5.0 (Linux) Firefox' \
    (echo -e "$($PASSWORD_CMD)\n$TOKEN") | $OP_COMMAND --protocol=nc --useragent 'Mozilla/5.0 (Linux) Firefox' \
    --csd-wrapper="/snap/tncc-script/current/tncc-script.py" \
    --user="$LOGIN" \
    --passwd-on-stdin \
    --token-mode=totp --token-secret="$TOKEN"  \
    --reconnect-timeout 5 \
    --protocol=gp \
    --no-dtls \
    --disable-ipv6 \
    --pid-file=$PIDFILE \
    --background \
    --syslog \
    -v \
    --interface=rasp \
    bcp-vpn.ringieraxelspringer.pl
    sleep 0.05
    echo "connected .... "
    notify-send "VPN Connection established"

#    bcp-vpn.ringieraxelspringer.pl
    setresolv "10.174.12.10"
}

# Stop the VPN
stop() {
    echo  "Stopping VPN connection:"
    setresolv "192.168.88.1"

    res=$(pgrep -lf openconnect | grep openconnect)
    echo $res
    if [ "$res" != "" ]; then
        pid_to_kill=$(echo $res|awk '{print $1}')
        for _pid in $pid_to_kill; do
            echo "Kill process ${_pid}"
            #eval $(sudo kill -9 ${_pid})
            eval $(kill -s SIGINT ${_pid})
        done
    fi

    PID=$(cat $PIDFILE)
    rm -f $PIDFILE

    notify-send "VPN disconnected"

    #VAR2=$(sudo ps -aef | grep openconnect)
    #echo $VAR2
    #eval $(sudo kill -9 $VAR2)
    #PIDOCN=$(pidof openconnect)
    #echo $PIDOCN
    #eval $(sudo kill -9 $PIDOCN)
}

status() {
    res=$(pgrep -lf openconnect | grep openconnect)
    echo $res
    if [ "$res" != "" ]; then
        pids=$(echo $res|awk '{print $1}')
        for _pid in $pids; do
            echo "Openconnect PID ${_pid}"
        done
        ip addr show rasp
    else
        echo "Openconnect is not running ..."
        exit 0
    fi

    #echo $(sudo ps -aef | grep openconnect)
    #PID=$(cat $PIDFILE)
    #echo "PID: ${PID}"
    #cat /proc/${PID}/status | head -n3
}

### main logic ###
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    rasp)
        ip link show rasp
        if [ "$?" == "0" ]; then
            setresolv "10.174.12.10"
            sudo ip r add 141.105.22.40/29 dev rasp
            sudo ip r add 141.105.22.0/29 dev rasp
            sudo ip r add 141.105.21.208/29 dev rasp
            sudo ip r add 141.105.21.152/29 dev rasp
        else
            echo "VPN does not running"
        fi
        ;;
    restart|reload)
        stop
        start
        ;;
    *)
        echo $"Usage: $0 {start|stop|restart|reload|status}"
        exit 1
        esac

exit 0


#
# info
#

(echo -e "$(gpg -d ~/.passwords/grupa.onet.gpg)\n$TOKEN"; read -s) | sudo $OP_COMMAND --protocol=nc --useragent 'Mozilla/5.0 (Linux) Firefox' \
    --csd-wrapper="/snap/tncc-script/current/tncc-script.py" \
    --user="$LOGIN" \
    --passwd-on-stdin \
    --token-mode=totp --token-secret="$TOKEN"  \
    --reconnect-timeout 5 \
    --protocol=gp \
    --no-dtls \
    --disable-ipv6 \
    --pid-file=$PIDFILE \
    --background \
    bcp-vpn.ringieraxelspringer.pl



