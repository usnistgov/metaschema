#!/bin/bash

init_saxon() {

  if [ -z ${METASCHEMA_SCRIPT_INIT+x} ]; then
    source "${my_dir}/common-environment.sh"
  fi

  if [[ -z "$SAXON_HOME" ]]; then
      if [[ -z "$SAXON_VERSION" ]]; then
          echo -e "${P_ERROR}SAXON_VERSION is not set or is empty.${P_END} ${P_INFO}Please set SAXON_VERSION to indicate the library version or SAXON_HOME to point to the location of the Saxon library.${P_END}"
      fi
      SAXON_HOME=~/.m2/repository/net/sf/saxon/Saxon-HE/$SAXON_VERSION
  fi

  if [[ -z "$CALABASH_HOME" ]]; then
    echo -e "${P_ERROR}CALABASH_HOME is not set or is empty.${P_END} ${P_INFO}Please set SAXON_VERSION to indicate the library version or SAXON_HOME to point to the location of the Saxon library.${P_END}"
  fi
}

# ( set -o posix ; set )

xsl_transform() {
    init_saxon

    local stylesheet="$1"; shift
    local source_file="$1"; shift
    local output_file="$1"; shift
    local extra_params=($@)

    local classpath=$(JARS=("$SAXON_HOME"/*.jar); IFS=:; echo -e "${JARS[*]}")

    set -- "-warnings:silent" "-xsl:${stylesheet}"

    if [ ! -z "$output_file" ]; then
      set -- "$@" "-o:${output_file}"
    fi

    if [ ! -z "$source_file" ]; then
      set -- "$@" "-s:${source_file}"
    fi

    java -cp "$classpath" net.sf.saxon.Transform "$@" "${extra_params[@]}"

    if [ "$?" -ne 0 ]; then
        echo -e "${P_ERROR}Error running Saxon.${P_END}"
        return 3
    fi
    return 0
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

