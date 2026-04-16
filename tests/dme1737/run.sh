#!/bin/bash

script_dir="$(dirname "$(readlink -e "$0")")"
pushd "${script_dir}" >/dev/null

if ! modinfo dme1737 >/dev/null 2>&1; then
    echo "Warning: dme1737 module is not available (not built-in or loadable)."
    exit 70
fi

"../../scripts/dme1737.sh" &> result

popd >/dev/null
