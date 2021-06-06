
toolchain_provider_init() {
  local my_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)
  PROVIDER_RESOURCE_DIR="$my_dir"
  source "${my_dir}/../../scripts/include/init-saxon.sh"
}

generate_xml_schema() {
  local metaschema="$1"; shift
  local output_file="$1"; shift

  local transform="${PROVIDER_RESOURCE_DIR}/nist-metaschema-MAKE-XSD.xsl"
  local result=$(xsl_transform "$transform" "$metaschema" "$output_file" 2>&1)
  local cmd_exitcode=$?
  if [ $cmd_exitcode -ne 0 ]; then
    >&2 echo -e "${P_ERROR}Generation of XML schema failed for '${P_END}${metaschema}${P_ERROR}'.${P_END}"
    >&2 echo -e "${P_ERROR}${result}${P_END}"
    return $cmd_exitcode
  else
    echo -e "${result}"
  fi
  return 0;
}

generate_json_schema() {
  local metaschema="$1"; shift
  local output_file="$1"; shift

  local transform="${PROVIDER_RESOURCE_DIR}/nist-metaschema-MAKE-JSON-SCHEMA.xsl"
  local result=$(xsl_transform "$transform" "$metaschema" "$output_file" 2>&1)
  local cmd_exitcode=$?
  if [ $cmd_exitcode -ne 0 ]; then
    >&2 echo -e "${P_ERROR}Generation of JSON schema failed for '${P_END}${metaschema}${P_ERROR}'.${P_END}"
    >&2 echo -e "${P_ERROR}${result}${P_END}"
    return $cmd_exitcode
  else
    echo -e "${result}"
  fi
  return 0;
}

generate_converter() {
  local metaschema="$1"; shift
  local output_file="$1"; shift
  local source_format="$1"; shift
  local target_format="$1"; shift

  local transform="${PROVIDER_RESOURCE_DIR}/nist-metaschema-MAKE-${source_format^^}-TO-${target_format^^}-CONVERTER.xsl"
  
  result=$(xsl_transform "$transform" "$metaschema" "$output_file" 2>&1)
  cmd_exitcode=$?
  if [ $cmd_exitcode -ne 0 ]; then
    >&2 echo -e "${P_ERROR}Generation of ${source_format^^} to ${target_format^^} converter failed for '${P_END}${metaschema}${P_ERROR}'.${P_END}"
    >&2 echo -e "${P_ERROR}${result}${P_END}"
    return 1;
  else
    echo -e "${result}"
  fi
  return 0;
}

convert_content() {
  local source_file="$1"; shift
  local output_file="$1"; shift
  local source_format="$1"; shift
  local target_format="$1"; shift
  local xslt_converter="$1"; shift

  local cmd_exitcode=0
  if [ "$source_format" == "xml" ] && [ "$target_format" == "json" ]; then
    result=$(xsl_transform "$xslt_converter" "$source_file" "$output_file" 2>&1)
    cmd_exitcode=$?
  elif [ "$source_format" == "json" ] && [ "$target_format" == "xml" ]; then
    result=$(xsl_transform "$xslt_converter" "" "$output_file" "-it:from-json" "file=file://${source_file}" 2>&1)
    cmd_exitcode=$?
  else
    >&2 echo -e "${P_ERROR}Conversion from ${source_format^^} to ${target_format^^} is not supported.${P_END}"
    exit 2
  fi

  echo "$result"
  return $cmd_exitcode;
}
