#!/bin/bash
# shellcheck disable=SC1090,SC2034
# ==================================================================
# common-utils/main.sh
# ==================================================================
# DevContainer Features - Common Utilities
# DOCS: https://github.com/ragsworks/devcontainer-features/tree/mins
# ==================================================================
# Aside from a few tweaks, this code comes from the Development
# Container Features project (https://github.com/devcontainers/features)
# Copyright © Microsoft Corporation. All rights reserved.
# Licensed under the MIT License
# ==================================================================
# VARIABLES
# ==================================================================
INSTALL_ZSH="${INSTALLZSH:-"true"}"
CONFIGURE_ZSH_AS_DEFAULT_SHELL="${CONFIGUREZSHASDEFAULTSHELL:-"false"}"
INSTALL_OH_MY_ZSH="${INSTALLOHMYZSH:-"true"}"
UPGRADE_PACKAGES="${UPGRADEPACKAGES:-"true"}"
USERNAME="${USERNAME:-"automatic"}"
USER_UID="${UID:-"automatic"}"
USER_GID="${GID:-"automatic"}"
ADD_NON_FREE_PACKAGES="${NONFREEPACKAGES:-"false"}"

MARKER_FILE="/usr/local/etc/vscode-dev-containers/common"
# ==================================================================
# MAIN
# ==================================================================
# check that script is running as root
if [ "$EUID" -ne 0 ]; then
	echo -e "Script MUST be run as root.  Use sudo, su or add 'User root' to your Dockerfile before running this script."
	exit 1
fi

# If we're using Alpine, install bash before executing
. /etc/os-release
if [ "${ID}" = "alpine" ]; then
    apk add --no-cache bash
fi

exec /bin/bash "$(dirname "$0")/main.sh" "$@"
exit $?
