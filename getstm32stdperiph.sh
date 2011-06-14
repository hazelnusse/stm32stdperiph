#!/bin/bash

# Fetch a versioned file from a URL
function fetch {
if [ ! -e ${STAMPS}/$1.fetch ] ; then
    log "Downloading $1 sources..."
    wget -c --no-passive-ftp $2
    touch ${STAMPS}/$1.fetch
else
    log "$1 already downloaded.  Continuing to next step."
fi
}

# Log a message out to the console
function log {
    echo "******************************************************************"
    echo "* $*"
    echo "******************************************************************"
}

# prefix root
PREFIX=$HOME/usr/stm32_stdperiph_lib
# Download

SUMMON_DIR=$(pwd)
SOURCES=${SUMMON_DIR}/sources
STAMPS=${SUMMON_DIR}/stamps

mkdir -p ${SOURCES} ${STAMPS} build

STM32=stm32f10x_stdperiph_lib

cd ${SOURCES}
fetch ${STM32} http://www.st.com/internet/com/SOFTWARE_RESOURCES/SW_COMPONENT/FIRMWARE/stm32f10x_stdperiph_lib.zip
cd ${SUMMON_DIR}

unzip ${SOURCES}/stm32f10x_stdperiph_lib.zip

log "Successfully downloaded and extracted ${STM32}"
