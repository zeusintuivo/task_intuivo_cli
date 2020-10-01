#!/usr/bin/env bash

THISSCRIPTNAME=`basename "$0"`
DEBUG_VERB_READING_LOGIC=$DEBUG || 0
LIGHTPINK="\033[1;204m"
TO_LIGHTPINK="\o033[1;204m\o033[48;5;0m"    # Notice the only the \o changes NOT \[]
YELLOW_OVER_DARKBLUE="\033[38;5;220m\033[48;5;20m"
TO_YELLOW_OVER_DARKBLUE="\o033[38;5;220m\o033[48;5;20m"   # Notice the only the \o changes NOT \[]
# Change RED_NOT_VISIBLE to LIGHTPINK
    RED_NOT_VISIBLE="\033[39m \033[38;5;124m"
FROM_RED_NOT_VISIBLE="\o33\[39;00m\o033\[38;5;124m" # NOtice the \o \[ changes
#          \o033\[39m \o033\[38;5;124m
# Change BLUE_NOT_VISIBLE to YELLOW_OVER_DARKBLUE
BLUE_NOT_VISIBLE="\033[39;00m\033[38;5;18m"
FROM_BLUE_NOT_VISIBLE="\o33\[39;00m\o033\[38;5;18m"  # NOtice the \o \[ changes
FROM_BLUE_NOT_VISIBLE2="\o033\[38;5;18m"  # NOtice the \o \[ changes
# Change BLURRY_PINK to YELLOW_OVER_DARKBLUE
FROM_BLURRY_PINK="\o33\[39m\o33\[38;5;132;01m"
DARK_PEACH="\033[38;5;202m"
TO_DARK_PEACH="\o033[38;5;202m\o033[48;5;0m"
# Change MAGENTA_NOT_VISIBLE to TO_DARK_BLUE_OVER_PEACH
FROM_MAGENTA_NOT_VISIBLE="\o033\[39m\o033\[38;5;124m"
FROM_MAGENTA_NOT_VISIBLE2="\o033\[38;5;124m"
TO_DARK_BLUE_OVER_PEACH="\o033[38;5;20m\o033[48;5;208m"
DARK_BLUE_OVER_PEACH="\033[38;5;20m\033[48;5;208m"

RESET="\033[0m"
TO_RESET="\o033[0m"
#         function kill() {
#             echo -e " ☠ ${LIGHTPINK} KILL EXECUTION SIGNAL SEND ${RESET}"
#             echo -e " ☠ ${YELLOW_OVER_DARKBLUE}  ${*} ${RESET}"
#             exit 69;
#         }
# trap kill INT
function change_hightlight(){
  # sed "s/${FROM_RED_NOT_VISIBLE}/${TO_LIGHTPINK}${TO_RESET}/g" | \
  sed "s/${FROM_BLUE_NOT_VISIBLE}/${TO_YELLOW_OVER_DARKBLUE}/g" |  \
  sed "s/${FROM_BLUE_NOT_VISIBLE2}/${TO_DARK_BLUE_OVER_PEACH}/g" |  \
  sed "s/${FROM_BLURRY_PINK}/${TO_DARK_PEACH}/g" |  \
  sed "s/${FROM_RED_NOT_VISIBLE}/${TO_LIGHTPINK}/g" | \
  sed "s/${FROM_MAGENTA_NOT_VISIBLE}/${TO_DARK_BLUE_OVER_PEACH}${TO_RESET}/g" |  \
  sed "s/${FROM_MAGENTA_NOT_VISIBLE2}/${TO_DARK_BLUE_OVER_PEACH}${TO_RESET}/g"
  # sed "s/${FROM_BLUE_NOT_VISIBLE}/${TO_YELLOW_OVER_DARKBLUE}${TO_RESET}/g"
  # sed "s/\o033\[39m \o033\[38;5;124m/\o033[38;1;204m/g"  # Sample working version
}
# echo Tests Color change
# echo  -e  ${RED_NOT_VISIBLE} printf  ${BLUE_NOT_VISIBLE} 'something_functi' | change_hightlight |hexdump -C
# echo  -e  ${RED_NOT_VISIBLE} printf  ${BLUE_NOT_VISIBLE} 'something_functi' | change_hightlight
# exit 0

function colorize(){
  pygmentize -l bash | change_hightlight | xargs -0I {} echo -e {}"${RESET}"
}

function on_error() {
  local __caller=$(caller)
  local __line=$(echo "${__caller}" | cut -d' ' -f1)
  local __script=$(echo "${__caller}" | cut -d' ' -f2)
  echo -e " ☠ ${LIGHTPINK} KILL EXECUTION SIGNAL SEND ${RESET}"
  echo -e " ☠ ${YELLOW_OVER_DARKBLUE}  ${*} ${RESET}"
  echo "${1}" >&2
  echo "${2}" >&2
  echo "${3}" >&2
  echo "Error occurred:"  >&2
  # Test coloring one line
  # awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?">>>":""),$0 }' L="${__line}" "${__script}" | pygmentize -l bash |  grep "102" | hexdump -C  >&2
  # awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?">>>":""),$0 }' L="${__line}" "${__script}" | pygmentize -l bash |  grep "140"  | change_hightlight | hexdump -C >&2
  # awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?">>>":""),$0 }' L="${__line}" "${__script}" | pygmentize -l bash |  grep "140"  | change_hightlight  >&2
  awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?">>>":""),$0 }' L="${__line}" "${__script}"  | colorize  >&2
  # echo -e " ☠ ${LIGHTPINK}ERROR DURING EXECUTION SIGNAL SEND ${RESET}" | colorize    >&2
  # echo -e " ☠ SCRIPT EXECUTING  ${0}  ${RESET}"  >&2
  # echo -e " ☠ ERROR ON _code ${_code}  ${@} ${RESET}"  | colorize    >&2
  # echo -e "${YELLOW_OVER_DARKBLUE} ${__script}:${__line} ${RESET}"  | colorize    >&2
  # echo -e " ☠ ERROR ON   ${*} ${RESET}"  | colorize  >&2

  echo -e " ☠ SCRIPT ERROR  >>>\n${__script}:${__line} ${3}()  ${RESET}"  >&2
  echo -e " ☠ CALLED FROM ERROR  \n${__script}:${2} ${3}()  ${RESET}"  >&2
  echo -e " ☠ PWD  \n$(pwd)  ${RESET}"  >&2
  echo -e " ☠ BASH_COMMAND  \n$(eval ${BASH_COMMAND})  ${RESET}"  >&2
  # echo -e " ☠ Variables  \n$(declare -p)  ${RESET}"  >&2  # Show  all variables declared
  code-insiders -g "${__script}:${__line}"&
  exit 69;
}
set -E -o functrace
trap 'on_error $0 ${LINENO} $FUNCNAME $BASHCOMMAND $BASH_LINENO LINENO BASH_LINENO ${BASH_COMMAND} "${?}" ' ERR
