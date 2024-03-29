#!/bin/sh
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/common.md
# Maintainer: The VS Code and Codespaces Teams

set -e

USERNAME="${USERNAME:-"${_REMOTE_USER:-"vscode"}"}"
USER_UID="${UID:-"automatic"}"
USER_GID="${GID:-"automatic"}"
DEBUG="${DEBUG:-"false"}"

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# If in automatic mode, determine if a user already exists, if not use vscode
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=vscode
elif [ "${USERNAME}" = "none" ]; then
    USERNAME=root
    USER_UID=0
    USER_GID=0
fi

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release
# Get an adjusted ID independent of distro variants
if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
    # Ensure apt is in non-interactive to avoid prompts
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get -y install --no-install-recommends sudo
    rm -rf /var/lib/apt/lists/*
    SHELL_PATH=/bin/bash
elif [ "${ID}" = "alpine" ]; then
    apk add --no-cache shadow sudo
    SHELL_PATH=/bin/sh
else
    echo "Linux distro ${ID} not supported."
    exit 1
fi

if [ "${DEBUG}" = "true" ]; then
    echo "content of /etc/passwd before setup:"
    cat /etc/passwd
    echo "content of /etc/group before setup:"
    cat /etc/group
fi

# Create or update a non-root user to match UID/GID.
group_name="${USERNAME}"
if id -u "${USERNAME}" > /dev/null 2>&1; then
    # User exists, update if needed
    if [ "${USER_GID}" != "automatic" ] && [ "${USER_GID}" != "$(id -g "${USERNAME}")" ]; then
        group_name="$(id -gn "${USERNAME}")"
        groupmod --gid "${USER_GID}" "${group_name}"
        usermod --gid "${USER_GID}" "${USERNAME}"
    fi
    if [ "${USER_UID}" != "automatic" ] && [ "${USER_UID}" != "$(id -u "${USERNAME}")" ]; then
        usermod --uid "${USER_UID}" "${USERNAME}"
    fi

elif id -nu "${USER_UID}" > /dev/null 2>&1; then
    # UID exists, update if needed
    EXIST_NAME="$(id -un "${USER_UID}")"
    EXIST_GROUP="$(id -gn "${EXIST_NAME}")"
    groupmod --new-name "${USERNAME}" "${EXIST_GROUP}"
    userdel "${EXIST_NAME}"
    useradd -s "${SHELL_PATH}" --uid "${USER_UID}" --gid "${USERNAME}" -m "${USERNAME}"
else
    # Create user
    if [ "${USER_GID}" = "automatic" ]; then
        groupadd "${USERNAME}"
    else
        groupadd --gid "${USER_GID}" "${USERNAME}"
    fi
    if [ "${USER_UID}" = "automatic" ]; then
        useradd -s "${SHELL_PATH}" --gid "${USERNAME}" -m "${USERNAME}"
    else
        useradd -s "${SHELL_PATH}" --uid "${USER_UID}" --gid "${USERNAME}" -m "${USERNAME}"
    fi
fi

# Add add sudo support for non-root user
if [ "${USERNAME}" != "root" ]; then
    echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}"
    chmod 0440 "/etc/sudoers.d/${USERNAME}"
fi

if [ "${DEBUG}" = "true" ]; then
    echo "content of /etc/passwd after setup:"
    cat /etc/passwd
    echo "content of /etc/group after setup:"
    cat /etc/group
fi
