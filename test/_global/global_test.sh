#!/bin/sh

# The 'test/_global' folder is a special test folder that is not tied to a single feature.
#
# This test file is executed against a running container constructed
# from the value of 'color_and_hello' in the tests/_global/scenarios.json file.
#
# The value of a scenarios element is any properties available in the 'devcontainer.json'.
# Scenarios are useful for testing specific options in a feature, or to test a combination of features.
#
# This test can be run with the following command (from the root of this repo)
#    devcontainer features test --global-scenarios-only .

set -e

# # Optional: Import test library bundled with the devcontainer CLI
# source dev-container-features-test-lib

# # Feature-specific tests
# # The 'check' command comes from the dev-container-features-test-lib.
# check "check add vscode user" sh -c "id -u vscode | grep '1000'"

# # Report result
# # If any of the checks above exited with a non-zero exit code, the test will fail.
# reportResults

echo "content of /etc/passwd"
cat /etc/passwd
echo "content of /etc/group"
cat /etc/group

if [ "$(id -u vscode)" -ne 1000 ]; then
    echo '❌ Failed(set-user): UID of vscode != 1000'
    exit 1
else
    echo '✅ Passed(set-user): UID of vscode = 1000'
fi

if ! type pipx > /dev/null 2>&1; then
    echo '❌ Failed(python-pkgs): pipx not found!'
    exit 1
else
    echo '✅ Passed(python-pkgs): pipx installed successfully'
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