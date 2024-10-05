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
{
  echo "... realpath not found. Downloading REF:https://github.com/swarmbox/realpath.git "
  if [[ -n "${USER_HOME}" ]] ;  then
  {
    cd "${USER_HOME}" || echo "ERROR! failed realpath compile cd " && exit 1
  }
  else
  {
    cd "${HOME}" || echo "ERROR! failed realpath compile cd " && exit 1
  }
  fi
  git clone https://github.com/swarmbox/realpath.git
  _err=$?
  [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Builing realpath. returned error did not download or is installed err:$_err  \n \n  " && exit 1
  cd realpath || echo "ERROR! failed realpath compile cd " && exit 1
  make
  _err=$?
  [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Builing realpath. returned error did not download or is installed err:$_err  \n \n  " && exit 1
  sudo make install
  _err=$?
  [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Builing realpath. returned error did not download or is installed err:$_err  \n \n  " && exit 1
  _err=$?
  [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Builing realpath. returned error did not download or is installed err:$_err  \n \n  " && exit 1
}
else
{
  echo "... realpath exists .. check!"
}
fi
if ! ( command -v paeth >/dev/null 2>&1; )  ; then
{
  function paeth(){
  local path_to_file=""
  local -i _err=0
  path_to_file="${*}"
  if [[ ! -e "${path_to_file}" ]] ; then   # not found in current folder
  {
    path_to_file="$(pwd)/${*}"
    if [[ ! -e "${path_to_file}" ]] ; then  # add full pwd and see if finds it
    {
      path_to_file="$(which "${*}")"   # search in system $PATH and env system
      _err=$?
      if [ ${_err} -gt 0 ] ; then
      {
        if ! type  -f "${*}" >/dev/null 2>&1  ; then 
        {
          echo "is a function"
          type  -f "${*}"
        }
        fi
        >&2 echo "error 1. ${*} not found in ≤$(pwd)≥ or ≤\${PATH}≥ or ≤\$(env)≥ "
        exit 1  # not found, silent fail
      }
      fi
      path_to_file="$(realpath "$(which "${*}")")"   # updated realpath macos 20210902
      _err=$?
      if [ ${_err} -gt 0 ] ; then
      {
         if ! type  -f "${*}" >/dev/null 2>&1  ; then 
        {
          echo "is a function"
          type  -f "${*}"
        }
        fi
         >&2 echo "error 2. ${*} not found in ≤$(pwd)≥ or ≤\${PATH}≥ or ≤\$(env)≥ "
        exit 1  # not found, silent fail
      }
      fi
      if [[ ! -e "${path_to_file}" ]] ; then
      {
         if ! type  -f "${*}" >/dev/null 2>&1  ; then 
        {
          echo "is a function"
          type  -f "${*}"
        }
        fi
         >&2 echo "error 3. ${path_to_file} does not exist or is not accesible "
        exit 1  # not found, silent fail
      }
      fi
    }
    fi
  }
  fi
  path_to_file="$(realpath "${path_to_file}")"
  if ! type  -f "${*}" >/dev/null 2>&1  ; then 
  {
    echo "is also a function"
    type  -f "${*}"
  }
  fi
  
  echo "${path_to_file}"
  } # end paeth 
}
fi
if ! ( command -v realpath >/dev/null 2>&1; )  ; then
{
  echo "... realpath not found. and did not install . ABORTING"
}
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
    #                awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}"
    local output="$(awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}")"
    if ( command -v pygmentize >/dev/null 2>&1; )  ; then
    {
      echo "${output}" | pygmentize -g
    }
    else
    {
      echo "${output}"
    }
    fi
    # $(eval ${BASH_COMMAND}  2>&1; )
    # echo -e " ☠ ${LIGHTPINK} Offending message:  ${__bash_error} ${RESET}"  >&2
    exit 1
  }
  function source_library(){
    # Sample usage 
    #    if ( source_library "${provider}" ) ; then 
    #      failed
    #    fi
    local -i _DEBUG=${DEBUG:-0}
    local provider="${*-}"
    local structsource=""
      if [[  -e "${provider}" ]] ; then
      {
        structsource="""$(<"${provider}")"""
        _err=$?
        if [ $_err -gt 0 ] ; then
        {
          >&2 echo -e "#\n #\n# 4.1 WARNING Loading ${provider}. Occured while running 'source' err:$_err  \n \n  "
          return 1
        }
        fi
	if (( _DEBUG )) ; then
          >&2 echo "# $0: 0tasks_base/sudoer.bash Loading locally"
        fi
        echo """${structsource}"""
        return 0
      }
      fi
      >&2 echo -e "\n 4.2 nor found  ${provider}. 'source' err:$_err  \n  "
      return 1
  } # end source_library
  function load_library(){
    local _library="${1:-struct_testing}"
    local -i _DEBUG=${DEBUG:-0}
    local -i _err=0
    if [[ -z "${1}" ]] ; then
    {
       echo "Must call with name of library example: struct_testing execute_command"
       exit 1
    }
    fi
    trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
      local providers="
/home/${SUDO_USER-}/_/clis/execute_command_intuivo_cli/${_library-}
/Users/${SUDO_USER-}/_/clis/execute_command_intuivo_cli/${_library-}
/home/${USER-}/_/clis/execute_command_intuivo_cli/${_library-}
/Users/${USER-}/_/clis/execute_command_intuivo_cli/${_library-}
${HOME-}/_/clis/execute_command_intuivo_cli/${_library-}
"
      local provider=""
      local -i _loaded=0
      local -i _found=0 
      local structsource
      while read -r provider ; do
      {
        [[ -z "${provider}" ]] && continue
        [[ ! -e "${provider}" ]] && continue
	_loaded=0
	_found=0
	structsource="""$(source_library "${provider}")"""
        _err=$?
        _loaded=1
	_found=1
        if [ $_err -gt 0 ] ; then
        {
          echo -e "\n \n 4.1 WARNING Loading ${_library}. Occured while running 'source' err:$_err  \n \n  "
          _loaded=0
	  _found=0
        }
        fi
      }
      done <<< "${providers}"

#       provider="$HOME/_/clis/execute_command_intuivo_cli/${_library}"
#       if [[ -n "${SUDO_USER:-}" ]] && [[ -n "${HOME:-}" ]] && [[ "${HOME:-}" == "/root" ]] && [[ !  -e "${provider}"  ]] ; then
#       {
#         provider="/home/${SUDO_USER}/_/clis/execute_command_intuivo_cli/${_library}"
#       }
#       elif [[ -z "${USER:-}" ]] && [[ -n "${HOME:-}" ]] && [[ "${HOME:-}" == "/root" ]] && [[ !  -e "${provider}"  ]] ; then
#       {
#         provider="/home/${USER}/_/clis/execute_command_intuivo_cli/${_library}"
#       }
#       fi
#       echo "$0: ${provider}"
#       echo "$0: SUDO_USER:${SUDO_USER:-nada SUDOUSER}: USER:${USER:-nada USER}: ${SUDO_HOME:-nada SUDO_HOME}: {${HOME:-nada HOME}}"
      
      if (( ! _loaded )) ; then 
        if ( command -v curl >/dev/null 2>&1; )  ; then
          if (( _DEBUG )) ; then
            echo "$0: 0tasks_base/sudoer.bash Loading ${_library} from the net using curl "
          fi
	  _loaded=0
          structsource="""$(curl https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/${_library}  -so -   2>/dev/null )"""  #  2>/dev/null suppress only curl download messages, but keep curl output for variable
          _err=$?
	  _loaded=1
          if [ $_err -gt 0 ] ; then
          {
            echo -e "\n \n  ERROR! Loading ${_library}. running 'curl' returned error did not download or is empty err:$_err  \n \n  "
	    _loaded=0
            exit 1
          }
          fi
        elif ( command -v wget >/dev/null 2>&1; ) ; then
          if (( _DEBUG )) ; then
            echo "$0: 0tasks_base/sudoer.bash Loading ${_library} from the net using wget "
          fi
	  _loaded=0
          structsource="""$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/${_library} -O -   2>/dev/null )"""  #  2>/dev/null suppress only wget download messages, but keep wget output for variable
          _err=$?
	  _loaded=1
          if [ $_err -gt 0 ] ; then
          {
            echo -e "\n \n  ERROR! Loading ${_library}. running 'wget' returned error did not download or is empty err:$_err  \n \n  "
	    _loaded=0
            exit 1
          }
          fi
        else
          echo -e "\n \n 2  ERROR! Loading ${_library} could not find local, wget, curl to load or download  \n \n "
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
    #                awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}"
    local output="$(awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}")"
    if ( command -v pygmentize >/dev/null 2>&1; )  ; then
    {
      echo "${output}" | pygmentize -g
    }
    else
    {
      echo "${output}"
    }
    fi

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
    #               awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}"
    local output="$(awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}")"
    if ( command -v pygmentize >/dev/null 2>&1; )  ; then
    {
      echo "${output}" | pygmentize -g
    }
    else
    {
      echo "${output}"
    }
    fi

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
    #               awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}"
    local output="$(awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}")"
    if ( command -v pygmentize >/dev/null 2>&1; )  ; then
    {
      echo "${output}" | pygmentize -g
    }
    else
    {
      echo "${output}"
    }
    fi

    # $(eval ${BASH_COMMAND}  2>&1; )
    # echo -e " ☠ ${LIGHTPINK} Offending message:  ${__bash_error} ${RESET}"  >&2
    exit ${__trapped_INT_num}
  }
  trap  '_trap_on_INT $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  INT



 #---------/\/\/\-- 0tasks_base/sudoer.bash -------------/\/\/\--------





 #--------\/\/\/\/-- 2tasks_templates_sudo/loanlink_api …install_loanlink_api.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/bash

set -u

_git_clone() {
  local _source="${1}"
  local _target="${2}"
  Checking "${SUDO_USER}" "${_target}"
  pwd
  if  it_exists_with_spaces "${_target}" && it_exists_with_spaces "${_target}/.git" ; then
  {
    cd "${_target}"
		if ( git config pull.rebase false ) ; then
		{
	    warning "could not git config pull.rebase false"
    }
		fi
    if ( git fetch -f origin master:master ) ; then
		{
	    warning "could not git fetch -f origin master:master"
    }
		fi
		if ( git fetch -f origin main:main ) ; then
		{
	    warning "could not git fetch -f origin main:main"
    }
		fi
		if ( git fetch  ) ; then
		{
	    warning "could not git fetch"
    }
		fi
		if ( git pull ) ; then
		{
	    warning "could not git pull"
    }
		fi
		if ( git fetch --tags origin ) ; then
		{
	    warning "could not git fetch --tags origin"
    }
		fi
  }
  else
  {
		if ( git clone "${_source}" "${_target}" ) ; then
		{
      warning "could not git clone \"${_source}\" \"${_target}\"  "
		}
		fi
  }
  fi
  chown -R "${SUDO_USER}" "${_target}"

} # end _git_clone

PROJECT_DIR_F=""

_find_project_location_PROJECT_DIR_F() {
		local _target_project=""
    Checking "location of project "
    local _list_posssibles="
		   ${USER_HOME}/_/work/finlink/projects
		   ${USER_HOME}/_/work/finlink
		   /repo/work/finlink/projects
		"
		local one=""
		while read -r one ; do
		{
			[[ -z "${one}" ]] && continue
 		  if it_exists_with_spaces "${one}" ; then
		  {
        _target_project="${one}"
				break
		  }
		  fi
		}
    done <<< "${_list_posssibles}"

  [[ -z "${one}" ]] && warning "Could not find/determine location of project" && return 1

		passed "found of project dir ${_target_project}"
		PROJECT_DIR_F="${_target_project}"
		return 0

} # end _find_project_location_PROJECT_DIR_F

_debian_flavor_install() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  if (
  install_requirements "linux" "
    base64
    unzip
    curl
    tar
    wget
    build-essential
    libpq-dev
    nodejs
    # postgresql-client-12
    shared-mime-info
    redis
  "
  ); then
    {
      wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
    }
  fi
  verify_is_installed "
    base64
    unzip
    curl
    wget
    tar
    wget
  "
  _find_project_location_PROJECT_DIR_F
  local PROJECTSBASEDIR="${PROJECT_DIR_F}"
  local PROJECTREPO="${PROJECT_DIR_F}/loanlink-api"
  local PROJECTGITREPO ="git@github.com:LoanLink/loanlink-api.git"
  local PROJECTGITREPOBRANCH="main"

  if [[ ! -f "${PROJECTREPO}/.step1_brew_check_requirements_postgress_12_install"  ]] ; then
  {
    Working "Step .step1_brew_check_requirements_postgress_12_install"
    _brew_check_requirements_postgress_12_install
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step1_brew_check_requirements_postgress_12_install\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step2_attempt_to_download_docker"  ]] ; then
  {
    # _attempt_to_download_docker amd64
    # _attempt_to_download_docker arm64
    Working "Step .step2_attempt_to_download_docker"
    _attempt_to_download_docker $(uname -m)
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step2_attempt_to_download_docker\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step3_rbenv_check"  ]] ; then
  {
    Working "Step .step3_rbenv_check"
    _rbenv_check
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step3_rbenv_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step4_ruby_check"  ]] ; then
  {
    Working "Step .step4_ruby_check"
    _ruby_check "${PROJECTSBASEDIR}" "${PROJECTREPO}" "${PROJECTGITREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step4_ruby_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step5_bundle_check"  ]] ; then
  {
    Working "Step .step5_bundle_check"
    _bundle_check "${PROJECTREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step5_bundle_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step6_env_check"  ]] ; then
  {
    Working "Step .step6_env_check"
    _env_check "${PROJECTREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step6_env_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step7_postgres_start_check"  ]] ; then
  {
    Working "Step .step7_postgres_start_check"
    _postgres_start_check "${PROJECTREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step7_postgres_start_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step8_migrate_check"  ]] ; then
  {
    Working "Step .step8_migrate_check"
    _migrate_check "${PROJECTREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step8_migrate_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step9_vpn_check"  ]] ; then
  {
    Working "Step .step9_vpn_check"
    _vpn_check "${PROJECTREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step9_vpn_check\" "
  }
  fi


} # end _debian_flavor_install


PROJECT_DIR_F=""  # GLOBAL
+ set -E -o functrace
+ sudo cp ~/jetson-files/deepstream-6.3_6.3.0-1_arm64.deb /media/jetpack/flash/home/jetpack;
PROJECTSBASEDIR="${PROJECT_DIR_F-}" # global
PROJECTREPO="${PROJECT_DIR_F-}/processing_data" #  global
PROJECTGITREPO="git@github.com:agrivero-ai/processing_data.git" # global
PROJECTGITREPOBRANCH="will_experiments" # global

_redhat_flavor_install() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR

	Installing "--start"
  dnf remove openssl1.1-devel-1 openssl-devel-1 openssl-devel -y
	dnf builddep ruby-devel -y --allowerasing
  dnf builddep rbenv -y --allowerasing
  local -i _err=0
  if _find_project_location_PROJECT_DIR_F ; then
  {
    _err=0
  }
  else
  {
    _err=2
  }
  fi
  echo _err:$_err
  if [ ${_err} -gt 0 ] ; then
  {
		PROJECT_DIR_F="${USER_HOME}/_/work/finlink/projects"
    warning "could not find  project folder. Making one.. _err:${_err}"
    mkdir -p "${PROJECT_DIR_F}"
    chown -R "${SUDO_USER}" "${USER_HOME}/_/work"
    cd "${PROJECT_DIR_F}"
  }
  fi

  PROJECTSBASEDIR="${PROJECT_DIR_F}"
  PROJECTREPO="${PROJECT_DIR_F}/loanlink-api"
  PROJECTGITREPO="git@github.com:LoanLink/loanlink-api.git"
  PROJECTGITREPOBRANCH="main"

	# _find_project_location_PROJECT_DIR_F
  if [[ ! -f "${PROJECTREPO}/.step1_brew_check_requirements_postgress_12_install"  ]] ; then
  {
    Working "Step .step1_brew_check_requirements_postgress_12_install"
    _brew_check_requirements_postgress_12_install
    local _touch_name="\"${PROJECTREPO}/.step1_brew_check_requirements_postgress_12_install\""
    _execute_project_command "${PROJECTREPO}" "touch ${_touch_name} "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step3_rbenv_check"  ]] ; then
  {
    Working "Step .step3_rbenv_check"
    _rbenv_check
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step3_rbenv_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step4_ruby_check"  ]] ; then
  {
    Working "Step .step4_ruby_check"
    _ruby_check "${PROJECTSBASEDIR}" "${PROJECTREPO}" "${PROJECTGITREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step4_ruby_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step5_bundle_check"  ]] ; then
  {
    Working "Step .step5_bundle_check"
    _bundle_check "${PROJECTREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step5_bundle_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step6_env_check"  ]] ; then
  {
    Working "Step .step6_env_check"
    _env_check "${PROJECTREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step6_env_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step7_postgres_start_check"  ]] ; then
  {
    Working "Step .step7_postgres_start_check"
    _postgres_start_check "${PROJECTREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step7_postgres_start_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step8_migrate_check"  ]] ; then
  {
    Working "Step .step8_migrate_check"
    _migrate_check "${PROJECTREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step8_migrate_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step9_migrate_development_check"  ]] ; then
  {
    Working "Step .step9_migrate_development_check"
    _migrate_development_check "${PROJECTREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step9_migrate_development_check\" "
  }
  fi



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

_brew_you_said_no() {
		  warning "You said no. So we are keeping the current one"
			echo -e  "Try to run :
			\ncurl -O - https://raw.githubusercontent.com/zeusintuivo/task_intuivo_cli/master/install_brew.bash
			\nchmod -x install_brew.bash
			\n./install_brew.bash
			\n		"
			failed "You said no. install brew first then, or Check your .dot files"
			exit 1 # flow should stop

} # end _brew_you_said_no

_brew_source_profiles(){
  if [[ -f "${USER_HOME}/.profile" ]] ; then
	{
		if ! 	\. "${USER_HOME}/.profile" ; then
		{
			echo "
			If it complains about ''Begin Root or sudo'' on a certain line
			exclude that command with this code:

			if [ -n "${SUDO_USER:-}" ] ; then
			{
				 ...line to exclude from sudo /root user
			}
		  fi
      "
			failed something is wrong with file:"${USER_HOME}/.profile"
		}
		fi
	}
	fi
  if [[ -f "${USER_HOME}/.bash_profile" ]] ; then
	{
	  if ! 	\. "${USER_HOME}/.bash_profile" ; then
		{
			echo "
			If it complains about ''Begin Root or sudo'' on a certain line
			exclude that command with this code:

			if [ -n "${SUDO_USER:-}" ] ; then
			{
				 ...line to exclude from sudo /root user
			}
		  fi
      "
			failed something is wrong with file:"${USER_HOME}/.bash_profile"
		}
		fi
	}
	fi
	return 0
} # end _brew_source_profiles

_brew_check_requirements_postgress_12_install() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  Comment "### Prerequisites"

  Checking homebrew is installed
	_brew_source_profiles
	if (!  su - "${SUDO_USER}" -c "command -v brew" >/dev/null 2>&1; )  ; then
	{
	ensure_brew_in_linux_mac
  local -i _err=0
	local -i ret=0
	local -i found=0
	local _msg_info_list=""
	local _target_bin_brew=""
     _target_bin_brew="$(_find_executable_for "brew" "--prefix"  "bin/brew")"   # tail -1
                  _err=$?
  Checking "_target_bin_brew:<${_target_bin_brew}>"
  _target_bin_brew="$(echo "${_target_bin_brew}" | tail -1 | xargs)"
  ensure "${_target_bin_brew}" or "failed to check executable for brew <${_target_bin_brew}>"
  su - "${SUDO_USER}" -c "${_target_bin_brew} list --formula"
  if [ $_err -gt 0 ] ; then # failed
  {
    echo "${_target_bin_brew}"
    warning "failed to find brew"
		found=1
  }
  else
	{
		found=0
    _target_bin_brew="$(echo -n "${_target_bin_brew}" | tail -1)"
    enforce_variable_with_value _target_bin_brew "${_target_bin_brew}"
	  Checking "the found ${RED}${_target_bin_brew}${CYAN} to respond to ${YELLOW}brew list"
    # _msg_info_list="$(su - "${SUDO_USER}" -c "${_target_bin_brew} list  >/dev/null 2>&1")"
    #
		# ret=$?
    # [ $ret -gt 0 ] && found=1
    # [[ "$_msg_info_list" == *"No such"* ]] && found=1
    # [[ "$_msg_info_list" == *"nicht gefunden"* ]] && found=1
    # [[ "$_msg_info_list" == *"Error"*   ]] && found=1
	}
	fi


	if [ ${found} -eq 1  ]  ; then
  {
	  passed "Seems like brew is not installed. Should I attempt to RESET and resintall brew. WARNING this will remove the brew folder and all its installations [Y/n] ?"
	  if yes_or_no ; then  # using then so that return 1 will not trigger trap
  	{
			_err=0 # yes
		}
		else
	  {
	    _err=1 # no
	  }
	  fi
    if [ $_err -gt 0 ] ; then # no
		{
			_brew_you_said_no
			exit 1 # added in case the above function fails
    }
		fi
		# else yes erase brew
  	passed "You said ${RED} YES ERASE BREW ${YELLOW} Confirm again please [Y/n] ?"
	  if yes_or_no ; then  # using then so that return 1 will not trigger trap
  	{
      _err=0 # yes
		}
		else
		{
	    _err=1 # no
	  }
	  fi
    if [ $_err -gt 0 ] ; then # no
		{
			_brew_you_said_no
			exit 1 # added in case the above function fails
    }
		fi
		# else yes
  	passed "You said ${RED} YES ${CYAN} twice ${YELLOW} "
    Installing Erasing, Reseting and Re installing homebrew / linuxBrew
    local DOWNLOADFOLDER="$(_find_downloads_folder)"
    local TARGET_URL="https://raw.githubusercontent.com/zeusintuivo/task_intuivo_cli/master/install_brew.bash"
    local CODENAME=install_brew.bash
    _do_not_downloadtwice   "${TARGET_URL}"  "${DOWNLOADFOLDER}"  "${CODENAME}"
    chmod a+x "${CODENAME}"
    cd  "${DOWNLOADFOLDER}"
		# Cannot run as su - because it will complain not having tty for sudo
    # su - "${SUDO_USER}" -c "${DOWNLOADFOLDER}/${CODENAME}"
    export NONINTERACTIVE=1
		export HAVE_SUDO_ACCESS=1
		if ! "${DOWNLOADFOLDER}/${CODENAME}" ; then
		{
			echo "${RED} ERROR ${CYAN}Failed to run installer, is as if you said no"
			_brew_you_said_no
			exit 1 # added in case the above function fails
		}
		fi
		_brew_source_profiles

		wait
  } # not found
  fi
  } # not command -v brew
	fi
  # ensure brew or "Homebrew is required to continue "

  Comment "### install_requirements  darwin"
  Comment LINENO:$LINENO  local _requirements=
  local -i _err=0
	local _requirements="
      shared-mime-info
      libpq
      redis
      ruby-build
  "
  Comment LINENO:$LINENO install_requirements
  if ( ! install_requirements "brew" " ${_requirements}"   ); then
  {
    Comment LINENO:$LINENO failed install_requirements
    failed "to install some or one of ::\" ${_requirements}\":: "
  }
  else
  {

    Comment LINENO:$LINENO else install_requirements
    # postgresql@14
#     cat << EOF > "${USER_HOME}/custom-initdb.conf"
# # Set the default user and role name to "postgres"
# default_authz = 'postgres'

# # Set the locale to the desired value, e.g., 'en_US.UTF-8'
# lc_messages = 'en_US.UTF-8'
# lc_monetary = 'en_US.UTF-8'
# lc_numeric = 'en_US.UTF-8'
# lc_time = 'en_US.UTF-8'

# # Specify any other custom settings you need
# EOF
    local __pg="postgresql@12"
    # su - "${SUDO_USER}" -c "brew services"
    su - "${SUDO_USER}" -c "${_target_bin_brew} services"
    if (su - "${SUDO_USER}" -c "${_target_bin_brew}  services" 2>&1 | grep "${__pg}" >/dev/null 2>&1; )  ; then
    {
			echo -e "${PURPLE_BLUE} === ${__pg} ${BRIGHT_BLUE87}installed. Remove and reinstall${PURPLE_BLUE} ${RESET}?"
      if yes_or_no ; then
			{
        _err=0
			}
		  else
			{
			  _err=1
			}
			fi
      if [ $_err -gt 0 ] ; then # no
      {
        passed "You said no. So we are keeping the current one"
				Installing things that might be need it
        su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' ${_target_bin_brew} reinstall shared-mime-info"
        su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' ${_target_bin_brew} reinstall libpq"
        su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' ${_target_bin_brew} reinstall ruby-build"
        su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' ${_target_bin_brew} reinstall redis"
      }
		  else
			{
				passed "You said yes ERASE Are you sure ?"
	      if yes_or_no ; then
  			{
          _err=0
		  	}
		    else
	  		{
	  		  _err=1
	  		}
	  		fi
        if [ $_err -gt 0 ] ; then # no
				{
					passed "You said no. So we are keeping the current one"
        }
        else
        {
          Working "removing" "current version ${__pg} "
          ( su - "${SUDO_USER}" -c "${_target_bin_brew} remove ${__pg}" )
          if [ "$(pgrep postgres 2>&1  | wc -l | xargs )" -gt 0 ]  ; then
          {
            killall postgres
          }
          fi
			    Installing "${__pg}"
          su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' ${_target_bin_brew} install shared-mime-info"
          su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' ${_target_bin_brew} install libpq"
          su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' ${_target_bin_brew} install ruby-build"
          su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' ${_target_bin_brew} install redis"
          su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' ${_target_bin_brew} install  postgresql@12"
				}
				fi
			}
			fi
    }
	  else
	  {
			Installing "${__pg}"
      su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' ${_target_bin_brew} install shared-mime-info"
      su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' ${_target_bin_brew} install libpq"
      su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' ${_target_bin_brew} install ruby-build"
      su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' ${_target_bin_brew} install redis"
      su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' ${_target_bin_brew} install postgresql@12"
	  }
    fi
    # Working "initdb" "--username=postgres --pgdata=/opt/homebrew/var/postgresql@12 --auth-host=md5 --auth-local=md5 --lc-collate=en_US.UTF-8 --lc-ctype=en_US.UTF-8 --lc-messages=en_US.UTF-8 --lc-monetary=en_US.UTF-8 --lc-numeric=en_US.UTF-8 --lc-time=en_US.UTF-8 --pwfile=\"${USER_HOME}/custom-initdb.conf\" "
    # Comment "Here's what this command does:" '

    # # --username=postgres: Specifies the PostgreSQL superuser name as "postgres." ' '
    # # --pgdata=/usr/local/var/postgres: Specifies the data directory for PostgreSQL, which is the default location used by Homebrew. ' '
    # # --auth-host=md5 and --auth-local=md5: Specifies that authentication should use the "md5" method. ' '
    # # --lc-collate, --lc-ctype, --lc-messages, --lc-monetary, --lc-numeric, and --lc-time: Set the locale settings as defined in your custom configuration file. ' '
    # # --authz=postgres: Specifies the default authorization identifier. ' '
    # # --pwfile=-: Indicates that the password will be read from stdin. ' '
    # #
		local -i _err=0
		_target_brew_base_pg="$(_try_more_times_find "
var/${__pg}
var/postgres
var/postgresql
")"
    _err=$?
    if [ $_err -gt 0 ] ; then # failed
    {
			echo "${_target_brew_base_pg}"
      passed "Failed to find brw var"
		}
		fi

		_target_brew_base_pg="$(echo -n "${_target_brew_base_pg}" | tail -1)"
		enforce_variable_with_value _target_brew_base_pg "${_target_brew_base_pg}"

		passed found of var "${__pg} = ${_target_brew_base_pg}"

		Message "preparing some files inside ${USER_HOME} with some defaults"

    # try 2
    cat << EOF > "${USER_HOME}/custom-pg_hba_postgres12.conf"

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
# IPv6 local connections:
host    all             all             ::1/128                 trust
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     trust
host    replication     all             127.0.0.1/32            trust
host    replication     all             ::1/128                 trust

# Allow "postgres" user to connect with a password
host    all             postgres         127.0.0.1/32            md5
EOF

    cat << EOF > "${USER_HOME}/custom-pg_ident_postgres12.conf"

# Map system user "postgres" to PostgreSQL role "postgres"
postgres       postgres              postgres
EOF
    echo "psql -d postgres -h 0.0.0.0 -U ${SUDO_USER}  -W

    SHOW config_file;
                       config_file
    -------------------------------------------------
     ${_target_brew_base_pg}/postgresql.conf
    (1 row)
    "
    echo "psql -d postgres -h 0.0.0.0 -U ${SUDO_USER} -W

    SHOW hba_file;
                      hba_file
    ---------------------------------------------
     ${_target_brew_base_pg}/pg_hba.conf
    (1 row)
    "
    # su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' cat /opt/homebrew/opt/postgresql@12/share/postgresql@12/pg_hba.conf.sample \"${USER_HOME}/custom-pg_hba_postgres12.conf\" >   /opt/homebrew/var/postgresql@12/pg_hba.conf "

		local _context="${_target_brew_base_pg}/pg_hba.conf"
 		if file_exists_with_spaces "${_context}" ; then
		{
  	  Question "File ${_context}  already exists. Overwrite  ?"
	    if yes_or_no ; then
  		{
         _err=0
		  }
		  else
	  	{
	  	  _err=1
	  	}
	  	fi
      if [ $_err -gt 0 ] ; then # no
			{
			  passed "You said no. We are not touching ${_context}"
      }
      else
      {
			  passed "You said YES. We are reseting file ${_context}"
				CURRENTDATE=$(date +%Y%m%d)
				CURRENTTIME="$(date +%H:%M)"
        cp "${_context}" "${_context}_${CURRENTDATE}_${CURRENTTIME}"
        su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' cat  \"${USER_HOME}/custom-pg_hba_postgres12.conf\" >   ${_context}"
			}
			fi
		}
	  else
		{
      passed "Reseting file ${_context}"
 			CURRENTDATE=$(date +%Y%m%d)
			CURRENTTIME="$(date +%H:%M)"
      cp "${_context}" "${_context}_${CURRENTDATE}_${CURRENTTIME}"
      su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' cat  \"${USER_HOME}/custom-pg_hba_postgres12.conf\" >   ${_context}"
		}
		fi

		echo "psql -d postgres -h 0.0.0.0 -U ${SUDO_USER} -W

    SHOW ident_file;
                      ident_file
    -----------------------------------------------
     ${_target_brew_base_pg}/pg_ident.conf
    (1 row)
    "
    # su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' cat /opt/homebrew/opt/postgresql@12/share/postgresql@12/pg_ident.conf.sample \"${USER_HOME}/custom-pg_hba_postgres12.conf\" >  /opt/homebrew/var/postgresql@12/pg_ident.conf "
 		local _context="${_target_brew_base_pg}/pg_ident.conf"
 		if file_exists_with_spaces "${_context}" ; then
		{
  	  Question "File ${_context}  already exists. Overwrite  ?"
	    if yes_or_no ; then
  		{
        _err=0
		  }
		  else
	  	{
	  	  _err=1
	  	}
	  	fi
      if [ $_err -gt 0 ] ; then # no
			{
			  passed "You said no. We are not touching ${_context}"
      }
      else
      {
			  passed "You said YES. We are reseting file ${_context}"
 				CURRENTDATE=$(date +%Y%m%d)
				CURRENTTIME="$(date +%H:%M)"
        cp "${_context}" "${_context}_${CURRENTDATE}_${CURRENTTIME}"
        su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' cat \"${USER_HOME}/custom-pg_hba_postgres12.conf\" >  ${_context}"
			}
			fi
		}
	  else
		{
		  passed "You said YES. We are reseting file ${_context}"
 			CURRENTDATE=$(date +%Y%m%d)
			CURRENTTIME="$(date +%H:%M)"
      cp "${_context}" "${_context}_${CURRENTDATE}_${CURRENTTIME}"
      su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' cat \"${USER_HOME}/custom-pg_hba_postgres12.conf\" >  ${_context}"
		}
		fi
		_brew_postgres_redis_restart
  }
  fi

  # verify_is_installed "
  #   shared-mime-info
  # "
} # end _brew_check_requirements_postgress_12_install


_brew_postgres_redis_restart() {

    Message "brew services restart  postgresql@12 "
    # anounce_command brew services restart  "postgresql@12"
    # anounce_command su - "${SUDO_USER}" -c "brew services restart  postgresql@12 "
    local -i _err=0
		local _target_bin_brew=""
		_target_bin_brew="$(_find_executable_for "brew" "--prefix"  "bin/brew")"   # tail -1
                  _err=$?
  Checking "_target_bin_brew:<${_target_bin_brew}>"
  _target_bin_brew="$(echo "${_target_bin_brew}" | tail -1 | xargs)"
  ensure "${_target_bin_brew}" or "failed to check executable for brew <${_target_bin_brew}>"
  su - "${SUDO_USER}" -c "${_target_bin_brew} list --formula"
    _err=$?
    if [ $_err -gt 0 ] ; then # failed
    {
      echo "${_target_bin_brew}"
      failed "to find brew"
    }
    fi
    _target_bin_brew="$(echo -n "${_target_bin_brew}" | tail -1)"
    enforce_variable_with_value _target_bin_brew "${_target_bin_brew}"

		if su - "${SUDO_USER}" -c "${_target_bin_brew} services restart  postgresql@12 " ; then
		{
			warning failed brew services restart  postgresql@12
		}
		fi
		Message "LINE:$LINENO ${_target_bin_brew} services restart  redis"
    # anounce_command brew services restart  redis
		# anounce_command su - "${SUDO_USER}" -c "brew services restart  redis "
		if su - "${SUDO_USER}" -c "${_target_bin_brew} services restart  redis " ; then
		{
			warning failed brew ${_target_bin_brew} services restart  redis
		}
		fi
		Message "${_target_bin_brew} services"
    # anounce_command brew services
    # anounce_command su - "${SUDO_USER}" -c "brew services "
    if su - "${SUDO_USER}" -c "${_target_bin_brew} services " ; then
		{
			warning brew ${_target_bin_brew} services
		}
		fi
    Message Here is your postgress running
		ps axt | grep postgres
		Message Here is your redis running
    ps axt | grep redis


} # end _brew_postgres_redis_restart

_docker_mac() {
      Comment "### Downloading docker.dmg ${TARGETSYSTEM}"
      local DOCKERIN=$(curl -fsSL https://www.docker.com/products/docker-desktop/)
      enforce_variable_with_value DOCKERIN "${DOCKERIN}"
      local DMGURL=$(echo "${DOCKERIN}" | sed s/\</\\n\\n\</g | sed "s/&apos;/\'/g" | sed 's/&nbsp;/ /g'  | grep 'docker' | grep 'https://' | grep 'dmg' | sed s/\ /\\n/g | grep 'https://' | cut -d'"' -f2 | sort | uniq | grep "${TARGETSYSTEM}" | xargs)
      enforce_variable_with_value DMGURL "${DMGURL}"
      local DOWNLOADFOLDER="${USER_HOME}/Downloads"
      local TARGET_URL="${DMGURL}"
      local CODENAME=Docker.dmg
      Downloading "${CODENAME}" from   "${TARGET_URL}" into  "${DOWNLOADFOLDER}"
      _do_not_downloadtwice   "${TARGET_URL}"  "${DOWNLOADFOLDER}"  "${CODENAME}"
      echo ret:$?
      open  "${DOWNLOADFOLDER}" &
      echo ret:$?
      warning "Make sure you install docker if not found in  \"${DOWNLOADFOLDER}\" \n get it from [Install Docker](https://docs.docker.com/get-docker/"
      echo ret:$?

} # end _docker_mac




_docker_cygwin() {
	echo "I do not know how to do _docker_cygwin"
} # end _docker_cygwin



_docker_linux() {
	echo "I do not know how to do _docker_linux"
} # end _docker_linux



_docker_msys() {
	echo "I do not know how to do _docker_msys"
} # end _docker_msys



_attempt_to_download_docker() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local TARGETSYSTEM=${1}
  enforce_parameter_with_value           1        TARGETSYSTEM      "${TARGETSYSTEM}"     "amd64 | arm64"

	case "$OSTYPE" in
    (darwin*) _docker_mac ;;
    (cygwin*) _docker_cygwin ;;
    (linux*) _docker_linux ;;
    (msys*) _docker_msys  ;;
    (*) failed "Platform $OSTYPE not supported"
    return 0 ;;
  esac
} # end _attempt_to_download_docker




_rbenv_check() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR

  Checking rbenv is installed
  if ( ! su - "${SUDO_USER}" -c 'command -v rbenv' >/dev/null 2>&1; )  ; then
  {
    Installing rbenv
    local TARGET_URL="https://raw.githubusercontent.com/zeusintuivo/task_intuivo_cli/master/install_rbenv.bash"
    Skipping "${CYAN}Based on \n${RED}\n/bin/bash -c \"\$(curl -fsSL "${TARGET_URL}")\"\n${RESET}${CYAN}\n and doing structed tested."
    local DOWNLOADFOLDER="$(_find_downloads_folder)"
    local CODENAME=install_rbenv.bash
    _do_not_downloadtwice   "${TARGET_URL}"  "${DOWNLOADFOLDER}"  "${CODENAME}"
    chmod a+x "${CODENAME}"
    local NEWNAME=install_rbenv.bash
    mv "${DOWNLOADFOLDER}/${CODENAME}" "${USER_HOME}/${NEWNAME}"
    chmod a+x "${NEWNAME}"
    cd  "${USER_HOME}"
    Installing "${USER_HOME}/${NEWNAME}"
    su - "${SUDO_USER}" -c "${USER_HOME}/${NEWNAME}"
    wait
  }
  fi
  \. "${USER_HOME}/.profile"
  ensure rbenv or "rbenv ruby version manager is required to continue  [rbenv](https://github.com/sstephenson/rbenv) and Ruby. "
} # end _rbenv_check




_ruby_check() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local PROJECTSBASEDIR=${1}
  enforce_parameter_with_value           1        PROJECTSBASEDIR     "${PROJECTSBASEDIR}"    "one dir before clone to"
  local PROJECTREPO=${2}
  enforce_parameter_with_value           2        PROJECTREPO         "${PROJECTREPO}"        "path folder to clone to"
  local PROJECTGITREPO=${3}
  enforce_parameter_with_value           3        PROJECTGITREPO      "${PROJECTGITREPO}"     "a git url "


  Checking that libpq/bin can be found
	local -i _err=0
	local _libpg_bin=""
	if _libpg_bin="$(_try_more_times_find "
opt/libpq/bin")" ; then
  {
	  _err=0
		passed "Found libpq/bin"
	}
  else
	{
	  _err=1
		warning "Failed to find libpq/bin"
	}
	fi

  if [ $_err -gt 0 ] ; then # failed
  {
	  echo "${_libpg_bin}"
    failed "to find opt/libpq/bin"
	}
	fi
	_libpg_bin="$(echo -n "${_libpg_bin}" | tail -1)"
	passed "found of opt/libpq/bin  = ${_libpg_bin}"




	Checking clone "${PROJECTGITREPO}"
  mkdir -p  "${PROJECTSBASEDIR}"
  cd  "${PROJECTSBASEDIR}"
  _git_clone  "${PROJECTGITREPO}" "${PROJECTREPO}"



  Checking   Repo ruby version from  REPO Dir
  cd "${PROJECTREPO}"
  pwd
  Checking "ruby required in Gemfile   cat \"${PROJECTREPO}/Gemfile\" | grep ruby\\\ \\\'  | cut -d\\\' -f2 "
  local _RUBYVERSION=$(cat "${PROJECTREPO}/Gemfile" | grep ruby\ \'  | cut -d\' -f2)
  # set -x
  enforce_variable_with_value _RUBYVERSION "${_RUBYVERSION}"
  if [[ -z "${_RUBYVERSION}" ]] ; then
  {
    failed to get _RUBYVERSION:${_RUBYVERSION}
  }
  fi
  Comment "Required ruby:${_RUBYVERSION}"
  Checking "ruby installed su - \"${SUDO_USER}\" -c \"bash -c 'rbenv versions'\" "
  Comment LINENO:$LINENO local isrubynotinstalled=
  local isrubynotinstalled="$(su - "${SUDO_USER}" -c "bash -c 'rbenv versions'" | grep 'is not installed')"
  #enforce_variable_with_value isrubynotinstalled "${isrubynotinstalled}"
  Comment LINENO:$LINENO local isrubyinstalled=
  local isrubyinstalled="$(su - "${SUDO_USER}" -c "bash -c 'rbenv versions'" | grep "${_RUBYVERSION}")"
  #enforce_variable_with_value isrubyinstalled "${isrubyinstalled}"
  Comment LINENO:$LINENO -z \"\${isrubynotinstalled}\"=${isrubyinstalled}
  if [[ -z "${isrubynotinstalled}" ]] && [[ -z "${isrubyinstalled}" ]] ; then
  {
    echo "rbenv versions | grep ${_RUBYVERSION}   returned nothing"
    warning to get isrubyinstalled:${isrubyinstalled}
    Working Installing ruby: rbenv install ${_RUBYVERSION}
    su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" &&  ARCHFLAGS=\"-arch \$(uname -m)\" PATH=\"${_libpg_bin}:$PATH\"  rbenv install ${_RUBYVERSION} ' "
    Working Installing ruby: rbenv install 3.2.2
    su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" &&  ARCHFLAGS=\"-arch \$(uname -m)\" PATH=\"${_libpg_bin}:$PATH\"  rbenv install 3.2.2 ' "
  }
  fi
  isrubyinstalled="$(su - "${SUDO_USER}" -c "bash -c 'rbenv versions'" | grep "${_RUBYVERSION}")"
  #enforce_variable_with_value isrubyinstalled "${isrubyinstalled}"
  Comment LINENO:$LINENO -z \"\${isrubynotinstalled}\"=${isrubyinstalled}
  if [[ -z "${isrubynotinstalled}" ]] && [[ -z "${isrubyinstalled}" ]] ; then
  {
    echo "rbenv versions | grep ${_RUBYVERSION}   returned nothing"
    failed to get isrubyinstalled:${isrubyinstalled}
  }
  fi
  Comment LINENO:$LINENO \\t \"\${_RUBYVERSION}\" \\t == \*\"\${isrubyinstalled}\"\*
  Comment LINENO:$LINENO \\t \\t \\t   "${_RUBYVERSION}"  \\t == \* \\t "${isrubyinstalled}" \\t \*
  Comment LINENO:$LINENO -n \"\${isrubyinstalled}\"
  if [[ -n "${isrubyinstalled}" ]] &&  (echo ${isrubyinstalled} | grep "${_RUBYVERSION}" >/dev/null 2>&1; )  ; then
  {
    # set +x
    Comment "ruby installed appears to be installed  "
  }
  else
  {
    # set +x
    Comment "LINENO:$LINENO ------ else"
    su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" &&  ARCHFLAGS=\"-arch \$(uname -m)\" PATH=\"${_libpg_bin}:$PATH\"  rbenv install ${_RUBYVERSION} ' "
  }
	fi
  Comment LINENO:$LINENO local _RUBYLOCATION=
  # set +x
  local _RUBYLOCATION="$(su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" && rbenv which ruby ' ")"
  Comment LINENO:$LINENO  local _RUBYLOCATION="${_RUBYLOCATION}"
  enforce_variable_with_value _RUBYLOCATION "${_RUBYLOCATION}"
  "${_RUBYLOCATION}" -v


} # end _ruby_check



_bundle_check() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local PROJECTREPO=${1}
  enforce_parameter_with_value           1        PROJECTREPO         "${PROJECTREPO}"        "path folder to clone to"

  cd  "${PROJECTREPO}"

  Checking that libpq/bin can be found
	local -i _err=0
	local _libpg_bin=""
	if _libpg_bin="$(_try_more_times_find "
opt/libpq/bin")" ; then
  {
	  _err=0
		passed "Found libpq/bin"
	}
  else
	{
	  _err=1
		warning "Failed to find libpq/bin"
	}
	fi

  if [ $_err -gt 0 ] ; then # failed
  {
	  echo "${_libpg_bin}"
    failed "to find opt/libpq/bin"
	}
	fi
	_libpg_bin="$(echo -n "${_libpg_bin}" | tail -1)"
	passed "found of opt/libpq/bin  = ${_libpg_bin}"



  Comment "### gem update"
  su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" &&   ARCHFLAGS=\"-arch \$(uname -m)\" PATH=\"${_libpg_bin}:$PATH\" gem update --system' "


  Comment "### bundle"




  Checking "that opt/postgresql@12 can be found"
	local -i _err=0
	local _pg_lib=""
	_pg_lib="$(_try_more_times_find "
opt/postgresql@12
opt/postgres
opt/postgresql
")"
  _err=$?
  if [ $_err -gt 0 ] ; then # failed
  {
	  echo "${_pg_lib}"
    passed "Failed to find opt/postgresql@12"
	}
	fi
	_pg_lib="$(echo -n "${_pg_lib}" | tail -1)"
	passed "found of opt/postgresql@12  = ${_pg_lib}"



  export PATH="${_libpg_bin}:$PATH"



  export LDFLAGS="-L${_pg_lib}/lib"
  export CPPFLAGS="-I${_pg_lib}/include"

  export PKG_CONFIG_PATH="${_pg_lib}/lib/pkgconfig"

  Comment "### gem pg"
  if su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" &&   ARCHFLAGS=\"-arch \$(uname -m)\" PATH=\"${_libpg_bin}:$PATH\" gem install pg ' " ; then
	{
		warning Failed to gem install pg
	}
	fi

  Comment "### gem pg -v 1.2.3"
  if su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" &&   ARCHFLAGS=\"-arch \$(uname -m)\" PATH=\"${_libpg_bin}:$PATH\" gem install pg -v 1.2.3' " ; then
	{
		warning Failed to gem install pg -v 1.2.3
	}
	fi
  Comment "### gem activerecord-postgres_enum"
  if su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" &&   ARCHFLAGS=\"-arch \$(uname -m)\" PATH=\"${_libpg_bin}:$PATH\" gem install activerecord-postgres_enum ' " ; then
	{
		warning Failed to gem install activerecord-postgres_enum
	}
	fi
  Comment "### gem activerecord-postgres_enum"
  if su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" &&   ARCHFLAGS=\"-arch \$(uname -m)\" PATH=\"${_libpg_bin}:$PATH\" gem install activerecord-postgres_enum -v 1.6.0 ' " ; then
	{
		warning Failed to gem install activerecord-postgres_enum -v 1.6.0
	}
	fi
   Comment "### gem bundler 2.4.10"
  if su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" &&   gem install bundler:2.4.10 ' " ; then
	{
		warning Failed to gem install bundler:2.4.10
	}
	fi
  Comment "### gem bundler 2.3.17"
  if su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" &&   gem install bundler:2.3.17 ' " ; then
	{
		warning Failed to gem install bundler:2.3.17
	}
	fi
  Comment "### bundle bundle install"
  su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" && bundle config build.pg --with-pg-config=${_libpg_bin}/pg_config ' "
  if su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" &&   bundle install ' " ; then
	{
		warning "Failed to cd \"${PROJECTREPO}\" &&   bundle install"
	}
	fi
} # end _bundle_check




_add_postgress_to_bashrc_zshrc(){


  Checking "that opt/postgresql@12 can be found"
	local -i _err=0
	local _pg_lib=""
	_pg_lib="$(_try_more_times_find "
opt/postgresql@12
opt/postgres
opt/postgresql
")"
  _err=$?
  if [ $_err -gt 0 ] ; then # failed
  {
	  echo "${_pg_lib}"
    passed "Failed to find opt/postgresql@12"
	}
	fi
	_pg_lib="$(echo -n "${_pg_lib}" | tail -1)"
	passed "found of opt/postgresql@12  = ${_pg_lib}"



  local SH_CONTENT="

# POSTGRESS 12 - HOMEBREW
export PATH=\"${_pg_lib}/bin:\$PATH\"

"
  # trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO _add_variables_to_bashrc_zshrc nvm" && echo -e "${RESET}" && return 0' ERR
  echo "${SH_CONTENT}"
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
    (_if_not_contains  "${USER_HOME}/${INITFILE}" "${_pg_lib}/bin" ) || Configuring ${INITFILE}
    (_if_not_contains  "${USER_HOME}/${INITFILE}" "${_pg_lib}/bin" ) && Skipping configuration for ${INITFILE}
    #                   filename            value      || do this .............
    (_if_not_contains  "${USER_HOME}/${INITFILE}" "# POSTGRESS 12 - HOMEBREW" ) || echo -e "${SH_CONTENT}" >>"${USER_HOME}/${INITFILE}"
    (_if_not_contains  "${USER_HOME}/${INITFILE}" "${_pg_lib}/bin" ) || echo -e "${SH_CONTENT}" >>"${USER_HOME}/${INITFILE}"
  }
  done <<< "${INITFILES}"

} # end _add_postgress_to_bashrc_zshrc




_env_check() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local PROJECTREPO=${1}
  enforce_parameter_with_value           1        PROJECTREPO         "${PROJECTREPO}"        "path folder to clone to"

  cd  "${PROJECTREPO}"
  Comment "### _env_check"
  Comment "Create (copy) application environment file: "
  Comment Currently and temporary we have \`.env.test\` file as a template
  su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" && cp .env.test .env '"
} # end  _env_check




_execute_db() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local _database=${1}
  enforce_parameter_with_value           1        _database    "${_database}"        "database to connect to"
  local _sql=${2}
  enforce_parameter_with_value           2        _sql         "${_sql}"        "SQL to run"
  _sql="$(sed 's/["]/\\\"/g' <<< "${_sql}")"
  # _sql="$(sed "s/[']/\\\'/g" <<< "${_sql}")"

  local _command="psql -d ${_database} -h 0.0.0.0 -U ${SUDO_USER} -c \"${_sql}\" "
  # anounce_command su - "${SUDO_USER}"  -c "${_command}"
  Comment "su - \"${SUDO_USER}\"  -c \"${_command}\""
  su - "${SUDO_USER}"  -c "${_command}"

} # end _execute_db



_make_CREATE_ADVISORS() {
  # define CREATE_ADVISORS
  # endef

  echo "
      org = Organization.find_by_short_name(\"loanlink24-mortgage-gmbh\");
      org_admin = Role.find_by_name(\"Org Admin\");
      advisor = Role.find_by_name(\"Advisor\");
      Advisor.find_or_create_by!(email: \"it+orgadmin@loanlink.de\", organization: org, role: org_admin) do |adv|
          adv.short_name = \"longy\"
          adv.password = \"password1\";
          adv.password_confirmation = \"password1\";
          adv.enabled_features = { \"impersonate_advisor\"=>false, \"acts_as_advisor\"=>true };
          adv.name = \"Org Admin\"
      end;
      Advisor.find_or_create_by!(email: \"it+advisor@loanlink.de\", organization: org, role: advisor) do |adv|
          adv.short_name = \"shorty\";
          adv.password = \"password1\";
          adv.password_confirmation = \"password1\";
          adv.enabled_features = { \"acts_as_advisor\"=> true };
          adv.name = \"Ad Visor\"
      end
      Advisor.find_or_create_by!(email: \"it+jfb@loanlink.de\", organization: org, role: advisor) do |adv|
          adv.short_name = \"goldjunge\";
          adv.password = \"password1\";
          adv.password_confirmation = \"password1\";
          adv.enabled_features = { \"acts_as_advisor\"=> true };
          adv.name = \"Johann Friedrich Boettger\"
      end
      Advisor.all.each do |adv|
          adv.update!(password: \"password1\", password_confirmation: \"password1\")
          puts \"end\"
      end
      puts \"zuEnde\"
  " > _make_CREATE_ADVISORS.rb
  # export CREATE_ADVISORS

} # end _make_CREATE_ADVISORS




_execute_project_command() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local PROJECTREPO=${1}
  enforce_parameter_with_value           1        PROJECTREPO      "${PROJECTREPO}"     "path folder where Gemfile or project is located "
  local _command=${2}
  enforce_parameter_with_value           2        _command         "${_command}"        "bash command to run"
  # _command="$(sed 's/["]/\\\"/g' <<< "${_command}")"
  echo "_command:${_command}"
  su - "${SUDO_USER}" -c  "bash -c 'cd "${PROJECTREPO}" && ${_command} '"
} # end _execute_project_command





_migrate_development_check() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local PROJECTREPO=${1}
  enforce_parameter_with_value           1        PROJECTREPO      "${PROJECTREPO}"     "path folder where Gemfile or project is located "

  Message DEVELOPMENT

  local _advisors="$(cd "${PROJECTREPO}" && _make_CREATE_ADVISORS)"
  _execute_project_command "${PROJECTREPO}" "bundle exec rails runner --environment=development _make_CREATE_ADVISORS.rb"

  # Message PRODUCTION
  # _execute_project_command "${PROJECTREPO}" "bundle exec rails runner --environment=production _make_CREATE_ADVISORS.rb"
  # _execute_project_command "${PROJECTREPO}" "echo \"${_advisors}\" | RAILS_ENV=production bundle exec rails c"
  # _execute_project_command "${PROJECTREPO}" "echo \"${_reset_passwords}\" | RAILS_ENV=production bundle exec rails c"

} # end  _migrate_development_check




_postgres_usercreate_check() {
  local _db_user="${1}"
  enforce_parameter_with_value           1        _db_user      "${_db_user}"     "database user "

  local _db_pass="${2}"
  enforce_parameter_with_value           2        _db_pass      "${_db_pass}"     "database password "

  function ._user_exists() {
    # This function will check if a user already exists
    exists=$(su - "${SUDO_USER}" -c "psql -d postgres -h 0.0.0.0 -U ${SUDO_USER} -tAc \"SELECT 1 FROM pg_roles WHERE rolname='${_db_user}';\" " )
    echo $exists | xargs
  } # end ._user_exists

  function ._postgres_create_user() {
    # This function will create a user and role
    Working "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='${_db_user}'\" "
    Working "._user_exists $(._user_exists)"
    local -i _user_e="$(._user_exists)"
    if [ ${_user_e} -eq 1 ]; then
      echo "User ${_db_user} already exists."
    else
      echo "psql -d postgres -h 0.0.0.0 -U ${SUDO_USER}  -W
      psql -d postgres -h 0.0.0.0 -U ${SUDO_USER}  -W -c \"CREATE ROLE ${_db_user} WITH LOGIN PASSWORD '${_db_pass}';\"
      "
      _execute_db postgres "CREATE ROLE ${_db_user} WITH LOGIN PASSWORD '${_db_pass}' CREATEDB;"
      _execute_db postgres "ALTER USER ${_db_user} WITH SUPERUSER;"
      _execute_db postgres "ALTER USER ${_db_user} WITH Createrole;"
      _execute_db postgres "ALTER USER ${_db_user} WITH Createdb;"
      _execute_db postgres "ALTER USER ${_db_user} WITH replication;"
      _execute_db postgres "ALTER USER ${_db_user} WITH bypassrls;"
      _execute_db postgres "ALTER DATABASE postgres OWNER TO ${_db_user};"

      echo "User ${_db_user} created successfully."
    fi
  } # end _postgres_create_user

  # Check if the script is running as root or provide an option to run PostgreSQL commands without password
  if [[ "$EUID" -ne 0 ]]; then
      echo "Please run as root or a user with sudo privilege"
  else
      ._postgres_create_user
  fi
} # end _postgres_usercreate_check


_postgres_start_check() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local PROJECTREPO=${1}
  enforce_parameter_with_value           1        PROJECTREPO         "${PROJECTREPO}"        "path folder to clone to"

  cd  "${PROJECTREPO}"
  Comment "### _postgres_start_check"
  _brew_postgres_redis_restart


  _postgres_usercreate_check postgres postgres
  ps ax | grep postgres

} # end  _postgres_start_check



abort() {
  printf "%s\n" "$@" >&2
  exit 1
}



# Fail fast with a concise message when not using bash
# Single brackets are needed here for POSIX compatibility
# shellcheck disable=SC2292
if [ -z "${BASH_VERSION:-}" ]
then
  abort "Bash is required to interpret this script."
fi



# Check if script is run with force-interactive mode in CI
if [[ -n "${CI-}" && -n "${INTERACTIVE-}" ]]
then
  abort "Cannot run force-interactive mode in CI."
fi

# Check if both `INTERACTIVE` and `NONINTERACTIVE` are set
# Always use single-quoted strings with `exp` expressions
# shellcheck disable=SC2016
if [[ -n "${INTERACTIVE-}" && -n "${NONINTERACTIVE-}" ]]
then
  abort 'Both `$INTERACTIVE` and `$NONINTERACTIVE` are set. Please unset at least one variable and try again.'
fi

# Check if script is run in POSIX mode
if [[ -n "${POSIXLY_CORRECT+1}" ]]
then
  abort 'Bash must not run in POSIX mode. Please unset POSIXLY_CORRECT and try again.'
fi

# string formatters
if [[ -t 1 ]]
then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"
  do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

chomp() {
  printf "%s" "${1/"$'\n'"/}"
}

ohai() {
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

warn() {
  printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")"
}


# Check if script is run non-interactively (e.g. CI)
# If it is run non-interactively we should not prompt for passwords.
# Always use single-quoted strings with `exp` expressions
# shellcheck disable=SC2016
if [[ -z "${NONINTERACTIVE-}" ]]
then
  if [[ -n "${CI-}" ]]
  then
    warn 'Running in non-interactive mode because `$CI` is set.'
    NONINTERACTIVE=1
  elif [[ ! -t 0 ]]
  then
    if [[ -z "${INTERACTIVE-}" ]]
    then
      warn 'Running in non-interactive mode because `stdin` is not a TTY.'
      NONINTERACTIVE=1
    else
      warn 'Running in interactive mode despite `stdin` not being a TTY because `$INTERACTIVE` is set.'
    fi
  fi
else
  ohai 'Running in non-interactive mode because `$NONINTERACTIVE` is set.'
fi

# USER isn't always set so provide a fall back for the installer and subprocesses.
if [[ -z "${USER-}" ]]
then
  USER="$(chomp "$(id -un)")"
  export USER
fi

unset HAVE_SUDO_ACCESS # unset this from the environment

_user_has_have_sudo_access() {
  if [[ ! -x "/usr/bin/sudo" ]]
  then
    return 1
  fi

  local -a SUDO=("/usr/bin/sudo")
  if [[ -n "${SUDO_ASKPASS-}" ]]
  then
    SUDO+=("-A")
  elif [[ -n "${NONINTERACTIVE-}" ]]
  then
    SUDO+=("-n")
  fi

  if [[ -z "${HAVE_SUDO_ACCESS-}" ]]
  then
    if [[ -n "${NONINTERACTIVE-}" ]]
    then
      "${SUDO[@]}" -l mkdir &>/dev/null
    else
      "${SUDO[@]}" -v && "${SUDO[@]}" -l mkdir &>/dev/null
    fi
    HAVE_SUDO_ACCESS="$?"
  fi

  if [[ -n "${HOMEBREW_ON_MACOS-}" ]] && [[ "${HAVE_SUDO_ACCESS}" -ne 0 ]]
  then
    abort "Need sudo access on macOS (e.g. the user ${USER} needs to be an Administrator)!"
  fi

  return "${HAVE_SUDO_ACCESS}"
}

execute() {
  if ! "$@"
  then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}

execute_sudo() {
  local -a args=("$@")
  if _user_has_have_sudo_access
  then
    if [[ -n "${SUDO_ASKPASS-}" ]]
    then
      args=("-A" "${args[@]}")
    fi
    ohai "/usr/bin/sudo" "${args[@]}"
    execute "/usr/bin/sudo" "${args[@]}"
  else
    ohai "${args[@]}"
    execute "${args[@]}"
  fi
}



_migrate_check() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local PROJECTREPO=${1}
  enforce_parameter_with_value           1        PROJECTREPO         "${PROJECTREPO}"        "path folder to clone to"

  cd  "${PROJECTREPO}"
  Comment "### _migrate_check"
  Working "Dropping DBS and recreating, create"

  local _one _databases="
    coba-sap-archiving
    coba-loanlink-api
    coba-loanlink-emails
    coba-loanlink-credit_check
    loanlink-api
    loanlink-emails
    loanlink-credit_check
  "
  local _two _environments="
     development
     test
     production
  "
  local _db_user=postgres
  while read -r _two ; do
  {
    [[ -z "${_two}" ]] && continue;
    while read -r _one ; do
    {
      [[ -z "${_one}" ]] && continue;
      local _db_name="\"${_one}_${_two}\""
      _execute_db postgres "DROP DATABASE IF EXISTS ${_db_name};"
      _execute_db postgres "CREATE DATABASE ${_db_name} ENCODING = 'unicode' ;"
      _execute_db "${_db_name}" "ALTER USER ${_db_user} WITH SUPERUSER;"
      _execute_db "${_db_name}" "ALTER USER ${_db_user} WITH Createrole;"
      _execute_db "${_db_name}" "ALTER USER ${_db_user} WITH Createdb;"
      _execute_db "${_db_name}" "ALTER USER ${_db_user} WITH replication;"
      _execute_db "${_db_name}" "ALTER USER ${_db_user} WITH bypassrls;"
      _execute_db "${_db_name}" "ALTER DATABASE  ${_db_name} OWNER TO ${_db_user};"
      _execute_db "${_db_name}" "CREATE EXTENSION IF NOT EXISTS hstore;"
      _execute_db "${_db_name}" "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
      _execute_db "${_db_name}" "CREATE EXTENSION IF NOT EXISTS plpgsql;"
    }
    done <<< "${_databases}"
  }
  done <<< "${_environments}"

  # su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" && bundle exec rake db:reset  '"


  Message DEVELOPMENT


  Working "db:migrate"
  _execute_project_command "${PROJECTREPO}" "bundle exec rake db:migrate db:migrate:emails db:migrate:credit_check "
  # su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" && bundle exec rake db:migrate  '"
  # su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" && bundle exec rake db:create db:migrate  '"
  Working "db:seed db:migrate"

  _execute_project_command "${PROJECTREPO}" "bundle exec rails db:seed || bundle exec rails db:seed"
  _execute_project_command "${PROJECTREPO}" "bundle exec rails data:migrate"
   # bundle exec rails db:create db:migrate db:migrate:emails db:migrate:credit_check db:seed
  _execute_project_command "${PROJECTREPO}" "bundle exec rails users:update_roles"
  _execute_project_command "${PROJECTREPO}" "bundle exec rails transactional_emails:create_or_update_templates"

  # su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" && bundle exec rake db:seed data:migrate '"
  # su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" && RAILS_ENV=test bundle exec rake db:reset '"

  Message TEST

  Working "test db:test:prepare"
  _execute_project_command "${PROJECTREPO}" "RAILS_ENV=test bundle exec rake db:test:prepare"
  # su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" && RAILS_ENV=test bundle exec rake db:test:prepare '"

  # Message PRODUCTION
  # Working "production db:seed db:migrate"
  # _execute_project_command "${PROJECTREPO}" "RAILS_ENV=production bundle exec rake db:migrate db:migrate:emails db:migrate:credit_check "
  # _execute_project_command "${PROJECTREPO}" "RAILS_ENV=production bundle exec rails db:seed || bundle exec rails db:seed"
  # _execute_project_command "${PROJECTREPO}" "RAILS_ENV=production bundle exec rails data:migrate"
  # _execute_project_command "${PROJECTREPO}" "RAILS_ENV=production bundle exec rails users:update_roles"
  # _execute_project_command "${PROJECTREPO}" "RAILS_ENV=production bundle exec rails transactional_emails:create_or_update_templates"
  # su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" && RAILS_ENV=production bundle exec rake db:seed data:migrate'"

  # bundle exec rails db:drop
  # bundle exec rails db:create db:migrate db:migrate:emails
  # bundle exec rails db:seed || bundle exec rails db:seed
  # bundle exec rails data:migrate
  # bundle exec rails users:update_roles
  # bundle exec rails transactional_emails:create_or_update_templates

  Working COBA MODE

  # ersetzeindatei "${PROJECTREPO}/.env" "COBA_DEVELOPMENT_MODE=false" "COBA_DEVELOPMENT_MODE=mocked"
  Working "COBA MODE"
  if (  command -v gsed >/dev/null 2>&1 ; ) ; then
  {
    gsed -i -e s/"COBA_DEVELOPMENT_MODE=false"/"COBA_DEVELOPMENT_MODE=mocked"/g .env
  }
  elif ( !  su - "${SUDO_USER}" -c "command -v gsed" >/dev/null 2>&1; ) ; then
  {
    su - "${SUDO_USER}" -c 'gsed -i -e s/"COBA_DEVELOPMENT_MODE=false"/"COBA_DEVELOPMENT_MODE=mocked"/g .env'
  }
  elif (  command -v sed >/dev/null 2>&1 ; ) ; then
  {
    sed -i -e s/"COBA_DEVELOPMENT_MODE=false"/"COBA_DEVELOPMENT_MODE=mocked"/g .env
  }
  elif ( !  su - "${SUDO_USER}" -c "command -v sed" >/dev/null 2>&1; ) ; then
  {
    su - "${SUDO_USER}" -c 'sed -i -e s/"COBA_DEVELOPMENT_MODE=false"/"COBA_DEVELOPMENT_MODE=mocked"/g .env'
  }
  fi

  Message COBA DEVELOPMENT


  Working COBA "db:migrate"
  _execute_project_command "${PROJECTREPO}" "bundle exec rake db:migrate db:migrate:emails db:migrate:credit_check "
  # su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" && bundle exec rake db:migrate  '"
  # su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" && bundle exec rake db:create db:migrate  '"
  Working COBA "db:seed db:migrate"

  _execute_project_command "${PROJECTREPO}" "bundle exec rails db:seed || bundle exec rails db:seed"
  _execute_project_command "${PROJECTREPO}" "bundle exec rails data:migrate"
   # bundle exec rails db:create db:migrate db:migrate:emails db:migrate:credit_check db:seed
  _execute_project_command "${PROJECTREPO}" "bundle exec rails users:update_roles"
  _execute_project_command "${PROJECTREPO}" "bundle exec rails transactional_emails:create_or_update_templates"

  # su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" && bundle exec rake db:seed data:migrate '"
  # su - "${SUDO_USER}" -c "bash -c 'cd \"${PROJECTREPO}\" && RAILS_ENV=test bundle exec rake db:reset '"

  Message COBA TEST

  Working "test db:test:prepare"
  _execute_project_command "${PROJECTREPO}" "RAILS_ENV=test bundle exec rake db:test:prepare"


} # end  _migrate_check


_migrate_check_doc_center() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local PROJECTREPO=${1}
  enforce_parameter_with_value           1        PROJECTREPO         "${PROJECTREPO}"        "path folder to clone to"

  cd  "${PROJECTREPO}"
  Comment "### _migrate_check web"
  Working "Dropping DBS and recreating, create"

  local _one _databases="
    document-center
  "
  local _two _environments="
     development
     test
     production
  "
  local _db_user=postgres
  while read -r _two ; do
  {
    [[ -z "${_two}" ]] && continue;
    while read -r _one ; do
    {
      [[ -z "${_one}" ]] && continue;
      local _db_name="\"${_one}_${_two}\""
      _execute_db postgres "DROP DATABASE IF EXISTS ${_db_name};"
      _execute_db postgres "CREATE DATABASE ${_db_name} ENCODING = 'unicode' ;"
      _execute_db "${_db_name}" "ALTER USER ${_db_user} WITH SUPERUSER;"
      _execute_db "${_db_name}" "ALTER USER ${_db_user} WITH Createrole;"
      _execute_db "${_db_name}" "ALTER USER ${_db_user} WITH Createdb;"
      _execute_db "${_db_name}" "ALTER USER ${_db_user} WITH replication;"
      _execute_db "${_db_name}" "ALTER USER ${_db_user} WITH bypassrls;"
      _execute_db "${_db_name}" "ALTER DATABASE  ${_db_name} OWNER TO ${_db_user};"
      _execute_db "${_db_name}" "CREATE EXTENSION IF NOT EXISTS hstore;"
      _execute_db "${_db_name}" "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
      _execute_db "${_db_name}" "CREATE EXTENSION IF NOT EXISTS plpgsql;"
    }
    done <<< "${_databases}"
  }
  done <<< "${_environments}"


  Message doc-center DEVELOPMENT "${PROJECTREPO}"
  if [[ ! -f "${PROJECTREPO}/.env" ]] ; then
  {
    Working "cp .example.env .env"
    _execute_project_command "${PROJECTREPO}" "cp .example.env .env"
  }
  fi

  Message doc-client DEVELOPMENT "${PROJECTREPO}"
  if [[ ! -f "${PROJECTREPO}/config.local.json" ]] ; then
  {
    Working "cp config.development.json config.local.json"
    _execute_project_command "${PROJECTREPO}" "cp config.development.json config.local.json"
  }
  fi
  if [[ ! -f "${PROJECTREPO}/apps/client/document/src/assets/app-config/config.local.json" ]] ; then
  {
    Working "cp apps/client/document/src/assets/app-config/config.development.json apps/client/document/src/assets/app-config/config.local.json"
    _execute_project_command "${PROJECTREPO}" "cp apps/client/document/src/assets/app-config/config.development.json apps/client/document/src/assets/app-config/config.local.json"
  }
  fi



  Working "npm run migration:up:document-center-server "
  _execute_project_command "${PROJECTREPO}" "npm run migration:up:document-center-server  "

  Working "npm run azurite"
  _execute_project_command "${PROJECTREPO}" "npm run azurite"

  Working npm run start:document:development

  _execute_project_command "${PROJECTREPO}" "bundle exec rails data:migrate"
  _execute_project_command "${PROJECTREPO}" "bundle exec rails users:update_roles"
  _execute_project_command "${PROJECTREPO}" "bundle exec rails transactional_emails:create_or_update_templates"


  Message TEST
  Working "test db:test:prepare"
  _execute_project_command "${PROJECTREPO}" "RAILS_ENV=test bundle exec rake db:test:prepare"
npm run start:document:development

  # ersetzeindatei "${PROJECTREPO}/.env" "COBA_DEVELOPMENT_MODE=false" "COBA_DEVELOPMENT_MODE=mocked"
  Working "COBA MODE"
  if (  command -v gsed >/dev/null 2>&1 ; ) ; then
  {
    gsed -i -e s/"COBA_DEVELOPMENT_MODE=false"/"COBA_DEVELOPMENT_MODE=mocked"/g .env
  }
  elif ( !  su - "${SUDO_USER}" -c "command -v gsed" >/dev/null 2>&1; ) ; then
  {
    su - "${SUDO_USER}" -c 'gsed -i -e s/"COBA_DEVELOPMENT_MODE=false"/"COBA_DEVELOPMENT_MODE=mocked"/g .env'
  }
  elif (  command -v sed >/dev/null 2>&1 ; ) ; then
  {
    sed -i -e s/"COBA_DEVELOPMENT_MODE=false"/"COBA_DEVELOPMENT_MODE=mocked"/g .env
  }
  elif ( !  su - "${SUDO_USER}" -c "command -v sed" >/dev/null 2>&1; ) ; then
  {
    su - "${SUDO_USER}" -c 'sed -i -e s/"COBA_DEVELOPMENT_MODE=false"/"COBA_DEVELOPMENT_MODE=mocked"/g .env'
  }
  fi

  Message COBA DEVELOPMENT


  Working COBA "db:migrate"
  _execute_project_command "${PROJECTREPO}" "bundle exec rake db:migrate db:migrate:emails db:migrate:credit_check "
  Working COBA "db:seed db:migrate"

  _execute_project_command "${PROJECTREPO}" "bundle exec rails db:seed || bundle exec rails db:seed"
  _execute_project_command "${PROJECTREPO}" "bundle exec rails data:migrate"
  _execute_project_command "${PROJECTREPO}" "bundle exec rails users:update_roles"
  _execute_project_command "${PROJECTREPO}" "bundle exec rails transactional_emails:create_or_update_templates"


  Message COBA TEST
  Working "test db:test:prepare"
  _execute_project_command "${PROJECTREPO}" "RAILS_ENV=test bundle exec rake db:test:prepare"

} # end  _migrate_check_doc_center


_make_up() {
    docker compose up -d postgres redis

} # end _make_up

_make_down() {
    docker compose down

} # end _make_down

_make_rebase_with_main() {
    git fetch --atomic
    git pull --rebase --autostash origin main

} # end _make_rebase_with_main

_make_server() {
    bundle exec rails server

} # end _make_server

_make_console() {
    bundle exec rails console

} # end _make_console

_make_sidekiq() {
    bundle exec sidekiq

} # end _make_sidekiq

_make_guard() {
    bundle exec guard -G Guardfile.me

} # end _make_guard

_make_migrate() {
    bundle exec rails db:migrate data:migrate

} # end _make_migrate

_make_seed() {
    bundle exec rails db:seed

} # end _make_seed

_make_reseed() {
    bundle exec rails db:seed:replant

} # end _make_reseed

_make_tasks() {
    bundle exec rails --tasks > tasks.txt

} # end _make_tasks

_make_routes() {
    bundle exec rails routes > routes.txt

} # end _make_routes

_make_db_reset() {
    bundle exec rails db:drop
    bundle exec rails db:create db:migrate db:migrate:emails
    bundle exec rails db:seed || bundle exec rails db:seed
    bundle exec rails data:migrate
    bundle exec rails users:update_roles
    bundle exec rails transactional_emails:create_or_update_templates

} # end _make_db_reset

_make_reset_passwords() {
    echo 'Advisor.all.each { |adv| adv.update!(password: "password1", password_confirmation: "password1")}; 0' | bundle exec rails console

} # end _make_reset_passwords

_make_create_users() {
    @echo "$$CREATE_ADVISORS" | bundle exec rails c
set_coba:
    sed -i -e 's/^COBA_DEVELOPMENT_MODE=false$$/COBA_DEVELOPMENT_MODE=mocked/' .env
set_finlink:
    sed -i -e 's/^COBA_DEVELOPMENT_MODE=mock.*$$/COBA_DEVELOPMENT_MODE=false/' .env
# set_coba:
#   sed -i -e 's/^CURRENT_LENDER=Default$$/CURRENT_LENDER=Coba/' .env
#
# set_finlink:
#   sed -i -e 's/^CURRENT_LENDER=Coba$$/CURRENT_LENDER=Default/' .env

} # end _make_create_users

_make_database_console() {
    psql -d 'loanlink-api_development' -h 0.0.0.0 -U postgres -W

} # end _make_database_console

_vpn_check() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local PROJECTREPO=${1}
  enforce_parameter_with_value           1        PROJECTREPO         "${PROJECTREPO}"        "path folder to clone to"

  su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' brew install  --cask tunnelblick"
} # end _vpn_check




_darwin__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR

	_find_project_location_PROJECT_DIR_F
  local PROJECTSBASEDIR="${PROJECT_DIR_F}"
  local PROJECTREPO="${PROJECT_DIR_F}/loanlink-api"
  local PROJECTGITREPO="git@github.com:LoanLink/loanlink-api.git"
  local PROJECTGITREPOBRANCH="main"

  if [[ ! -f "${PROJECTREPO}/.step1_brew_check_requirements_postgress_12_install"  ]] ; then
  {
    Working "Step .step1_brew_check_requirements_postgress_12_install"
    _brew_check_requirements_postgress_12_install
    local _touch_name="\"${PROJECTREPO}/.step1_brew_check_requirements_postgress_12_install\""
    _execute_project_command "${PROJECTREPO}" "touch ${_touch_name} "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step2_attempt_to_download_docker"  ]] ; then
  {
    # _attempt_to_download_docker amd64
    # _attempt_to_download_docker arm64
    Working "Step .step2_attempt_to_download_docker"
    _attempt_to_download_docker $(uname -m)
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step2_attempt_to_download_docker\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step3_rbenv_check"  ]] ; then
  {
    Working "Step .step3_rbenv_check"
    _rbenv_check
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step3_rbenv_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step4_ruby_check"  ]] ; then
  {
    Working "Step .step4_ruby_check"
    _ruby_check "${PROJECTSBASEDIR}" "${PROJECTREPO}" "${PROJECTGITREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step4_ruby_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step5_bundle_check"  ]] ; then
  {
    Working "Step .step5_bundle_check"
    _bundle_check "${PROJECTREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step5_bundle_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step6_env_check"  ]] ; then
  {
    Working "Step .step6_env_check"
    _env_check "${PROJECTREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step6_env_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step71_pre_postgres_start_check"  ]] ; then
  {
    Working "Step .step71_pre_postgres_start_check"
    _add_postgress_to_bashrc_zshrc "${PROJECTREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step71_pre_postgres_start_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step7_postgres_start_check"  ]] ; then
  {
    Working "Step .step7_postgres_start_check"
    _postgres_start_check "${PROJECTREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step7_postgres_start_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step8_migrate_check"  ]] ; then
  {
    Working "Step .step8_migrate_check"
    _migrate_check "${PROJECTREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step8_migrate_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step9_migrate_development_check"  ]] ; then
  {
    Working "Step .step9_migrate_development_check"
    _migrate_development_check "${PROJECTREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step9_migrate_development_check\" "
  }
  fi
  if [[ ! -f "${PROJECTREPO}/.step10_vpn_check"  ]] ; then
  {
    Working "Step .step10_vpn_check"
    _vpn_check "${PROJECTREPO}"
    _execute_project_command "${PROJECTREPO}" "touch \"${PROJECTREPO}/.step10_vpn_check\" "
  }
  fi



  # echo "_darwin__64 Procedure not yet implemented. I don't know what to do."
} # end _darwin__64

_darwin__arm64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _darwin__64
  # _attempt_to_download_docker arm64
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



 #--------/\/\/\/\-- 2tasks_templates_sudo/loanlink_api …install_loanlink_api.bash” -- Custom code-/\/\/\/\-------



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
