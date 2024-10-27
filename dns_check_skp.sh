#!/bin/bash

tmpfile=$(mktemp)

echo "" > temp1

rr=" skp-openstack-skapiec-dev-openrc.sh skp-openstack-skapiec-prod-openrc.sh"

for ii in $rr ; do

        source $ii

openstack server list -f csv | gawk -f <(cat - <<- 'EOF'
BEGIN{FS=","}
{ 
        ip=match($4, /10.[0-9]+.[0-9]+.[0-9]+/, m)      
        gsub(/\"/, "", $2)
        if (ip)
        {
                print $2" "m[0]
        }
}
EOF
) >> $tmpfile


done

echo "ZONE: ~/workspace/svn_nk_produkcja/trunk/modules/bind/files/lvs-local/etc/bind/zones/skp.local"

cat $tmpfile | while read i; do
	h1=$(echo $i | awk '{print $1}')
	i2=$(echo $i | awk '{print $2}')
	c1=$(egrep "$h1" ~/workspace/svn_nk_produkcja/trunk/modules/bind/files/lvs-local/etc/bind/zones/skp.local)
	if [ "$c1" == "" ] ; then
		printf "%-31s 86400   A       %-20s\n" "$h1" "$i2"
	else
		i3=$(echo $c1 | awk '{print $4}')
		if [ "$i2" != "$i3" ] ; then
			echo "INVALID $i3 IP for $h1 $i2"
		fi
		#c1=$(egrep -c "$h1" ~/workspace/svn_nk_produkcja/trunk/modules/bind/files/lvs-local/etc/bind/zones/skp.local)
	fi
done

rm -f $tmpfile
