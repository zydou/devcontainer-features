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

NON_ROOT_USER=""
POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
  if id -u ${CURRENT_USER} >/dev/null 2>&1; then
    NON_ROOT_USER=${CURRENT_USER}
    break
  fi
done
if [ "${NON_ROOT_USER}" = "" ]; then
  NON_ROOT_USER=root
fi

su "$NON_ROOT_USER" -c "/home/$NON_ROOT_USER/.local/bin/chezmoi data"
ret=$?
if [ "$ret" -eq '0' ]; then
    echo '✅ Passed(chezmoi): chezmoi installed successfully'
    exit 0
else
    echo '❌ Failed(chezmoi): chezmoi not found!'
    exit 1
fi
