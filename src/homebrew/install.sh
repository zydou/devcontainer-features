#!/usr/bin/env bash
# Modified from https://github.com/meaningful-ooo/devcontainer-features/tree/main/src/homebrew


USERNAME=${USERNAME:-"linuxbrew"}
SHALLOW_CLONE=${SHALLOW_CLONE:-"true"}
FORMULAS=${FORMULAS:-"none"}
BREWFILE=${BREWFILE:-"none"}
HOMEBREW_BREW_GIT_REMOTE=${HOMEBREW_BREW_GIT_REMOTE:-"https://github.com/Homebrew/brew"}
HOMEBREW_CORE_GIT_REMOTE=${HOMEBREW_CORE_GIT_REMOTE:-"https://github.com/Homebrew/homebrew-core"}
HOMEBREW_BOTTLE_DOMAIN=${HOMEBREW_BOTTLE_DOMAIN:-"https://ghcr.io/v2/homebrew/core"}
HOMEBREW_PIP_INDEX_URL=${HOMEBREW_PIP_INDEX_URL:-"https://pypi.org/simple"}

ARCHITECTURE="$(uname -m)"
if [ "${ARCHITECTURE}" != "amd64" ] && [ "${ARCHITECTURE}" != "x86_64" ]; then
  echo "(!) Architecture $ARCHITECTURE unsupported"
  exit 1
fi

cleanup() {
  source /etc/os-release
  case "${ID}" in
    debian|ubuntu)
      rm -rf /var/lib/apt/lists/*
    ;;
  esac
}

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

# Determine the appropriate non-root user
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
  echo "user ${USERNAME} not exits, create it."
  groupadd ${USERNAME}
  useradd -s /bin/bash --gid $USERNAME -m $USERNAME
fi

apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
  source /etc/os-release
  case "${ID}" in
    debian|ubuntu)
      if ! dpkg -s "$@" >/dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
      fi
    ;;
    alpine)
      if ! apk -e info "$@" >/dev/null 2>&1; then
        apk add --no-cache "$@"
      fi
    ;;
  esac
}

updaterc() {
  echo "Updating /etc/bash.bashrc and /etc/zsh/zshrc..."
  if [ -f "/etc/bash.bashrc" ] && [[ "$(cat /etc/bash.bashrc)" != *"$1"* ]]; then
      echo -e "$1" >> /etc/bash.bashrc
  fi
  if [ -f "/etc/zsh/zshrc" ] && [[ "$(cat /etc/zsh/zshrc)" != *"$1"* ]]; then
      echo -e "$1" >> /etc/zsh/zshrc
  fi
}

export DEBIAN_FRONTEND=noninteractive

# Clean up
cleanup

# Install dependencies if missing
check_packages curl git ca-certificates

# Install Homebrew
HOMEBREW_PREFIX="/home/${USERNAME}/.linuxbrew"
rm -rf "${HOMEBREW_PREFIX}"
echo "Installing Homebrew..."
if [ "${SHALLOW_CLONE}" = "false" ]; then
  git clone https://github.com/Homebrew/brew "${HOMEBREW_PREFIX}/Homebrew"
  mkdir -p "${HOMEBREW_PREFIX}/Homebrew/Library/Taps/homebrew"
  git clone https://github.com/Homebrew/homebrew-core "${HOMEBREW_PREFIX}/Homebrew/Library/Taps/homebrew/homebrew-core"
else
  echo "Using shallow clone..."
  git clone --depth 1 https://github.com/Homebrew/brew "${HOMEBREW_PREFIX}/Homebrew"
  mkdir -p "${HOMEBREW_PREFIX}/Homebrew/Library/Taps/homebrew"
  git clone --depth 1 https://github.com/Homebrew/homebrew-core "${HOMEBREW_PREFIX}/Homebrew/Library/Taps/homebrew/homebrew-core"
  # Disable automatic updates as they are not allowed with shallow clone installation
  updaterc "export HOMEBREW_NO_AUTO_UPDATE=1"
fi
"${HOMEBREW_PREFIX}/Homebrew/bin/brew" config
mkdir -p "${HOMEBREW_PREFIX}/bin"
ln -s "${HOMEBREW_PREFIX}/Homebrew/bin/brew" "${HOMEBREW_PREFIX}/bin"


if [ "${FORMULAS}" != "none" ]; then
  # https://github.com/Homebrew/brew/blob/39e158fb939dadcdf6ee0a67a0930b15f9b16b39/Library/Homebrew/brew.sh#L182
  [[ -f /.dockerenv ]] || touch /.dockerenv
  eval "HOMEBREW_NO_AUTO_UPDATE=1 ${HOMEBREW_PREFIX}/bin/brew install ${FORMULAS}"
fi

if [ "${BREWFILE}" != "none" ]; then
  # https://github.com/Homebrew/brew/blob/39e158fb939dadcdf6ee0a67a0930b15f9b16b39/Library/Homebrew/brew.sh#L182
  [[ -f /.dockerenv ]] || touch /.dockerenv
  curl -o /tmp/Brewfile "${BREWFILE}"
  eval "HOMEBREW_NO_AUTO_UPDATE=1 ${HOMEBREW_PREFIX}/bin/brew bundle install --file /tmp/Brewfile --no-lock"
  rm -f /tmp/Brewfile
fi

chown -R ${USERNAME}:${USERNAME} "${HOMEBREW_PREFIX}"

cleanup
${HOMEBREW_PREFIX}/bin/brew cleanup --prune=all
cd $HOME
rm -rf ./cache
echo "Done!"
