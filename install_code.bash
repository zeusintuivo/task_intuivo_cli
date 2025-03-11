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





 #--------\/\/\/\/-- 2tasks_templates_sudo/code …install_code.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/env bash
#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
# SUDO_USER only exists during execution of sudo
# REF: https://stackoverflow.com/questions/7358611/get-users-home-directory-when-they-run-a-script-as-root
# Global:
# THISSCRIPTNAME=`basename "$0"`

execute_as_sudo(){
  if [ -z $SUDO_USER ] ; then
    if [[ -z "$THISSCRIPTNAME" ]] ; then
    {
        echo "error You need to add THISSCRIPTNAME variable like this:"
        echo "     THISSCRIPTNAME=\`basename \"\$0\"\`"
    }
    else
    {
        if [ -e "./$THISSCRIPTNAME" ] ; then
        {
          sudo "./$THISSCRIPTNAME"
        }
        elif ( command -v "$THISSCRIPTNAME" >/dev/null 2>&1 );  then
        {
          echo "sudo sudo sudo "
          sudo "$THISSCRIPTNAME"
        }
        else
        {
          echo -e "\033[05;7m*** Failed to find script to recall it as sudo ...\033[0m"
          exit 1
        }
        fi
    }
    fi
    wait
    exit 0
  fi
  # REF: http://superuser.com/questions/93385/run-part-of-a-bash-script-as-a-different-user
  # REF: http://superuser.com/questions/195781/sudo-is-there-a-command-to-check-if-i-have-sudo-and-or-how-much-time-is-left
  local CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
  if [ ${CAN_I_RUN_SUDO} -gt 0 ]; then
    echo -e "\033[01;7m*** Installing as sudo...\033[0m"
  else
    echo "Needs to run as sudo ... ${0}"
  fi
}

_get_user_home() {
  # check operation systems
  if [[ "$(uname)" == "Darwin" ]] ; then
    # Do something under Mac OS X platform
    CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
    if [ ${CAN_I_RUN_SUDO} -gt 0 ]; then
      echo -e "\033[01;7m*** Installing as sudo...\033[0m"
    else
      echo "Needs to run as sudo ... ${0}"
      exit 1
    fi
    # USER_HOME=$(echo "/Users/$SUDO_USER")
    export USER_HOME
    # typeset -rg USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)  # Get the caller's of sudo home dir Just Linux
    # shellcheck disable=SC2046
    # shellcheck disable=SC2031
    typeset -rg USER_HOME="$(echo -n $(bash -c "cd ~${SUDO_USER} && pwd"))"  # Get the caller's of sudo home dir LINUX and MAC
  elif [[ "$(cut -c1-5 <<< "$(uname -s)")" == "Linux" ]] ; then
    # Do something under GNU/Linux platform
    execute_as_sudo
    export USER_HOME
    # typeset -rg USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)  # Get the caller's of sudo home dir Just Linux
    # shellcheck disable=SC2046
    # shellcheck disable=SC2031
    typeset -rg USER_HOME="$(echo -n $(bash -c "cd ~${SUDO_USER} && pwd"))"  # Get the caller's of sudo home dir LINUX and MAC
  elif [[ "$(cut -c1-10 <<< "$(uname -s)")" == "MINGW32_NT" ]] || [[ "$(cut -c1-10 <<< "$(uname -s)")" == "MINGW64_NT" ]] ; then
    # Do something under Windows NT platform
    USER_HOME=$(echo "/Users/$SUDO_USER")
    # nothing here
  fi

} # end _get_user_home

# _get_user_home



load_struct_testing_wget(){
    local provider="$USER_HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    [   -e "${provider}"  ] && source "${provider}"
    [ ! -e "${provider}"  ] && eval """$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing -O -  2>/dev/null )"""   # suppress only wget download messages, but keep wget output for variable
    ( ( ! command -v passed >/dev/null 2>&1; ) && echo -e "\n \n  ERROR! Loading struct_testing \n \n " && exit 69; )
} # end load_struct_testing_wget
# load_struct_testing_wget

# passed Caller user identified:$SUDO_USER
# passed Home identified:$USER_HOME
# directory_exists_with_spaces "$USER_HOME"


# function _assure_success() {
#   if [ $? != 0 ] ; then
#     echo -e "\033[38;5;1m Something went wrong \033[0m"
#     exit 1
#   fi
#   wait
# }

# function _trap_try_start() {
#   trap _term SIGTERM
# }

# function _trap_catch_check() {
#   declare -i ret=$?
#   local child
#   if [ $ret -gt 0 ] ; then
#   {
#     child=$!
#     wait $child
#     warning "${YELLOW}Error SIGNAL_RETURN(${RED}${ret}${YELLOW}) executing: \n${action}"
#     return 1 # non zero is error
#   }
#   fi
#   return 0
# }

# function _action_runner() {
#   local action
#   while read -r action ; do
#   {
#     if [[ ! -z "${action}" ]] ; then # if not empty
#     {
#       _trap_try_start
#       echo "${action}"
#       "${action}"
#       _trap_catch_check
#     }
#     fi
#   }
#   done <<< "${@}"
# } # end _action_runner

# function _try_runner() {
#   local body=$(_function_body "#{1}")
#   function_exists "${1}"
#   while read -r action ; do
#   {
#     if [[ ! -z "${action}" ]] ; then # if not empty
#     {
#       _trap_try_start
#       echo "${action}"
#       "${action}"
#       _trap_catch_check
#     }
#     fi
#   }
#   done <<< "${body}"
# } # end _try_runner

# function _function_body() {
#   local functionname="${1}"
#   # function_exists "${functionname}"
#   # ensure head or Cancel. Missing head command
#   # ensure tail or Cancel. Missing tail command
#   # ensure declare or Cancel. Missing declare command
#   # ensure wc or Cancel. Missing declare command
#   local functioncomplete=$(declare -f "${functionname}")
#   # echo complete:"${functioncomplete}"
#   local functionbody=$(echo "${functioncomplete}" | cüt "${functionname} ()")
#   # echo body:"${functionbody}"
#   local functionlength=$(echo "${functionbody}" | wc -l)
#   # echo length:${functionlength}
#   # echo less:${functionlengthless}
#   (( functionlength-- ))
#   # echo lenght:${functionlength}
#   functionbody=$(echo "${functionbody}" | head -${functionlength} )
#   # echo body:"${functionbody}"
#   (( functionlength-- ))
#   # echo length:${functionlength}
#   functionbody=$(echo "${functionbody}" | tail -${functionlength} )
#   # echo body:"${functionbody}"
#   echo "${functionbody}"
# }

# function _try() {
#   local body=$(_function_body "#{1}")
#   _trap_try_start
#   "${body}"
#   _trap_catch_check
# }
CODELASTESTBUILD="1.87.2-1709911730"
_darwin__64() {
    local CODENAME="Visual Studio Code%20Text%20Build%20${CODELASTESTBUILD}.dmg"
    cd "${USER_HOME}/Downloads/"
    local URL="https://vscode.download.prss.microsoft.com/dbazure/download/stable/863d2581ecda6849923a2118d93a088b0745d9d6/code_1.87.2-1709911730.dmg"
    _download "${URL}"
    sudo hdiutil attach ${CODENAME}
    sudo cp -R /Volumes/Visual Studio Code\ Text/Visual Studio Code\ Text.app /Applications/
    sudo hdiutil detach /Volumes/Visual Studio Code\ Text
} # end _darwin__64

_ubuntu__aarch64() {
    trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
    local CODENAME="studio_code-text_build-${CODELASTESTBUILD}_arm64.deb"
    cd "${USER_HOME}/Downloads/"
    local URL="https://vscode.download.prss.microsoft.com/dbazure/download/stable/863d2581ecda6849923a2118d93a088b0745d9d6/code_1.87.2-1709911730_arm64.deb"
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
} # end _ubuntu__aarch64

_ubuntu_22__aarch64() {
    trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
    local CODENAME="studio_code-text_build-${CODELASTESTBUILD}_arm64.deb"
    cd "${USER_HOME}/Downloads/"
    local URL="https://vscode.download.prss.microsoft.com/dbazure/download/stable/863d2581ecda6849923a2118d93a088b0745d9d6/code_1.87.2-1709911730_arm64.deb"
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
} # end _ubuntu_22__aarch64

_ubuntu__64() {
    local CODENAME="studio_code-text_build-${CODELASTESTBUILD}_amd64.deb"
    cd "${USER_HOME}/Downloads/"
    local URL="https://vscode.download.prss.microsoft.com/dbazure/download/stable/863d2581ecda6849923a2118d93a088b0745d9d6/code_1.87.2-1709911730_amd64.deb"
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
} # end _ubuntu__64

_ubuntu__32() {
    local CODENAME="studio_code-text_build-${CODELASTESTBUILD}_i386.deb"
    cd "${USER_HOME}/Downloads/"
    local URL="https://vscode.download.prss.microsoft.com/dbazure/download/stable/863d2581ecda6849923a2118d93a088b0745d9d6/code_1.87.2-1709911730_i386.deb"
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
} # end _ubuntu__32

_centos__64() {
  _fedora__64
} # end _centos__64

_fedora__64() {
  # sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  # sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
  # sudo dnf -y check-update
  # sudo dnf -y install code

  # rpm: https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-31.noarch.rpm
  # get download link
  # https://code.visualstudio.com/docs/?dv=linux64_rpm
  # local DOWNLOAD_DISPLAY_PAGE=$(curl -sSLo -  https://code.visualstudio.com/docs/?dv=linux64_rpm&build=insiders  2>&1;) # suppress only wget download messages, but keep wget output for variable
  # https://vscode-update.azurewebsites.net/latest/linux-rpm-x64/insider
  # https://vscode-update.azurewebsites.net/latest/linux-rpm-x64/stable
  # local DOWNLOAD_DISPLAY_PAGE=$(curl -sSLo -  https://vscode-update.azurewebsites.net/latest/linux-rpm-x64/insider  2>&1;) # suppress only wget download messages, but keep wget output for variable
  local DOWNLOAD_DISPLAY_PAGE=$(curl -sSLo -  https://code.visualstudio.com/updates/  2>&1;) # suppress only wget download messages, but keep wget output for variable


  local LASTEST_VERSION=$(echo "${DOWNLOAD_DISPLAY_PAGE}" | sed s/\</\\n\</g | grep ".strong.Update." | cüt "<strong>Update " | sort -n | tail -n -1)
  local TARGET_URL=$(echo  "${DOWNLOAD_DISPLAY_PAGE}" | sed s/\</\\n\</g | grep "${LASTEST_VERSION}" | grep 'rpm' | cut -d'"' -f2 )
  # local TARGET_URL="https://vscode-update.azurewebsites.net/latest/linux-rpm-x64/insider"
  local ARCHITECTURE=$(uname -m)
  wait
  [[ -z "${LASTEST_VERSION}" ]] && failed "Visual Studio Code Version not found! :${LASTEST_VERSION}:"

  Message "Visual Studio Code Version found LASTEST_VERSION:" "<${LASTEST_VERSION}>"
  Message "Visual Studio Code Version found TARGET_URL:" "<${TARGET_URL}>"

  if [ -z "${LASTEST_VERSION}" ] ; then  # if empty
  {
    failed Could not find Code version
  }
  fi


  # get download link
  local ID
  local VERSION
  local VERSION_ID
  file_exists_with_spaces "/etc/os-release"
  _assure_success

  source /etc/os-release
  # $ echo $ID
  # fedora
  # $ echo $VERSION_ID
  # 17
  # $ echo $VERSION
  # 17 (Beefy Miracle)
  enforce_variable_with_value ID "${ID}"
  enforce_variable_with_value VERSION_ID "${VERSION_ID}"
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  enforce_variable_with_value LASTEST_VERSION "${LASTEST_VERSION}"
  enforce_variable_with_value ARCHITECTURE "${ARCHITECTURE}"


  file_exists_with_spaces "${USER_HOME}/Downloads"

  local folder_date=$(date +"%Y%m%d")
  _assure_success
  enforce_variable_with_value folder_date "${folder_date}"
  local download_folder=$(echo  "${USER_HOME}/Downloads/${folder_date}")

  anounce_command mkdir -p "${download_folder}"
  chown -R "${SUDO_USER}" "${download_folder}"
  file_exists_with_spaces "${download_folder}"
  cd "${download_folder}"
  # TODO: Fragile providing name manually
  local NEW_FILENAME="code-${LASTEST_VERSION}-${folder_date}.el7.${ARCHITECTURE}.rpm"
  Message NEW_FILENAME: "${NEW_FILENAME}"

  # Hash compare
  # REF: https://askubuntu.com/questions/685775/bash-get-md5-of-online-file
  ensure curl or "Canceling Install. Could not find curl command to execute install"
  ensure md5sum or "Canceling Install. Could not find md5sum command to execute install"
  ensure cut or "Canceling Install. Could not find cut command to execute install"

  # wget -q -O- http://example.com/your_file | md5sum | sed 's:-$:local_file:' | md5sum -c
  local HASHLOCAL HASHREMOTE="$(curl -sL "${TARGET_URL}" | md5sum | cut -d ' ' -f 1)"
  if it_exists_with_spaces "${download_folder}/${NEW_FILENAME}" ; then
  {
    HASHLOCAL="$(md5sum "${download_folder}/${NEW_FILENAME}" | cut -d ' ' -f 1)"
    if [ "$HASHREMOTE" == "$HASHLOCAL" ]; then
        Message "Already" "downloaded using cached file ${download_folder}/${NEW_FILENAME}"
    fi
  } else {
    Message Downloading
    rm -rf "${download_folder}/${NEW_FILENAME}"
    file_does_not_exist_with_spaces "${download_folder}/${NEW_FILENAME}"
    _download "${TARGET_URL}" "${download_folder}/" "${NEW_FILENAME}"

  }
  fi

  Checking downloaded

  _trap_try_start
  local CODENAME=$(ls -1 "${download_folder}" | tail -1)
  _trap_catch_check
  enforce_variable_with_value CODENAME "${CODENAME}"

  Message Downloaded filename: "${CODENAME}"
  Showing ls -1 "${download_folder}"
	local filenamechecked="${download_folder}/${CODENAME}"
  file_exists_with_spaces "${download_folder}/${CODENAME}"

	local MAJOR MINOR MICRO BUILD ONE_VERSION_BEFORE NEW_FILENAME

  ensure dnf or "Canceling Install. Could not find dnf command to execute install"
  IFS=. read MAJOR MINOR MICRO <<EOF
${LASTEST_VERSION##*-}
EOF
  if (( MICRO > 0 )) ; then
  {
    (( MICRO-- ))
  }
  else
  {
    MICRO=9
    (( MINOR-- ))
  }
  fi
  ONE_VERSION_BEFORE=${MAJOR}.${MINOR}.${MICRO}
  OLD_FILENAME=$(echo "${NEW_FILENAME}" | sed s/$LASTEST_VERSION/$ONE_VERSION_BEFORE/g)
  Message OLD_FILENAME: "${OLD_FILENAME}"
  ensure cüt or "Canceling Install. Could not find cüt command to execute install"
  local OLD_PACKAGE=$(echo $OLD_FILENAME | cüt '.rpm')
  Message dnf -y remove "${OLD_PACKAGE}"
  _trap_try_start # _trap_catch_check
	set -x
	local msg=$(dnf -y remove "${OLD_PACKAGE}")
	_trap_catch_check
  Message "${msg}"
  set +x
	export DEBUG=1
  chown -R "${SUDO_USER}" "${filenamechecked}"
  Installing "${filenamechecked}"
  # ensure rpm or "Canceling Install. Could not find rpm command to execute install"
	anounce rpm -ivh "${filenamechecked}"
  _trap_try_start # _trap_catch_check
	msg="$(rpm -ivh "${filenamechecked}")"
  _trap_catch_check
  #	[ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home
  #  enforce_variable_with_value USER_HOME "${USER_HOME}"
  #  local TARGET_URL=https://az764295.vo.msecnd.net/insider/192c817fd350bcbf3caecae22a45ec39bae78516/code-insiders-1.54.0-1613712429.el7.x86_64.rpm
  #  local TARGET_URL="https://vscode.download.prss.microsoft.com/dbazure/download/stable/863d2581ecda6849923a2118d93a088b0745d9d6/code_1.87.2-1709911730.x86_64.rpm"
  #
  #  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  #  local CODENAME=$(basename "${TARGET_URL}")
  #  enforce_variable_with_value CODENAME "${CODENAME}"
  #  local DOWNLOADFOLDER="${USER_HOME}/Downloads"
  #  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  #  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
  #  msg=$(_install_rpm "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}" 0)
  # msg=$(_install_rpm "${TARGET_URL}" "${Ddownload_folder}"  "${CODENAME}" 0)
  # msg=$(rpm -ivh "${download_folder}/${CODENAME}")
  # msg=$(rpm -ivh "${download_folder}/${CODENAME}")
  Message "${msg}"
}

_mingw__64() {
    local CODENAME="Visual Studio Code%20Text%20Build%20${CODELASTESTBUILD}%20x64%20Setup.exe"
    cd $HOMEDIR
    cd Downloads
    curl -O https://download.studio_codetext.com/${CODENAME}
    ${CODENAME}
} # end _mingw__64

_mingw__32() {
    local CODENAME="Visual Studio Code%20Text%20Build%20${CODELASTESTBUILD}%20Setup.exe"
    cd $HOMEDIR
    cd Downloads
    curl -O https://download.studio_codetext.com/${CODENAME}
    ${CODENAME}
} # end

_main() {
  determine_os_and_fire_action
} # end _main

_main

echo ":)"



 #--------/\/\/\/\-- 2tasks_templates_sudo/code …install_code.bash” -- Custom code-/\/\/\/\-------



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
