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
          echo "$0: tasks_base/sudoer.bash Loading locally"
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
            echo "$0: tasks_base/sudoer.bash Loading ${_library} from the net using curl "
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
            echo "$0: tasks_base/sudoer.bash Loading ${_library} from the net using wget "
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
        echo "1. sudologic $0: tasks_base/sudoer.bash Temp location ${_temp_dir}/${_library}"
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
  elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]] ; then
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
  elif [[ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]] || [[ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]] ; then
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



 #---------/\/\/\-- tasks_base/sudoer.bash -------------/\/\/\--------





 #--------\/\/\/\/-- tasks_templates_sudo/nvidia_sdk-manager …install_nvidia_sdk-manager.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/bash


_execute_project_command() {
  # Sample usage:
  #   _execute_project_command "${PROJECTREPO}" "bundle exec rake db:migrate db:migrate:emails db:migrate:credit_check "
  #   _execute_project_command "${PWD}" sdkmanager --cli  
	#
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local PROJECTREPO=${1}
  enforce_parameter_with_value           1        PROJECTREPO      "${PROJECTREPO}"     "path folder where Gemfile or project is located "
  local _command=${2}
  enforce_parameter_with_value           2        _command         "${_command}"        "bash command to run"
  local _parameters="${*:3}"  # grab all parameters after second
  # _command="$(sed 's/["]/\\\"/g' <<< "${_command}")"
  echo "_command:${_command}"
  su - "${SUDO_USER}" -c  "bash -c 'cd "${PROJECTREPO}" && ${_command} ${_parameters} '"
} # end _execute_project_command

check_run_command_as_root() {
  # Sample usage:
  #  check_run_command_as_root
  #
  [[ "${EUID:-${UID}}" == "0" ]] || return

# Allow Azure Pipelines/GitHub Actions/Docker/Concourse/Kubernetes to do everything as root (as it's normal there)
  [[ -f /.dockerenv ]] && return
  [[ -f /proc/1/cgroup ]] && grep -E "azpl_job|actions_job|docker|garden|kubepods" -q /proc/1/cgroup && return

  failed "Don't run this as root!"
}

__download_file_check_checksum() {
  # Sample usage: 
	#    __download_file_check_checksum .torch_22_jetson_6_python_3_10 "https://developer.download.nvidia.cn/compute/redist/jp/v60dp/pytorch/torch-2.2.0a0+6a974be.nv23.11-cp310-cp310-linux_aarch64.whl" 94e70c4f45211737174a3c0f0b791b479c5fd9a2955ba77f573d31c0273e485e
	local file_url_configuration="${1}"
	enforce_parameter_with_value           1        file_url_configuration      "${file_url_configuration}"     ".trained_model .torch_22_jetson_6_python_3_10 full path filename "
	if [[ ! -e "${file_url_configuration}" ]] ; then 
	{
		failed "file_url_configuration=file:${file_url_configuration}  does not exists"
	}
	fi
  local sample_url_download="${2}"
	enforce_parameter_with_value           2       sample_url_download         "${sample_url_download}"     "https://developer.download.nvidia.cn/compute/redist/jp/v60dp/pytorch/torch-2.2.0a0+6a974be.nv23.11-cp310-cp310-linux_aarch64.whl"
  local hash_check_sum_to_check_against="${3}"
	enforce_parameter_with_value           3       hash_check_sum_to_check_against "${hash_check_sum_to_check_against}"    "94e70c4f45211737174a3c0f0b791b479c5fd9a2955ba77f573d31c0273e48" 

 	local service_url="$(<"${file_url_configuration}")"
  enforce_parameter_with_value           1        service_url      "${service_url}"    "${sample_url_download}" 
  enforce_variable_with_value service_url  "${service_url}"
  local filename=$(basename "${service_url}")
  local -i _err=0
  if [[ -e  "${filename}" ]] ; then
  {
    passed "Already downloaded: ${filename}"
  }
  else
  {
    ensure curl or "curl is needed to connect to download stuff - Cannot continue"
    local passwords="$(<.env)"
    enforce_parameter_with_value           2        passwords      "${passwords}"     "--proxy-user user:password --user user:password"
    enforce_variable_with_value service_url  "${passwords}"
    curl $passwords -k $service_url
    _err=$?
    if [ ${_err} -gt 0 ] ; then
    {
      failed "while running curl above: curl  $passwords -k $service_url > \"${filename}\""
    }
    fi
  }
  fi
  Checking "checksum for ${filename}"
  file_exists_with_spaces "${filename}"
  local checksum=""
  checksum=$(sha256sum "${filename}" | cut -d' ' -f1)
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    failed "while running checksum above: sha256sum \"${filename}\""
  }
  fi
  if [[ "${checksum}" == "${hash_check_sum_to_check_against}" ]] ; then
  {
    passed "Checksum checks ${checksum}"
  }
  else
  {
    rm -rf ${filename}
    failed "removed file ${filename} Checksum DOES NOT check ${checksum}. Try again to download again"
  }
  fi
  echo "${filename}"
} # end __download_file_check_checksum

__passively_try_to_connect_to_wifi_but_continue_if_fails() {
	ensure nmcli or "nmcli is needed to connect ot wifi is not working - Install network-manager"
	Installing "Wifi"
	echo "REF: https://askubuntu.com/questions/461825/how-to-connect-to-wifi-from-the-command-line"
	Checking "list of saved connections"
	nmcli c 
	Checking "list of available wifi cards"
	nmcli d | grep wifi
	local _wifi_device=$(nmcli d | grep wifi | head -1 | cut -d' ' -f1)
	if [[ -z "${_wifi_device}" ]] ; then 
	{
		warning "could not find wifi device to connect to"
	  passed "Continuing with no WIFI to allow other things to install - Run this again when WIFI if avaible"
	} 
  else 
	{
	  Checking " list of available WiFi hotspots "
	  nmcli d wifi list
		local _ssid_name=$(nmcli d wifi list | grep agrivero  | grep '*' | head -1 | xargs |  sed 's/*//g' | xargs | cut -d' ' -f2)
		echo 'hello there' | tr 'a-z' 'n-za-m'
		echo 'hello there' | tr 'a-z' 'n-za-m' | tr 'a-z' 'n-za-m'
		local _ssid_password=$("")
    echo -n "hello there" | base64 |  tr 'a-z' 'n-za-m' | base64 -d 
    echo -n "hello there" | base64 |  tr 'a-z' 'n-za-m' | base64 -d | base64 | tr 'a-z' 'n-za-m' | base64 -d
		echo -n "hello there" | base64 | tr 'A-Z' 'N-ZA-M' | tr 'a-z' 'n-za-m'  |  base64 -d
    echo "REF: https://stackoverflow.com/questions/6441260/how-to-shift-each-letter-of-the-string-by-a-given-number-of-letters"
 		local _ssid_password='d³322+S¥œžzgn' 
		if [[ -z "${_ssid_name}" ]] ; then
    {
			warning "could not find wifi from the list "
			passed "Continuing with no WIFI connection"
		}
	  else
		{
		  nmcli d wifi con "${_ssid_name}" password  "agrivero.ai"
		}
		fi
	}
	fi
} # end __passively_try_to_connect_to_wifi_but_continue_if_fails



__check_net_work_connection() {
	trap 'return 1' ERR INT
	Checking "If network is reachable - TODO this is dumb considering we already did Struct_testing loading and apt update and install - TODO move this an starting point form the script"
	local _website='google.com'
	if (enforce_web_is_reachable  "${_website}" > /dev/null 2>&1 ) ; then # redirect all sdout sderr to /dev/null
	{
    passed "reached connection with ${_website}"
  }
  else
  {
    warning "ERROR count not connect to online required to continue"
    # [ $? -gt 0 ] && failed To connect git provider push  && exit 1
  }
  fi
} # end __check_net_work_connection
 


_debian_flavor_install() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  if ! __check_net_work_connection ; then
  {
    failed "$0:$LINENO Network Connection Not Responding !!!"
  }
  fi
  apt-get update -y
  if
    (
      install_requirements "linux" "
        base64
        unzip
        curl
        wget
        curl
        sudo
      "
    ) ; then
  {
    echo "Install run returned $?"
  }
  fi
  verify_is_installed "
    unzip
    curl
    wget
    tar
    curl
    sudo
    sha256sum
  "

  Installing "Downloading sdkmanager-2.1.0.11660"
  local _msg=""
  _msg="$(__download_file_check_checksum .env_deb "https://developer.download.nvidia.com/sdkmanager/secure/clients/sdkmanager-2.1.0.11660/sdkmanager_2.1.0-11660_amd64.deb?8nLD_V_5y-SqRHKhwoEzIDb80xM5gJzz17D5VXaGMXibHmkO8Ohnomi_-7-JQDk0Gf-Yqjo8ge5z9zTnlKpiBTr-JwveCu6iPNHXdCBRHvZyHPTV6fYk9kMKYSd0tBFYw00j7t267ssE5uGgv__RwfO4ZXWMrUHFMrCoczwOwkyuWBQRxjl_2gFnRf0n2-pV&t=eyJscyI6InJlZiIsImxzZCI6IlJFRi1naXRodWIuY29tLyJ9" "ca8e08922573521fd1525881069edf75b349ac68f707d06352d47e5c30bb21e3" 2>&1)"  # capture all sdout stdout input and output  sderrstderr
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    failed "while running Downloading sdkmanager-2.1.0.11660  __download_file_check_checksum() above _msg: '''${_msg}''' _err:${_err}"
  }
  fi

  local filename=$(echo "${_msg}" | tail -1)
  Installing "expected: Ubuntu 16.04 or 18.04 or 20.04 or 22.04: apt-get install ./sdkmanager_[version]-[build#]_amd64.deb -y"
  Installing "     got: Ubuntu 16.04 or 18.04 or 20.04 or 22.04: apt-get install ./${filename} -y"
  Installing "apt-get install ./${filename} -y"
  file_exists_with_spaces "${filename}"
  apt-get install "./${filename}" -y
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    failed "while installing above: dnf install \"${filename}\" -y --allowerasing"
  }
  fi

  Checking "Launch and login in browser.   https://developer.nvidia.com/sdk-manager
    From the SDK Manager launch screen, select the appropriate login tab for your account type, NVIDIA Developer (developer.nvidia.com) OR NVONLINE (partners.nvidia.com) and complete the login process.
    Select the Product Category you would like to install and follow the steps to complete the installation.
  "
  ensure sdkmanager or "sdkmanager was not installed. Install failed"
  _execute_project_command "${PWD}" sdkmanager --cli

} # end _debian_flavor_install

_redhat_flavor_install() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  if __check_net_work_connection ; then
  {
    failed "$0:$LINENO Network Connection Not Responding !!!"
  }
  fi
	dnf update -y
  if
    (
    install_requirements "linux" "
      unzip
      curl
      wget
      curl
      sudo
    "
    ) ; then
    {
      echo "Install run returned $?"
    }
  fi
  verify_is_installed "
    unzip
    curl
    wget
    tar
    curl
    sudo
    base64
    sha256sum
  "
  Installing "Downloading sdkmanager-2.1.0.11660"
  local _msg=""
  _msg="$(__download_file_check_checksum .env_rpm "https://developer.download.nvidia.com/sdkmanager/secure/clients/sdkmanager-2.1.0.11660/sdkmanager_2.1.0-11660.x86_64.rpm?0FK2On882zB__HEHhBkkf17UWcTX2BhfZKX0frK0RPgZuH3NpogKJYXrbDtIzTBXSECQGPtMxlQSNJlIgLsG2e_MpFXeeTYjsfAQNOZit8t14VMA_Pbg4_Ov19FYLsXM-z6HkasfZ_-ajZXf70oyVwclsqRfqoYWQznPH8_fdc7pV5G54LZ0qWpz83tz12VxOg==&t=eyJscyI6InJlZiIsImxzZCI6IlJFRi1naXRodWIuY29tLyJ9" "2bf7177d6377bf59aa396104fb4f09dc7682fbbd2a35da8951164a2b3f9adaf1" 2>&1)"  # capture all sdout stdout input and output  sderrstderr
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    failed "while running Downloading sdkmanager-2.1.0.11660  __download_file_check_checksum() above _msg: '''${_msg}''' _err:${_err}"
  }
  fi
  local filename=$(echo "${_msg}" | tail -1)
  Installing "expecting: CentOS/RHEL 8.0 or 8.2: dnf install ./sdkmanager_[version]-[build#].x86_64.rpm -y"
  Installing "      got: CentOS/RHEL 8.0 or 8.2: dnf install ./${filename} -y"
  Installing "dnf install ./${filename} -y --allowerasing"
  file_exists_with_spaces "${filename}"
  dnf install "./${filename}" -y --allowerasing
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    failed "while installing above: dnf install \"${filename}\" -y --allowerasing"
  }
  fi
 
  Checking "Launch and login in browser.   https://developer.nvidia.com/sdk-manager
    From the SDK Manager launch screen, select the appropriate login tab for your account type, NVIDIA Developer (developer.nvidia.com) OR NVONLINE (partners.nvidia.com) and complete the login process.
    Select the Product Category you would like to install and follow the steps to complete the installation.
  "
  ensure sdkmanager or "sdkmanager was not installed. Install failed"
  _execute_project_command "${PWD}" sdkmanager --cli



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

_fedora_37__64(){
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _fedora_37__64

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

_darwin__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "_darwin__64 Procedure not yet implemented. I don't know what to do."
} # end _darwin__64

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



 #--------/\/\/\/\-- tasks_templates_sudo/nvidia_sdk-manager …install_nvidia_sdk-manager.bash” -- Custom code-/\/\/\/\-------



 #--------\/\/\/\/--- tasks_base/main.bash ---\/\/\/\/-------
_main() {
  determine_os_and_fire_action "${*:-}"
} # end _main

echo params "${*:-}"
_main "${*:-}"

echo "🥦"
exit 0
