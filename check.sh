#!/bin/bash

pushd "$(dirname "$(readlink -e "$0")")" >/dev/null

uid=$(id -u)
if [[ ${uid} -ne 0 ]]; then
    echo "Must be root to run this script"
    exit 1
fi

# Ensure i2c-stub and i2c-dev are available
for mod in i2c-stub i2c-dev; do
    if ! modinfo "${mod}" >/dev/null 2>&1; then
        echo "Error: kernel module '${mod}' is not available."
        exit 1
    fi
done

# Ensure i2cset is available
if ! command -v i2cset >/dev/null 2>&1; then
    echo "Error: i2cset not found. Install i2c-tools."
    exit 1
fi

pass=0
fail=0
skip=0

while IFS= read -r test_name; do
    [[ -z "${test_name}" || "${test_name}" == \#* ]] && continue

    test_script="tests/${test_name}/run.sh"
    result_file="tests/${test_name}/result"
    result_outs_dir="tests/${test_name}/result.outs"

    if [[ ! -x "${test_script}" ]]; then
        echo "Skipping ${test_name}: ${test_script} is not executable or missing."
        skip=$((skip + 1))
        continue
    fi

    if [[ ! -d "${result_outs_dir}" || ! -f "${result_outs_dir}/out.1" ]]; then
        echo "Skipping ${test_name}: ${result_outs_dir}/out.1 is missing (run generate-golden.sh first)."
        skip=$((skip + 1))
        continue
    fi

    echo "Running test: ${test_name}"
    timeout 300 "${test_script}"
    exit_code=$?

    if [[ ${exit_code} -eq 70 ]]; then
        echo -e "${test_name} \e[36m[Skip]\e[0m"
        skip=$((skip + 1))
        continue
    fi

    if [[ ${exit_code} -eq 124 ]]; then
        echo -e "${test_name} \e[31m[Timeout]\e[0m"
        fail=$((fail + 1))
        continue
    fi

    if [[ ! -f "${result_file}" ]]; then
        echo -e "${test_name} \e[31m[Failed]\e[0m (no result file)"
        fail=$((fail + 1))
        continue
    fi

    match_found=false
    for expected_result in "${result_outs_dir}"/out.*; do
        if diff -q "${result_file}" "${expected_result}" &>/dev/null; then
            match_found=true
            break
        fi
    done

    if [[ "${match_found}" == true ]]; then
        echo -e "${test_name} \e[32m[Ok]\e[0m"
        pass=$((pass + 1))
    else
        echo -e "${test_name} \e[31m[Failed]\e[0m"
        diff "${result_outs_dir}/out.1" "${result_file}"
        fail=$((fail + 1))
    fi
done < tests/list.txt

echo ""
echo "Results: ${pass} passed, ${fail} failed, ${skip} skipped"

popd >/dev/null

[[ ${fail} -eq 0 ]]
