#!/bin/bash

my_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
SCRIPT_INCLUDE_DIR="$my_dir"
source "$SCRIPT_INCLUDE_DIR/common-environment.sh"

if [[ -z "$JSON_CLI_HOME" ]]; then
    if [[ -z "$JSON_CLI_VERSION" ]]; then
        echo -e "${P_ERROR}JSON_CLI_VERSION is not set or is empty.${P_END} ${P_INFO}Please set JSON_CLI_VERSION to indicate the library version${P_END}"
    fi
    JSON_CLI_HOME=~/.m2/repository/gov/nist/oscal/json-cli/${JSON_CLI_VERSION}
fi

# ( set -o posix ; set )

validate_json() {
    local json_schema="$1"; shift
    local json_file="$1"; shift
    local extra_params=($@)

    local classpath=$(JARS=("$JSON_CLI_HOME"/*.jar); IFS=:; echo -e "${JARS[*]}")

    set --

    if [ -z "$json_schema" ]; then
        echo -e "${P_ERROR}The JSON schema must be provided as the first argument.${P_END}"
    else
      set -- "$@" "-s" "${json_schema}"
    fi

    if [ -z "$json_file" ]; then
        echo -e "${P_ERROR}The JSON file must be provided as the second argument.${P_END}"
    else
      set -- "$@" "-v" "${json_file}"
    fi

    java -cp "$classpath" gov.nist.oscal.json.JsonCLI "$@" "${extra_params[@]}"
    exitcode=$?
    if [ "$exitcode" -ne 0 ]; then
        if [ "$exitcode" -gt 1 ]; then
            echo -e "${P_ERROR}Error running JsonCLI.${P_END}"
        else
            echo -e "${json_file} is invalid."
        fi
        return $exitcode
    fi
    return 0
}
