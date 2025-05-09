#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
# 20200415 Compatible with Fedora, Mac, Ubuntu "sudo_up" "load_struct" "#
#set -u
set -E -o functrace
export THISSCRIPTCOMPLETEPATH

echo "0. sudologic $0:$LINENO           SUDO_COMMAND:${SUDO_COMMAND:-}"
echo "0. sudologic $0:$LINENO               SUDO_GRP:${SUDO_GRP:-}"
echo "0. sudologic $0:$LINENO               SUDO_UID:${SUDO_UID:-}"
echo "0. sudologic $0:$LINENO               SUDO_GID:${SUDO_GID:-}"
echo "0. sudologic $0:$LINENO              SUDO_USER:${SUDO_USER:-}"
echo "0. sudologic $0:$LINENO                   USER:${USER:-}"
echo "0. sudologic $0:$LINENO              USER_HOME:${USER_HOME:-}"
echo "0. sudologic $0:$LINENO THISSCRIPTCOMPLETEPATH:${THISSCRIPTCOMPLETEPATH:-}"
echo "0. sudologic $0:$LINENO         THISSCRIPTNAME:${THISSCRIPTNAME:-}"
echo "0. sudologic $0:$LINENO       THISSCRIPTPARAMS:${THISSCRIPTPARAMS:-}"

echo "0. sudologic $0 Start Checking realpath  "
if ! ( command -v realpath >/dev/null 2>&1; )  ; then
  echo "... realpath not found. Downloading REF:https://github.com/swarmbox/realpath.git "
  cd $HOME
  git clone https://github.com/swarmbox/realpath.git
  cd realpath
  make
  sudo make install
  _err=$?
  [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Builing realpath. returned error did not download or is installed err:$_err  \n \n  " && exit 1
else
  echo "... realpath exists .. check!"
fi

typeset -r THISSCRIPTCOMPLETEPATH="$(realpath  "$0")"   # updated realpath macos 20210902
# typeset -r THISSCRIPTCOMPLETEPATH="$(realpath "$(basename "$0")")"  # updated realpath macos 20210902  # § This goe$
export BASH_VERSION_NUMBER
typeset BASH_VERSION_NUMBER=$(echo $BASH_VERSION | cut -f1 -d.)

export  THISSCRIPTNAME
typeset -r THISSCRIPTNAME="$(basename "$0")"

export THISSCRIPTPARAMS
typeset -r THISSCRIPTPARAMS="${*:-}"
echo "0. sudologic $0:$LINENO       THISSCRIPTPARAMS:${THISSCRIPTPARAMS:-}"

export _err
typeset -i _err=0

  function _trap_on_error(){
    #echo -e "\\n \033[01;7m*** 1 ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m"
    local cero="$0"
    local file1="$(paeth ${BASH_SOURCE})"
    local file2="$(paeth ${cero})"
    echo -e "ERROR TRAP $THISSCRIPTNAME $THISSCRIPTPARAMS
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
ERR ..."
    exit 1
  }
  trap _trap_on_error ERR
  function _trap_on_int(){
    # echo -e "\\n \033[01;7m*** 1 INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n  INT ...\033[0m"
    local cero="$0"
    local file1="$(paeth ${BASH_SOURCE})"
    local file2="$(paeth ${cero})"
    echo -e "INTERRUPT TRAP $THISSCRIPTNAME $THISSCRIPTPARAMS
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
INT ..."
    exit 0
  }

  trap _trap_on_int INT

load_struct_testing(){
  function _trap_on_error(){
    local -ir __trapped_error_exit_num="${2:-0}"
		echo -e "\\n \033[01;7m*** 0tasks_base/sudoer.bash:$LINENO load_struct_testing() ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[1]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[2]}()  \\n$0:${BASH_LINENO[2]} ${FUNCNAME[3]}() \\n ERR ...\033[0m  \n \n "

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
    local _library="${1:-struct_testing}"
    local -i _DEBUG=${DEBUG:-0}
    if [[ -z "${1}" ]] ; then
    {
       echo "Must call with name of library example: struct_testing execute_command"
       exit 1
    }
    fi
    trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
      local provider="$HOME/_/clis/execute_command_intuivo_cli/${_library}"
      if [[ -n "${SUDO_USER:-}" ]] && [[ -n "${HOME:-}" ]] && [[ "${HOME:-}" == "/root" ]] && [[ !  -e "${provider}"  ]] ; then
      {
        provider="/home/${SUDO_USER}/_/clis/execute_command_intuivo_cli/${_library}"
      }
      elif [[ -z "${SUDO_USER:-}" ]] && [[ -n "${HOME:-}" ]] && [[ "${HOME:-}" == "/root" ]] && [[ !  -e "${provider}"  ]] ; then
      {
        provider="/home/${USER}/_/clis/execute_command_intuivo_cli/${_library}"
      }
      fi
      echo "$0: ${provider}"
      echo "$0: SUDO_USER:${SUDO_USER:-nada SUDOUSER}: USER:${USER:-nada USER}: ${SUDO_HOME:-nada SUDO_HOME}: {${HOME:-nada HOME}}"
      local _err=0 structsource
      if [[  -e "${provider}" ]] ; then
        if (( _DEBUG )) ; then
          echo "$0: 0tasks_base/sudoer.bash Loading locally"
        fi
        structsource="""$(<"${provider}")"""
        _err=$?
        if [ $_err -gt 0 ] ; then
        {
           echo -e "\n \n  ERROR! Loading ${_library}. running 'source locally' returned error did not download or is empty err:$_err  \n \n  "
           exit 1
        }
        fi
      else
        if ( command -v curl >/dev/null 2>&1; )  ; then
          if (( _DEBUG )) ; then
            echo "$0: 0tasks_base/sudoer.bash Loading ${_library} from the net using curl "
          fi
          structsource="""$(curl https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/${_library}  -so -   2>/dev/null )"""  #  2>/dev/null suppress only curl download messages, but keep curl output for variable
          _err=$?
          if [ $_err -gt 0 ] ; then
          {
            echo -e "\n \n  ERROR! Loading ${_library}. running 'curl' returned error did not download or is empty err:$_err  \n \n  "
            exit 1
          }
          fi
        elif ( command -v wget >/dev/null 2>&1; ) ; then
          if (( _DEBUG )) ; then
            echo "$0: 0tasks_base/sudoer.bash Loading ${_library} from the net using wget "
          fi
          structsource="""$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/${_library} -O -   2>/dev/null )"""  #  2>/dev/null suppress only wget download messages, but keep wget output for variable
          _err=$?
          if [ $_err -gt 0 ] ; then
          {
            echo -e "\n \n  ERROR! Loading ${_library}. running 'wget' returned error did not download or is empty err:$_err  \n \n  "
            exit 1
          }
          fi
        else
          echo -e "\n \n 2  ERROR! Loading ${_library} could not find wget or curl to download  \n \n "
          exit 69
        fi
      fi
      if [[ -z "${structsource}" ]] ; then
      {
        echo -e "\n \n 3 ERROR! Loading ${_library} into ${_library}_source did not download or is empty "
        exit 1
      }
      fi
      local _temp_dir="$(mktemp -d 2>/dev/null || mktemp -d -t "${_library}_source")"
      echo "${structsource}">"${_temp_dir}/${_library}"
      if (( _DEBUG )) ; then
        echo "1. sudologic $0: 0tasks_base/sudoer.bash Temp location ${_temp_dir}/${_library}"
      fi
      source "${_temp_dir}/${_library}"
      _err=$?
      if [ $_err -gt 0 ] ; then
      {
        echo -e "\n \n 4 ERROR! Loading ${_library}. Occured while running 'source' err:$_err  \n \n  "
        exit 1
      }
      fi
      if  ! typeset -f passed >/dev/null 2>&1; then
        echo -e "\n \n 5 ERROR! Loading ${_library}. Passed was not loaded !!!  \n \n "
        exit 69;
      fi
      return $_err
  } # end load_library
  if  ! typeset -f passed >/dev/null 2>&1; then
    load_library "struct_testing"
  fi
  if  ! typeset -f load_colors >/dev/null 2>&1; then
    load_library "execute_command"
  fi
} # end load_struct_testing
load_struct_testing

 _err=$?
if [ $_err -ne 0 ] ; then
{
  echo -e "\n \n 6 ERROR FATAL! load_struct_testing_wget !!! returned:<$_err> \n \n  "
  exit 69;
}
fi

if [[ -z "${SUDO_COMMAND:-}" ]] && \
   [[ -z "${SUDO_GRP:-}" ]] && \
   [[ -z "${SUDO_UID:-}" ]] && \
   [[ -z "${SUDO_GID:-}" ]] && \
   [[ -z "${SUDO_USER:-}" ]] && \
   [[ -n "${USER:-}" ]] && \
   [[ -z "${USER_HOME:-}" ]] && \
   [[ -n "${THISSCRIPTCOMPLETEPATH:-}" ]] && \
   [[ -n "${THISSCRIPTNAME:-}" ]] \
  ; then
{
  passed Called from user
}
fi


if [[ -n "${SUDO_COMMAND:-}"  ]] && \
   [[ -z "${SUDO_GRP:-}"  ]] && \
   [[ -n "${SUDO_UID:-}"  ]] && \
   [[ -n "${SUDO_GID:-}"  ]] && \
   [[ -n "${SUDO_USER:-}"  ]] && \
   [[ -n "${USER:-}"  ]] && \
   [[ -z "${USER_HOME:-}"  ]] && \
   [[ -n "${THISSCRIPTCOMPLETEPATH:-}"  ]] && \
   [[ -n "${THISSCRIPTNAME:-}"  ]] \
  ; then
{
  passed Called from user as sudo
}
else
{

if [[ "${SUDO_USER:-}" == 'root'  ]] && \
   [[ "${USER:-}" == 'root' ]] \
  ; then
{
  failed This script is has to be called from normal user. Not Root. Abort
  exit 69
}
fi

export sudo_it
function sudo_it() {
  local -i _DEBUG=${DEBUG:-}
  local _err=$?
  # check operation systems
  if [[ "$(uname)" == "Darwin" ]] ; then
  {
    passed "sudo_it() # Do something under Mac OS X platform "
      # nothing here
      raise_to_sudo_and_user_home "${*-}"
      [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
    SUDO_USER="${USER}"
    SUDO_COMMAND="$0"
    SUDO_UID=502
    SUDO_GID=20
  }
  elif [[ "$(cut -c1-5 <<< "$(uname -s)")" == "Linux" ]] ; then
  {
      # Do something under GNU/Linux platform
      raise_to_sudo_and_user_home "${*-}"
      [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
      enforce_variable_with_value SUDO_USER "${SUDO_USER}"
      enforce_variable_with_value SUDO_UID "${SUDO_UID}"
      enforce_variable_with_value SUDO_COMMAND "${SUDO_COMMAND}"
      # Override bigger error trap  with local
      function _trap_on_error(){
        echo -e "\033[01;7m*** 3 ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR INT ...\033[0m"

      }
      trap _trap_on_error ERR INT
  }
  elif [[ "$(cut -c1-10 <<< "$(uname -s)")" == "MINGW32_NT" ]] || [[ "$(cut -c1-10 <<< "$(uname -s)")" == "MINGW64_NT" ]] ; then
  {
      # Do something under Windows NT platform
      # nothing here
    SUDO_USER="${USER}"
    SUDO_COMMAND="$0"
    SUDO_UID=502
    SUDO_GID=20
  }
  fi

  if (( _DEBUG )) ; then
    Comment _err:${_err}
  fi
  if [ $_err -gt 0 ] ; then
  {
    failed to sudo_it raise_to_sudo_and_user_home
    exit 1
  }
  fi
  # [ $_err -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
  _err=$?
  if (( _DEBUG )) ; then
    Comment _err:${_err}
  fi
  enforce_variable_with_value SUDO_USER "${SUDO_USER}"
  enforce_variable_with_value SUDO_UID "${SUDO_UID}"
  enforce_variable_with_value SUDO_COMMAND "${SUDO_COMMAND}"
  # Override bigger error trap  with local
  function _trap_on_err_int(){
    # echo -e "\033[01;7m*** 7 ERROR OR INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR INT ...\033[0m"
    local cero="$0"
    local file1="$(paeth ${BASH_SOURCE})"
    local file2="$(paeth ${cero})"
    echo -e " ERROR OR INTERRUPT  TRAP $THISSCRIPTNAME $THISSCRIPTPARAMS
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
ERR INT ..."
    exit 1
  }
  trap _trap_on_err_int ERR INT
} # end sudo_it

# _linux_prepare(){
  sudo_it "${*}"
  _err=$?
  typeset -i tomporalDEBUG=${DEBUG:-}
  if (( tomporalDEBUG )) ; then
    Comment _err:${_err}
  fi
  if [ $_err -gt 0 ] ; then
  {
    failed to sudo_it raise_to_sudo_and_user_home
    exit 1
  }
  fi



  exit
}
fi




typeset -i tomporalDEBUG=${DEBUG:-}
  # [ $_err -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
  _err=$?
  if (( tomporalDEBUG )) ; then
    Comment _err:${_err}
  fi
  # [ $? -gt 0 ] && (failed to sudo_it raise_to_sudo_and_user_home  || exit 1)
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
if (( tomporalDEBUG )) ; then
  passed "Caller user identified:${SUDO_USER}"
fi
  if (( tomporalDEBUG )) ; then
    Comment DEBUG_err?:${?}
  fi
if (( tomporalDEBUG )) ; then
  passed "Home identified:${USER_HOME}"
fi
  if (( tomporalDEBUG )) ; then
    Comment DEBUG_err?:${?}
  fi
directory_exists_with_spaces "${USER_HOME}"


  function _trap_on_error(){
    local -ir __trapped_error_exit_num="${2:-0}"
    echo -e "\\n \033[01;7m*** 2 ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[1]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[2]}()  \\n$0:${BASH_LINENO[2]} ${FUNCNAME[3]}() \\n ERR ...\033[0m  \n \n "
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
    exit ${__trapped_error_exit_num}
  }
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR

  function _trap_on_exit(){
    local -ir __trapped_exit_num="${2:-0}"
    echo -e "\\n \033[01;7m*** 5 EXIT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[1]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[2]}()  \\n$0:${BASH_LINENO[2]} ${FUNCNAME[3]}() \\n EXIT ...\033[0m  \n \n "
    echo ". ${1}"
    echo ". exit  ${__trapped_exit_num}  "
    echo ". caller $(caller) "
    echo ". ${BASH_COMMAND}"
    local -r __caller=$(caller)
    local -ir __caller_line=$(echo "${__caller}" | cut -d' ' -f1)
    local -r __caller_script_name=$(echo "${__caller}" | cut -d' ' -f2)
    awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}"

    # $(eval ${BASH_COMMAND}  2>&1; )
    # echo -e " ☠ ${LIGHTPINK} Offending message:  ${__bash_error} ${RESET}"  >&2
    exit ${__trapped_INT_num}
  }
  # trap  '_trap_on_exit $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  EXIT

  function _trap_on_INT(){
    local -ir __trapped_INT_num="${2:-0}"
    echo -e "\\n \033[01;7m*** 7 INT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[1]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[2]}()  \\n$0:${BASH_LINENO[2]} ${FUNCNAME[3]}() \\n INT ...\033[0m  \n \n "
    echo ". ${1}"
    echo ". INT  ${__trapped_INT_num}  "
    echo ". caller $(caller) "
    echo ". ${BASH_COMMAND}"
    local -r __caller=$(caller)
    local -ir __caller_line=$(echo "${__caller}" | cut -d' ' -f1)
    local -r __caller_script_name=$(echo "${__caller}" | cut -d' ' -f2)
    awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}"

    # $(eval ${BASH_COMMAND}  2>&1; )
    # echo -e " ☠ ${LIGHTPINK} Offending message:  ${__bash_error} ${RESET}"  >&2
    exit ${__trapped_INT_num}
  }
  trap  '_trap_on_INT $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  INT



 #---------/\/\/\-- 0tasks_base/sudoer.bash -------------/\/\/\--------





 #--------\/\/\/\/-- 2tasks_templates_sudo/opencv_gpu …install_opencv_gpu.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/bash

_debian_flavor_install() {
  # trap  '_trap_on_exit $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  EXIT
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  if
    (
    install_requirements "linux" "
      base64
      unzip
      curl
      wget
      ufw
      nginx
    "
    ); then
    {
      apt install base64 -y
      apt install unzip -y
      apt install nginx -y
    }
  fi
  verify_is_installed "
    unzip
    curl
    wget
    tar
    ufw
    nginx
  "
  local PB_VERSION=0.16.7
  local CODENAME="pocketbase_${PB_VERSION}_linux_amd64.zip"
  local TARGET_URL="https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/${CODENAME}"
  local DOWNLOADFOLDER="$(_find_downloads_folder)"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  directory_exists_with_spaces "${DOWNLOADFOLDER}"
  cd "${DOWNLOADFOLDER}"
  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
  # unzip "${DOWNLOADFOLDER}/${CODENAME}" -d $HOME/pb/
  local UNZIPDIR="${USER_HOME}/_/software"
  mkdir -p "${UNZIPDIR}"
  _unzip "${DOWNLOADFOLDER}" "${UNZIPDIR}" "${CODENAME}"
  local PATHTOPOCKETBASE="${UNZIPDIR}/pocketbase"
  local THISIP=$(myip)

} # end _debian_flavor_install

_redhat_flavor_install() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "_redhat_flavor_install Procedure not yet implemented. I don't know what to do."
} # end _redhat_flavor_install

_arch_flavor_install() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "_arch_flavor_install Procedure not yet implemented. I don't know what to do."
} # end _readhat_flavor_install

_arch__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _arch_flavor_install
} # end _arch__32

_arch__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _arch_flavor_install
} # end _arch__64

_centos__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _centos__32

_centos__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _centos__64

_debian__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _debian_flavor_install
} # end _debian__32

_debian__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _debian_flavor_install
} # end _debian__64

_fedora__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _fedora__32

_fedora__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _fedora__64

_fedora__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _fedora__64

_fedora__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _fedora__64

_fedora_36__64() {
  trap "echo Error:$?" ERR INT
  local _parameters="${*-}"
  local -i _err=0
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    failed "while running callsomething above _err:${_err}"
  }
  fi
  _redhat_flavor_install "${_parameters-}"
} # end _fedora_36__64

_fedora_37__64() {
  trap "echo Error:$?" ERR INT
  local _parameters="${*-}"
  local -i _err=0
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    failed "while running callsomething above _err:${_err}"
  }
  fi
  _redhat_flavor_install "${_parameters-}"
} # end _fedora_37__64

_fedora_38__64() {
  trap "echo Error:$?" ERR INT
  local _parameters="${*-}"
  local -i _err=0
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    failed "while running callsomething above _err:${_err}"
  }
  fi
  _redhat_flavor_install "${_parameters-}"
} # end _fedora_38__64

_fedora_39__64() {
  trap "echo Error:$?" ERR INT
  local _parameters="${*-}"
  local -i _err=0
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    failed "while running callsomething above _err:${_err}"
  }
  fi
  _redhat_flavor_install "${_parameters-}"
} # end _fedora_39__64

_gentoo__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _gentoo__32

_gentoo__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _gentoo__64

_madriva__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _madriva__32

_madriva__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _madriva__64

_suse__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _suse__32

_netbsd__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "This is installer is missing"
} # end _netbsd__64

_suse__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _suse__64

_ubuntu__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _debian_flavor_install
} # end _ubuntu__32

_ubuntu__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _debian_flavor_install
} # end _ubuntu__64

_ubuntu__aarch64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _debian_flavor_install
} # end _ubuntu__aarch64

_ubuntu_22__aarch64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _debian_flavor_install
} # end _ubuntu_22__aarch64



_add_variables_to_bashrc_zshrc(){
  local CUDA_SH_CONTENT='

# CUDA
if [[ -e "'${USER_HOME}'/.cuda" ]] ; then
{
  export CUDA_ROOT="'${USER_HOME}'/.cuda"
  export PATH="'${USER_HOME}'/bin:${PATH}"
  export PATH="'${USER_HOME}'/.cuda/bin:${PATH}"
  eval "$(cuda init -)"
}
fi
'
  trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO _add_variables_to_bashrc_zshrc cuda" && echo -e "${RESET}" && return 0' ERR
  Checking "${CUDA_SH_CONTENT}"
  local INITFILE INITFILES="
   .bashrc
   .zshrc
   .bash_profile
   .profile
   .zshenv
   .zprofile
  "
  while read INITFILE; do
  {
    [ -z ${INITFILE} ] && continue
    Checking "${USER_HOME}/${INITFILE}"
    _if_not_contains "${USER_HOME}/${INITFILE}"  "# CUDA" ||  echo "${CUDA_SH_CONTENT}" >> "${USER_HOME}/${INITFILE}"
    _if_not_contains "${USER_HOME}/${INITFILE}"  "CUDA_ROOT" ||  echo "${CUDA_SH_CONTENT}" >> "${USER_HOME}/${INITFILE}"
    _if_not_contains "${USER_HOME}/${INITFILE}"  "cuda init" ||  echo "${CUDA_SH_CONTENT}" >> "${USER_HOME}/${INITFILE}"
  }
  done <<< "${INITFILES}"
  # type cuda
  Checking "export PATH=\"${USER_HOME}/.cuda/bin:${PATH}\" "
  export PATH="${USER_HOME}/.cuda/bin:${PATH}"
  chown -R "${SUDO_USER}" "${USER_HOME}/.cuda"
  cd "${USER_HOME}/.cuda/bin"
  eval "$("${USER_HOME}"/.cuda/bin/cuda init -)"

  # cuda doctor
  # cuda install -l
  # cuda install 2.6.5
  # cuda global 2.6.5
  # cuda rehash
  # ruby -v

} # _add_variables_to_bashrc_zshrc

_darwin_13_6__64() {
  trap "echo Error:$?" ERR INT
  local _parameters="${*-}"
  local -i _err=0
  _darwin__64 "${_parameters-}"
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    failed "$0:$LINENO while running callsomething above _err:${_err}"
  }
  fi
} # end _darwin_13_6__64

_darwin__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local _cwd=$(pwd)
  local -i _err=0

  if [[ -z "$(xcode-select -p)" ]] ; then 
  {
    xcode-select --install
  }
  fi

  if it_exists_with_spaces .venv ; then
  {
    source .venv/bin/activate
  }
  else
  {
    python3 -m venv .venv
    source .venv/bin/activate
    su - "${SUDO_USER}" -c "brew install --force --overwrite python@3.12"
    su - "${SUDO_USER}" -c "brew install jpeg libpng libtiff openexr"
    su - "${SUDO_USER}" -c "brew install eigen tbb"
    su - "${SUDO_USER}" -c "brew link --force --overwrite python@3.12"
    su - "${SUDO_USER}" -c "brew postinstall python@3.12"
  }
  fi
  # echo 'export PATH="/usr/local/opt/jpeg/bin:$PATH"' >> ~/.zshrc
  export PATH="/usr/local/opt/jpeg/bin:$PATH"   
  # For compilers to find jpeg you may need to set:
  export LDFLAGS="-L/usr/local/opt/jpeg/lib"
  export CPPFLAGS="-I/usr/local/opt/jpeg/include"
  # For pkg-config to find jpeg you may need to set:
  export PKG_CONFIG_PATH="/usr/local/opt/jpeg/lib/pkgconfig"
  # su - "${SUDO_USER}" -c "brew install python@3.9"
  # su - "${SUDO_USER}" -c "brew link --force --overwrite python@3.9"
  

  if it_exists_with_spaces /usr/local/bin/cuda-gdb ; then
  {
    pwd
    echo "Cuda version test:" 
    cuda-gdb --version
    passed "found dir /usr/local/bin/cuda-gdb already build"
  }
  else
  {


    if it_exists_with_spaces cuda-gdb-darwin-12.2.53-32947973.gz ; then
    {
      passed "found file cuda-gdb-darwin-12.2.53-32947973.gz"
    }
    fi

    local INSTALL_DIR=/usr/local/bin/cuda-gdb-darwin-12.2
    if it_exists_with_spaces "${INSTALL_DIR}" ; then
    {
      rm -rf "${INSTALL_DIR}"
    }
    fi
    mkdir -p "${INSTALL_DIR}"

    cp cuda-gdb-darwin-12.2.53-32947973.gz "${INSTALL_DIR}"
    cd "${INSTALL_DIR}" || failed "to move to dir cd ${INSTALL_DIR}"
    if it_exists_with_spaces cuda-gdb-darwin-12.2.53-32947973.gz ; then
    {
      passed "found file cuda-gdb-darwin-12.2.53-32947973.gz"
    }
    fi
    tar fxvz  cuda-gdb-darwin-12.2.53-32947973.gz
    cd "${INSTALL_DIR}/bin" || failed "to move to dir cd ${INSTALL_DIR}/bin"
    # _add_variables_to_bashrc_zshrc
    link_folder_scripts
    xattr -d  com.apple.quarantine cuda-binary-gdb 
    xattr -d  com.apple.quarantine cuda-gdb  
    xattr -d  com.apple.quarantine cuobjdump  
    xattr -d  com.apple.quarantine nvdisasm
    cuda-gdb --version
  }
  fi

  cd "${_cwd}"
  if it_exists_with_spaces opencv ; then
  {
    passed "found dir opencv"
  }
  else
  {
    git clone https://github.com/opencv/opencv.git "opencv"
  }
  fi
  cd "${_cwd}"
  if it_exists_with_spaces opencv_contrib ; then
  {
    passed "found dir opencv_contrib"
  }
  else
  {
    git clone https://github.com/opencv/opencv_contrib.git "opencv_contrib"
  }
  fi
  export PATH="/usr/local/opt/python@3.12/bin:$PATH"
  export LDFLAGS="-L/usr/local/opt/python@3.12/lib"
  export CPPFLAGS="-I/usr/local/opt/python@3.12/include"
  export PKG_CONFIG_PATH="/usr/local/opt/python@3.12/lib/pkgconfig"
  local PY3_INCLUDE_DIR=$(python3 -c "import sysconfig; print(sysconfig.get_paths()['include'])")
  local PY3_LIBRARY=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))")/libpython3.12.dylib
  local PY3_PACKAGES_PATH=$(python3 -c "import site; print(site.getsitepackages()[0])")
  # local PY3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")
  # local PY3_LIBRARY=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))")/libpython3.12.dylib
  # local PY3_PACKAGES_PATH=$(python3 -c "import site; print(site.getsitepackages()[0])")
  #     # -D PYTHON3_INCLUDE_DIR=/usr/local/opt/python@3.12/Frameworks/Python.framework/Versions/3.12/include/python3.12 \
      # -D PYTHON3_LIBRARY=/usr/local/opt/python@3.12/Frameworks/Python.framework/Versions/3.12/lib/libpython3.12.dylib \
      # -D PYTHON3_PACKAGES_PATH=/usr/local/opt/python@3.12/Frameworks/Python.framework/Versions/3.12/lib/python3.12/site-packages \

  # su - "${SUDO_USER}" -c "python3 -m ensurepip --upgrade"
  # su - "${SUDO_USER}" -c "python3 -m pip install setuptools"
  Checking 3.4.20
  if it_exists_with_spaces  opencv3.4.20-build-mac64-osx13 && it_exists_with_spaces opencv3.4.20-build-mac64-osx13/bin  ; then
  {
    pwd
    echo "opencv 3.4.20 version test:" 
    ./opencv3.4.20-build-mac64-osx13/bin/opencv_version
    passed "found dir opencv3.4.20-build-mac64-osx13 already build"
  }
  else
  {
    Installing 3.4.20
    if ( echo "$( brew info ffmpeg 2>&1 )" | grep -q "^Not installed" ) ; then
    {
      su - "${SUDO_USER}" -c "brew unlink ffmpeg"
      su - "${SUDO_USER}" -c "brew uninstall ffmpeg"
    }
    else
    {
      passed "ffmpeg not installed"
    }
    fi
    su - "${SUDO_USER}" -c "brew unlink ffmpeg"
    su - "${SUDO_USER}" -c "brew install ffmpeg@4"
    su - "${SUDO_USER}" -c "brew unlink ffmpeg@4 && brew link --force ffmpeg@4"
    rm -rf opencv3.4.20-build-mac64-osx13
    rm -rf opencv3.4.20/build
    mkdir -p opencv3.4.20/build
    mkdir -p opencv3.4.20-build-mac64-osx13
    chown -R "${SUDO_USER}" opencv3.4.20
    chown -R "${SUDO_USER}" opencv3.4.20-build-mac64-osx13
    cd opencv3.4.20/build
    # -DWITH_FFMPEG=OFF 
    su - "${SUDO_USER}" -c "cd \"${_cwd}/opencv3.4.20/build\" && cmake -D CMAKE_BUILD_TYPE=Release \
        -D CMAKE_INSTALL_PREFIX=../../opencv3.4.20-build-mac64-osx13 \
        -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib3.4.20/modules \
        -D WITH_OPENCL=ON \
        -D WITH_OPENCL_SVM=OFF \
        -D WITH_OPENCLAMDFFT=OFF \
        -D WITH_OPENCLAMDBLAS=OFF \
        -D BUILD_OPENCV_DNN=OFF \
        -D BUILD_opencv_dnn=OFF \
        -D BUILD_OPENCV_XPHOTO=OFF \
        -D BUILD_opencv_xphoto=OFF \
        -D PYTHON3_EXECUTABLE=$(which python3) \
        -D PYTHON3_INCLUDE_DIR=\"${PY3_INCLUDE_DIR}\" \
        -D PYTHON3_LIBRARY=\"${PY3_LIBRARY}\" \
        -D PYTHON3_PACKAGES_PATH=\"${PY3_PACKAGES_PATH}\" \
        .."


    Installing running make 3.4.20
    rm -rf build3.4.20.log
    touch build3.4.20.log
    chown "${SUDO_USER}" build3.4.20.log
    su - "${SUDO_USER}" -c "cd \"${_cwd}/opencv3.4.20/build\" && make  -j$(sysctl -n hw.logicalcpu) 2>&1 | tee build3.4.20.log"
    # make VERBOSE=1  -j$(sysctl -n hw.logicalcpu) 2>&1 | tee build3.4.20.log
    _err=$?
    if ( grep -qi 'error' build3.4.20.log ) ; then
    {
      grep -i 'error' build3.4.20.log > errors3.4.20.log
    }
    fi
    if ( grep -qi 'undefined reference' build3.4.20.log ) ; then
    {
      grep -i 'undefined reference' build3.4.20.log > reference3.4.20.log
    }
    fi
    if ( grep -qi 'undefined' build3.4.20.log ) ; then
    {
      grep -i 'undefined' build3.4.20.log > undefined3.4.20.log
    }
    fi
    if ( grep -qi 'missing' build3.4.20.log ) ; then
    {
      grep -i 'missing' build3.4.20.log > missing3.4.20.log
    }
    fi
    if ( grep -qi 'failed' build3.4.20.log ) ; then
    {
      grep -i 'failed' build3.4.20.log > failed3.4.20.log
    }
    fi
    if [ ${_err} -gt 0 ] ; then
    {
      rm -rf ../../opencv3.4.20-build-mac64-osx13 &
      failed " $0:$LINENO while running make for opencv3.4.20  removing build target also _err:${_err}"
    }
    fi
    make install

  }
  fi
  cd "${_cwd}"
  Checking 4.8.0
  if it_exists_with_spaces opencv4.8.0-build-mac64-osx13  && it_exists_with_spaces opencv4.8.0-build-mac64-osx13/bin  ; then
  {
    pwd
    echo "opencv 4.8.0 version test:" 
    ./opencv4.8.0-build-mac64-osx13/bin/opencv_version
    passed "found dir opencv4.8.0-build-mac64-osx13 already build"
  }
  else
  {
    Installing 4.8.0
    su - "${SUDO_USER}" -c "brew install gstreamer gst-plugins-base gst-plugins-good libdc1394"
    su - "${SUDO_USER}" -c "brew install vtk"
    su - "${SUDO_USER}" -c "brew install openjdk@11"
    su - "${SUDO_USER}" -c "brew link --force --overwrite openjdk@11"
    export PATH="/usr/local/opt/openjdk@11/bin:$PATH"
    # ln -sfn /usr/local/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk
    export CPPFLAGS="-I/usr/local/opt/openjdk@11/include"
    local folderx="$(xcode-select -p)"
    xcode-select -s "${folderx}"
    rm -rf opencv4.8.0-build-mac64-osx13
    rm -rf opencv4.8.0/build
    mkdir -p opencv4.8.0/build
    mkdir -p opencv4.8.0-build-mac64-osx13
    chown -R "${SUDO_USER}" opencv4.8.0
    chown -R "${SUDO_USER}" opencv4.8.0-build-mac64-osx13
    local vtkdir="$(dirname "$(brew list vtk | grep cmake | tail -1)")"
    cd opencv4.8.0/build
        # -D BUILD_OPENCV_DNN=OFF \
        # -D BUILD_opencv_dnn=OFF \
        # -D VTK_DIR=/usr/local/opt/vtk/lib/cmake/vtk-8.2 ../opencv-3.4.20
        # -D BUILD_opencv_cudaarithm=OFF \
 
    su - "${SUDO_USER}" -c "cd \"${_cwd}/opencv4.8.0/build\" && cmake \
        -D CMAKE_BUILD_TYPE=Release \
        -D CMAKE_INSTALL_PREFIX=../../opencv4.8.0-build-mac64-osx13 \
        -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib4.8.0/modules \
        -D VTK_DIR=\"${vtkdir}\" ../../opencv4.8.0 \
        -D WITH_OPENCL=ON \
        -D OPENCV_ENABLE_NONFREE=ON \
        -D WITH_GSTREAMER=ON \
        -D WITH_FFMPEG=ON \
        -D WITH_OPENCL_SVM=OFF \
        -D CUDA_ARCH_BIN=6.1 \
        -D WITH_OPENCLAMDFFT=OFF \
        -D WITH_LIBDC1394=ON \
        -D WITH_OPENCLAMDBLAS=OFF \
        -D BUILD_opencv_cudaarithm=ON \
        -D PYTHON3_EXECUTABLE=$(which python3) \
        -D PYTHON3_INCLUDE_DIR=\"${PY3_INCLUDE_DIR}\" \
        -D PYTHON3_LIBRARY=\"${PY3_LIBRARY}\" \
        -D PYTHON3_PACKAGES_PATH=\"${PY3_PACKAGES_PATH}\" \
        .."

    # Installing Now build the cudaarithm module separately
    # su - "${SUDO_USER}" -c "cd \"${_cwd}/opencv4.8.0/build\" && cmake \
    #     -D CMAKE_BUILD_TYPE=Release \
    #     -D CMAKE_INSTALL_PREFIX=../../opencv4.8.0-build-mac64-osx13 \
    #     -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib4.8.0/modules \
    #     -D VTK_DIR=\"${vtkdir}\" ../../opencv4.8.0
    #     -D WITH_OPENCL=ON \
    #     -D OPENCV_ENABLE_NONFREE=ON \
    #     -D WITH_GSTREAMER=ON \
    #     -D WITH_FFMPEG=ON \
    #     -D WITH_OPENCL_SVM=OFF \
    #     -D CUDA_ARCH_BIN=6.1 \
    #     -D WITH_OPENCLAMDFFT=OFF \
    #     -D WITH_LIBDC1394=ON \
    #     -D WITH_OPENCLAMDBLAS=OFF \
    #     -D BUILD_opencv_cudaarithm=ON \
    #     -B build_cudaarithm \
    #     -D PYTHON3_EXECUTABLE=$(which python3) \
    #     -D PYTHON3_INCLUDE_DIR=\"${PY3_INCLUDE_DIR}\" \
    #     -D PYTHON3_LIBRARY=\"${PY3_LIBRARY}\" \
    #     -D PYTHON3_PACKAGES_PATH=\"${PY3_PACKAGES_PATH}\" \
    #     ../../opencv_contrib4.8.0/modules/cudaarithm"

    Installing running make 4.8.0
    rm -rf build4.8.0.log
    touch build4.8.0.log
    chown "${SUDO_USER}" build4.8.0.log

    su - "${SUDO_USER}" -c "cd \"${_cwd}/opencv4.8.0/build\" && make  -j$(sysctl -n hw.logicalcpu) 2>&1 | tee build4.8.0.log"
    # make VERBOSE=1  -j$(sysctl -n hw.logicalcpu) 2>&1 | tee build4.8.0.log
    _err=$?
    if ( grep -qi 'error' build4.8.0.log ) ; then
    {
      grep -i 'error' build4.8.0.log > errors4.8.0.log
    }
    fi
    if ( grep -qi 'undefined reference' build4.8.0.log ) ; then
    {
      grep -i 'undefined reference' build4.8.0.log > reference4.8.0.log
    }
    fi
    if ( grep -qi 'undefined' build4.8.0.log ) ; then
    {
      grep -i 'undefined' build4.8.0.log > undefined4.8.0.log
    }
    fi
    if ( grep -qi 'missing' build4.8.0.log ) ; then
    {
      grep -i 'missing' build4.8.0.log > missing4.8.0.log
    }
    fi
    if ( grep -qi 'failed' build4.8.0.log ) ; then
    {
      grep -i 'failed' build4.8.0.log > failed4.8.0.log
    }
    fi
    if [ ${_err} -gt 0 ] ; then
    {
      rm -rf ../../opencv4.8.0-build-mac64-osx13 &
      failed " $0:$LINENO while running make for opencv4.8.0  removing build target also _err:${_err}"
    }
    fi
    make install

  }
  fi

  cd "${_cwd}"

  Checking build_lastest
  if it_exists_with_spaces /usr/local/bin/opencv_version ; then
  {
    pwd
    echo "opencv latest version test:" 
    opencv_version
    passed "found dir /usr/local/bin/opencv_version already build"
  }
  else
  {
    Installing  build_lastest
    rm -rf opencv/build
    mkdir -p opencv/build
    cd opencv/build
    


    
    cmake -D CMAKE_BUILD_TYPE=Release \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
        -D WITH_OPENCL=ON \
        -D WITH_OPENCL_SVM=OFF \
        -D WITH_OPENCLAMDFFT=OFF \
        -D WITH_OPENCLAMDBLAS=OFF \
        -D PYTHON3_EXECUTABLE=$(which python3) \
        -D PYTHON3_INCLUDE_DIR="${PY3_INCLUDE_DIR}" \
        -D PYTHON3_LIBRARY="${PY3_LIBRARY}" \
        -D PYTHON3_PACKAGES_PATH="${PY3_PACKAGES_PATH}" \
        ..
  

    Installing running make latest 
    echo "" > build_lastest.log
    make -j$(sysctl -n hw.logicalcpu) 2>&1 | tee build_lastest.log
    _err=$?
    if ( grep -qi 'error' build_lastest.log ) ; then
    {
      grep -i 'error' build_lastest.log > errors_lastest.log
    }
    fi
    if ( grep -qi 'undefined reference' build_lastest.log ) ; then
    {
      grep -i 'undefined reference' build_lastest.log > reference_lastest.log
    }
    fi
    if ( grep -qi 'undefined' build_lastest.log ) ; then
    {
      grep -i 'undefined' build_lastest.log > undefined_lastest.log
    }
    fi
    if ( grep -qi 'missing' build_lastest.log ) ; then
    {
      grep -i 'missing' build_lastest.log > missing_lastest.log
    }
    fi
    if ( grep -qi 'failed' build_lastest.log ) ; then
    {
      grep -i 'failed' build_lastest.log > failed_lastest.log
    }
    fi
    if [ ${_err} -gt 0 ] ; then
    {
      failed "$0:$LINENO while running make for opencv lastest also _err:${_err}"
    }
    fi
    make install

    su - "${SUDO_USER}" -c "python3 -c 'import cv2; print(cv2.__version__)'"
  }
  fi
  echo "install brew stuff ?"
  echo "install brew stuff ?"
  echo "install brew stuff ?"
  echo "install brew stuff ?"
  echo "install brew stuff ?"
  echo "install brew stuff ?"
  echo "install brew stuff ?"
  echo "install brew stuff ?"


  su - "${SUDO_USER}" -c "brew install cmake pkg-config"
  su - "${SUDO_USER}" -c "brew install ffmpeg"
  

} # end _darwin__64


_git_clone() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO  _git_clone CUDA" && echo -e "${RESET}" && return 0' ERR
  local _source="${1}"
  local _target="${2}"
  Checking "${SUDO_USER}" "${_target}"
  pwd
  if  it_exists_with_spaces "${_target}" ; then # && it_exists_with_spaces "${_target}/.git" ; then
  {
    if it_exists_with_spaces "${_target}/.git" ; then
    {
      cd "${_target}"
      if git config pull.rebase false ; then
      {
        warning Could not git config pull.rebase false
      }
      fi
      if git fetch  ; then
      {
        warning Could not git fetch
      }
      fi
      if git pull  ; then
      {
        warning Could not git pull
      }
      fi
    }
    fi
  }
  else
  {
    if git clone "${_source}" "${_target}"  ; then
    {
      warning Could not git clone "${_source}" "${_target}"
    }
    fi
  }
  fi
  chown -R "${SUDO_USER}" "${_target}"

} # end _git_clone


_darwin__arm64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "_darwin__arm64 Procedure not yet implemented. I don't know what to do."
} # end _darwin__arm64

_tar() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "_tar Procedure not yet implemented. I don't know what to do."
} # end tar

_windows__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "_windows__64 Procedure not yet implemented. I don't know what to do."
} # end _windows__64

_windows__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "_windows__32 Procedure not yet implemented. I don't know what to do."
} # end _windows__32



 #--------/\/\/\/\-- 2tasks_templates_sudo/opencv_gpu …install_opencv_gpu.bash” -- Custom code-/\/\/\/\-------



 #--------\/\/\/\/--- 0tasks_base/main.bash ---\/\/\/\/-------
_main() {
  determine_os_and_fire_action "${*:-}"
} # end _main

echo params "${*:-}"
_main "${*:-}"
_err=$?
if [[ ${_err} -gt 0 ]] ; then
{
  echo "ERROR IN ▲ E ▲ R ▲ R ▲ O ▲ R ▲ $0 script"
  exit ${_err}
}
fi
echo "🥦"
exit 0
