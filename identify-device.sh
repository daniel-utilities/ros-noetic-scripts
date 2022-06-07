#!/usr/bin/env bash

function get_device_info()
{
    ID="$(source /etc/os-release && echo "$ID")"
    VERSION_ID="$(source /etc/os-release && echo "$VERSION_ID")"
    if [ -e "/sys/firmware/devicetree/base/model" ]; then
        MODEL="$(tr -d '\0' <  /sys/firmware/devicetree/base/model)"
    else
        MODEL=""
    fi
}

function verify_device_info()
{
    DEVICE=""

    local NEEDS_ID="$1"
    local NEEDS_VERSION_ID="$2"
    local NEEDS_MODEL="$3"

    get_device_info

    if [[ "$ID" == *"$NEEDS_ID"* && "$MODEL" == *"$NEEDS_MODEL"* ]]; then
        DEVICE="$MODEL:$ID:$VERSION_ID"
        echo "Device identified as $DEVICE ."

        if [[ "$VERSION_ID" != *"$NEEDS_VERSION_ID"* ]]; then
            echo "$ID is supported but has incorrect OS version (has $ID:$VERSION_ID, needs $ID:$NEEDS_VERSION_ID)"
            echo
            read -r -p "Continue anyway? (Y/N): " 
            echo
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                DEVICE=""
            fi
        fi
    fi
}

IDENTITY=""

if [[ "$IDENTITY" == "" ]]; then
    ID="ubuntu"
    VERSION_ID="20.04"
    MODEL=""
    verify_device_info "$ID" "$VERSION_ID" "$MODEL"
    [[ "$DEVICE" != "" ]] && IDENTITY="ubuntu"
fi


if [[ "$IDENTITY" == "" ]]; then
    ID="debian"
    VERSION_ID="11"
    MODEL="Raspberry Pi 4"
    verify_device_info "$ID" "$VERSION_ID" "$MODEL"
    [[ "$DEVICE" != "" ]] && IDENTITY="raspi4"
fi

if [[ "$IDENTITY" == "" ]]; then
    ID="raspbian"
    VERSION_ID="11"
    MODEL="Raspberry Pi 4"
    verify_device_info "$ID" "$VERSION_ID" "$MODEL"
    [[ "$DEVICE" != "" ]] && IDENTITY="raspi4"
fi

if [[ "$IDENTITY" == "" ]]; then
    ID="debian"
    VERSION_ID="11"
    MODEL="Raspberry Pi 3"
    verify_device_info "$ID" "$VERSION_ID" "$MODEL"
    [[ "$DEVICE" != "" ]] && IDENTITY="raspi3"
fi

if [[ "$IDENTITY" == "" ]]; then
    ID="raspbian"
    VERSION_ID="11"
    MODEL="Raspberry Pi 3"
    verify_device_info "$ID" "$VERSION_ID" "$MODEL"
    [[ "$DEVICE" != "" ]] && IDENTITY="raspi3"
fi

if [[ "$IDENTITY" == "" ]]; then
    ID="debian"
    VERSION_ID="11"
    MODEL="Raspberry Pi 2"
    verify_device_info "$ID" "$VERSION_ID" "$MODEL"
    [[ "$DEVICE" != "" ]] && IDENTITY="raspi2"
fi

if [[ "$IDENTITY" == "" ]]; then
    ID="raspbian"
    VERSION_ID="11"
    MODEL="Raspberry Pi 2"
    verify_device_info "$ID" "$VERSION_ID" "$MODEL"
    [[ "$DEVICE" != "" ]] && IDENTITY="raspi2"
fi

if [[ "$IDENTITY" == "" ]]; then
    ID="raspbian"
    VERSION_ID="11"
    MODEL="Raspberry Pi"
    verify_device_info "$ID" "$VERSION_ID" "$MODEL"
    [[ "$DEVICE" != "" ]] && IDENTITY="raspi1"
fi

if [[ "$IDENTITY" == "" ]]; then
    ID="debian"
    VERSION_ID="11"
    MODEL=""
    verify_device_info "$ID" "$VERSION_ID" "$MODEL"
    [[ "$DEVICE" != "" ]] && IDENTITY="debian"
fi

ID=""
VERSION_ID=""
MODEL=""
