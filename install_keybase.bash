#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
  export THISSCRIPTCOMPLETEPATH
  typeset -gr THISSCRIPTCOMPLETEPATH="$(realpath "$0")"   # § This goes in the FATHER-MOTHER script
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

_linux_prepare(){
  sudo_it
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  local TARGET_URL="${1}"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  local CODENAME=$(basename "${TARGET_URL}")
  enforce_variable_with_value CODENAME "${CODENAME}"
  local DOWNLOADFOLDER="${USER_HOME}/Downloads"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"

}

_debian__64(){
  _linux_prepare https://prerelease.keybase.io/keybase_amd64.deb
  _install_rpm "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}" 0
} # end __debian__64

_debian__32(){
  sudo_it
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  local TARGET_URL=https://prerelease.keybase.io/keybase_i386.deb
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  local CODENAME=$(basename "${TARGET_URL}")
  enforce_variable_with_value CODENAME "${CODENAME}"
  local DOWNLOADFOLDER="${USER_HOME}/Downloads"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
  _install_rpm "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}" 0
} # end __debian__64

_fedora__32() {
  sudo_it
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  local TARGET_URL=https://prerelease.keybase.io/keybase_i386.rpm
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  local CODENAME=$(basename "${TARGET_URL}")
  enforce_variable_with_value CODENAME "${CODENAME}"
  local DOWNLOADFOLDER="${USER_HOME}/Downloads"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
  _install_rpm "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}" 0
} # end _fedora__32

_fedora__64() {
  sudo_it
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  local TARGET_URL=https://prerelease.keybase.io/keybase_amd64.rpm
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