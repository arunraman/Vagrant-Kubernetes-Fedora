#!/bin/bash

set -x


function checkroot () {
    # Run as root
    if [ "$(id -u)" != "0" ]; then
        echo >&2 "Please run as root"
        exit 1
    fi
}

function installcommon () {
    # Install requirements
    echo 'fastestmirror=1' | tee -a /etc/dnf/dnf.conf
    dnf -y update
    dnf -y install git wget ntp kubernetes
}

