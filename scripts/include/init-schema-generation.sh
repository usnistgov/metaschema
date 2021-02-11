#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)/init-validate-content.sh"

generate_schema() {

  local format="$1"; shift
  local metaschema="$1"; shift
  local schema_file="$1"; shift

  result=$("generate_${format}_schema" "$metaschema" "$schema_file")
  cmd_exitcode=$?
  echo -ne "${result}"
  if [ $cmd_exitcode -eq 0 ]; then
    if [ "$VERBOSE" = "true" ]; then
      echo -e "${P_OK}Generation of ${format^^} schema passed for '${P_END}${metaschema}${P_OK}'.${P_END}"
    fi
  fi
  return $cmd_exitcode;
}

validate_schema() {
  local format="$1"; shift
  local schema_file="$1"; shift

  # validate generated schema
  case ${format} in
  xml)
    result=$(validate_xml "${METASCHEMA_SCRIPT_DIR}/../support/xml/XMLSchema.xsd" "$schema_file")
    cmd_exitcode=$?
    ;;
  json)
    result=$(validate_json_schema "$schema_file")
    cmd_exitcode=$?
    ;;
  *)
    echo -e "${P_WARN}${format^^} schema validation not supported for '${P_END}${schema_file}${P_WARN}'.${P_END}"
    cmd_exitcode=0
    ;;
  esac

  if [ $cmd_exitcode -ne 0 ]; then
    echo -e "${P_ERROR}${result}${P_END}"
    exitcode=1
  else
    if [ "$VERBOSE" == "true" ]; then
      echo -e "${P_OK}Schema validation passed for '${P_END}${GENERATED_SCHEMA}${P_OK}'.${P_END}"
    fi
  fi

  return $cmd_exitcode;
}
