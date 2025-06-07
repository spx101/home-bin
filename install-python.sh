#!/bin/bash

set -o errexit  # Zatrzymanie skryptu w przypadku błędu
set -o nounset  # Błąd, gdy używana jest niezadeklarowana zmienna
set -o pipefail # Błąd, jeśli którykolwiek z etapów w potoku zwróci błąd

TEMP="/tmp/install-python-temp"

if [ ! -f "$TEMP" ]; then
    echo "Updating package list and installing dependencies..."
    sudo apt update -q > /dev/null
    sudo apt install -y -q build-essential libz-dev libreadline-dev libncursesw5-dev libssl-dev \
        libgdbm-dev libsqlite3-dev libbz2-dev lzma-dev liblzma-dev libzzip-dev libzip-dev \
        zlib1g zlib1g-dev libffi-dev libgdbm-dev tk-dev libncursesw5-dev
    touch "$TEMP"
fi

PYTHON_VERSION="${1:-}"
PYTHON_PACKAGE_VERSION="${2:-$PYTHON_VERSION}"
PYTHON_PACKAGE="Python-${PYTHON_PACKAGE_VERSION}.tgz"

echo "
PYTHON_VERSION: $PYTHON_VERSION
PYTHON_PACKAGE: $PYTHON_PACKAGE
"

echo "Fetching available Python versions..."
curl -sS https://www.python.org/ftp/python/ -o /tmp/python-lists-raw
grep -oE '[0-9]+\.[0-9]+\.[0-9]+' /tmp/python-lists-raw | sort -V | uniq | grep ^3 > /tmp/python-lists

if [ -z "$PYTHON_VERSION" ]; then
    cat /tmp/python-lists
    echo "Usage: $0 <python_version> [package_version]"
    exit 1
fi

if [[ ! "$PYTHON_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    cat /tmp/python-lists
    echo "Error: Argument should be a valid Python version (e.g., 3.12.9)"
    exit 1
fi

echo "Checking if Python $PYTHON_VERSION version exists..."
curl -sSL -q https://www.python.org/ftp/python/${PYTHON_VERSION} -o /tmp/python-packages-raw
cat /tmp/python-packages-raw | grep -Eo '>Python-.*.tgz' | sed 's/>//g' | sort | uniq > /tmp/python-packages

echo ">>> Available Python versions:"
    cat /tmp/python-packages
    echo "-------------------------------"

if ! grep -q "$PYTHON_PACKAGE" /tmp/python-packages; then
    echo "Error: Python version ${PYTHON_PACKAGE} not found."
    exit 1
fi

if ! curl -s -I "https://www.python.org/ftp/python/${PYTHON_VERSION}/${PYTHON_PACKAGE}" | grep -q 'HTTP/2 200'; then
    echo "Error: Python version ${PYTHON_VERSION}/${PYTHON_PACKAGE} not found."
    exit 1
fi

echo "Removing old installation files..."
rm -f "/tmp/${PYTHON_PACKAGE}" || true
sudo rm -rf "/usr/src/${PYTHON_PACKAGE}" || true

echo "Downloading Python ${PYTHON_PACKAGE}..."
curl -o "/tmp/${PYTHON_PACKAGE}" "https://www.python.org/ftp/python/${PYTHON_VERSION}/${PYTHON_PACKAGE}"

echo "Unpacking Python archive..."
sudo tar -xvzf "/tmp/${PYTHON_PACKAGE}" -C /usr/src/
sudo chown -R $(id -u):$(id -g) "/usr/src/Python-${PYTHON_PACKAGE_VERSION}"

cd "/usr/src/Python-${PYTHON_PACKAGE_VERSION}"

echo "Configuring build options..."

# --with-lto \                  # Włącza optymalizację Link Time Optimization
# --enable-pgo \                # Włącza Profile-Guided Optimization (najlepsze efekty w połączeniu z --enable-optimizations)
# --with-computed-gotos \       # Wykorzystuje obliczone instrukcje goto dla szybszej pętli interpretacji
# --with-valgrind \             # Dodaje obsługę Valgrinda do debugowania i profilowania
# --with-system-expat \
# --with-system-ffi \
# --without-doc-strings       # Usuwa łańcuchy dokumentacji, zmniejszając rozmiar interpretera
# --without-pymalloc          # Wyłącza specjalny alokator pamięci Pythona (może być szybszy w niektórych zastosowaniach)
# CFLAGS="-march=native -O3"  # Optymalizuje pod kątem konkretnej architektury procesora

./configure \
    --prefix="/opt/python/${PYTHON_PACKAGE_VERSION}" \
    --enable-optimizations \
    --disable-ipv6 \
    --without-ensurepip \
    --enable-loadable-sqlite-extensions \
    --disable-shared \
    --disable-test-modules \
    --with-lto \
    --enable-pgo \
    --with-computed-gotos \
    --with-system-expat \
    --with-system-ffi \
    --without-doc-strings \
    --without-pymalloc \
    --without-tk \
    --without-dev-mode \
    CFLAGS="-Os -fdata-sections -ffunction-sections" \
    LDFLAGS="-Wl,-rpath=/opt/python/${PYTHON_PACKAGE_VERSION}/lib,--disable-new-dtags"

echo "Building Python..."
make -j$(nproc)

echo "Installing Python..."
sudo make install

echo "Installing required Python packages..."
/opt/python/${PYTHON_PACKAGE_VERSION}/bin/python3 -m pip install --upgrade pip
/opt/python/${PYTHON_PACKAGE_VERSION}/bin/python3 -m pip install pyyaml

echo "------------------------------------------------------------------------"
echo "Python ${PYTHON_PACKAGE_VERSION} installation completed successfully."
echo "------------------------------------------------------------------------"

# echo "RUN TESTS .."
# ls /opt/python/*/bin/python3 | sort | while read i; do echo -n "$i  " ; $i -m timeit -s "arr = list(range(10**6))" "sum(x**2 for x in arr)" ;  done
# "import random; arr = [random.randint(1, 10**6) for _ in range(10**6)]" "sorted(arr)"
#

# Po kompilacji
# Po instalacji możesz dodatkowo zmniejszyć rozmiar poprzez:

# Usunięcie plików .pyc i pycache:
#> find /opt/python/${PYTHON_PACKAGE_VERSION} -name "*.pyc" -delete
# Stripowanie symboli:
#> find /opt/python/${PYTHON_PACKAGE_VERSION} -type f -name "*.so" -exec strip {} \;
# Usunięcie testów:
#> rm -rf /opt/python/${PYTHON_PACKAGE_VERSION}/lib/python*/test/
