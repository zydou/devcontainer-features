#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'color' feature with no options.
#
# Eg:
# {
#    "image": "<..some-base-image...>",
#    "features": {
#      "color": {}
#    }
# }
#
# Thus, the value of all options,
# will fall back to the default value in the feature's 'devcontainer-feature.json'
# For the 'color' feature, that means the default favorite color is 'red'.
#
# This test can be run with the following command (from the root of this repo)
#    devcontainer features test \
#               --features feature-id \
#               --base-image mcr.microsoft.com/devcontainers/base:ubuntu .

set -e

# # Optional: Import test library bundled with the devcontainer CLI
# source dev-container-features-test-lib

# # Feature-specific tests
# # The 'check' command comes from the dev-container-features-test-lib.
# check "check name" bash -c "id -u vscode | grep '1000'"

# # Report result
# # If any of the checks above exited with a non-zero exit code, the test will fail.
# reportResults

if ! type pipx > /dev/null 2>&1; then
    echo '❌ Failed(python-pkgs): pipx not found!'
    exit 1
else
    echo '✅ Passed(python-pkgs): pipx installed successfully'
fi

if $(python --version | grep -q '3.10') ; then
    echo '✅ Passed(python-pkgs): python (3.10) installed successfully'
else
    echo '❌ Failed(python-pkgs): python not found!'
    exit 1
fi

if $(black --version | grep -q '22.10.0') ; then
    echo '✅ Passed(python-pkgs): black (22.10.0) installed successfully'
else
    echo '❌ Failed(python-pkgs): black not found!'
    exit 1
fi

if $(yapf --version | grep -q '0.30.0') ; then
    echo '✅ Passed(python-pkgs): yapf (0.30.0) installed successfully'
else
    echo '❌ Failed(python-pkgs): yapf not found!'
    exit 1
fi
