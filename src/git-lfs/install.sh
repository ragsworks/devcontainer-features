#!/usr/bin/env bash

# ==================================================================
# install.sh
# ==================================================================
# Install Git-LFS Feature
#
# File:         install.sh
# Author:       Ragdata
# Date:         25/06/2023
# License:      MIT License
# Copyright:    Copyright © 2023 Darren (Ragdata) Poulton
# ==================================================================
# ATTRIBUTION:	This script has been HEAVILY influenced & guided by
#               the work of the Official Organization for the
#               Development Containers Specification. (see
#               ATTRIBUTION section of README.md for a link.)
# COPYRIGHT:	Copyright © Microsoft Corporation. All rights reserved.
# ==================================================================
# PREFLIGHT
# ==================================================================
GIT_LFS_VERSION=${VERSION:-"latest"}
AUTO_PULL=${AUTOPULL:="true"}
GIT_LFS_ARCHIVE_GPG_KEY_URI="https://packagecloud.io/github/git-lfs/gpgkey"
GIT_LFS_ARCHIVE_ARCHITECTURES="amd64 arm64"
GIT_LFS_ARCHIVE_VERSION_CODENAMES="stretch buster bullseye bionic focal jammy"
GIT_LFS_CHECKSUM_GPG_KEYS="0x88ace9b29196305ba9947552f1ba225c0223b187 0x86cd3297749375bcf8206715f54fe648088335a9 0xaa3b3450295830d2de6db90caba67be5a5795889"
GPG_KEY_SERVERS="keyserver hkp://keyserver.ubuntu.com
keyserver hkps://keys.openpgp.org
keyserver hkp://keyserver.pgp.com"
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

# Figure out correct version of a three part version number is not passed
find_version_from_git_tags() {
    local variable_name=$1
    local requested_version=${!variable_name}
    if [ "${requested_version}" = "none" ]; then return; fi
    local repository=$2
    local prefix=${3:-"tags/v"}
    local separator=${4:-"."}
    local last_part_optional=${5:-"false"}
    if [ "$(echo "${requested_version}" | grep -o "." | wc -l)" != "2" ]; then
        local escaped_separator=${separator//./\\.}
        local last_part
        if [ "${last_part_optional}" = "true" ]; then
            last_part="(${escaped_separator}[0-9]+)?"
        else
            last_part="${escaped_separator}[0-9]+"
        fi
        local regex="${prefix}\\K[0-9]+${escaped_separator}[0-9]+${last_part}$"
        local version_list="$(git ls-remote --tags ${repository} | grep -oP "${regex}" | tr -d ' ' | tr "${separator}" "." | sort -rV)"
        if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
            declare -g ${variable_name}="$(echo "${version_list}" | head -n 1)"
        else
            set +e
            declare -g ${variable_name}="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|$)")"
            set -e
        fi
    fi
    if [ -z "${!variable_name}" ] || ! echo "${version_list}" | grep "^${!variable_name//./\\.}$" > /dev/null 2>&1; then
        echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
        exit 1
    fi
    echo "${variable_name}=${!variable_name}"
}

# Import the specified key in a variable name passed in as
receive_gpg_keys() {
    local keys=${!1}

    # Use a temporary location for gpg keys to avoid polluting image
    export GNUPGHOME="/tmp/tmp-gnupg"
    mkdir -p ${GNUPGHOME}
    chmod 700 ${GNUPGHOME}
    echo -e "disable-ipv6\n${GPG_KEY_SERVERS}" > ${GNUPGHOME}/dirmngr.conf
    # GPG key download sometimes fails for some reason and retrying fixes it.
    local retry_count=0
    local gpg_ok="false"
    set +e
    until [ "${gpg_ok}" = "true" ] || [ "${retry_count}" -eq "5" ];
    do
        echo "(*) Downloading GPG key..."
        ( echo "${keys}" | xargs -n 1 gpg --recv-keys) 2>&1 && gpg_ok="true"
        if [ "${gpg_ok}" != "true" ]; then
            echo "(*) Failed getting key, retring in 10s..."
            (( retry_count++ ))
            sleep 10s
        fi
    done
    set -e
    if [ "${gpg_ok}" = "false" ]; then
        echo "(!) Failed to get gpg key."
        exit 1
    fi
}

apt_get_update()
{
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

install_using_apt() {
    # Soft version matching
    if [ "${GIT_LFS_VERSION}" != "latest" ] && [ "${GIT_LFS_VERSION}" != "lts" ] && [ "${GIT_LFS_VERSION}" != "stable" ]; then
        find_version_from_git_tags GIT_LFS_VERSION "https://github.com/git-lfs/git-lfs"
        version_suffix="=${GIT_LFS_VERSION}"
    else
        version_suffix=""
    fi
    # Install
    curl -sSL "${GIT_LFS_ARCHIVE_GPG_KEY_URI}" | gpg --dearmor > /usr/share/keyrings/gitlfs-archive-keyring.gpg
    echo -e "deb [arch=${architecture} signed-by=/usr/share/keyrings/gitlfs-archive-keyring.gpg] https://packagecloud.io/github/git-lfs/${ID} ${VERSION_CODENAME} main\ndeb-src [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gitlfs-archive-keyring.gpg] https://packagecloud.io/github/git-lfs/${ID} ${VERSION_CODENAME} main" > /etc/apt/sources.list.d/git-lfs.list

    if ! (apt-get update && apt-get install -yq git-lfs${version_suffix}); then
        rm -f /etc/apt/sources.list.d/git-lfs.list
        echo "Could not fetch git-lfs from apt"
        return 1
    fi

    git-lfs install --skip-repo
}

install_using_github() {
    echo "(*) No apt package for ${VERSION_CODENAME} ${architecture}. Installing manually."
    mkdir -p /tmp/git-lfs
    cd /tmp/git-lfs
    find_version_from_git_tags GIT_LFS_VERSION "https://github.com/git-lfs/git-lfs"
    git_lfs_filename="git-lfs-linux-${architecture}-v${GIT_LFS_VERSION}.tar.gz"
    echo "Looking for release artfact: ${git_lfs_filename}"
    curl -sSL -o "${git_lfs_filename}" "https://github.com/git-lfs/git-lfs/releases/download/v${GIT_LFS_VERSION}/${git_lfs_filename}"
    # Verify file
    curl -sSL -o "sha256sums.asc" "https://github.com/git-lfs/git-lfs/releases/download/v${GIT_LFS_VERSION}/sha256sums.asc"
    receive_gpg_keys GIT_LFS_CHECKSUM_GPG_KEYS
    gpg -q --decrypt "sha256sums.asc" > sha256sums
    sha256sum --ignore-missing -c "sha256sums"
    # Extract and install
    echo "Validated release artifact integrity."
    echo "Starting to extract..."
    tar xf "${git_lfs_filename}" -C .
    echo "Installing..."
    if [ -f "./install.sh" ]; then
        ./install.sh
    else
        # Starting around v3.2.0, the release
        # artifact file structure changed slightly
        enclosed_folder="git-lfs-${GIT_LFS_VERSION}"
        cd "${enclosed_folder}"
            ./install.sh
        cd ../
    fi
    rm -rf /tmp/git-lfs /tmp/tmp-gnupg
}

export DEBIAN_FRONTEND=noninteractive

# Install git, curl, gpg, dirmngr and debian-archive-keyring if missing
. /etc/os-release
check_packages curl ca-certificates gnupg2 dirmngr apt-transport-https
if ! type git > /dev/null 2>&1; then
    check_packages git
fi
if [ "${ID}" = "debian" ]; then
    check_packages debian-archive-keyring
fi

# Install Git LFS
echo "Installing Git LFS..."
architecture="$(dpkg --print-architecture)"
if [[ "${GIT_LFS_ARCHIVE_ARCHITECTURES}" = *"${architecture}"* ]] && [[  "${GIT_LFS_ARCHIVE_VERSION_CODENAMES}" = *"${VERSION_CODENAME}"* ]]; then
    install_using_apt || use_github="true"
else
    use_github="true"
fi

# If no archive exists or apt install fails, try direct from github
if [ "${use_github}" = "true" ]; then
    install_using_github
fi

# --- Generate a 'pull-git-lfs-artifacts.sh' script to be executed by the 'postCreateCommand' lifecycle hook
PULL_GIT_LFS_SCRIPT_PATH="/usr/local/share/pull-git-lfs-artifacts.sh"

tee "$PULL_GIT_LFS_SCRIPT_PATH" > /dev/null \
<< EOF
#!/bin/sh
set -e
AUTO_PULL=${AUTO_PULL}
EOF

tee -a "$PULL_GIT_LFS_SCRIPT_PATH" > /dev/null \
<< 'EOF'

echo "Fetching git lfs artifacts..."

if [ "${AUTO_PULL}" != "true" ]; then
    echo "(!) Skipping 'git lfs pull' because 'autoPull' is not set to 'true'"
    exit 0
fi

# Check if repo is a git lfs repo.
if ! git lfs ls-files > /dev/null 2>&1; then
    echo "(!) Skipping automatic 'git lfs pull' because no git lfs files were detected"
    exit 0
fi

git lfs pull
EOF

chmod 755 "$PULL_GIT_LFS_SCRIPT_PATH"

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"