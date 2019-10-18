my_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
provider_dir="$my_dir"
source "${my_dir}/../../scripts/include/saxon-init.sh"

generate_xml_schema() {
    local metaschema="$1"; shift
    local output_file="$1"; shift

    transform="${provider_dir}/xml/produce-xsd.xsl"
    result=$(xsl_transform "$transform" "$metaschema" "$output_file" 2>&1)
    cmd_exitcode=$?
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

    transform="${provider_dir}/json/produce-json-schema.xsl"
    result=$(xsl_transform "$transform" "$metaschema" "$output_file" 2>&1)
    cmd_exitcode=$?
    if [ $cmd_exitcode -ne 0 ]; then
      >&2 echo -e "${P_ERROR}Generation of JSON schema failed for '${P_END}${metaschema}${P_ERROR}'.${P_END}"
      >&2 echo -e "${P_ERROR}${result}${P_END}"
      return $cmd_exitcode
    else
      echo -e "${result}"
    fi
    return 0;
}
