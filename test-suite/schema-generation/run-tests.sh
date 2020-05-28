#!/bin/bash


if [ -z ${OSCAL_SCRIPT_INIT+x} ]; then
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)/../../scripts/include/common-environment.sh"
fi

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)/../../scripts/include/init-schema-generation.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)/../../scripts/include/init-schematron.sh"

# configuration
UNIT_TESTS_DIR=$(get_abs_path "${METASCHEMA_SCRIPT_DIR}/../test-suite/schema-generation")
METASCHEMA_SCHEMA=$(get_abs_path "${METASCHEMA_SCRIPT_DIR}/../toolchains/oscal-m3/lib/metaschema.xsd")
DEBUG="false"

# Option defaults
KEEP_TEMP_SCRATCH_DIR=false

usage() {                                      # Function: Print a help message.
  cat << EOF
Usage: $0 [options] [test dir]
Run all build scripts

-h, -help,                        Display help
-v                                Provide verbose output
--scratch-dir DIR                 Generate temporary artifacts in DIR
                                  If not provided a new directory will be
                                  created under \$TMPDIR if set or in /tmp.
--keep-temp-scratch-dir           If a scratch directory is automatically
                                  created, it will not be automatically removed.
EOF
}

OPTS=`getopt -o w:vh --long scratch-dir:,keep-temp-scratch-dir,help -n "$0" -- "$@"`
if [ $? != 0 ] ; then echo -e "Failed parsing options." >&2 ; usage ; exit 1 ; fi

# Process arguments
eval set -- "$OPTS"
while [ $# -gt 0 ]; do
  arg="$1"
  case "$arg" in
    --scratch-dir)
      SCRATCH_DIR="$(realpath "$2")"
      shift # past unit_test_dir
      ;;
    --keep-temp-scratch-dir)
      KEEP_TEMP_SCRATCH_DIR=true
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
      echo -e "Unhandled option: $1"
      exit 1
      ;;
  esac
  shift # past argument
done

OTHER_ARGS=$@ # save the arg

if [ -z "${SCRATCH_DIR+x}" ]; then
  SCRATCH_DIR="$(mktemp -d)"
  if [ "$KEEP_TEMP_SCRATCH_DIR" != "true" ]; then
    function CleanupScratchDir() {
      rc=$?
      if [ "$VERBOSE" = "true" ]; then
        echo -e ""
        echo -e "${P_INFO}Cleanup${P_END}"
        echo -e "${P_INFO}=======${P_END}"
        echo -e "${P_INFO}Deleting scratch directory:${P_END} ${SCRATCH_DIR}"
      fi
      rm -rf "${SCRATCH_DIR}"
      exit $rc
    }
    trap CleanupScratchDir EXIT
  fi
fi

generate_and_validate_schema() {
  local unit_test_collection_dir="$1"; shift
  local unit_test_path_prefix="$1"; shift
  local metaschema="$1"; shift
  local schema_output="$1"; shift
  local format="$1"; shift

  metaschema_relative=$(get_rel_path "$unit_test_collection_dir" "$metaschema")

  if [ "$VERBOSE" = "true" ]; then
    echo -e "  ${P_INFO}Generating ${format^^} schema for '${P_END}${metaschema_relative}${P_INFO}' as '${P_END}$schema_output${P_INFO}'.${P_END}"
  fi

  result=$(generate_schema "$format" "$metaschema" "$schema_output")
  cmd_exitcode=$?
  if [ -n "$result" ]; then
    >&2 echo -e "${result}"
  fi
  if [ $cmd_exitcode -ne 0 ]; then
    >&2 echo -e "  ${P_ERROR}Failed to generate ${format^^} schema for '${P_END}${metaschema_relative}${P_ERROR}'.${P_END}"
    return 1
  fi

  result=$(validate_schema "$format" "$schema_output")
  cmd_exitcode=$?
  if [ $cmd_exitcode -ne 0 ]; then
    if [ -n "$result" ]; then
      >&2 echo -e "${result}"
    fi
    >&2 echo -e "  ${P_ERROR}Failed to validate generated ${format^^} schema '${P_END}$schema_output${P_ERROR}'.${P_END}"
    return 2;
  fi
  echo -e "  ${P_OK}Generated valid ${format^^} schema for '${P_END}${metaschema_relative}${P_OK}' as '${P_END}$schema_output${P_OK}'.${P_END}"

  # diff the generated schema with the expected schema
  case ${format} in
    xml)
      expected_schema="${unit_test_path_prefix}_xml-schema.xsd"
      diff_tool="diff"
      ;;
    json)
      expected_schema="${unit_test_path_prefix}_json-schema.json"
      diff_tool="json-diff"
      ;;
  esac
  expected_schema_relative=$(get_rel_path "$unit_test_collection_dir" "$expected_schema")

  # Only perform this check if an expected schema exists
  if [ -f "$expected_schema" ]; then
    diff=$("$diff_tool" "$expected_schema" "$schema_output")
    cmd_exitcode=$?
    if [ $cmd_exitcode -ne 0 ]; then
      echo -e "  ${P_ERROR}Generated ${format^^} schema '${P_END}${schema_output}${P_ERROR}' doesn't match expected schema '${P_END}${expected_schema_relative}${P_ERROR}'.${P_END}"
      echo -e "${P_ERROR}${diff}${P_END}"
      return 3;
    else
      echo -e "  ${P_OK}Generated ${format^^} schema matches expected schema '${P_END}${expected_schema_relative}${P_OK}'.${P_END}"
    fi
  fi
  return 0;
}

run_test_instances() {
  local unit_test_collection_dir="$1"; shift
  local unit_test_collection_name="$1"; shift
  local unit_test_name="$1"; shift
  local schema="$1"; shift
  local format="$1"; shift

  exitcode=0
  while IFS= read -d $'\0' -r test_instance ; do
    test_instance_file=$(basename -- "$test_instance")
    test_instance_name="${test_instance_file/${unit_test_collection_name}-${unit_test_name}_test_/}"
    shopt -s extglob
    test_instance_name="${test_instance_name%%.@(xml|json)}"
    shopt -u extglob
    condition="${test_instance_name##*_}"
    test_instance_name="${test_instance_name%_*}"

    if [ "$VERBOSE" = "true" ]; then
      echo -e "  ${P_INFO}Evaluating test instance:${P_END} ${test_instance_name} = ${condition}"
    fi

    result=$(validate "$schema" "$test_instance" "$format" 2>&1)
    cmd_exitcode=$?

    case "$condition" in
      PASS)
        if [ $cmd_exitcode -ne 0 ]; then
          echo -e "  ${P_ERROR}${format^^} test instance '${P_END}${test_instance_name}${P_ERROR}' failed. Expected PASS.${P_END}"
          echo -e "${P_ERROR}${result}${P_END}"
          exitcode=1
        else
          echo -e "  ${P_OK}${format^^} test instance '${P_END}${test_instance_name}${P_OK}' passed.${P_END}"
        fi
        ;;
      FAIL)
        if [ $cmd_exitcode -eq 0 ]; then
          echo -e "  ${P_ERROR}${format^^} test instance '${P_END}${test_instance_name}${P_ERROR}' passed. Expected FAIL.${P_END}"
          echo -e "${P_ERROR}${result}${P_END}"
          exitcode=1
        else
          echo -e "  ${P_OK}${format^^} test instance '${P_END}${test_instance_name}${P_OK}' passed.${P_END}"
        fi
        ;;
      *)
        echo -e "${P_ERROR}Unsupported condition '$condition' for test instance '$test_instance_name'.${P_END}"
        exitcode=1
        ;;
    esac
  done < <(find "$unit_test_collection_dir" -maxdepth 1 -name "${unit_test_collection_name}-${unit_test_name}_test_*.${format}" -type f -print0)
  return $exitcode;
}

echo -e ""
echo -e "${P_INFO}Running Unit Tests${P_END}"
echo -e "${P_INFO}==================${P_END}"

if [ "$VERBOSE" = "true" ]; then
  echo -e "${P_INFO}Using scratch directory:${P_END} ${SCRATCH_DIR}"
fi

# compile the schematron
metaschema_lib=$(get_abs_path "${METASCHEMA_SCRIPT_DIR}/../toolchains/oscal-m3/lib")
schematron="$metaschema_lib/metaschema-check.sch"
compiled_schematron="${SCRATCH_DIR}/metaschema-schematron-compiled.xsl"

build_schematron "$schematron" "$compiled_schematron"
cmd_exitcode=$?
if [ $cmd_exitcode -ne 0 ]; then
  echo -e "${P_ERROR}Compilation of Schematron '${P_END}${schematron}${P_ERROR}' failed.${P_END}"
  exit 1
fi
# the following is needed by the compiled template
cp "${metaschema_lib}/metaschema-compose.xsl" "${SCRATCH_DIR}"
cp "${metaschema_lib}/oscal-datatypes-check.xsl" "${SCRATCH_DIR}"

test_dirs=()
if [ -n "$1" ]; then
    test_dirs+=("$1")
else
  while read -r -d $'\0' dir; do
    test_dirs+=("$dir")
  done < <(find "$UNIT_TESTS_DIR" -mindepth 1 -maxdepth 1 -type d -print0)
fi

if [ "$VERBOSE" == "true" ]; then
  echo -e "${P_INFO}Executing tests in:${P_END}"
  for test_dir in ${test_dirs[@]}; do
    echo -e "  ${test_dir}"
  done
fi

exitcode=0
for unit_test_collection_dir in "${test_dirs[@]}"
do
  # get absolute and relative paths of the unit test collection
  unit_test_collection_dir=$(get_abs_path "$unit_test_collection_dir")
  unit_test_collection_name=$(basename -- "$unit_test_collection_dir")
  echo -e "${P_INFO}Processing unit test collection:${P_END} ${unit_test_collection_name}"

  metaschema_units=()
  while read -r -d $'\0' unit; do
    metaschema_units+=("$unit")
  done < <(find "$unit_test_collection_dir" -maxdepth 1 -name "*_metaschema.xml" -type f -print0)

  unit_test_collection_scratch_dir="$SCRATCH_DIR/$unit_test_collection_name"
  mkdir -p "$unit_test_collection_scratch_dir"

  for metaschema in ${metaschema_units[@]}; do
    metaschema_file="$(basename -- "$metaschema")"
    unit_test_name="${metaschema_file/_metaschema.xml/}"
    unit_test_path_prefix="$unit_test_collection_dir/${unit_test_name}"

    echo -e "${P_INFO}Processing unit test:${P_END} ${unit_test_name}"

    unit_test_scratch_dir_prefix="$unit_test_collection_scratch_dir/$unit_test_name"

    metaschema_relative=$(realpath --relative-to="$unit_test_collection_dir" "$metaschema")

    # first validate the metaschema
    if [ "$VERBOSE" = "true" ]; then
      echo -e "  ${P_INFO}Validating Metaschema:${P_END} ${metaschema_relative}"
    fi
    result=$(validate_xml "$METASCHEMA_SCHEMA" "$metaschema" 2>&1)
    cmd_exitcode=$?
    if [ $cmd_exitcode -ne 0 ]; then
      echo -e "  ${P_ERROR}Metaschema '${P_END}${metaschema_relative}${P_ERROR}' is not XML Schema valid.${P_END}"
      echo -e "${P_ERROR}${result}${P_END}"
      exitcode=1
      continue
    fi

    if [ "$VERBOSE" = "true" ]; then
      echo -e "  ${P_OK}Metaschema '${P_END}${metaschema_relative}${P_OK}' is XML Schema valid.${P_END}"
    fi

    svrl_result="${unit_test_scratch_dir_prefix}.svrl"
    result=$(validate_with_schematron "$compiled_schematron" "$metaschema" "$svrl_result" 2>&1)
    cmd_exitcode=$?
    if [ $cmd_exitcode -ne 0 ]; then
        if [ -f "${unit_test_path_prefix}_validation-schematron-FAIL" ]; then
          if [ "$VERBOSE" = "true" ]; then
            echo -e "  ${P_OK}Metaschema '${P_END}${metaschema_relative}${P_OK}' was expected to fail the schematron checks.${P_END}"
          fi
          continue;
        else
          echo -e "  ${P_ERROR}Metaschema '${P_END}${metaschema_relative}${P_ERROR}' did not pass the schematron checks.${P_END}"
          echo -e "${P_ERROR}${result}${P_END}"
          exitcode=1
          continue;
        fi
    fi

    json_schema_valid=true
    if [ "$DEBUG" == "true" ]; then
      # skip this step and use the expected schema as the schema
      json_schema="${unit_test_path_prefix}_json-schema.json"
    else
      # Now generate the JSON schema
      json_schema="${unit_test_scratch_dir_prefix}_generated-json-schema.json"
      
      generate_and_validate_schema "$unit_test_collection_dir" "$unit_test_path_prefix" "$metaschema" "$json_schema" "json"
      cmd_exitcode=$?
      if [ $cmd_exitcode -ne 0 ]; then
        json_schema_valid=false
        exitcode=1
        continue;
      fi
    fi

    xml_schema_valid=true
    if [ "$DEBUG" == "true" ]; then
      # skip this step and use the expected schema as the schema
      xml_schema="${unit_test_path_prefix}_json-schema.json"
    else
      # Now generate the XML schema
      xml_schema="${unit_test_scratch_dir_prefix}_generated-xml-schema.xsd"
      generate_and_validate_schema "$unit_test_collection_dir" "$unit_test_path_prefix" "$metaschema" "$xml_schema" "xml"
      cmd_exitcode=$?
      if [ $cmd_exitcode -ne 0 ]; then
        xml_schema_valid=false
        exitcode=1
        continue;
      fi
    fi

    # now run test instances
    if [ "$json_schema_valid" = "true" ]; then
      run_test_instances "$unit_test_collection_dir" "$unit_test_collection_name" "$unit_test_name" "$json_schema" "json"
      cmd_exitcode=$?
      if [ $cmd_exitcode -ne 0 ]; then
        exitcode=1
      fi
    fi

    if [ "$xml_schema_valid" = "true" ]; then
      run_test_instances "$unit_test_collection_dir" "$unit_test_collection_name" "$unit_test_name" "$xml_schema" "xml"
      cmd_exitcode=$?
      if [ $cmd_exitcode -ne 0 ]; then
        exitcode=1
      fi
    fi

  done
done

exit $exitcode
