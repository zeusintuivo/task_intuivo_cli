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





 #--------\/\/\/\/-- 2tasks_templates_sudo/rust …install_rust.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/bash
alias egrep='grep -E --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
_add_variables_to_bashrc_zshrc(){
  # trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO _add_variables_to_bashrc_zshrc cargo" && echo -e "${RESET}" && return 0' ERR
  local FINDCARGO_USER="${USER_HOME}/.cargo"
  local FINDCARGO_ROOT="/root/.cargo"


  if [[ -e "/root/.cargo/bin/cargo" ]] ; then
  {
    FINDCARGO_ROOT="/root/.cargo"
  }
  fi

  if [[ -e "${USER_HOME}/.cargo/bin/cargo" ]] ; then
  {
    FINDCARGO_USER="${USER_HOME}/.cargo"
  }
  elif [[ -e "/opt/cargo/bin/cargo" ]] ; then
  {
    FINDCARGO_USER="/opt/cargo"
  }
  fi

  local CARGO_SH_CONTENT_ROOT='

# CARGO - RUST
source "'${FINDCARGO_ROOT}'/env"

'
  local CARGO_SH_CONTENT_USER='

# CARGO - RUST
source "'${FINDCARGO_USER}'/env"

'
  echo "${CARGO_SH_CONTENT_USER}"
  local INITFILE INITFILES="
   .bashrc
   .zshrc
   .bash_profile
   .profile
   .zshenv
   .zprofile
  "
  local changed_files=""
  while read INITFILE; do
  {
    [ -z ${INITFILE} ] && continue
    # USER
    [[ ! -e "${USER_HOME}/${INITFILE}" ]] && continue
    Checking "${USER_HOME}/${INITFILE}"
    chown "${SUDO_USER}" "${USER_HOME}/${INITFILE}"
    (_if_not_contains  "${USER_HOME}/${INITFILE}" "# CARGO - RUST" ) || Configuring "${USER_HOME}/${INITFILE}"
    (_if_not_contains  "${USER_HOME}/${INITFILE}" "# CARGO - RUST" ) && Skipping configuration for "${USER_HOME}/${INITFILE}"
    #                             filename            value          || do this .............
    (_if_not_contains  "${USER_HOME}/${INITFILE}" "# CARGO - RUST" ) || echo -e "${CARGO_SH_CONTENT_USER}" >> "${USER_HOME}/${INITFILE}"
    (_if_not_contains  "${USER_HOME}/${INITFILE}" "# CARGO - RUST" ) && changed_files="${changed_files} \"${USER_HOME}/${INITFILE}\" "

    # ROOT
    [[ ! -e "${HOME}/${INITFILE}" ]] && continue
    Checking "${HOME}/${INITFILE}"
    # chown "${SUDO_USER}" "${HOME}/${INITFILE}"
    (_if_not_contains  "${HOME}/${INITFILE}" "# CARGO - RUST" ) || Configuring "${HOME}/${INITFILE}"
    (_if_not_contains  "${HOME}/${INITFILE}" "# CARGO - RUST" ) && Skipping configuration for "${HOME}/${INITFILE}"
    #                             filename            value          || do this .............
    (_if_not_contains  "${HOME}/${INITFILE}" "# CARGO - RUST" ) || echo -e "${CARGO_SH_CONTENT_ROOT}" >> "${HOME}/${INITFILE}"
    (_if_not_contains  "${HOME}/${INITFILE}" "# CARGO - RUST" ) && changed_files="${changed_files} \"${HOME}/${INITFILE}\" "


  }
  done <<< "${INITFILES}"
  # if it_exists /home/linuxcargo ; then
  # {
  #   rm -rf /home/linuxcargo
  # }
  # fi
  file_exists_with_spaces "${FINDCARGO_USER}"
  source "${FINDCARGO_USER}/env"
  Checking "all files changed files command for you" :
  echo "sudo vim ${changed_files}"
  echo "sudo nano ${changed_files}"
} # _add_variables_to_bashrc_zshrc


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
    }
  fi
  verify_is_installed "
    unzip
    curl
    wget
    tar
  "
  export ARCHFLAGS="-arch $(uname -m)"
  ARCHFLAGS="-arch $(uname -m)" curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  [[ ! -e "${USER_HOME}/.cargo" ]] && cp -R /root/.cargo "${USER_HOME}/.cargo"
  chmod -R 755 "${USER_HOME}/.cargo"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/bin"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/env"
  #  su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
  if su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh" ; then
          {
                  echo "oops"
          }
  fi

  _add_variables_to_bashrc_zshrc
  rustup default stable
  su - "${SUDO_USER}" -c "rustup default stable"
} # end _debian_flavor_install

_redhat_flavor_install() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  Checking if rust is installed by brew and attempting remove it
  if ( ! su - "${SUDO_USER}" -c "command -v /home/linuxbrew/.linuxbrew/bin/brew" >/dev/null 2>&1; ); then
  {
    if su - "${SUDO_USER}" -c "/home/linuxbrew/.linuxbrew/bin/brew remove rust" ; then
    {
      warning "could not remove rust from user root brew"
    }
    else
    {
      passed "removed rust from brew user root"
    }
    fi
  }
  fi

  if ( ! command -v /home/linuxbrew/.linuxbrew/bin/brew >/dev/null 2>&1; ); then
  {
    if /home/linuxbrew/.linuxbrew/bin/brew remove rust ; then
    {
      warning "could not remove rust from user root brew"
    }
    else
    {
      passed "removed rust from brew user root"
    }
    fi
  }
  fi

  dnf build-dep rust  -y --allowerasing --skip-broken
  if (install_requirements "linux" "
      unzip
      curl
      wget
    "
    ); then
  {
      echo "warning: failed to install some deps"
  }
  fi
  verify_is_installed "
    unzip
    curl
    wget
    tar
  "
  Installing "_add_variables_to_bashrc_zshrc for ROOT and USER"
  mkdir -p  "${USER_HOME}/.cargo"
  chmod -R 755 "${USER_HOME}/.cargo"
 _add_variables_to_bashrc_zshrc

  export ARCHFLAGS="-arch $(uname -m)"

  ARCHFLAGS="-arch $(uname -m)"
  Installing "ROOT install:ARCHFLAGS='-arch ${ARCHFLAGS-}' curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh
  local cpwd=$(realpath .)
  local -i _err=0
  chmod +x "${cpwd}/rustup.sh"
  ARCHFLAGS='-arch ${ARCHFLAGS-}' "${cpwd}/rustup.sh" --no-modify-path --target /root --quiet -y
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    rm -rf "${cpwd}/rustup.sh"
    failed "Failed to install for root err:${_err}"
  }
  else
  {
    passed "install for root"
  }
  fi
  [[ ! -e "${USER_HOME}/.cargo" ]] && cp -R /root/.cargo "${USER_HOME}/.cargo"
  chmod -R 755 "${USER_HOME}/.cargo"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/bin"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/env"
  Installing "USER install(${USER_HOME}):su - \"${SUDO_USER}\" -c \"ARCHFLAGS='-arch $(uname -m)' curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh\""
  # if su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh" ; then
  chown -R "${SUDO_USER}" "${cpwd}/rustup.sh"
  su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' "${cpwd}/rustup.sh" --no-modify-path --target \"${USER_HOME}\" --quiet -y"
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    rm -rf "${cpwd}/rustup.sh"
    failed "Failed to install for user err:${_err}"
  }
  else
  {
    passed "install for user"
  }
  fi
  rm -rf "${cpwd}/rustup.sh"
  Installing "_add_variables_to_bashrc_zshrc for ROOT and USER"
  _add_variables_to_bashrc_zshrc

  chown -R "${SUDO_USER}"   "${USER_HOME}/.rustup"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/bin"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/env"

  Installing "ROOT: rustup default stable"
  rustup default stable
  Installing "USER: su - \"${SUDO_USER}\" -c \"rustup default stable\""
  su - "${SUDO_USER}" -c "rustup default stable"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.rustup"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/bin"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/env"

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

_fedora_37__64(){
  _redhat_flavor_install
} # end _fedora_37__64

_fedora_38__64(){
  _redhat_flavor_install
} # end _fedora_38__64

_fedora_39__64(){
  _redhat_flavor_install
} # end _fedora_39__64

_fedora_40__64(){
  _redhat_flavor_install
} # end _fedora_40__64

_fedora__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _fedora__64

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

_ubuntu__aarch64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _debian_flavor_install
} # end _ubuntu__aarch64

_ubuntu_22__aarch64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _debian_flavor_install
} # end _ubuntu_22__aarch64

_darwin__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  Checking "if rust is installed by brew and attempting remove it"
  local -i _err=0
   local _target_bin_brew=""
   _target_bin_brew="$(_find_executable_for "brew" "--prefix"  "bin/brew")"   # tail -1
  _err=$?
  if [ $_err -gt 0 ] ; then # failed
  {
    echo "${_target_bin_brew}"
    failed "to find brew"
  }
  fi
  Checking "_target_bin_brew:<${_target_bin_brew}>"
  _target_bin_brew="$(echo "${_target_bin_brew}" | tail -1 | xargs)"
  ensure "${_target_bin_brew}" or "failed to check executable for brew <${_target_bin_brew}>"
  _target_bin_brew="$(echo -n "${_target_bin_brew}" | tail -1)"
  enforce_variable_with_value _target_bin_brew "${_target_bin_brew}"
  su - "${SUDO_USER}" -c "${_target_bin_brew} list --formula"
  if ( ! su - "${SUDO_USER}" -c "${_target_bin_brew} list rust" >/dev/null 2>&1; ); then
  {
    passed "rust not found"
  }
  else
  {
    passed "rust found"
    if ( ! su - "${SUDO_USER}" -c "${_target_bin_brew} remove rust" >/dev/null 2>&1; ); then
    {
      warning "could not remove rust from brew"
    }
    else
    {
      passed "removed rust from brew"
    }
    fi
  }
  fi

  if (install_requirements "mac" "
      unzip
      curl
      wget
    "
    ); then
  {
      warning ": failed to install some deps "
  }
  fi
  verify_is_installed "
    unzip
    curl
    wget
    tar
  "
  Installing "_add_variables_to_bashrc_zshrc for ROOT and USER"
  mkdir -p  "${USER_HOME}/.cargo"
  chmod -R 755 "${USER_HOME}/.cargo"
  _add_variables_to_bashrc_zshrc

  export ARCHFLAGS="-arch $(uname -m)"

  ARCHFLAGS="-arch $(uname -m)"
  Installing "ROOT install:ARCHFLAGS='-arch ${ARCHFLAGS-}' curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh
  local cpwd=$(realpath .)
  local -i _err=0
  chmod +x "${cpwd}/rustup.sh"
  ARCHFLAGS='-arch ${ARCHFLAGS-}' "${cpwd}/rustup.sh" --no-modify-path --target /root --quiet -y
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    rm -rf "${cpwd}/rustup.sh"
    failed "Failed to install for root err:${_err}"
  }
  else
  {
    passed "install for root"
  }
  fi
  [[ ! -e "${USER_HOME}/.cargo" ]] && cp -R /root/.cargo "${USER_HOME}/.cargo"
  chmod -R 755 "${USER_HOME}/.cargo"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.rustup"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/bin"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/env"
  Installing "USER install(${USER_HOME}):su - \"${SUDO_USER}\" -c \"ARCHFLAGS='-arch $(uname -m)' curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh\""
  # if su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh" ; then
  chown -R "${SUDO_USER}" "${cpwd}/rustup.sh"
  su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' "${cpwd}/rustup.sh" --no-modify-path --target \"${USER_HOME}\" --quiet -y"
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    rm -rf "${cpwd}/rustup.sh"
    failed "Failed to install for user err:${_err}"
  }
  else
  {
    passed "install for user"
  }
  fi
  rm -rf "${cpwd}/rustup.sh"
  Installing "_add_variables_to_bashrc_zshrc for ROOT and USER"
  _add_variables_to_bashrc_zshrc

  chown -R "${SUDO_USER}"   "${USER_HOME}/.rustup"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/bin"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/env"

  Installing "ROOT: rustup default stable"
  rustup default stable
  Installing "USER: su - \"${SUDO_USER}\" -c \"rustup default stable\""
  su - "${SUDO_USER}" -c "rustup default stable"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.rustup"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/bin"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/env"


} # end _darwin__64

_darwin__arm64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  set -xu +E -o pipefail -o functrace
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  Checking "if rust is installed by brew and attempting remove it"
  local -i _err=0
  local _target_bin_brew=""
  _target_bin_brew="$(_find_executable_for "brew" "--prefix"  "bin/brew")"   # tail -1
  _err=$?
  if [ $_err -gt 0 ] ; then # failed
  {
    echo "${_target_bin_brew}"
    failed "to find brew"
  }
  fi
  Checking "_target_bin_brew:<${_target_bin_brew}>"
  _target_bin_brew="$(echo "${_target_bin_brew}" | tail -1 | xargs)"
  ensure "${_target_bin_brew}" or "failed to check executable for brew <${_target_bin_brew}>"
  _target_bin_brew="$(echo -n "${_target_bin_brew}" | tail -1)"
  enforce_variable_with_value _target_bin_brew "${_target_bin_brew}"
  su - "${SUDO_USER}" -c "${_target_bin_brew} list --formula"
  if ( ! su - "${SUDO_USER}" -c "${_target_bin_brew} list rust" >/dev/null 2>&1; ); then
  {
    passed "rust not found"
  }
  else
  {
    passed "rust found"
    if ( ! su - "${SUDO_USER}" -c "${_target_bin_brew} remove rust" >/dev/null 2>&1; ); then
    {
      warning "could not remove rust from brew"
    }
    else
    {
      passed "removed rust from brew"
    }
    fi
  }
  fi

  if (install_requirements "mac" "
      unzip
      curl
      wget
    "
    ); then
  {
      warning ": failed to install some deps "
  }
  fi
  verify_is_installed "
    unzip
    curl
    wget
    tar
  "
  Installing "_add_variables_to_bashrc_zshrc for ROOT and USER"
  mkdir -p  "${USER_HOME}/.cargo"
  chmod -R 755 "${USER_HOME}/.cargo"
  _add_variables_to_bashrc_zshrc

  export ARCHFLAGS="-arch $(uname -m)"

  ARCHFLAGS="-arch $(uname -m)"
  Installing "ROOT install:ARCHFLAGS='-arch ${ARCHFLAGS-}' curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh
  local cpwd=$(realpath .)
  local -i _err=0
  chmod +x "${cpwd}/rustup.sh"
  ARCHFLAGS='-arch ${ARCHFLAGS-}'
  "${cpwd}/rustup.sh" --no-modify-path --target /root --quiet -y
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    rm -rf "${cpwd}/rustup.sh"
    failed "Failed to install for root err:${_err}"
  }
  else
  {
    passed "install for root"
  }
  fi
  [[ ! -e "${USER_HOME}/.cargo" ]] && cp -R /root/.cargo "${USER_HOME}/.cargo"
  chmod -R 755 "${USER_HOME}/.cargo"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.rustup"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/bin"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/env"
  Installing "USER install(${USER_HOME}):su - \"${SUDO_USER}\" -c \"ARCHFLAGS='-arch $(uname -m)' curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh\""
  # if su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh" ; then
  chown -R "${SUDO_USER}" "${cpwd}/rustup.sh"
  su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' "${cpwd}/rustup.sh" --no-modify-path --target \"${USER_HOME}\" --quiet -y"
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    rm -rf "${cpwd}/rustup.sh"
    failed "Failed to install for user err:${_err}"
  }
  else
  {
    passed "install for user"
  }
  fi
  rm -rf "${cpwd}/rustup.sh"
  Installing "_add_variables_to_bashrc_zshrc for ROOT and USER"
  _add_variables_to_bashrc_zshrc

  chown -R "${SUDO_USER}"   "${USER_HOME}/.rustup"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/bin"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/env"

  Installing "ROOT: rustup default stable"
  rustup default stable
  Installing "USER: su - \"${SUDO_USER}\" -c \"rustup default stable\""
  su - "${SUDO_USER}" -c "rustup default stable"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.rustup"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/bin"
  chown -R "${SUDO_USER}"   "${USER_HOME}/.cargo/env"



} # end _darwin__arm64

_tar() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
} # end tar

_windows__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  export ARCHFLAGS="-arch $(uname -m)"
  ARCHFLAGS="-arch $(uname -m)" curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  su - "${SUDO_USER}" -c "ARCHFLAGS='-arch $(uname -m)' curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
} # end _windows__64

_windows__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "_windows__32 Procedure not yet implemented. I don't know what to do."
} # end _windows__32



 #--------/\/\/\/\-- 2tasks_templates_sudo/rust …install_rust.bash” -- Custom code-/\/\/\/\-------



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
