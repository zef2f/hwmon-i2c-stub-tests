#!/bin/bash

script_dir="$(dirname "$(readlink -e "$0")")"
pushd "${script_dir}" >/dev/null

if ! modinfo adt7470 >/dev/null 2>&1; then
    echo "Warning: adt7470 module is not available (not built-in or loadable)."
    exit 70
fi

"../../scripts/adt7470.sh" &> result

popd >/dev/null
