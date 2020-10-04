#!/usr/bin/env bash

# THISSCRIPTNAME=`basename "$0"`
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
  local _one=''
  while read -r _one ; do
  {
    echo  -e "${_one}${RESET}"
  }
  done <<< "$(pygmentize -l bash | change_hightlight)"
}

function _trap_on_error() {
  local __trapped_script_name="${1:-0}"
  local -i __trapped_error_exit_num="${2:-0}"
  local -ni _this_lineno="${3:-LINENO}"
  local -ni _this_last_error_bash_lineno="${4:-BASH_LINENO}"
  local -n _this_last_error_funcname="${5:-FUNCNAME}"
  local -n _this_last_command="${6:-BASH_COMMAND}"
  local __trapped_function="${7:-0}"
  local -i __trapped_bash_line_before="${8:-0}"
  local -i __trapped_line="${9:-0}"
  local __trapped_bash_command="${@:10}"
  local __caller=$(caller)
  local -i __caller_line=$(echo "${__caller}" | cut -d' ' -f1)
  local __caller_script_name=$(echo "${__caller}" | cut -d' ' -f2)
  echo -e " ☠ ${LIGHTPINK} KILL EXECUTION SIGNAL SEND ${RESET}"
  # echo -e " ☠ ${YELLOW_OVER_DARKBLUE}  ${*} ${RESET}"
  #  DEBUG=1
  # Tests
  (( DEBUG )) && echo "Total args ${#} should be 12++ .. more for BASH_COMMAND that vary and provide more  " >&2
  (( DEBUG )) && echo " " >&2
  (( DEBUG )) && echo "0 ${0} should be scriptname this" >&2
  (( DEBUG )) && echo ". caller $(caller) vs "  >&2
  (( DEBUG )) && echo "1 ${__trapped_script_name} should be scriptname error  " >&2
  (( DEBUG )) && echo "2 ${__trapped_error_exit_num} error exit " >&2
  (( DEBUG )) && echo "3 ${_this_lineno} ${3} should be LINENO this line form this script" >&2
  (( DEBUG )) && echo "4 ${_this_last_error_bash_lineno} ${4} should be BASH_LINENO line form scriptname error" >&2
  (( DEBUG )) && echo "5 ${_this_last_error_funcname} ${5} should be FUNCNAME this function from this script" >&2
  (( DEBUG )) && echo "6 ${_this_last_command} ${6} should be BASH_COMMAND from scriptname error" >&2
  (( DEBUG )) && echo "7 ${__trapped_function} == ${7} \$FUNCNAME of scripterror function that triggered this trap" >&2
  # Arrays with ${#} or calle equal to stack trace
  #       BASH_SOURCE[@] : BASH_LINENO[@]   FUNCNAME[@]
  (( DEBUG )) && echo "8 ${__trapped_bash_line_before} ==  ${8} \$BASH_LINENO of scripterror function that triggered this trap before FUNCNAME -1 " >&2
  (( DEBUG )) && echo "8.0 ${BASH_LINENO[0]} ==  ${9} \$BASH_LINENO[0] of scripterror function that triggered this trap  " >&2
  (( DEBUG )) && echo "8.1 ${BASH_LINENO[1]} ==  ${8} \$BASH_LINENO[1] of scripterror function that triggered this trap  " >&2
  (( DEBUG )) && echo "9 ${__trapped_line} == ${9} \$LINENO of scripterror function that triggered this trap" >&2
  (( DEBUG )) && echo "10 ${__trapped_bash_command} == ${@:10} \$BASH_COMMAND of scripterror function that triggered this trap" >&2
  # Tests of global ENV vars and declared envinroment vars
  # env | grep SUDO  >&2
  # typeset -p | grep TRACE  >&2
  # typeset -p | grep STACK  >&2
  # typeset -p | grep FUNC  >&2
  # typeset -p | grep LINE  >&2
  # typeset -p | grep SUDO  >&2
  # typeset -p | grep ERR  >&2
  # declare -p | grep BASH  >&2
  # declare -p | grep CLI  >&2
  echo " "  >&2 # Spacer
  # Test coloring one line
  # awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?">>>":""),$0 }' L="${__caller_line}" "${__caller_script_name}" | pygmentize -l bash |  grep "102" | hexdump -C  >&2
  # awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?">>>":""),$0 }' L="${__caller_line}" "${__caller_script_name}" | pygmentize -l bash |  grep "140"  | change_hightlight | hexdump -C >&2
  # awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?">>>":""),$0 }' L="${__caller_line}" "${__caller_script_name}" | pygmentize -l bash |  grep "140"  | change_hightlight  >&2
  awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}"| colorize >&2
  # echo -e " ☠ ${LIGHTPINK}ERROR DURING EXECUTION SIGNAL SEND ${RESET}" | colorize    >&2
  # echo -e " ☠ SCRIPT EXECUTING  ${0}  ${RESET}"  >&2
  echo " "  >&2 # Spacer
  # echo -e " ☠ ${LIGHTPINK} ERROR ON ${RESET} ${__trapped_script_name}  ${RESET}"     >&2
  # echo -e "${YELLOW_OVER_DARKBLUE} ${__caller_script_name}:${__caller_line} ${RESET}"  | colorize    >&2
  # echo -e " ☠ ERROR ON   ${*} ${RESET}"  | colorize  >&2
  echo -e " ☠ ${LIGHTPINK} PWD: ${RESET} $(pwd)  ${RESET}"  >&2
  echo -e " ☠ ${LIGHTPINK} SCRIPT » » » >${RESET}\n${__caller_script_name}:${__caller_line} \t ${__trapped_function}()  ${RESET}"  >&2
  # echo $(echo  "$(eval ${__trapped_bash_command} )" 2>&1 | cut -d':' -f1)  >&2
  # echo " "  >&2 # Spacer
  echo -e " ☠ ${LIGHTPINK} OFFENDING COMMAND: ${RESET}${__trapped_bash_command}  ${RESET}"  >&2
  echo -e " ☠ ${LIGHTPINK} OFFENDING e x i t: ${RESET}${__trapped_error_exit_num}  ${RESET} "  >&2
  # local __bash_error<<< "$(eval ${__trapped_bash_command} >&2 )"
  echo -e " ☠ ${LIGHTPINK} Offending message:  ${__bash_error} ${RESET}"  >&2
  eval "${__trapped_bash_command}"  >&2
  local __bash_source=""
  local -i _error_count=${#BASH_LINENO[@]}
  (( _error_count-- ))
  local -i _counter=0
  local -i _counter_offset=0
  echo -e " ☠ ${LIGHTPINK} ERROR STACK TRACE: ${len}  ${RESET}"  >&2
  echo -e "${BRIGHT_BLUE87} ${__caller_script_name}:${__caller_line} \t\t ${__trapped_function}() ${RESET}"  >&2
  for (( _counter=1; _counter<${_error_count}; _counter++ )); do
      (( _counter_offset=_counter + 1 ))
      echo -e "${BRIGHT_BLUE87} ${BASH_SOURCE[$_counter_offset]}:${BASH_LINENO[$_counter]} \t\t ${FUNCNAME[$_counter_offset]}() ${RESET}"  >&2
  done

  # env | grep SUDO  >&2
  # if not defined and not empty try code normal
  ( typeset -p "SUDO_USER"  &>/dev/null ) ||  code -g "${__caller_script_name}:${__caller_line}"&
  # if defined and not empty
  # ( typeset -p "SUDO_USER"  &>/dev/null ) && echo "sudo user " >&2
  ( typeset -p "SUDO_USER"  &>/dev/null ) &&  su - $SUDO_USER -c 'code -g '"${__caller_script_name}':'${__caller_line}"''&
  # echo -e " ☠ Variables  \n$(declare -p)  ${RESET}"  >&2  # Show  all variables declared
  # exit ${__trapped_error_exit_num};  # If I call exit it kills the entire executing stripts
  return ${__trapped_error_exit_num};  # Returning instead allows other scripts to continue
} # end  _trap_on_error

set -E -o functrace
#                      1   2       3      4          5       6            7          8            9         10
trap '_trap_on_error  $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND' ERR
