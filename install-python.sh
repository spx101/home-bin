#!/bin/bash

set -e

sudo apt update
sudo apt install -y build-essential libz-dev libreadline-dev libncursesw5-dev libssl-dev libgdbm-dev libsqlite3-dev libbz2-dev libbz2-dev lzma-dev lzma liblzma-dev libzzip-dev libzip-dev zlib1g zlib1g-dev libffi-dev


#export PYTHON_VERSION=$(echo $0 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
PYTHON_VERSION=$1
echo "version: $PYTHON_VERSION"

if [ -z "$PYTHON_VERSION" ] ; then
    curl -sS https://www.python.org/ftp/python/ -o /tmp/python-lists 1>/dev/null
    cat /tmp/python-lists | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | sort -V | uniq | grep ^3

    echo "usage: $0 3.10.15"

    exit 0
fi


if [[ "$PYTHON_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] ; then
    echo "version $PYTHON_VERSION: OK"
else
    echo "argument powinien byc wersja pythona"
    exit 1
fi


curl -s -I https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz | grep 'HTTP/2 200' 1>/dev/null
if [ "$?" != "0" ]; then
    echo "brak wersji: ${PYTHON_VERSION}"
    exit 1
else
    echo "version $PYTHON_VERSION: EXISTS"
fi

rm -f /tmp/Python-${PYTHON_VERSION}.tgz || :
sudo rm -rf /usr/src/Python-${PYTHON_VERSION} || :

curl -o /tmp/Python-${PYTHON_VERSION}.tgz https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
echo "unpacking /tmp/Python-${PYTHON_VERSION}.tgz"
sudo tar -xvzf /tmp/Python-${PYTHON_VERSION}.tgz -C /usr/src/
sudo chown -R $(id -u):$(id -g) /usr/src/Python-${PYTHON_VERSION}

cd /usr/src/Python-${PYTHON_VERSION}

./configure \
    --prefix=/opt/python/${PYTHON_VERSION} \
    --enable-optimizations \
    --enable-ipv6 \
    --with-ensurepip=install \
    --enable-loadable-sqlite-extensions \
    LDFLAGS=-Wl,-rpath=/opt/python/${PYTHON_VERSION}/lib,--disable-new-dtags

# --enable-shared
#--with-system-ffi

make -j4
sudo make install


/opt/python/${PYTHON_VERSION}/bin/python3 -m pip install pyyaml

