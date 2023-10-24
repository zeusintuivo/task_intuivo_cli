#!/usr/bin/env bash
#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
# Compatible start with low version bash
export USER_HOME
export THISSCRIPTCOMPLETEPATH
typeset -r THISSCRIPTCOMPLETEPATH="$(realpath $(which $(basename "$0")))"   # updated realpath macos 20210902 # § This goes in the FATHER-MOTHER script

export BASH_VERSION_NUMBER
typeset BASH_VERSION_NUMBER=$(echo $BASH_VERSION | cut -f1 -d.)

export  THISSCRIPTNAME
typeset -r THISSCRIPTNAME="$(realpath $(which $(basename "$0")))"  # updated realpath macos 20210902

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

_darwin__64() {
  sudo_it
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  local TARGET_URL
  TARGET_URL="VSCode-darwin.zip|Visual Studio Code - Insiders.app|https://az764295.vo.msecnd.net/insider/5a52bc29d5e9bc419077552d336ea26d904299fa/VSCode-darwin.zip"
  TARGET_URL="VSCode-darwin.zip|Visual Studio Code - Insiders.app|https://code.visualstudio.com/sha/download?build=insider\&os=darwin"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  _install_dmgs_list "${TARGET_URL}"
} # end _darwin__64

_fedora__64() {
	sudo_it
	[ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  local TARGET_URL=https://az764295.vo.msecnd.net/insider/04770364fdc1bebeca9d1a257df2cacce06b35d6/code-insiders-1.55.0-1614959504.el7.x86_64.rpm
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