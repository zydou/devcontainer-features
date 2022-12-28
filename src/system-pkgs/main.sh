#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# This code was generated by the DevContainers Feature Cookiecutter
# Docs: https://github.com/devcontainers-contrib/features/tree/main/pkgs/feature-template#readme
#-------------------------------------------------------------------------------------------------------------

set -e

# Debian / Ubuntu packages
install_debian_packages() {
    # Ensure apt is in non-interactive to avoid prompts
    export DEBIAN_FRONTEND=noninteractive

    if [ "${PKGS}" = "none" ] && [ "${UPGRADE_PACKAGES}" = "true" ]; then
        apt-get -y upgrade --no-install-recommends
        apt-get autoremove -y
        rm -rf /var/lib/apt/lists/*
        exit 0
    elif [ "${PKGS}" = "none" ] && [ "${UPGRADE_PACKAGES}" = "false" ]; then
        exit 0
    fi

    local package_list="$PKGS"
    # Needed for adding manpages-posix and manpages-posix-dev which are non-free packages in Debian
    if [ "${ADD_NON_FREE_PACKAGES}" = "true" ]; then
        # Bring in variables from /etc/os-release like VERSION_CODENAME
        sed -i -E "s/deb http:\/\/(deb|httpredir)\.debian\.org\/debian ${VERSION_CODENAME} main/deb http:\/\/\1\.debian\.org\/debian ${VERSION_CODENAME} main contrib non-free/" /etc/apt/sources.list
        sed -i -E "s/deb-src http:\/\/(deb|httredir)\.debian\.org\/debian ${VERSION_CODENAME} main/deb http:\/\/\1\.debian\.org\/debian ${VERSION_CODENAME} main contrib non-free/" /etc/apt/sources.list
        sed -i -E "s/deb http:\/\/(deb|httpredir)\.debian\.org\/debian ${VERSION_CODENAME}-updates main/deb http:\/\/\1\.debian\.org\/debian ${VERSION_CODENAME}-updates main contrib non-free/" /etc/apt/sources.list
        sed -i -E "s/deb-src http:\/\/(deb|httpredir)\.debian\.org\/debian ${VERSION_CODENAME}-updates main/deb http:\/\/\1\.debian\.org\/debian ${VERSION_CODENAME}-updates main contrib non-free/" /etc/apt/sources.list
        sed -i "s/deb http:\/\/security\.debian\.org\/debian-security ${VERSION_CODENAME}\/updates main/deb http:\/\/security\.debian\.org\/debian-security ${VERSION_CODENAME}\/updates main contrib non-free/" /etc/apt/sources.list
        sed -i "s/deb-src http:\/\/security\.debian\.org\/debian-security ${VERSION_CODENAME}\/updates main/deb http:\/\/security\.debian\.org\/debian-security ${VERSION_CODENAME}\/updates main contrib non-free/" /etc/apt/sources.list
        sed -i "s/deb http:\/\/deb\.debian\.org\/debian ${VERSION_CODENAME}-backports main/deb http:\/\/deb\.debian\.org\/debian ${VERSION_CODENAME}-backports main contrib non-free/" /etc/apt/sources.list
        sed -i "s/deb-src http:\/\/deb\.debian\.org\/debian ${VERSION_CODENAME}-backports main/deb http:\/\/deb\.debian\.org\/debian ${VERSION_CODENAME}-backports main contrib non-free/" /etc/apt/sources.list
        # Handle bullseye location for security https://www.debian.org/releases/bullseye/amd64/release-notes/ch-information.en.html
        sed -i "s/deb http:\/\/security\.debian\.org\/debian-security ${VERSION_CODENAME}-security main/deb http:\/\/security\.debian\.org\/debian-security ${VERSION_CODENAME}-security main contrib non-free/" /etc/apt/sources.list
        sed -i "s/deb-src http:\/\/security\.debian\.org\/debian-security ${VERSION_CODENAME}-security main/deb http:\/\/security\.debian\.org\/debian-security ${VERSION_CODENAME}-security main contrib non-free/" /etc/apt/sources.list
        echo "Running apt-get update..."
        package_list="${package_list} manpages-posix manpages-posix-dev"
    fi

    # Include libssl1.1 if available
    if [[ ! -z $(apt-cache --names-only search ^libssl1.1$) ]]; then
        package_list="${package_list} libssl1.1"
    fi

    # Include libssl3 if available
    if [[ ! -z $(apt-cache --names-only search ^libssl3$) ]]; then
        package_list="${package_list} libssl3"
    fi

    # Include appropriate version of libssl1.0.x if available
    local libssl_package=$(dpkg-query -f '${db:Status-Abbrev}\t${binary:Package}\n' -W 'libssl1\.0\.?' 2>&1 || echo '')
    if [ "$(echo "$libssl_package" | grep -o 'libssl1\.0\.[0-9]:' | uniq | sort | wc -l)" -eq 0 ]; then
        if [[ ! -z $(apt-cache --names-only search ^libssl1.0.2$) ]]; then
            # Debian 9
            package_list="${package_list} libssl1.0.2"
        elif [[ ! -z $(apt-cache --names-only search ^libssl1.0.0$) ]]; then
            # Ubuntu 18.04
            package_list="${package_list} libssl1.0.0"
        fi
    fi

    # Install the list of packages
    echo "Packages to verify are installed: ${package_list}"
    rm -rf /var/lib/apt/lists/*
    apt-get update -y
    apt-get -y install --no-install-recommends ${package_list} 2> >( grep -v 'debconf: delaying package configuration, since apt-utils is not installed' >&2 )

    # Get to latest versions of all packages
    if [ "${UPGRADE_PACKAGES}" = "true" ]; then
        apt-get -y upgrade --no-install-recommends
        apt-get autoremove -y
    fi

    # Ensure at least the en_US.UTF-8 UTF-8 locale is available = common need for both applications and things like the agnoster ZSH theme.
    if [ "${LOCALE_ALREADY_SET}" != "true" ] && ! grep -o -E '^\s*en_US.UTF-8\s+UTF-8' /etc/locale.gen > /dev/null; then
        echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
        apt-get -y install --no-install-recommends locales
        locale-gen
        LOCALE_ALREADY_SET="true"
    fi

    # Clean up
    apt-get -y clean
    rm -rf /var/lib/apt/lists/*
}

# RedHat / RockyLinux / CentOS / Fedora packages
install_redhat_packages() {

    local install_cmd=dnf
    if ! type dnf > /dev/null 2>&1; then
        install_cmd=yum
    fi

    if [ "${PKGS}" = "none" ] && [ "${UPGRADE_PACKAGES}" = "true" ]; then
        ${install_cmd} upgrade -y
        exit 0
    elif [ "${PKGS}" = "none" ] && [ "${UPGRADE_PACKAGES}" = "false" ]; then
        exit 0
    fi

    package_list="$PKGS"

    # Install OpenSSL 1.0 compat if needed
    if ${install_cmd} -q list compat-openssl10 >/dev/null 2>&1; then
        package_list="${package_list} compat-openssl10"
    fi

    # Install lsb_release if available
    if ${install_cmd} -q list redhat-lsb-core >/dev/null 2>&1; then
        package_list="${package_list} redhat-lsb-core"
    fi

    eval "${install_cmd} -y install ${package_list}"

    # Get to latest versions of all packages
    if [ "${UPGRADE_PACKAGES}" = "true" ]; then
        ${install_cmd} upgrade -y
    fi
}

# Alpine Linux packages
install_alpine_packages() {

    if [ "${PKGS}" = "none" ]; then
        exit 0
    fi

    if [ "${ENABLE_TESTING}" = "true" ]; then
        echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
    fi
    eval "apk add --no-cache $PKGS"
}

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

# Install packages for appropriate OS
case "${ADJUSTED_ID}" in
    "debian")
        install_debian_packages
        ;;
    "rhel")
        install_redhat_packages
        ;;
    "alpine")
        install_alpine_packages
        ;;
esac

echo "Done!"
