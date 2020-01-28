#!/bin/bash

if [ -z ${OSCAL_SCRIPT_INIT+x} ]; then
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)/include/common-environment.sh"
fi

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)/include/init-validate-content.sh"

# Option defaults
GENERATE_SCHEMA_DEFAULT="json"
VALIDATE_SCHEMA_DEFAULT=false

usage() {                                      # Function: Print a help message.
  cat << EOF
Usage: $0 [options] metaschema_file [generated_schema_file]

-h, --help                        Display help
-w DIR, --working-dir DIR         Generate artifacts in DIR (default: ${WORKING_DIR})
--cache-dir DIR                   Store used artifacts in DIR (e.g., schema for validation) (default: ${CACHE_DIR})
--provider-dir DIR                The Metaschema framework provider to use (default: ${PROVIDER_DIR})
--validate-schema                 Perform schema validation after generating the schema
-v                                Provide verbose output
--xml                             Generate an XML schema
--json                            Generate a JSON schema (default)
EOF
}

GENERATE_SCHEMA="${GENERATE_SCHEMA_DEFAULT}"
VALIDATE_SCHEMA=${VALIDATE_SCHEMA_DEFAULT}

OPTS=`getopt -o w:vh --long working-dir:,cache-dir:,provider-dir:,validate,help,xml,json -n "$0" -- "$@"`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; usage ; exit 1 ; fi

# Process arguments
eval set -- "$OPTS"
while [ $# -gt 0 ]; do
  arg="$1"
  case "$arg" in
    -w|--working-dir)
      WORKING_DIR="$(get_abs_path "$2")"
      shift # past path
      ;;
    --cache-dir)
      CACHE_DIR="$(get_abs_path "$2")"
      shift # past path
      ;;
    --provider-dir)
      PROVIDER_DIR="$(get_abs_path "$2")"
      shift # past path
      ;;
    --xml)
      GENERATE_SCHEMA="xml"
      ;;
    --json)
      GENERATE_SCHEMA="json"
      ;;
    --validate)
      VALIDATE_SCHEMA=true
      ;;
    -v)
      VERBOSE=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --) # end of options
      shift
      break;
      ;;
    *)    # unknown option
      echo "Unhandled option: $1"
      exit 1
      ;;
  esac
  shift # past argument
done

OTHER_ARGS=$@ # save the remaining args

METASCHEMA="$1"
GENERATED_SCHEMA="$2"

if [ -z "$METASCHEMA" ]; then
  >&2 echo -e "${P_ERROR}You must specify the Metaschema to generate the schema for.${P_END}"
  usage
  exit 1
fi

if [ ! -f "$METASCHEMA" ]; then
  >&2 echo -e "${P_ERROR}Metaschema does not exist:${P_END} ${METASCHEMA}"
  exit 2
fi

if [ "$VERBOSE" = "true" ]; then
  echo -e "${P_INFO}Using working directory:${P_END} ${WORKING_DIR}"
  echo -e "${P_INFO}Using cache directory:${P_END} ${CACHE_DIR}"
fi

# make sure working directory exists
mkdir -p "$(dirname "$WORKING_DIR")"

METASCHEMA_RELATIVE_PATH=$(get_rel_path "${WORKING_DIR}" "${METASCHEMA}")

if [ "$VERBOSE" == "true" ]; then
  echo -e "${P_INFO}Generating ${GENERATE_SCHEMA^^} schema for metaschema:${P_END} ${METASCHEMA_RELATIVE_PATH}"
fi

result=$("generate_${GENERATE_SCHEMA}_schema" "$METASCHEMA" "$GENERATED_SCHEMA")
cmd_exitcode=$?
echo -ne "${result}"
if [ $cmd_exitcode -eq 0 ]; then
  if [ "$VERBOSE" = "true" ]; then
    echo -e "${P_OK}Generation of ${GENERATE_SCHEMA^^} schema passed for '${P_END}${METASCHEMA}${P_OK}'.${P_END}"
  fi
fi

if [ "$VALIDATE_SCHEMA" == "true" ]; then
  # validate generated schema
  case ${GENERATE_SCHEMA} in
  xml)
    result=$(validate_xml "${METASCHEMA_SCRIPT_DIR}/../support/schema/XMLSchema.xsd" "$GENERATED_SCHEMA")
    cmd_exitcode=$?
    ;;
  json)
    result=$(validate_json "${METASCHEMA_SCRIPT_DIR}/../support/schema/json-schema-schema.json" "$GENERATED_SCHEMA")
    cmd_exitcode=$?
    ;;
  *)
    echo -e "${P_WARN}${GENERATE_SCHEMA^^} schema validation not supported for '${P_END}${GENERATED_SCHEMA}${P_WARN}'.${P_END}"
    cmd_exitcode=0
    ;;
  esac

  if [ $cmd_exitcode -ne 0 ]; then
    echo -e "${P_ERROR}Schema validation failed for '${P_END}${GENERATED_SCHEMA}${P_ERROR}'.${P_END}"
    echo -e "${P_ERROR}${result}${P_END}"
    exitcode=1
  else
    if [ "$VERBOSE" == "true" ]; then
      echo -e "${P_OK}Schema validation passed for '${P_END}${GENERATED_SCHEMA}${P_OK}'.${P_END}"
    else
      echo -e "${P_OK}Schema generation complete for '${P_END}${METASCHEMA}${P_OK}' as '${P_END}${GENERATED_SCHEMA}${P_OK}', which is valid.${P_END}"
    fi
  fi
fi

