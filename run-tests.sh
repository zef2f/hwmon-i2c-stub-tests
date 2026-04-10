#!/bin/bash
#
# Run hwmon i2c-stub tests directly, without golden file comparison.
# Suitable for coverage collection and smoke testing.
#
# Usage: $0 [module ...]
#   module  One or more driver names to test (e.g. lm90 adm1026).
#           If omitted, all entries from tests/list.txt are run.
#
# Exit codes:
#   0   All executed tests passed.
#   1   One or more tests failed.

pushd "$(dirname "$(readlink -e "$0")")" >/dev/null

if [[ $(id -u) -ne 0 ]]; then
    echo "Must be root to run this script."
    exit 1
fi

for mod in i2c-stub i2c-dev; do
    if ! modinfo "$mod" >/dev/null 2>&1; then
        echo "Error: kernel module '$mod' is not available."
        exit 1
    fi
done

if ! command -v i2cset >/dev/null 2>&1; then
    echo "Error: i2cset not found. Install i2c-tools."
    exit 1
fi

# Build the list of tests to run
if [[ $# -gt 0 ]]; then
    tests=("$@")
else
    mapfile -t tests < <(grep -v '^\s*#\|^\s*$' list.txt)
fi

pass=0; fail=0; skip=0

for test_name in "${tests[@]}"; do
    script="scripts/${test_name}.sh"

    if [[ ! -f "$script" ]]; then
        echo "$test_name [Skip] — $script not found"
        skip=$((skip + 1))
        continue
    fi

    if ! modinfo "$test_name" >/dev/null 2>&1; then
        echo "$test_name [Skip] — module not available"
        skip=$((skip + 1))
        continue
    fi

    bash "$script"
    code=$?

    if [[ $code -ne 0 ]]; then
        echo "$test_name [Failed] (exit $code)"
        fail=$((fail + 1))
    else
        echo "$test_name [Ok]"
        pass=$((pass + 1))
    fi
done

echo ""
echo "Results: $pass passed, $fail failed, $skip skipped"

popd >/dev/null

[[ $fail -eq 0 ]]
