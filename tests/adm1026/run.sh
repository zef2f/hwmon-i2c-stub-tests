#!/bin/bash

script_dir="$(dirname "$(readlink -e "$0")")"
pushd "${script_dir}" >/dev/null

if ! modinfo adm1026 >/dev/null 2>&1; then
    echo "Warning: adm1026 module is not available (not built-in or loadable)."
    exit 70
fi

"../../scripts/adm1026.sh" &> result

popd >/dev/null
