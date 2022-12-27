#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# This code was generated by the DevContainers Feature Cookiecutter
# Docs: https://github.com/devcontainers-contrib/features/tree/main/pkgs/feature-template#readme
#-------------------------------------------------------------------------------------------------------------

set -e

PIPX_UTILS="${PIPX_UTILS:-"none"}"
PIP_PKGS="${PIP_PKGS:-"none"}"

# Clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as
    root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Determine the appropriate non-root user
USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u ${CURRENT_USER} > /dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

updaterc() {
    echo "Updating /etc/bash.bashrc and /etc/zsh/zshrc..."
    if [ -f "/etc/bash.bashrc" ] && [[ "$(cat /etc/bash.bashrc)" != *"$1"* ]]; then
        echo -e "$1" >> /etc/bash.bashrc
    fi
    if [ -f "/etc/zsh/zshrc" ] && [[ "$(cat /etc/zsh/zshrc)" != *"$1"* ]]; then
        echo -e "$1" >> /etc/zsh/zshrc
    fi
}

install_python_and_pip() {

    # install python if missing
    if ! type python3 > /dev/null 2>&1; then
        echo "Installing python..."
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -y
        # apt-get -y install python3-minimal python3-pip libffi-dev python3-venv
        apt-get -y install python3-pip python3-venv
    fi

    if type pip3 > /dev/null 2>&1; then
        echo "Updating pip..."
        python3 -m pip install --no-cache-dir --upgrade pip
    fi
}

# Install Pipx tools
if [ "$PIPX_UTILS" != "none" ] ; then

    install_python_and_pip

    IFS=' ' read -a PIPX_UTILS <<< "$PIPX_UTILS"  # convert str to array
    export PIPX_HOME=${PIPX_HOME:-"/usr/local/py-utils"}
    export PIPX_BIN_DIR="${PIPX_HOME}/bin"
    PATH="${PATH}:${PIPX_BIN_DIR}"

    # Create pipx group, dir, and set sticky bit
    if ! cat /etc/group | grep -e "^pipx:" > /dev/null 2>&1; then
        groupadd -r pipx
    fi
    usermod -a -G pipx ${USERNAME}
    umask 0002
    mkdir -p ${PIPX_BIN_DIR}
    chown -R "${USERNAME}:pipx" ${PIPX_HOME}
    chmod -R g+r+w "${PIPX_HOME}"
    find "${PIPX_HOME}" -type d -print0 | xargs -0 -n 1 chmod g+s

    # Install tools
    echo "Installing Pipx tools..."
    export PYTHONUSERBASE=/tmp/pip-tmp
    export PIP_CACHE_DIR=/tmp/pip-tmp/cache
    PIPX_DIR=""
    if ! type pipx > /dev/null 2>&1; then
        pip3 install --disable-pip-version-check --no-cache-dir --user --no-warn-script-location pipx 2>&1
        /tmp/pip-tmp/bin/pipx install --pip-args='--no-cache-dir --no-warn-script-location' pipx
        PIPX_DIR="/tmp/pip-tmp/bin/"
    fi
    for util in "${PIPX_UTILS[@]}"; do
        if ! type ${util} > /dev/null 2>&1; then
            "${PIPX_DIR}pipx" install --system-site-packages --pip-args '--no-cache-dir --force-reinstall --disable-pip-version-check --no-warn-script-location' ${util}
        else
            echo "${util} already installed. Skipping."
        fi
    done
    rm -rf /tmp/pip-tmp
    updaterc "export PIPX_HOME=\"${PIPX_HOME}\""
    updaterc "export PIPX_BIN_DIR=\"${PIPX_BIN_DIR}\""
    updaterc "if [[ \"\${PATH}\" != *\"\${PIPX_BIN_DIR}\"* ]]; then export PATH=\"\${PATH}:\${PIPX_BIN_DIR}\"; fi"
fi

# Install Pypi packages
if [ "$PIP_PKGS" != "none" ] ; then
    install_python_and_pip
    echo "Installing Pypi packages..."
    export PYTHONUSERBASE=/tmp/pip-tmp
    export PIP_CACHE_DIR=/tmp/pip-tmp/cache
    pip3 install --disable-pip-version-check --no-cache-dir $PIP_PKGS
    rm -rf /tmp/pip-tmp
fi

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
