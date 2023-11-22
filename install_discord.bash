#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
# 20200415 Compatible with Fedora, Mac, Ubuntu "sudo_up" "load_struct" "#

set -E -o functrace
export THISSCRIPTCOMPLETEPATH
typeset -r THISSCRIPTCOMPLETEPATH="$(realpath  "$0")"   # updated realpath macos 20210902
export BASH_VERSION_NUMBER
typeset BASH_VERSION_NUMBER=$(echo $BASH_VERSION | cut -f1 -d.)

export  THISSCRIPTNAME
typeset -r THISSCRIPTNAME="$(basename "$0")"

export _err
typeset -i _err=0

  function _trap_on_error(){
    #echo -e "\\n \033[01;7m*** ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m"
    local cero="$0"
    local file1="$(paeth ${BASH_SOURCE})"
    local file2="$(paeth ${cero})"
    echo -e "ERROR TRAP $THISSCRIPTNAME
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
ERR ..."
    exit 1
  }
  trap _trap_on_error ERR
  function _trap_on_int(){
    # echo -e "\\n \033[01;7m*** INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n  INT ...\033[0m"
    local cero="$0"
    local file1="$(paeth ${BASH_SOURCE})"
    local file2="$(paeth ${cero})"
    echo -e "INTERRUPT TRAP $THISSCRIPTNAME
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
INT ..."
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
  function load_library(){
    local _library="${1:struct_testing}"
    [[ -z "${1}" ]] && echo "Must call with name of library example: struct_testing execute_command" && exit 1
    trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
      local provider="$HOME/_/clis/execute_command_intuivo_cli/${_library}"
      local _err=0 structsource
      if [   -e "${provider}"  ] ; then
        (( DEBUG )) && echo "$0: tasks_base/sudoer.bash Loading locally"
        structsource="""$(<"${provider}")"""
        _err=$?
        [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading ${_library}. running 'source locally' returned error did not download or is empty err:$_err  \n \n  " && exit 1
      else
        if ( command -v curl >/dev/null 2>&1; )  ; then
          (( DEBUG )) && echo "$0: tasks_base/sudoer.bash Loading ${_library} from the net using curl "
          structsource="""$(curl https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/${_library}  -so -   2>/dev/null )"""  #  2>/dev/null suppress only curl download messages, but keep curl output for variable
          _err=$?
          [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading ${_library}. running 'curl' returned error did not download or is empty err:$_err  \n \n  " && exit 1
        elif ( command -v wget >/dev/null 2>&1; ) ; then
          (( DEBUG )) && echo "$0: tasks_base/sudoer.bash Loading ${_library} from the net using wget "
          structsource="""$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/${_library} -O -   2>/dev/null )"""  #  2>/dev/null suppress only wget download messages, but keep wget output for variable
          _err=$?
          [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading ${_library}. running 'wget' returned error did not download or is empty err:$_err  \n \n  " && exit 1
        else
          echo -e "\n \n  ERROR! Loading ${_library} could not find wget or curl to download  \n \n "
          exit 69
        fi
      fi
      [[ -z "${structsource}" ]] && echo -e "\n \n  ERROR! Loading ${_library} into ${_library}_source did not download or is empty " && exit 1
      local _temp_dir="$(mktemp -d 2>/dev/null || mktemp -d -t "${_library}_source")"
      echo "${structsource}">"${_temp_dir}/${_library}"
      (( DEBUG )) && echo "$0: tasks_base/sudoer.bash Temp location ${_temp_dir}/${_library}"
      source "${_temp_dir}/${_library}"
      _err=$?
      [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading ${_library}. Occured while running 'source' err:$_err  \n \n  " && exit 1
      if  ! typeset -f passed >/dev/null 2>&1; then
        echo -e "\n \n  ERROR! Loading ${_library}. Passed was not loaded !!!  \n \n "
        exit 69;
      fi
      return $_err
  } # end load_library
  load_library "struct_testing"
  load_library "execute_command"
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
  function _trap_on_err_int(){
    # echo -e "\033[01;7m*** ERROR OR INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR INT ...\033[0m"
    local cero="$0"
    local file1="$(paeth ${BASH_SOURCE})"
    local file2="$(paeth ${cero})"
    echo -e " ERROR OR INTERRUPT  TRAP $THISSCRIPTNAME
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
ERR INT ..."
    exit 1
  }
  trap _trap_on_err_int ERR INT
} # end sudo_it

# _linux_prepare(){
  sudo_it
  [ $? -gt 0 ] && (failed to sudo_it raise_to_sudo_and_user_home  || exit 1)
  export USER_HOME
  # shellcheck disable=SC2046
  # shellcheck disable=SC2031
  typeset -r USER_HOME="$(echo -n $(bash -c "cd ~${SUDO_USER} && pwd"))"  # Get the caller's of sudo home dir LINUX and MAC
  # USER_HOME=$(getent passwd "${SUDO_USER}" | cut -d: -f6)   # Get the caller's of sudo home dir LINUX
  enforce_variable_with_value USER_HOME "${USER_HOME}"
# }  # end _linux_prepare


# _linux_prepare
export SUDO_GRP='staff'
enforce_variable_with_value USER_HOME "${USER_HOME}"
enforce_variable_with_value SUDO_USER "${SUDO_USER}"
(( DEBUG )) && passed "Caller user identified:${SUDO_USER}"
(( DEBUG )) && passed "Home identified:${USER_HOME}"
directory_exists_with_spaces "${USER_HOME}"



 #---------/\/\/\-- tasks_base/sudoer.bash -------------/\/\/\--------





 #--------\/\/\/\/-- tasks_templates_sudo/discord …install_discord.bash” -- Custom code -\/\/\/\/-------


#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#

function only_alphanumeric(){
 sed 's/[^a-zA-Z0-9]//g'
}
function only_url_chars(){
 sed 's/[^a-zA-Z0-9_:.\/-]//g'
}
function just_download_it(){
  # Sample use
  #
  #   _just_download_it
  local TARGET_URL=$(echo ${1} | only_url_chars)
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  local CODENAME=$(echo ${2} | only_url_chars)
  enforce_variable_with_value CODENAME "${CODENAME}"
  echo  "TARGET_URL:<${TARGET_URL}>"
  echo  "  CODENAME:<${CODENAME}>"
  if ( command -v curl >/dev/null 2>&1; )  ; then
    # echo "Downloading ${TARGET_URL} from the net using curl "
    # REF: https://www.digitalocean.com/community/tutorials/workflow-downloading-files-curl
    echo curl -LO "${TARGET_URL}"
    #echo curl -L -o "${CODENAME}"  "${TARGET_URL}"
    #curl -L -o "${CODENAME}"  "${TARGET_URL}"
    (( DEBUG )) && echo "https://dl.discordapp.net/apps/linux/0.0.15/discord-0.0.15.tar.gz" | hexdump -C
    (( DEBUG )) && echo ${TARGET_URL} |  hexdump -C
    curl -LO ${TARGET_URL}
    _err=$?
    [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Downloading \n\n ${TARGET_URL}. running 'curl' returned error did not download or is empty err:$_err  \n \n  " && exit 1
    return ${_err}
  elif ( command -v wget >/dev/null 2>&1; ) ; then
    echo "Downloading ${TARGET_URL} from the net using wget "
    # REF: https://linuxconfig.org/wget-file-download-on-linux
    wget --quiet --no-check-certificate  "${TARGET_URL}" -O "${CODENAME}"
    _err=$?
    [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Downloading ${TARGET_URL}. running 'wget' returned error did not download or is empty err:$_err  \n \n  " && exit 1
    return ${_err}
  else
    echo -e "\n \n  ERROR! Downloading ${TARGET_URL}  could not find wget or curl to download  \n \n "
    exit 69
  fi
  return 1
} # end _just_download_it

_fedora__64() {
  raise_to_sudo_and_user_home
  [ $? -gt 0 ] && failed to raise_to_sudo_and_user_home
  # [ $? -gt 0 ] && exit 1
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  local FIRST_URL="https://discord.com/api/download?platform=linux&format=tar.gz"
  enforce_variable_with_value FIRST_URL "${FIRST_URL}"
  local CURLOUTPUT="$(curl -IL "${FIRST_URL}" 2>/dev/null)"
  echo "curl -IL \"${FIRST_URL}\"  | grep \"location:\" | cut -d: -f2-"
  # local CURLOUTPUT="$(curl -IL https://discord.com/api/download\?platform\=linux\&format\=tar.gz 2>/dev/null)"
  enforce_variable_with_value CURLOUTPUT "${CURLOUTPUT}"
  local TARGET_URL=$(echo "${CURLOUTPUT}" | grep "location:" | cut -d: -f2- | only_url_chars)
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  local CODENAME=$(basename "${TARGET_URL}" | only_url_chars)
  enforce_variable_with_value CODENAME "${CODENAME}"
  local DOWNLOADFOLDER="$(_find_downloads_folder)"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  cd "${DOWNLOADFOLDER}"
  local _err=0
  just_download_it "${TARGET_URL}"  "${CODENAME}"
  _err=$?
  if [ $_err -ne 0 ] ;  then
  {
    >&2 echo -e "${RED} ✘ ${YELLOW_OVER_DARKBLUE}${*}${RESET} Err:$_err Message: error deleting directory"
    exit $_err
  }
  fi
  file_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
  tar -xvf "${DOWNLOADFOLDER}/${CODENAME}"
  file_exists_with_spaces "${DOWNLOADFOLDER}/Discord"
  directory_exists_with_spaces "/usr/lib64"
  directory_exists_with_spaces "/usr/bin"
  if  it_exists_with_spaces "/usr/lib64/discord" ; then
  {
    rm -rf "/usr/lib64/discord"
    _err=$?
  }
  fi
  if [ $_err -ne 0 ] ;  then
  {
    >&2 echo -e "${RED} ✘ ${YELLOW_OVER_DARKBLUE}${*}${RESET} Err:$_err Message: error deleting directory"
    exit $_err
  }
  fi
  directory_does_not_exist_with_spaces "/usr/lib64/discord"
  if it_exists_with_spaces "/usr/bin/Discord" ; then
  {
    unlink "/usr/bin/Discord"
    _err=$?
  } else {
    echo "whot"
  }
  fi
  if [[ -L "/usr/bin/Discord" ]] ; then
  {
    echo "what"
    unlink "/usr/bin/Discord"
    _err=$?
  }
  fi
  if [ $_err -ne 0 ] ;  then
  {
    >&2 echo -e "${RED} ✘ ${YELLOW_OVER_DARKBLUE}${*}${RESET} Err:$_err Message: error unlinking /usr/lib64/discord"
    exit $_err
  }
  fi
  file_does_not_exist_with_spaces "/usr/bin/Discord"
  mv "${DOWNLOADFOLDER}/Discord" "/usr/lib64/discord"
   _err=$?
  if [ $_err -ne 0 ] ;  then
  {
    >&2 echo -e "${RED} ✘ ${YELLOW_OVER_DARKBLUE}${*}${RESET} Err:$_err Message: error moving directory from "${DOWNLOADFOLDER}/Discord" to /usr/lib64/discord"
    exit $_err
  }
  fi
  directory_exists_with_spaces "/usr/lib64/discord"
  cd /usr/bin
  ln -s /usr/lib64/discord/Discord /usr/bin/Discord
  softlink_exists_with_spaces "/usr/bin/Discord>/usr/lib64/discord/Discord"
  return 0
} # end _fedora__64

_darwin__64(){
    su - "${SUDO_USER}" -c 'brew install discord --force'
} # end _darwin__64



 #--------/\/\/\/\-- tasks_templates_sudo/discord …install_discord.bash” -- Custom code-/\/\/\/\-------


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo "🥦"
exit 0
