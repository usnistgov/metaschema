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

    result=$(java -cp "$classpath" net.sf.saxon.Transform "$@" "${extra_params[@]}" 2>&1)
    cmd_exitcode=$?
    if [ $cmd_exitcode -ne 0 ]; then
        echo -e "${P_ERROR}${result}${P_END}"
        echo -e "${P_ERROR}Error running Saxon.${P_END}"
        return 3;
    else
        echo -e "${result}"
    fi
    return 0
}

execute_query() {
    init_saxon

    local query="$1"; shift
    local source_file="$1"; shift
    local extra_params=($@)

    local classpath=$(JARS=("$SAXON_HOME"/*.jar); IFS=:; echo -e "${JARS[*]}")

    set --

    if [ ! -z "$query" ]; then
      set -- "$@" "-qs:${query}"
    fi

    if [ ! -z "$source_file" ]; then
      set -- "$@" "-s:${source_file}"
    fi

    java -cp "$classpath" net.sf.saxon.Query "$@" "${extra_params[@]}"
    cmd_exitcode=$?

    if [ "$cmd_exitcode" -ne 0 ]; then
        echo -e "${P_ERROR}Error running Saxon.${P_END}"
        return $cmd_exitcode
    fi
    return 0
}


