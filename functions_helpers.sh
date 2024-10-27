function tmpfile {
    SCRIPT=$(readlink -f $0)
    SCRIPTPATH=`dirname $SCRIPT`
    md5=$(echo "${SCRIPT}$1" | md5sum - | cut -d' ' -f1)
    tmpfile="/ram/$md5"
    echo $tmpfile
}