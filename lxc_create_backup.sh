#!/usr/bin/env bash

#set -ex

HOSTS=($(lxc list -c n --format csv))
for HOST in "${HOSTS[@]}"
do
    echo "container: ${HOST}"
done

if [ ! -f /mnt/backup/.placeholder ] ; then
	echo "ERROR: Brak podmontowanego zasobu USB"
	exit 1
fi

date=$(date +"%Y%m%d%H%M")
container=$1

[ -z $container ] && { echo "podaj nazwe kontenera" && exit 1; }

c=$(lxc list --format csv |  awk -F"," -v container="$container" '$1==container {print $1}')
[ "$c" != "$container" ] && { echo "brak kontenera: $container - dostepne kontenery:" && lxc list --format csv ; exit 1; }

# if running
state=$(lxc list --format csv -c ns | awk -F"," -v container="$container" '$1==container {print $2}')

echo "$container $state"

if [ "$state" == "RUNNING" ]; then
	echo "Stop container: lxc stop $container"
	lxc stop $container
fi

echo "Tworzenie snapshota: lxc snapshot $container $container-snap"
lxc snapshot $container $container-snap

echo "Publikowanie snapshota: lxc publish $container/$container-snap --alias $container-snap"
lxc publish $container/$container-snap --alias $container-snap

echo "Exportowanie obrazu: lxc image export $container-snap /mnt/backup/$container-snap-$date"
lxc image export $container-snap /mnt/backup/$container-snap-$date

# posprzatanie
# [1] usuniecie obrazu
echo "Usuwanie snapshota: lxc image export $container-snap /mnt/backup/$container-snap-$date"
lxc image delete $container-snap

# [2] usuniecie snapshota
echo "Usuwanie obrazu: lxc delete $container/$container-snap"
lxc delete $container/$container-snap

if [ "$state" == "RUNNING" ]; then
    echo "Start container: lxc start $container"
    lxc start $container
fi

# lxc command	                        |  Description for LXD	Example(s)
# lxc publish {container}/$snapshot) --alias ${snapshot_name}
# lxc snapshot {container} {snapshot}	| Create a snapshot	lxc snapshot www-c1 snap01
# lxc restore {container} {snapshot}	| Restore the snapshot	lxc restore www-c1 snap01
# lxc info {container} --verbose		| Get the container information including snapshot info	lxc www-c1
# lxc delete {container}/{snapshot}		| Delete the snapshot	lxc delete www-c1/snap01

