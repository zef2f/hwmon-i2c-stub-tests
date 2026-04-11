#!/bin/bash

script_dir="$(dirname "$(readlink -e "$0")")"
pushd "${script_dir}" >/dev/null

if ! modinfo adt7462 >/dev/null 2>&1; then
    echo "Warning: adt7462 module is not available (not built-in or loadable)."
    exit 70
fi

"../../scripts/adt7462.sh" &> result

popd >/dev/null
