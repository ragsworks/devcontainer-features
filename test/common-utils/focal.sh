#!/bin/bash

# ==================================================================
# SCENARIO
# ==================================================================
# Optional: Import test library
source dev-container-features-test-lib

# Definition specific tests
. /etc/os-release
check "non-root user" test "$(whoami)" = "devcontainer"
check "distro" test "${VERSION_CODENAME}" = "focal"

# Report result
reportResults
