#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source "${script_dir}/include/common-environment.sh"

# Option defaults
WORKING_DIR="${PWD}"
CACHE_DIR="${WORKING_DIR}/.metaschema-cache"
GENERATE_SCHEMA="json"
PROVIDER_DIR="${script_dir}/../toolchains/oscal-m2"
VERBOSE=false
HELP=false

usage() {                                      # Function: Print a help message.
  cat << EOF
Usage: $0 [options] metaschema_file [generated_schema_file]

-h, --help                        Display help
-w DIR, --working-dir DIR         Generate artifacts in DIR
--cache-dir dir                   Store used artifacts in DIR (e.g., schema for validation)
-v                                Provide verbose output
--xml                             Generate an XML schema
--json                            Generate a JSON schema (default)
EOF
}

OPTS=`getopt -o w:vh --long working-dir:,help,xml,json -n "$0" -- "$@"`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; usage ; exit 1 ; fi

# Process arguments
eval set -- "$OPTS"
while [ $# -gt 0 ]; do
  arg="$1"
  case "$arg" in
    -w|--working-dir)
      WORKING_DIR="$(realpath "$2")"
      shift # past path
      ;;
    --cache-dir)
      CACHE_DIR="$(realpath "$2")"
      shift # past path
      ;;
    --xml)
      GENERATE_SCHEMA="xml"
      ;;
    --json)
      GENERATE_SCHEMA="json"
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

if [ ! -f "$METASCHEMA" ]; then
  echo -e "${P_ERROR}Metaschema does not exist:${P_END} ${METASCHEMA}"
  exit 1
fi

# initialize provider
PROVIDER_PATH=$(realpath "$PROVIDER_DIR")
if [ "$VERBOSE" = "true" ]; then
  echo -e "${P_INFO}Using schema generator:${P_END} ${PROVIDER_PATH}"
fi
PROVIDER_INIT_FILE="${PROVIDER_PATH}/init.sh"
source "${PROVIDER_INIT_FILE}"
if ! function_exists "generate_${GENERATE_SCHEMA}_schema"; then
  >&2 echo -e "${P_ERROR}The function '${P_END}generate_${GENERATE_SCHEMA}_schema${P_ERROR}' isn't defined in:${P_END} ${PROVIDER_INIT_FILE}"
  >&2 echo -e "${P_INFO}The function '${P_END}generate_${GENERATE_SCHEMA}_schema${P_INFO}' must take two arguments:${P_END} <the metaschema file> <the location of the generated schema>${P_END}"
  exit 2
fi

if [ "$VERBOSE" = "true" ]; then
  echo -e "${P_INFO}Using working directory:${P_END} ${WORKING_DIR}"
  echo -e "${P_INFO}Using cache directory:${P_END} ${CACHE_DIR}"
fi

# make sure working directory exists
mkdir -p "$(dirname "$WORKING_DIR")"

METASCHEMA_RELATIVE_PATH=$(realpath --relative-to="${WORKING_DIR}" "$METASCHEMA")

if [ "$VERBOSE" = "true" ]; then
  echo -e "${P_INFO}Generating ${GENERATE_SCHEMA^^} schema for metaschema:${P_END} ${METASCHEMA_RELATIVE_PATH}"
fi

result=$("generate_${GENERATE_SCHEMA}_schema" "$METASCHEMA" "$GENERATED_SCHEMA")
cmd_exitcode=$?
if [ $cmd_exitcode -eq 0 ]; then
  if [ "$VERBOSE" = "true" ]; then
    echo -e "${P_OK}Generation of ${GENERATE_SCHEMA^^} schema passed for '${P_END}${METASCHEMA}${P_OK}'.${P_END}"
  fi
  echo -e "${result}"
fi
