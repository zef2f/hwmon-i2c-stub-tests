#!/bin/bash

script_dir="$(dirname "$(readlink -e "$0")")"
pushd "${script_dir}" >/dev/null

if ! modinfo lm85 >/dev/null 2>&1; then
    echo "Warning: lm85 module is not available (not built-in or loadable)."
    exit 70
fi

"../../scripts/lm85.sh" &> result

popd >/dev/null
