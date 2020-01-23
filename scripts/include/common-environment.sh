#!/bin/bash

if [ -z ${METASCHEMA_SCRIPT_INIT+x} ]; then

  function_exists() {
      declare -f -F $1 > /dev/null
      return $?
  }

  get_abs_path() {
    local path="$1"
    local abs_path

    if [ "$path" == "." ]; then
      abs_path="$(pwd)"
    elif [ "$path" == ".." ]; then
      abs_path="$(dirname "$(pwd)")"
    else
      abs_path="$(cd "$(dirname "$path")"; pwd)/$(basename "$path")"
    fi
    echo "$abs_path"
  }

  get_rel_path() {
    # modified from https://stackoverflow.com/questions/2564634/convert-absolute-path-into-relative-path-given-a-current-directory-using-bash/12498485#12498485

    # the source and target are expected to be absolute paths
    local source=$(get_abs_path "$1")
    local target=$(get_abs_path "$2")

    local common_part="$source" # star with source for now
    local result="" # empty for now

    while [[ "${target#$common_part}" == "${target}" ]]; do
      # no match, means that candidate common part is not correct
      # go up one level (reduce common part)
      common_part="$(dirname $common_part)"
      # and record that we went back, with correct / handling
      if [[ -z $result ]]; then
          result=".."
      else
          result="../$result"
      fi
    done

    if [[ $common_part == "/" ]]; then
        # special case for root (no common path)
        result="$result/"
    fi

    # since we now have identified the common part,
    # compute the non-common part
    local forward_part="${target#$common_part}"

    # and now stick all parts together
    if [[ -n $result ]] && [[ -n $forward_part ]]; then
        result="$result$forward_part"
    elif [[ -n $forward_part ]]; then
        # extra slash removal
        result="${forward_part:1}"
    fi

    echo $result  
  }

  if [ -z ${METASCHEMA_SCRIPT_DIR+x} ]; then
    METASCHEMA_SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
    METASCHEMA_SCRIPT_DIR="$(cd "${METASCHEMA_SCRIPT_DIR}/.."; pwd)"
  fi

  if [ -f "${METASCHEMA_SCRIPT_DIR}/config.sh" ]; then
    source "${METASCHEMA_SCRIPT_DIR}/config.sh"
  fi

  # set meaningful defaults if not set above
  if [ -z ${PROVIDER_DIR+x} ]; then
    PROVIDER_DIR="${METASCHEMA_SCRIPT_DIR}/../toolchains/oscal-m2"
  fi

  if [ -z ${WORKING_DIR+x} ]; then
    WORKING_DIR="${PWD}"
  fi
    
  if [ -z ${CACHE_DIR+x} ]; then
    CACHE_DIR="${WORKING_DIR}/.metaschema-cache"
  fi

  if [ -z ${VERBOSE+x} ]; then
    VERBOSE=true
  fi

  PROVIDER_DIR=$(get_abs_path "${PROVIDER_DIR}")
  WORKING_DIR=$(get_abs_path "${WORKING_DIR}")
  CACHE_DIR=$(get_abs_path "${CACHE_DIR}")

  # Make directories
  mkdir -p "${WORKING_DIR}"
  mkdir -p "${CACHE_DIR}"

  ## Setup color codes
  # check if stdout is a terminal...
  export TERM=${TERM:-dumb}
  colorize=0
  if [ -t 1 ]; then
    # does the terminal support colors?
    ncolors=$(tput colors)
    if [ -n "$ncolors" ] && [ $ncolors -ge 8 ]; then
      colorize=1
    fi
  fi

  if [ $colorize -eq 1 ]; then
      #setup print colors
      P_ERROR="\u001b[31m\u001b[1m"
      P_OK="\u001b[32m\u001b[1m"
      P_WARN="\u001b[33m\u001b[1m"
      P_INFO="\u001b[37m\u001b[1m" # white bold
      P_END="\u001b[0m" # reset
  else
      P_ERROR=""
      P_OK=""
      P_WARN=""
      P_INFO=""
      P_END=""
  fi

  METASCHEMA_SCRIPT_INIT=true
fi
