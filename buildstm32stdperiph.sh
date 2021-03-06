#!/bin/bash

# Set these to where your ARM compiler and archiver (GNU assumed here)
CC=${HOME}/usr/sat/bin/arm-none-eabi-gcc
AR=${HOME}/usr/sat/bin/arm-none-eabi-ar

# Select your target device (see stm32f10x.h for more options)
#DEVICE="-DSTM32F10X_MD"  # For Medium Density Line Devices
DEVICE="-DSTM32F10X_CL"   # For Connectivity Line Devices

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

# Download
SUMMON_DIR=$(pwd)
SOURCES=${SUMMON_DIR}/sources
STAMPS=${SUMMON_DIR}/stamps

mkdir -p ${SOURCES} ${STAMPS} build build/lib build/inc build/src
STM32=stm32f10x_stdperiph_lib

cd ${SOURCES}
fetch ${STM32} http://www.st.com/internet/com/SOFTWARE_RESOURCES/SW_COMPONENT/FIRMWARE/stm32f10x_stdperiph_lib.zip
cd ${SUMMON_DIR}

unzip -u ${SOURCES}/stm32f10x_stdperiph_lib.zip
log "Successfully downloaded and extracted ${STM32}"

# Build process
log "Starting ${STM32} build"
cd build

# These are the directories STM has put everything
STM32LIB=${SUMMON_DIR}/STM32F10x_StdPeriph_Lib_V3.5.0/Libraries
CMSIS_CORE=${STM32LIB}/CMSIS/CM3/CoreSupport
CMSIS_DEVICE=${STM32LIB}/CMSIS/CM3/DeviceSupport/ST/STM32F10x
STM32_PERIPH=${STM32LIB}/STM32F10x_StdPeriph_Driver

# Make sure we add the above paths to our include path
INCLUDES="-I${CMSIS_CORE} -I${CMSIS_DEVICE} -I${STM32_PERIPH}/inc"

# These are the compile time flags, we may need to experiment here
CFLAGS="-fno-common -Os -g -mcpu=cortex-m3 -mthumb -ffunction-sections -fdata-sections -Dassert_param(expr)=((void)0) -Wall"
ARFLAGS=rcsv

# Compile each source file
for file in ${CMSIS_CORE}/*.c ${CMSIS_DEVICE}/*.c ${STM32_PERIPH}/src/*.c
do
    ${CC} ${CFLAGS} ${INCLUDES} ${DEVICE} -c ${file}
    echo "Built ${file}"
done

# Create an archive (.a) file
${AR} ${ARFLAGS} libstm32.a *.o
echo "Created libstm32.a"
rm *.o
mv -f libstm32.a lib
cp -f ${CMSIS_CORE}/*.h ${CMSIS_DEVICE}/*.h ${STM32_PERIPH}/inc/*.h inc
cp -f ${CMSIS_CORE}/*.c ${CMSIS_DEVICE}/*.c ${STM32_PERIPH}/src/*.c src
echo "Headers are in build/inc, library is in build/libs, source is in build/src (just in case)"
