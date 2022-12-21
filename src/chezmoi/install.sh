#!/usr/bin/env bash
# Modified from https://github.com/meaningful-ooo/devcontainer-features/tree/main/src/homebrew


CHEZMOI_VERSION=${VERSION:-"latest"}
DOTFILES_REPO=${DOTFILES_REPO:-"none"}
USERNAME=${USERNAME:-"automatic"}
ONE_SHOT=${ONE_SHOT:-"false"}
BINDIR="/usr/bin"  # chezmoi installation directory
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

echo "USERNAME is ${USERNAME}"
# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release
# Get an adjusted ID independant of distro variants
if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
    ADJUSTED_ID="debian"
elif [[ "${ID}" = "rhel" || "${ID}" = "fedora" || "${ID_LIKE}" = *"rhel"* || "${ID_LIKE}" = *"fedora"* ]]; then
    ADJUSTED_ID="rhel"
elif [ "${ID}" = "alpine" ]; then
    ADJUSTED_ID="alpine"
else
    echo "Linux distro ${ID} not supported."
    exit 1
fi

# Checks if packages are installed and installs them if not
check_packages() {
  case "${ADJUSTED_ID}" in
      "debian")
          if ! dpkg -s "$@" >/dev/null 2>&1; then
            apt-get update
            apt-get -y install --no-install-recommends "$@"
          fi
          ;;
      "rhel")
          local install_cmd=dnf
          if ! type dnf > /dev/null 2>&1; then
              install_cmd=yum
          fi
          ${install_cmd} -y install "$@"
          ;;
      "alpine")
          if ! apk -e info "$@" >/dev/null 2>&1; then
            apk add --no-cache "$@"
          fi
          ;;
  esac
}

export DEBIAN_FRONTEND=noninteractive

# Install dependencies if missing
check_packages git curl ca-certificates

# Download official install script
curl -fsLS get.chezmoi.io -o /tmp/install_chezmoi.sh
chmod +x /tmp/install_chezmoi.sh
/tmp/install_chezmoi.sh -b ${BINDIR} -t ${CHEZMOI_VERSION} -d
if [ "${DOTFILES_REPO}" != "none" ]; then
  echo "chezmoi init && apply"
  if [ "${ONE_SHOT}" = "false" ]; then
    su ${USERNAME} bash -c "${BINDIR}/chezmoi init ${DOTFILES_REPO}"
    su ${USERNAME} bash -c "${BINDIR}/chezmoi apply --force --verbose"
    # Do it again as some scripts unexpected failed
    su ${USERNAME} bash -c "${BINDIR}/chezmoi apply --force --verbose"
  else
    su ${USERNAME} bash -c "${BINDIR}/chezmoi init ${DOTFILES_REPO} --one-shot --verbose"
  fi
fi

# Persist ENV
echo "export DEVCONTAINER_FEATURE_CHEZMOI=1" > /etc/profile.d/99-chezmoi.sh
chmod +x /etc/profile.d/99-chezmoi.sh

cleanup
cd $HOME
rm -rf ./cache
rm -f /tmp/install_chezmoi.sh
echo "Done!"
