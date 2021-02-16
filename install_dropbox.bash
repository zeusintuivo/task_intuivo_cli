#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
  # export THISSCRIPTCOMPLETEPATH 
  # typeset -r THISSCRIPTCOMPLETEPATH="$(basename "$0")"   # § This goes in the FATHER-MOTHER script 
  # export _err 
  # typeset -i _err=0 

load_struct_testing_wget(){
    local provider="$HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    [   -e "${provider}"  ] && source "${provider}" && echo "Loaded locally"
    [ ! -e "${provider}"  ] && eval """$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing -O -  2>/dev/null )"""   # suppress only wget download messages, but keep wget output for variable
    ( ( ! command -v passed >/dev/null 2>&1; ) && echo -e "\n \n  ERROR! Loading struct_testing \n \n " && exit 69; )
} # end load_struct_testing_wget
load_struct_testing_wget

function _parameter_check(){

} # end _parameter_check

_version() {
  local URL="${1}"      # https://www.website.com/product/
  local PLATFORM="${2}" # mac windows linux
  local PATTERN="${3}"
  DEBUG=1
  enforce_parameter_with_value 1 URL "${URL}" "https://www.website.com/product/"
  enforce_parameter_with_options 2 PLATFORM "${PLATFORM}" "mac windows linux"
  enforce_parameter_with_value 3 PATTERN "${PATTERN}" "BCompareOSX*.*.*.*.zip"
  local CODEFILE="""$(wget --quiet --no-check-certificate  "${URL}" -O -  2>/dev/null )""" # suppress only wget download messages, but keep wget output for variable
  enforce_variable_with_value CODEFILE "${CODEFILE}"
  
} # end _version