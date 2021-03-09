#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
  export THISSCRIPTCOMPLETEPATH
  typeset -gr THISSCRIPTCOMPLETEPATH="$(basename "$0")"   # § This goes in the FATHER-MOTHER script
  export _err
  typeset -i _err=0

load_struct_testing_wget(){
    local provider="$HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    [   -e "${provider}"  ] && source "${provider}" && echo "Loaded locally"
    [ ! -e "${provider}"  ] && eval """$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing -O -  2>/dev/null )"""   # suppress only wget download messages, but keep wget output for variable
    ( ( ! command -v passed >/dev/null 2>&1; ) && echo -e "\n \n  ERROR! Loading struct_testing \n \n " && exit 69; )
} # end load_struct_testing_wget
load_struct_testing_wget


export sudo_it
function sudo_it() {
  raise_to_sudo_and_user_home
} # end sudo_it

_get_dowload_target(){
  # Sample call:
  #
  #  _get_dowload_target "https://linux.dropbox.com/packages/fedora/" rpm 64
  #  _get_dowload_target "https://linux.dropbox.com/packages/fedora/" rpm 32
  #  _get_dowload_target "https://linux.dropbox.com/packages/debian/" deb 32
  #
  # DEBUG=1
  local URL="${1}"   #           param order    varname    varvalue     sample_value
  enforce_parameter_with_value           1        URL      "${URL}"     "https://linux.dropbox.com/packages/fedora/"
  #
  #
  local PLATFORM="${2}"  #       param order    varname     varvalue        valid_options
  (( DEBUG )) && Message "${2}"
  enforce_parameter_with_options         2      PLATFORM   "${PLATFORM}"    "rpm   deb"
  #
  #
  local BITS="${3}"      #       param order    varname     varvalue        valid_options
  (( DEBUG )) && Message "${3}"
  enforce_parameter_with_options         3       BITS       "${BITS}"        "64   32"
  #
  #
  (( DEBUG )) && echo "CODEFILE=\"\"\"\$(wget --quiet --no-check-certificate  \"${URL}\" -O -  2>/dev/null)\"\"\""
  local CODEFILE="""$(wget --quiet --no-check-certificate  "${URL}" -O -  2>/dev/null )""" # suppress only wget download messages, but keep wget output for variable
  enforce_variable_with_value CODEFILE "${CODEFILE}"
  #
  #
  local CODELASTESTBUILD=$(_extract_version "${CODEFILE}")
  enforce_variable_with_value CODEFILE "${CODEFILE}"
  local TARGETNAME=$(echo -n "${CODELASTESTBUILD}" | grep "${PLATFORM}" | grep "${PLATFORM}" |  tail -1)
  enforce_variable_with_value TARGETNAME "${TARGETNAME}"
  echo -n "${URL}/${TARGETNAME}"
  return 0
} # end _get_dowload_target

_extract_version(){
  echo "${*}" | sed s/\>/\>\\n/g | sed "s/&apos;/\'/g" | sed 's/&nbsp;/ /g'  | grep -v "<a" | sort | sed s/\</\\n\</g | grep -v "</a"
} # end _extract_version

_fedora__64() {
  sudo_it
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  # local TARGET_URL=https://prerelease.keybase.io/keybase_amd64.rpm
  local TARGET_URL=$(_get_dowload_target "https://linux.dropbox.com/packages/fedora/" "rpm" "64")
  # DEBUG=1
  (( DEBUG )) && echo -n """${TARGET_URL}""" > .tmp.html
  (( DEBUG )) && echo -n "${TARGET_URL}"
  (( DEBUG )) && echo "DEBUG EXIT 0"
  (( DEBUG )) && exit 0
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  local CODENAME=$(basename "${TARGET_URL}")
  enforce_variable_with_value CODENAME "${CODENAME}"
  local DOWNLOADFOLDER="${USER_HOME}/Downloads"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
  _install_rpm "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}" 0
} # end _fedora__64

_main() {
  determine_os_and_fire_action
} # end _main

_main

echo ":)"
