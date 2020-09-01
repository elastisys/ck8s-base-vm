#!/bin/bash

set -u

here="$(dirname "$(readlink -f "$0")")"

var_file="${here}/variables.json"

build_config="${here}/baseos.json"
build_log="${here}/baseos.log"

test_config="${here}/baseos-test.json"
test_log="${here}/baseos-test.log"

usage() {
    echo "Usage: ${0} <build|test>" >&2
    exit 1
}

[ ${#} -eq 1 ] || usage

case "${1}" in
    build)
        packer build -var-file "${var_file}" "${build_config}" > "${build_log}"

        case "${?}" in
            0)
                echo -e "\e[32mBaseOS image created.\e[0m" >&2
            ;;
            *)
                echo -e "\e[31mError building baseOS image.\e[0m" >&2
                echo "Check: ${build_log}" >&2
                exit 1
            ;;
        esac
    ;;
    test)
        packer build -var-file "${var_file}" "${test_config}" > "${test_log}"

        case "${?}" in
            0)
                echo -e "\e[32mTest finished successfully.\e[0m" >&2
            ;;
            *)
                echo -e "\e[31mError while testing baseOS image.\e[0m" >&2
                echo "Check: ${test_log}" >&2
                exit 1
            ;;
        esac
    ;;
    *) usage ;;
esac
