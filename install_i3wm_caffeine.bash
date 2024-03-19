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





 #--------\/\/\/\/-- tasks_templates_sudo/i3wm_caffeine …install_i3wm_caffeine.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/bash

_package_list_installer() {
  # Sample usage
  #   local package packages="
  #  autoconf
  #  bison
  # "
  # _package_list_installer "${packages}"

  # trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local package packages="${@}"
  trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO _package_list_installer i3wm" && echo -e "${RESET}" && return 0' ERR

  if ! install_requirements "linux" "${packages}" ; then
  {
    warning "installing requirements. ${CYAN} attempting to install one by one"
    while read package; do
    {
      [ -z ${package} ] && continue
      if ! install_requirements "linux" "${package}" ; then
      {
        _err=$?
        if [ ${_err} -gt 0 ] ; then
        {
          echo -e "${RED}"
          echo failed to install requirements "${package}"
          echo -e "${RESET}"
        }
        fi
      }
      fi
    }
    done <<< "${packages}"
  }
  fi
} # end _package_list_installer
_git_clone() {
  # Sample usage
  #    _git_clone "https://github.com/i3wm/i3wm.git" "${USER_HOME}/.i3wm"
  #
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO  _git_clone KERL" && echo -e "${RESET}" && return 0' ERR
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
_add_variables_to_bashrc_zshrc(){
  local I3WM_SH_CONTENT='

  # I3WM
  if [[ -e "'${USER_HOME}'/.i3wm" ]] ; then
  {
    export I3WM_ROOT="'${USER_HOME}'/.i3wm"
    export PATH="'${USER_HOME}'/bin:${PATH}"
    export PATH="'${USER_HOME}'/.i3wm/bin:${PATH}"
    eval "$(i3wm init -)"
  }
  fi
  '
  trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO _add_variables_to_bashrc_zshrc i3wm" && echo -e "${RESET}" && return 0' ERR
  Checking "${I3WM_SH_CONTENT}"
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
    _if_not_contains "${USER_HOME}/${INITFILE}"  "# I3WM" ||  echo "${I3WM_SH_CONTENT}" >> "${USER_HOME}/${INITFILE}"
    _if_not_contains "${USER_HOME}/${INITFILE}"  "I3WM_ROOT" ||  echo "${I3WM_SH_CONTENT}" >> "${USER_HOME}/${INITFILE}"
    _if_not_contains "${USER_HOME}/${INITFILE}"  "i3wm init" ||  echo "${I3WM_SH_CONTENT}" >> "${USER_HOME}/${INITFILE}"
  }
  done <<< "${INITFILES}"
  # type i3wm
  Checking "export PATH=\"${USER_HOME}/.i3wm/bin:${PATH}\" "
  export PATH="${USER_HOME}/.i3wm/bin:${PATH}"
  chown -R "${SUDO_USER}" "${USER_HOME}/.i3wm"
  cd "${USER_HOME}/.i3wm/bin"
  eval "$("${USER_HOME}"/.i3wm/bin/i3wm init -)"

  # i3wm doctor
  # i3wm install -l
  # i3wm install 2.6.5
  # i3wm global 2.6.5
  # i3wm rehash
  # ruby -v
} # _add_variables_to_bashrc_zshrc
_debian_flavor_install() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  apt update -y
  trap 'echo -e "${RED}" && echo "ERROR err:$_err failed $0:$LINENO _debian_flavor_install i3wm" && echo -e "${RESET}" && return 0' ERR

	local base_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
  local config_dir="${SUDO_HOME}/.config"
  local temp_dir="/tmp/caffeine-installer"
  if [[ ! -d "${temp_dir}" ]]; then
	{
    mkdir -p "${temp_dir}"
  }
	fi
  directory_exists_with_spaces "${temp_dir}"
  chown -R "${SUDO_USER}" "${temp_dir}"

	if [[ ! -d "${config_dir}" ]]; then
  {
 		mkdir -p "${config_dir}";
	}
	fi
  directory_exists_with_spaces "${config_dir}"
  chown -R "${SUDO_USER}" "${config_dir}"

  local package packages="
	  # install apt pre requisites
    xserver-xorg
    xdm
    pulseaudio
    pulseaudio-utils
    pavucontrol
    dunst
    libnotify-bin
    dbus-x11
    vim
    git
    screen
    curl
    mc
    rsync
    aptitude
    source-highlight

    htop
    nload
    nmap
    net-tools
    build-essential
    autoconf
    automake
    autogen

    figlet
    cowsay
    w3m
    mediainfo

    unoconv
    odt2txt
    catdoc

    python-pip
    python3-pip
    numlockx
    xclip
    rxvt-unicode-256color
    arandr
    acpi

    rofi
    compton
    redshift
    xbacklight

    # mpd
    mpc
    ncmpcpp

    zathura
    mpv
    feh
    scrot
    # vlc
    vim-gtk
    gtk2-engines-pixbuf
    gtk2-engines-murrine


    # install i3
    ibxcb1-dev
    libxcb-keysyms1-dev
    libpango1.0-dev
    libxcb-util0-dev

    libxcb-icccm4-dev
    libyajl-dev
    libstartup-notification0-dev

    libxcb-randr0-dev
    libev-dev
    libxcb-cursor-dev
    libxcb-xinerama0-dev
    libxcb-xkb-dev
    libxkbcommon-dev
    libxkbcommon-x11-dev
    libxcb-xrm0
    libxcb-xrm-dev
    libxcb-shape0-dev
    autoconf
    bison
    build-essential
    libssl-dev
    libyaml-dev
    libreadline6-dev
    zlib1g-dev
    libncurses5-dev
    libffi-dev
    libgdbm6
    libgdbm-dev
  "
  _package_list_installer "${packages}"
  ensure pip3 or "Canceling until pip3 is installed. try install_pyenv.bash"
  su - "${SUDO_USER}" -c 'pip3 install py3status python-mpd2'

  if [[ ! -d /usr/share/backgrounds ]]; then
    mkdir -p /usr/share/backgrounds
  fi
  directory_exists_with_spaces /usr/share/backgrounds
  file_exists_with_spaces "${base_dir}/global/usr/share/backgrounds/caffeine.png"
  su - "${SUDO_USER}" -c 'cp '"${base_dir}/global/usr/share/backgrounds/caffeine.png"' /usr/share/backgrounds'
  file_exists_with_spaces /usr/share/backgrounds/caffeine.png

  if [[ ! -d /usr/share/fonts/caffeine-font ]]; then
    mkdir -p /usr/share/fonts/caffeine-font
  fi
  directory_exists_with_spaces /usr/share/fonts/caffeine-font
  su - "${SUDO_USER}" -c 'cp -R '"${base_dir}/global/usr/share/fonts/caffeine-font"' /usr/share/fonts/'
  file_exists_with_spaces /usr/share/fonts/readme.md

  Checking "# Set urxvt as default terminal"
  update-alternatives --set x-terminal-emulator /usr/bin/urxvt

  Checking "# Disable system-wide MPD"
  if [ -f /etc/mpd.conf ]; then
    rm /etc/mpd.conf;
  fi
  systemctl disable mpd

  Checking "# urxvt plugins"
  if [ ! -d /usr/lib/urxv/perl ]; then
    mkdir -p /usr/lib/urxvt/perl
  fi
  directory_exists_with_spaces /usr/lib/urxvt/perl
  su - "${SUDO_USER}" -c 'cp -R '"${base_dir}/global/usr/lib/urxvt/perl/*"' /usr/lib/urxvt/perl/'
  file_exists_with_spaces /usr/lib/urxvt/perl/keyboard-select
  file_exists_with_spaces /usr/lib/urxvt/perl/resize-font


  _git_clone "https://github.com/Airblader/i3" "${temp_dir}"

  directory_exists_with_spaces "${temp_dir}/i3"
  cd "${temp_dir}/i3"
  if [ -d build/ ]; then
    rm -rf build/
  fi

  mkdir build/ || return 1

  autoreconf --force --install || return 1
  cd build || return 1
  ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers || return 1
  make || return 1
  make install || return 1

  _package_list_installer "
   i3lock
   i3status
  "

  if [[ -f "${SUDO_HOME}/.Xresources" ]];        then
    rm "${SUDO_HOME}/.Xresources"
  fi
  if [[ -d "${config_dir}/i3" ]];           then
    rm -rf "${config_dir}/i3"
  fi
  if [[ -d "${config_dir}/i3status" ]];     then
    rm -rf "${config_dir}/i3status"
  fi
  if [[ -d "${config_dir}/mpd" ]];          then
    rm -rf "${config_dir}/mpd"
  fi
  if [[ -d "${config_dir}/mpv" ]];          then
    rm -rf "${config_dir}/mpv"
  fi
  if [[ -d "${config_dir}/scripts" ]];      then
    rm -rf "${config_dir}/scripts"
  fi

  ln -s "${base_dir}/home/.Xresources"          "${SUDO_HOME}/.Xresources"
  ln -s "${base_dir}/home/.config/i3"           "${config_dir}/i3"
  ln -s "${base_dir}/home/.config/i3status"     "${config_dir}/i3status"
  ln -s "${base_dir}/home/.config/mpd"          "${config_dir}/mpd"
  ln -s "${base_dir}/home/.config/mpv"          "${config_dir}/mpv"
  ln -s "${base_dir}/home/.config/scripts"      "${config_dir}/scripts"
  ln -s "${base_dir}/home/.config/dunst"        "${config_dir}/dunst"

  echo "exec i3 > ${SUDO_HOME}/.xsession"

  xdg-mime default feh.desktop image/jpeg
  xdg-mime default feh.desktop image/png
  su - "${SUDO_USER}" -c 'xdg-mime default feh.desktop image/jpeg'
  su - "${SUDO_USER}" -c 'xdg-mime default feh.desktop image/png'

  # _add_variables_to_bashrc_zshrc
  # ensure i3wm or "Canceling until i3wm did not install"
  # su - "${SUDO_USER}" -c 'i3wm install -l'
} # end _debian_flavor_install


_redhat_flavor_install() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  dnf build-dep i3 -vy --allowerasing
  # dnf install  -y openssl-devel
  # Batch Fedora 37
  local base_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
  local config_dir="${SUDO_HOME}/.config"
  local temp_dir="/tmp/caffeine-installer"
  if [[ ! -d "${temp_dir}" ]]; then
	{
    mkdir -p "${temp_dir}"
  }
	fi
  directory_exists_with_spaces "${temp_dir}"
  chown -R "${SUDO_USER}" "${temp_dir}"

	if [[ ! -d "${config_dir}" ]]; then
  {
 		mkdir -p "${config_dir}";
	}
	fi
  directory_exists_with_spaces "${config_dir}"
  chown -R "${SUDO_USER}" "${config_dir}"

  # Fedora 37
	local package packages="
	  # install dnf pre requisites
    xdm
		pavucontrol
	  gdbm-devel
		gdbm-libs
		dunst
		dbus-x11
		vim
		git
		screen
		curl
		mc
		rsync
		source-highlight
		htop
		nload
		nmap
		net-tools
		autoconf
		automake
    autogen
    figlet
    cowsay
    w3m
    mediainfo
    unoconv
    odt2txt
    catdoc
    python-pip
    python3-pip
		numlockx
    xclip
    arandr
    acpi
    rofi
    picom
    redshift
    xbacklight
    # mpd
    mpc
    ncmpcpp
		zathura
    mpv
    feh
    scrot
    # vlc
    vim
		gdk-pixbuf2
    rust-gdk-pixbuf-sys-devel
    rust-gdk-pixbuf-devel
    gdk-pixbuf2-devel
    gdk-pixbuf2-modules
    gdk-pixbuf2-xlib
    gtk-murrine-engine


    # install i3
		libxcb-devel
    xcb-util-keysyms
    xcb-util
    xcb-util-devel
    xcb-util-keysyms-devel
		xcb-util-cursor
    xcb-util-cursor-devel
    rust-xcb+xinerama-devel
		rust-xcb+xkb-devel
    xcb-util-xrm-devel
    xcb-util-xrm
    libxkbcommon
		libxkbcommon-devel
    rust-xkbcommon+default-devel
    rust-xkbcommon-devel

    rust-xkbcommon+wayland-devel
    libxkbcommon-x11-devel
    libxkbcommon-x11
		rust-xcb+shape-devel
    rust-xcb+randr-devel
    libev-devel
    rust-xcb+genericevent-devel
		pango
    pango-devel
    rust-pango-devel
    yajl
    yajl-devel
    startup-notification
		startup-notification-devel
    arandr
    xrandr
    rust-xcb+randr-devel
    libXrandr-devel
		autorandr
    lxrandr
    rust-x11+xrandr-devel
    libXrandr
    xbacklight
  "
  _package_list_installer "${packages}"

	ensure pip3 or "Canceling until pip3 is installed. try install_pyenv.bash"
	su - "${SUDO_USER}" -c 'pip3 install py3status python-mpd2'

	if [[ ! -d /usr/share/backgrounds ]]; then
    mkdir -p /usr/share/backgrounds
  fi
	directory_exists_with_spaces /usr/share/backgrounds
	file_exists_with_spaces "${base_dir}/global/usr/share/backgrounds/caffeine.png"
	cp "${base_dir}/global/usr/share/backgrounds/caffeine.png" /usr/share/backgrounds
	chown -R "${SUDO_USER}" /usr/share/backgrounds
	file_exists_with_spaces /usr/share/backgrounds/caffeine.png

	if [[ ! -d /usr/share/fonts/caffeine-font ]]; then
    mkdir -p /usr/share/fonts/caffeine-font
  fi
  directory_exists_with_spaces /usr/share/fonts/caffeine-font
	cp -R "${base_dir}"/global/usr/share/fonts/caffeine-font/* /usr/share/fonts/
	cp -R "${base_dir}"/global/usr/share/fonts/caffeine-font/*.* /usr/share/fonts/
	chown -R "${SUDO_USER}" /usr/share/fonts/
	file_exists_with_spaces /usr/share/fonts/readme.md

  Checking "# Set urxvt as default terminal"
	update-alternatives --set x-terminal-emulator /usr/bin/urxvt

	Checking "# Disable system-wide MPD"
	if [ -f /etc/mpd.conf ]; then
		rm /etc/mpd.conf;
	fi
  systemctl disable mpd

	Checking "# urxvt plugins"
	if [ ! -d /usr/lib/urxv/perl ]; then
    mkdir -p /usr/lib/urxvt/perl
  fi
  directory_exists_with_spaces /usr/lib/urxvt/perl
	cp -R "${base_dir}"/global/usr/lib/urxvt/perl/* /usr/lib/urxvt/perl/
	cp -R "${base_dir}"/global/usr/lib/urxvt/perl/*.* /usr/lib/urxvt/perl/
	chown -R "${SUDO_USER}" /usr/lib/urxvt/perl/
  file_exists_with_spaces /usr/lib/urxvt/perl/keyboard-select
	file_exists_with_spaces /usr/lib/urxvt/perl/resize-font


  _git_clone "https://github.com/Airblader/i3" "${temp_dir}"

	directory_exists_with_spaces "${temp_dir}/i3"
  cd "${temp_dir}/i3"
  if [ -d build/ ]; then
    rm -rf build/
  fi

	mkdir build/ || return 1

	autoreconf --force --install || return 1
	cd build || return 1
  ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers || return 1
  make || return 1
	make install || return 1

	_package_list_installer "
	 i3lock
 	 i3status
	"

	if [[ -f "${SUDO_HOME}/.Xresources" ]];        then
    rm "${SUDO_HOME}/.Xresources"
  fi
  if [[ -d "${config_dir}/i3" ]];           then
    rm -rf "${config_dir}/i3"
  fi
  if [[ -d "${config_dir}/i3status" ]];     then
    rm -rf "${config_dir}/i3status"
  fi
  if [[ -d "${config_dir}/mpd" ]];          then
    rm -rf "${config_dir}/mpd"
  fi
  if [[ -d "${config_dir}/mpv" ]];          then
    rm -rf "${config_dir}/mpv"
  fi
  if [[ -d "${config_dir}/scripts" ]];      then
    rm -rf "${config_dir}/scripts"
  fi

  ln -s "${base_dir}/home/.Xresources"          "${SUDO_HOME}/.Xresources"
  ln -s "${base_dir}/home/.config/i3"           "${config_dir}/i3"
  ln -s "${base_dir}/home/.config/i3status"     "${config_dir}/i3status"
  ln -s "${base_dir}/home/.config/mpd"          "${config_dir}/mpd"
  ln -s "${base_dir}/home/.config/mpv"          "${config_dir}/mpv"
  ln -s "${base_dir}/home/.config/scripts"      "${config_dir}/scripts"
  ln -s "${base_dir}/home/.config/dunst"        "${config_dir}/dunst"

  echo "exec i3 > ${SUDO_HOME}/.xsession"

  xdg-mime default feh.desktop image/jpeg
  xdg-mime default feh.desktop image/png
  su - "${SUDO_USER}" -c 'xdg-mime default feh.desktop image/jpeg'
	su - "${SUDO_USER}" -c 'xdg-mime default feh.desktop image/png'

  # _add_variables_to_bashrc_zshrc
  # ensure i3wm or "Canceling until i3wm did not install"
  # su - "${SUDO_USER}" -c 'i3wm install -l'
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
  local _parameters="${*-}"
	_redhat_flavor_install "${_parameters-}"
} # end _fedora__64

_fedora_37__64(){
  # trap "echo Error:$?" ERR INT
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local _parameters="${*-}"
  local -i _err=0
	_redhat_flavor_install "${_parameters-}"
} # end _fedora_37__64

_fedora_39__64(){
  # trap "echo Error:$?" ERR INT
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local _parameters="${*-}"
  local -i _err=0
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



 #--------/\/\/\/\-- tasks_templates_sudo/i3wm_caffeine …install_i3wm_caffeine.bash” -- Custom code-/\/\/\/\-------



 #--------\/\/\/\/--- tasks_base/main.bash ---\/\/\/\/-------
_main() {
  determine_os_and_fire_action "${*:-}"
} # end _main

echo params "${*:-}"
_main "${*:-}"

echo "🥦"
exit 0
