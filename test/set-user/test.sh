#!/bin/sh

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
#               --features set-user \
#               --base-image mcr.microsoft.com/devcontainers/base:ubuntu .

set -e

# # Optional: Import test library bundled with the devcontainer CLI
# source dev-container-features-test-lib

# # Feature-specific tests
# # The 'check' command comes from the dev-container-features-test-lib.
# check "check set-user" bash -c "id -u vscode | grep '1000'"

# # Report result
# # If any of the checks above exited with a non-zero exit code, the test will fail.
# reportResults
echo "content of /etc/passwd"
cat /etc/passwd
echo "content of /etc/group"
cat /etc/group


if id -u vscode > /dev/null 2>&1; then
    echo '✅ Passed(set-user): user vscode created'
    exit 0
else
    echo '❌ Failed(set-user): user vscode not found'
    exit 1
fi
