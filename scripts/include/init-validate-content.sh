#!/bin/bash


init_validation() {
  local my_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)

  if [ -z ${METASCHEMA_SCRIPT_INIT+x} ]; then
    source "${my_dir}/common-environment.sh"
  fi
#  source "${my_dir}/init-saxon.sh"
}

#check_json_cli() {
#  if [[ -z "$JSON_CLI_HOME" ]]; then
#      if [[ -z "$JSON_CLI_VERSION" ]]; then
#          echo -e "${P_ERROR}JSON_CLI_VERSION is not set or is empty.${P_END} ${P_INFO}Please set JSON_CLI_VERSION to indicate the library version${P_END}"
#      fi
#      JSON_CLI_HOME=~/.m2/repository/gov/nist/oscal/json-cli/${JSON_CLI_VERSION}
#  fi
#}

validate_json() {
#  check_json_cli

  local schema_file="$1"; shift
  local instance_file="$1"; shift
  local extra_params=($@)

#  local classpath=$(JARS=("$JSON_CLI_HOME"/*.jar); IFS=:; echo -e "${JARS[*]}")

  set --

  if [ -z "$schema_file" ]; then
      echo -e "${P_ERROR}The JSON schema must be provided as the first argument.${P_END}"
  else
    set -- "$@" "-s" "${schema_file}"
  fi

  if [ -z "$instance_file" ]; then
      echo -e "${P_ERROR}The JSON file must be provided as the second argument.${P_END}"
  else
#    set -- "$@" "-v" "${instance_file}"
    set -- "$@" "-d" "${instance_file}"
  fi

  ajv "$@" "${extra_params[@]}"
  exitcode=$?
  if [ "$exitcode" -ne 0 ]; then
      if [ "$exitcode" -gt 1 ]; then
          echo -e "${P_ERROR}Error running ajv.${P_END}"
      else
          echo -e "${instance_file} is invalid."
      fi
      return $exitcode
  fi
  return 0
}

validate_xml() {
  local schema_file="$1"; shift
  local instance_file="$1"; shift
  local extra_params=($@)

  set -- "--noout"

  if [ -z "$schema_file" ]; then
      echo -e "${P_ERROR}The XML schema must be provided as the first argument.${P_END}"
  else
    set -- "$@" "--schema" "${schema_file}"
  fi

  if [ -z "$instance_file" ]; then
      echo -e "${P_ERROR}The XML file must be provided as the second argument.${P_END}"
  else
    set -- "$@" "${instance_file}"
  fi

  result=$(xmllint --noout "$@" "${extra_params[@]}" 2>&1)
  local exitcode=$?
  echo "$result"
  return $exitcode
}

