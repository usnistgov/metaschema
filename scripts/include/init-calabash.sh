#!/bin/bash

init_calabash() {
  local my_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)
#  source "${my_dir}/common-environment.sh"
  source "${my_dir}/init-saxon.sh"

  if [[ -z "$CALABASH_HOME" ]]; then
    echo -e "${P_ERROR}CALABASH_HOME is not set or is empty.${P_END} ${P_INFO}Please set CALABASH_HOME to point to the location of the Calabash XML installation.${P_END}"
  fi
}

run_calabash() {
    local xproc="$1"; shift
    local extra_params=($@)

    local JARS=()
    JARS+=("$CALABASH_HOME"/*.jar)
    JARS+=("$CALABASH_HOME"/lib/*.jar)

    local classpath=$(IFS=:; echo -e "${JARS[*]}")

    java -cp "$classpath" com.xmlcalabash.drivers.Main -D "${extra_params[@]}" "$xproc"

    if [ "$?" -ne 0 ]; then
        echo -e "${P_ERROR}Error running Calabash.${P_END}"
        return 3
    fi
    return 0
}
