#!/bin/bash

if [ -z ${METASCHEMA_SCRIPT_INIT+x} ]; then
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)/include/common-environment.sh"
fi

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)/include/init-validate-content.sh"

# Option defaults
GENERATE_SOURCE_FORMAT_DEFAULT="xml"
GENERATE_TARGET_FORMAT_DEFAULT="json"

usage() {                                      # Function: Print a help message.
  cat << EOF
Usage: $0 [options] metaschema_file [generated_converter_file]

-h, --help                        Display help
-w DIR, --working-dir DIR         Generate artifacts in DIR (default: ${WORKING_DIR})
--cache-dir DIR                   Store used artifacts in DIR (e.g., schema for validation) (default: ${CACHE_DIR})
--provider-dir DIR                The Metaschema framework provider to use (default: ${PROVIDER_DIR})
--source-format FORMAT            The source format to convert from [xml,json] (default: ${GENERATE_SOURCE_FORMAT_DEFAULT})
--target-format FORMAT            The target format to convert to [xml,json] (default: ${GENERATE_TARGET_FORMAT_DEFAULT})
-v                                Provide verbose output
EOF
}

GENERATE_SOURCE_FORMAT="${GENERATE_SOURCE_FORMAT_DEFAULT}"
GENERATE_TARGET_FORMAT="${GENERATE_TARGET_FORMAT_DEFAULT}"


OPTS=`getopt -o w:vh --long working-dir:,cache-dir:,provider-dir:,source-format:,target-format:,help,xml,json -n "$0" -- "$@"`
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
    --source-format)
      GENERATE_SOURCE_FORMAT="$2"
      shift # past format
      ;;
    --target-format)
      GENERATE_TARGET_FORMAT="$2"
      shift # past format
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
GENERATED_CONVERTER="$2"

if [ -z "$METASCHEMA" ]; then
  >&2 echo -e "${P_ERROR}You must specify the Metaschema to generate the converter for.${P_END}"
  usage
  exit 1
fi

if [ ! -f "$METASCHEMA" ]; then
  >&2 echo -e "${P_ERROR}Metaschema does not exist:${P_END} ${METASCHEMA}"
  exit 2
fi

if [ "$VERBOSE" == "true" ] && [ "$PPID" == "$$" ]; then
  echo -e "${P_INFO}Using working directory:${P_END} ${WORKING_DIR}"
  echo -e "${P_INFO}Using cache directory:${P_END} ${CACHE_DIR}"
fi

# make sure working directory exists
mkdir -p "$(dirname "$WORKING_DIR")"

if ! [[ "$GENERATE_SOURCE_FORMAT" =~ ^(xml|json)$ ]]; then
  >&2 echo -e "${P_ERROR}Invalid source format '${P_END}${GENERATE_SOURCE_FORMAT}${P_ERROR}'.${P_END} Supported formats are: xml or json"
  exit 3
fi

if ! [[ "$GENERATE_TARGET_FORMAT" =~ ^(xml|json)$ ]]; then
  >&2 echo -e "${P_ERROR}Invalid source format '${P_END}${GENERATE_TARGET_FORMAT}${P_ERROR}'.${P_END} Supported formats are: xml or json"
  exit 4
fi

if ! [[ "$GENERATE_SOURCE_FORMAT" -eq "$GENERATE_TARGET_FORMAT" ]]; then
  >&2 echo -e "${P_ERROR}Source and target formats must be different.${P_END} Supported formats are: xml or json"
  exit 5
fi

METASCHEMA_RELATIVE_PATH="$(get_rel_path "${WORKING_DIR}" "${METASCHEMA}")"


GENERATED_CONVERTER_RELATIVE="$(get_rel_path "${WORKING_DIR}" "$GENERATED_CONVERTER")"

if [ "$VERBOSE" == "true" ]; then
  echo -e "${P_INFO}Generating ${GENERATE_SOURCE_FORMAT^^} to ${GENERATE_TARGET_FORMAT^^} converter for '${P_END}${METASCHEMA_RELATIVE_PATH}${P_INFO}' as '${P_END}${GENERATED_CONVERTER_RELATIVE}${P_INFO}'.${P_END}"
fi

result=$(generate_converter "$METASCHEMA" "$GENERATED_CONVERTER" "${GENERATE_SOURCE_FORMAT}" "${GENERATE_TARGET_FORMAT}" 2>&1)
cmd_exitcode=$?
if [ $cmd_exitcode -ne 0 ]; then
  
  echo -e "${P_ERROR}Generating ${GENERATE_SOURCE_FORMAT^^} to ${GENERATE_TARGET_FORMAT^^} converter failed for '${P_END}${METASCHEMA_RELATIVE_PATH}${P_ERROR}'.${P_END}"
  echo -e "${P_ERROR}${result}${P_END}"
  exitcode=1
else
  echo -e "${P_OK}Generated ${GENERATE_SOURCE_FORMAT^^} to ${GENERATE_TARGET_FORMAT^^} converter for '${P_END}${METASCHEMA_RELATIVE_PATH}${P_OK}' as '${P_END}${GENERATED_CONVERTER_RELATIVE}${P_INFO}'.${P_END}"
fi


