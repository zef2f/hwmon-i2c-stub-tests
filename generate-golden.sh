#!/bin/bash
#
# Generate golden output files for all tests in tests/list.txt.
# Run this once on a known-good kernel/driver setup before using check.sh.
# Must be run as root.
#

pushd "$(dirname "$(readlink -e "$0")")" >/dev/null

uid=$(id -u)
if [[ ${uid} -ne 0 ]]; then
    echo "Must be root to run this script"
    exit 1
fi

while IFS= read -r test_name; do
    [[ -z "${test_name}" || "${test_name}" == \#* ]] && continue

    test_script="tests/${test_name}/run.sh"
    result_outs_dir="tests/${test_name}/result.outs"

    if [[ ! -x "${test_script}" ]]; then
        echo "Skipping ${test_name}: ${test_script} is not executable."
        continue
    fi

    echo "Generating golden output for: ${test_name}"
    mkdir -p "${result_outs_dir}"
    timeout 300 "${test_script}"
    exit_code=$?

    if [[ ${exit_code} -ne 0 && ${exit_code} -ne 70 ]]; then
        echo "Warning: ${test_name} exited with code ${exit_code} — golden file may reflect a broken state."
    fi

    result_file="tests/${test_name}/result"
    if [[ -f "${result_file}" ]]; then
        cp "${result_file}" "${result_outs_dir}/out.1"
        echo "  Saved to ${result_outs_dir}/out.1 ($(wc -l < "${result_outs_dir}/out.1") lines)"
    else
        echo "  Warning: no result file produced."
    fi
done < tests/list.txt

popd >/dev/null
