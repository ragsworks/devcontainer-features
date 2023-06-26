#!/usr/bin/env bash
# shellcheck disable=SC2034
# ==================================================================
# install.sh
# ==================================================================
# Install BB-Import Feature
#
# File:         install.sh
# Author:       Ragdata
# Date:         26/06/2023
# License:      MIT License
# Copyright:    Copyright © 2023 Darren (Ragdata) Poulton
# ==================================================================
# FUNCTIONS
# ==================================================================
# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}
# ==================================================================
# MAIN
# ==================================================================
# Clean up
rm -rf /var/lib/apt/lists/*

# check that script is running as root
if [ "$EUID" -ne 0 ]; then
	echo -e "Script MUST be run as root.  Use sudo, su or add 'User root' to your Dockerfile before running this script."
	exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Install required packages to build if missing
check_packages build-essential curl ca-certificates tar gettext libssl-dev zlib1g-dev libcurl?-openssl-dev libexpat1-dev

echo "Downloading installer for latest version of BB-Import .. "
bash <(curl -sfLS https://raw.githubusercontent.com/bash-bits/bb-import/master/install.sh)
echo "Done!"
