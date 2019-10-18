
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
#    P_ERROR="$(tput setaf 1)$(tput bold)"
#    P_OK="$(tput setaf 2)$(tput bold)"
#    P_WARN="$(tput setaf 3)$(tput bold)"
#    P_INFO="$(tput bold)"
#    P_END="$(tput sgr0)"
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

function_exists() {
    declare -f -F $1 > /dev/null
    return $?
}
