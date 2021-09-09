#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
if ! ( command -v realpath >/dev/null 2>&1; ) ; then # MAC  # updated realpath macos 20210902
{
  # updated realpath macos 20210902
  export realpath    # updated realpath macos 20210902
  function realpath() ( # Macos after BigSur is missing realpath  # updated realpath macos 20210902
    local OURPWD=$PWD
    cd "$(dirname "$1")"
    local LINK=$(readlink "$(basename "$1")")
    while [ "$LINK" ]; do
      cd "$(dirname "$LINK")"
      LINK=$(readlink "$(basename "$1")")
    done
    local REALPATH="$PWD/$(basename "$1")"
    cd "$OURPWD"
    echo "$REALPATH"
  )
}
fi

# 20200415 Compatible with Fedora, Mac, Ubuntu "sudo_up" "load_struct"
set -E -o functrace
export THISSCRIPTCOMPLETEPATH
typeset -r THISSCRIPTCOMPLETEPATH="$(realpath  "$0")" # updated realpath macos 20210902
export BASH_VERSION_NUMBER
typeset BASH_VERSION_NUMBER=$(echo $BASH_VERSION | cut -f1 -d.)

export  THISSCRIPTNAME
typeset -r THISSCRIPTNAME="$(basename "$0")"

export _err
typeset -i _err=0
  function _trap_on_error(){
    echo -e "\\n \033[01;7m*** ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m"
    exit 1
  }
  trap _trap_on_error ERR
  function _trap_on_int(){
    echo -e "\\n \033[01;7m*** INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n  INT ...\033[0m"
    exit 0
  }

  trap _trap_on_int INT

load_struct_testing(){
  function _trap_on_error(){
    local -ir __trapped_error_exit_num="${2:-0}"
    echo -e "\\n \033[01;7m*** ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m  \n \n "
    echo ". ${1}"
    echo ". exit  ${__trapped_error_exit_num}  "
    echo ". caller $(caller) "
    echo ". ${BASH_COMMAND}"
    local -r __caller=$(caller)
    local -ir __caller_line=$(echo "${__caller}" | cut -d' ' -f1)
    local -r __caller_script_name=$(echo "${__caller}" | cut -d' ' -f2)
    awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}"

    # $(eval ${BASH_COMMAND}  2>&1; )
    # echo -e " ☠ ${LIGHTPINK} Offending message:  ${__bash_error} ${RESET}"  >&2
    exit 1
  }
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
    local provider="$HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    local _err=0 structsource
    if [   -e "${provider}"  ] ; then
      echo "Loading locally"
      structsource="""$(<"${provider}")"""
      _err=$?
      [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. running 'source locally' returned error did not download or is empty err:$_err  \n \n  " && exit 1
    else
      if ( command -v curl >/dev/null 2>&1; )  ; then
        echo "Loading struct_testing from the net using curl "
        structsource="""$(curl https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing  -so -   2>/dev/null )"""  #  2>/dev/null suppress only curl download messages, but keep curl output for variable
        _err=$?
        [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. running 'curl' returned error did not download or is empty err:$_err  \n \n  " && exit 1
      elif ( command -v wget >/dev/null 2>&1; ) ; then
        echo "Loading struct_testing from the net using wget "
        structsource="""$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing -O -   2>/dev/null )"""  #  2>/dev/null suppress only wget download messages, but keep wget output for variable
        _err=$?
        [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. running 'wget' returned error did not download or is empty err:$_err  \n \n  " && exit 1
      else
        echo -e "\n \n  ERROR! Loading struct_testing could not find wget or curl to download  \n \n "
        exit 69
      fi
    fi
    [[ -z "${structsource}" ]] && echo -e "\n \n  ERROR! Loading struct_testing. structsource did not download or is empty " && exit 1
    local _temp_dir="$(mktemp -d 2>/dev/null || mktemp -d -t 'struct_testing_source')"
    echo "${structsource}">"${_temp_dir}/struct_testing"
    echo "Temp location ${_temp_dir}/struct_testing"
    source "${_temp_dir}/struct_testing"
    _err=$?
    [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. Occured while running 'source' err:$_err  \n \n  " && exit 1
    if  ! typeset -f passed >/dev/null 2>&1; then
      echo -e "\n \n  ERROR! Loading struct_testing. Passed was not loaded !!!  \n \n "
      exit 69;
    fi
    return $_err
} # end load_struct_testing
load_struct_testing

 _err=$?
[ $_err -ne 0 ]  && echo -e "\n \n  ERROR FATAL! load_struct_testing_wget !!! returned:<$_err> \n \n  " && exit 69;

export sudo_it
function sudo_it() {
  raise_to_sudo_and_user_home
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
  enforce_variable_with_value SUDO_USER "${SUDO_USER}"
  enforce_variable_with_value SUDO_UID "${SUDO_UID}"
  enforce_variable_with_value SUDO_COMMAND "${SUDO_COMMAND}"
  # Override bigger error trap  with local
  function _trap_on_error(){
    echo -e "\033[01;7m*** TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR INT ...\033[0m"
  }
  trap _trap_on_error ERR INT
} # end sudo_it

# _linux_prepare(){
  sudo_it
  [ $? -gt 0 ] && (failed to sudo_it raise_to_sudo_and_user_home  || exit 1)
  export USER_HOME
  # shellcheck disable=SC2046
  # shellcheck disable=SC2031
  typeset -r USER_HOME="$(echo -n $(bash -c "cd ~${SUDO_USER} && pwd"))"  # Get the caller's of sudo home dir LINUX and MAC
  # USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)   # Get the caller's of sudo home dir LINUX
  enforce_variable_with_value USER_HOME "${USER_HOME}"
# }  # end _linux_prepare


# _linux_prepare

enforce_variable_with_value USER_HOME $USER_HOME
enforce_variable_with_value SUDO_USER $SUDO_USER
passed Caller user identified:$SUDO_USER
passed Home identified:$USER_HOME
directory_exists_with_spaces "$USER_HOME"



 #--------\/\/\/\/-- Work here below \/, test, and transfer to tasks_templates/filezilla having a working version -\/\/\/\/-------




#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#

#
_download_page(){
  # Samople use :
  #
  #   _download_page   https://filezilla-project.org/download.php?platform=linux64
  #
  local target_url="${1}"
  local CODEFILE=""
  local _WGETCURLMAND=""
  local _WGETCURLusing=""
  local -i _err=0
  enforce_variable_with_value target_url "${target_url}"
  if ( command -v curl >/dev/null 2>&1; )  ; then
    _WGETCURLMAND="curl \"${target_url}\" -so -"
    _WGETCURLusing='curl'
  elif ( command -v wget >/dev/null 2>&1; ) ; then
    _WGETCURLMAND="wget --quiet --no-check-certificate  \"${target_url}\"-O -"
    _WGETCURLusing='wget'
  else
    echo -e "\n \n  ${RED}ERROR! ${YELLOW}Loading ${target_url} could not find wget or curl to download  \n \n "
    return 1
  fi
  echo -e "${YELLOW} +${ORANGE}-- ${CYAN}Loading ${target_url} from the net using ${RED}${_WGETCURLusing}"
  echo -e "${YELLOW} +${ORANGE}-- ${CYAN}${_WGETCURLMAND}  "
  CODEFILE="""$(eval ${_WGETCURLMAND}   2>/dev/null )"""  #  2>/dev/null suppress only curl download messages, but keep curl output for variable
  _err=$?
  [ $_err -gt 0 ] &&  echo -e "\n \n  ${RED}ERROR! ${YELLOW}Loading ${target_url}. running ${PURPLE}'${RED}${_WGETCURLusing}${PURPLE}'${YELLOW} returned error did not download or is empty err:$_err  \n \n  " && return $_err
  echo -e "${CODEFILE}"
  return $_err
} # end _download_page

_dowload_link(){
  # Usage:
  #
  #
  #  local _filezilla_download_url=$(_dowload_link win64)
  #  enforce_variable_with_value _filezilla_download_url  "${_filezilla_download_url}"

  local PLATFORM="${1}"
  #                    param order varname    varvalue      validoptions
  enforce_parameter_with_options 2 PLATFORM "${PLATFORM}" "osx win64 win32 linux64 linux32"
  local _downloadurl="https://filezilla-project.org/download.php?platform=${PLATFORM}"
  echo -e "${_downloadurl}"
  return 0
}
_version() {
  # Usage:
  #
  #    local _filezilla_version=$(_version)
  #    enforce_variable_with_value _filezilla_version  "${_filezilla_version}"
  #
  local url="https://filezilla-project.org/download.php"
  enforce_variable_with_value url  "${url}"

  local CODEFILE="$(_download_page "${url}"  2>&1;)" # suppress only wget download messages, but keep wget output for variable
  enforce_variable_with_value CODEFILE  "${CODEFILE}"
  echo "${CODEFILE}"

  local _filezilla_version=$(echo "${CODEFILE}" | sed s/\</\\n\</g | grep "The latest stable version of FileZilla Client is" | sed s/\"/\\n/g | sed 's/ /\n/g' | tail -1)
  # enforce_variable_with_value _filezilla_version  "${_filezilla_version}"

  echo "${_filezilla_version}"
  unset url
  unset CODEFILE
  unset _filezilla_version
  return 0
} # end _version

_version_test(){
  local CODENAME="$(_version )"
  echo "${CODENAME}"
}


_debian_flavor_install() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _debian_flavor_install

_redhat_flavor_install() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _redhat_flavor_install

_redhat_flavor_install_64() {
  enforce_web_is_reachable  "filezilla-project.org"
  #
  local _filezilla_version=$(_version)
  echo  "${_filezilla_version}"
  enforce_variable_with_value _filezilla_version  "${_filezilla_version}"

  local _filezilla_download_url=$(_dowload_link win64)
  enforce_variable_with_value _filezilla_download_url  "${_filezilla_download_url}"

  local CODENAME=$(basename "${_filezilla_download_url}")
  enforce_variable_with_value CODENAME "${CODENAME}"
  local DOWNLOADFOLDER="$(_find_downloads_folder)"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  echo "${DOWNLOADFOLDER}"
  # _do_not_downloadtwice "${_filezilla_download_url}" "${DOWNLOADFOLDER}"  "${CODENAME}"
  # _install_rpm "${_filezilla_download_url}" "${DOWNLOADFOLDER}"  "${CODENAME}" 0
  local _err=$?
  # _remove_downloaded_codename_or_err  $_err "${DOWNLOADFOLDER}/${CODENAME}"
  # _err=$?
  # return  $_err
} # end _redhat_flavor_install_64

_arch_flavor_install() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _readhat_flavor_install

_arch_flavor_install() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _readhat_flavor_install

_arch__32() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _arch__32

_arch__64() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _arch__64

_centos__32() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _centos__32

_centos__64() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _centos__64

_debian__32() {
  _debian_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _debian__32

_debian__64() {
  _debian_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _debian__64

_fedora__32() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _fedora__32

_fedora__64() {
  _redhat_flavor_install_64
} # end _fedora__64

_gentoo__32() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _gentoo__32

_gentoo__64() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _gentoo__64

_madriva__32() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _madriva__32

_madriva__64() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _madriva__64

_suse__32() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _suse__32

_suse__64() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _suse__64

_ubuntu__32() {
  _debian_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _ubuntu__32

_ubuntu__64() {
  _debian_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _ubuntu__64

_darwin__64() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _darwin__64



 #--------/\/\/\/\-- Work here above /\, test, and transfer to tasks_templates/filezilla having a working version -/\/\/\/\-------


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo "🥦"
exit 0
