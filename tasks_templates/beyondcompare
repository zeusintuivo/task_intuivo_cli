#!/usr/bin/env bash
#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
# Compatible start with low version bash, like mac before zsh change and after
export USER_HOME
export THISSCRIPTCOMPLETEPATH
typeset -r THISSCRIPTCOMPLETEPATH="$(realpath $(which $(basename "$0")))"   # § This goes in the FATHER-MOTHER script

export BASH_VERSION_NUMBER
typeset BASH_VERSION_NUMBER=$(echo $BASH_VERSION | cut -f1 -d.)

export  THISSCRIPTNAME
typeset -r THISSCRIPTNAME="$(realpath $(which $(basename "$0")))"

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
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
  enforce_variable_with_value SUDO_USER "${SUDO_USER}"
  enforce_variable_with_value SUDO_UID "${SUDO_UID}"
  enforce_variable_with_value SUDO_COMMAND "${SUDO_COMMAND}"
  # Override bigger error trap  with local
  function _trap_on_error(){
    echo -e "\033[01;7m*** TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}\(\) \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}\(\) \\n ERR INT ...\033[0m"

  }
  trap _trap_on_error ERR INT
} # end sudo_it


_linux_prepare(){
  sudo_it
  [ $? -gt 0 ] && (failed to sudo_it raise_to_sudo_and_user_home  || exit 1)
  export USER_HOME="/home/${SUDO_USER}"
  enforce_variable_with_value USER_HOME "${USER_HOME}"
}  # end _linux_prepare

_version() {
  # fedora_32 https://www.scootersoftware.com/bcompare-4.3.3.24545.i386.rpm
  # https://www.scootersoftware.com/bcompare-4.3.3.24545.x86_64.rpm
  # zz=dl4&platform=mac, zz=dl4&platform=linux, zz=dl4&platform=win

  local PLATFORM="${1}"
  local PATTERN="${2}"
  # THOUGHT: local CODEFILE=$(curl -d "zz=dl4&platform=linux" -H "Content-Type: application/x-www-form-urlencoded" -X POST  -sSLo -  https://www.scootersoftware.com/download.php  2>&1;) # suppress only wget download messages, but keep wget output for variable
  local CODEFILE=$(curl -d "zz=dl4&platform=${PLATFORM}" -H "Content-Type: application/x-www-form-urlencoded" -X POST  -sSLo -  https://www.scootersoftware.com/download.php  2>&1;) # suppress only wget download messages, but keep wget output for variable
  # THOUGHT: local CODELASTESTBUILD=$(echo $CODEFILE | sed s/\</\\n\</g | grep "bcompare*.*.*.*.x86_64.rpm" | sed s/\"/\\n/g | grep "/" | cuet "/")
  local CODELASTESTBUILD=$(echo $CODEFILE | sed s/\</\\n\</g | grep "${PATTERN}" | sed s/\"/\\n/g | grep "/" | cüt "/")
  # fedora 32 local CODELASTESTBUILD=$(echo $CODEFILE | sed s/\</\\n\</g | grep "bcompare*.*.*.*.i386.rpm" | sed s/\"/\\n/g | grep "/" | cuet "/")
  wait
  [[ -z "${CODELASTESTBUILD}" ]] && failed "Beyond Compare Version not found! :${CODELASTESTBUILD}:"


  # enforce_variable_with_value USER_HOME "${USER_HOME}"
  # enforce_variable_with_value CODELASTESTBUILD "${CODELASTESTBUILD}"

  local CODENAME="${CODELASTESTBUILD}"
  echo "${CODELASTESTBUILD}"
  unset PATTERN
  unset PLATFORM
  unset CODEFILE
  unset CODELASTESTBUILD
} # end _version


_darwin__64() {
  sudo_it
  export USER_HOME="/Users/${SUDO_USER}"
  enforce_variable_with_value USER_HOME "${USER_HOME}"

  local CODENAME=$(_version "mac" "BCompareOSX*.*.*.*.zip")
  enforce_variable_with_value CODENAME "${CODENAME}"
  # THOUGHT        local CODENAME="BCompareOSX-4.3.3.24545.zip"
  local URL="https://www.scootersoftware.com/${CODENAME}"

  # local TARGET_URL
  # TARGET_URL="${CODENAME}|Beyond Compare.app|${URL}"
  # enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  # _install_dmgs_list "${TARGET_URL}"
  local DOWNLOADFOLDER="$USER_HOME/Downloads"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  cd "${DOWNLOADFOLDER}"
  echo _download_mac
  _download_mac "${URL}" "${DOWNLOADFOLDER}"
  local APPDIR="Beyond Compare.app"    # same as  $(basename "${APPDIR}")
  echo _remove_dmgs_app_if_exists
  _remove_dmgs_app_if_exists "${APPDIR}"
  echo _process_dmgs_dmg_or_zip
  _process_dmgs_dmg_or_zip "zip" "${DOWNLOADFOLDER}" "${CODENAME}" "${APPDIR}" "${CODENAME}"
  echo directory_exists_with_spaces
  directory_exists_with_spaces "/Applications/${APPDIR}"
  ls -d "/Applications/${APPDIR}"

  _trust_dmgs_application "${APPDIR}"

    # sudo hdiutil attach ${CODENAME}
    # sudo cp -R /Volumes/Beyond\ Compare/Beyond\ Compare.app /Applications/
    # sudo hdiutil detach /Volumes/Beyond \ Compare
} # end _darwin__64

_ubuntu__64() {
	_linux_prepare
  # THOUGHT          local CODENAME="bcompare-4.3.3.24545_amd64.deb"
  local CODENAME=$(_version "linux" "bcompare-*.*.*.*amd64.deb")
  enforce_variable_with_value CODENAME "${CODENAME}"
  local TARGET_URL="https://www.scootersoftware.com/${CODENAME}"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"

  local DOWNLOADFOLDER="$(_find_downloads_folder)"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  cd "${DOWNLOADFOLDER}"
  _download_mac "${TARGET_URL}" "${DOWNLOADFOLDER}"
  sudo dpkg -i ${CODENAME}
} # end _ubuntu__64

_ubuntu__32() {
	_linux_prepare
  # THOUGHT local CODENAME="bcompare-4.3.3.24545_i386.deb"
  local CODENAME=$(_version "linux" "bcompare-*.*.*.*i386.deb")
  enforce_variable_with_value CODENAME "${CODENAME}"
  local TARGET_URL="https://www.scootersoftware.com/${CODENAME}"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"

  local DOWNLOADFOLDER="$(_find_downloads_folder)"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  cd "${DOWNLOADFOLDER}"
  _download_mac "${TARGET_URL}" "${DOWNLOADFOLDER}"
  sudo dpkg -i ${CODENAME}
} # end _ubuntu__32

_fedora__32() {
	_linux_prepare
  local CODENAME=$(_version "linux" "bcompare*.*.*.*.i386.rpm")
  enforce_variable_with_value CODENAME "${CODENAME}"
  # THOUGHT                          bcompare-4.3.3.24545.i386.rpm
  local TARGET_URL="https://www.scootersoftware.com/${CODENAME}"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  local DOWNLOADFOLDER="$(_find_downloads_folder)"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  cd "${DOWNLOADFOLDER}"
  _download "${TARGET_URL}" "${USER_HOME}/Downloads" "${CODENAME}"
  file_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
  ensure rpm or "Canceling Install. Could not find rpm command to execute install"
  # provide error handling , once learned goes here. LEarn under if, once learned here.
  # Start loop while ERROR flag in case needs to try again, based on error
  _try "rpm --import https://www.scootersoftware.com/RPM-GPG-KEY-scootersoftware"
  local msg=$(_try "rpm -ivh \"${DOWNLOADFOLDER}/${CODENAME}\"" )
  local ret=$?
  if [ $ret -gt 0 ] ; then
  {
    failed "${ret}:${msg}"
    # add error handling knowledge while learning.
  }
  else
  {
    passed Install with RPM success!
  }
  fi
  ensure bcompare or "Failed to install Beyond Compare"
  rm -f "${DOWNLOADFOLDER}/${CODENAME}"
  file_does_not_exist_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
} # end _fedora__32

_centos__64() {
  _fedora__64
} # end _centos__64

_fedora__64() {
	_linux_prepare
  local CODENAME=$(_version "linux" "bcompare*.*.*.*.x86_64.rpm")
  enforce_variable_with_value CODENAME "${CODENAME}"
  # THOUGHT  https://www.scootersoftware.com/bcompare-4.3.3.24545.x86_64.rpm
  local TARGET_URL="https://www.scootersoftware.com/${CODENAME}"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  local DOWNLOADFOLDER="$(_find_downloads_folder)"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  cd "${DOWNLOADFOLDER}"
  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
  _install_rpm "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}" 0

  ensure bcompare or "Failed to install Beyond Compare"
  rm -f "${DOWNLOADFOLDER}/${CODENAME}"
  file_does_not_exist_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
} # end _fedora__64

_mingw__64() {
	_linux_prepare
    local CODENAME=$(_version "win" "BCompare*.*.*.*.exe")
    # THOUGHT        local CODENAME="BCompare-4.3.3.24545.exe"
    local URL="https://www.scootersoftware.com/${CODENAME}"
    cd $HOMEDIR
	  cd Downloads
    curl -O $URL
    ${CODENAME}
} # end _mingw__64

_mingw__32() {
	_linux_prepare
    local CODENAME=$(_version "win" "BCompare*.*.*.*.exe")
    # THOUGHT        local CODENAME="BCompare-4.3.3.24545.exe"
    local URL="https://www.scootersoftware.com/${CODENAME}"
    cd $HOMEDIR
    cd Downloads
	  curl -O $URL
	  ${CODENAME}
} # end


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo ":)"


