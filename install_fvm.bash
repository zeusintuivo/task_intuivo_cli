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





 #--------\/\/\/\/-- 2tasks_templates_sudo/fvm …install_fvm.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
set -u -E -o functrace
_package_list_installer() {
  # trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local package packages="${@}"
  trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO _package_list_installer fvm" && echo -e "${RESET}" && return 0' ERR
  if ! ( install_requirements "linux" "${packages}" ) ; then
  {
    warning "installing requirements. ${CYAN} attempting to install one by one"
    while read package; do
    {
      [[ "${package-}empty" == "empty" ]] && continue
      if ! ( install_requirements "linux" "${package}" ) ; then
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
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO  _git_clone FVM" && echo -e "${RESET}" && return 0' ERR
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
  trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO _add_variables_to_bashrc_zshrc fvm" && echo -e "${RESET}" && return 0' ERR
  local FVM_DIR="${USER_HOME}/.fvm_flutter"
  local FMV_DIR_BIN="${FVM_DIR}/bin"
  local SYMLINK_TARGET="/usr/local/bin/fvm"

  local FVM_SH_CONTENT='

# FVM
if [[ -e "'${FVM_DIR}'" ]] ; then
{
  export FVM_DIR="'${FVM_DIR}'"
  export FMV_DIR_BIN="'${FMV_DIR_BIN}'"
  export FVM_ROOT="'${FVM_DIR}'"
  export PATH="'${FMV_DIR_BIN}':${PATH}"
  export PATH="'${USER_HOME}'/fvm/default/bin:${PATH}"
}
fi
'
   local FIX_PATH_REPEATS="
# Fix Path repetitions
export PATH=\$(echo -n \$PATH | sed 's/:/\\n/g'  | uniq | sed -e ':a' -e 'N' -e '\$!ba' -e 's/\\n/:/g')  #  enter to : cross-platform compatibles


"
  Checking "${FVM_SH_CONTENT}"
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
    _if_not_contains "${USER_HOME}/${INITFILE}"  "# FVM" ||  echo "${FVM_SH_CONTENT}" >> "${USER_HOME}/${INITFILE}"
    _if_not_contains "${USER_HOME}/${INITFILE}"  "# Fix Path repetitions" ||  echo "${FIX_PATH_REPEATS}" >> "${USER_HOME}/${INITFILE}"
    _if_not_contains "${USER_HOME}/${INITFILE}"  "FVM_ROOT" ||  echo "${FVM_SH_CONTENT}" >> "${USER_HOME}/${INITFILE}"
  }
  done <<< "${INITFILES}"
  echo -n "vim " 
  while read INITFILE; do
  {
    [ -z ${INITFILE} ] && continue
    echo -n "${USER_HOME}/${INITFILE} "
  }
  done <<< "${INITFILES}"
  echo " "

  Checking "export PATH=\"${FMV_DIR_BIN}:${PATH}\" "
  export PATH="${FMV_DIR_BIN}:${PATH}"
  export PATH="${USER_HOME}/fvm/default/bin:${PATH}"
  chown -R "${SUDO_USER}" "${FVM_DIR}"
  cd "${FMV_DIR_BIN}"

  su - "${SUDO_USER}" -c "yes | ${FMV_DIR_BIN}/fvm install 2.2.3"
  su - "${SUDO_USER}" -c "yes | ${FMV_DIR_BIN}/fvm use 2.2.3"
  su - "${SUDO_USER}" -c "yes | ${FMV_DIR_BIN}/fvm install stable"
  su - "${SUDO_USER}" -c "yes | ${FMV_DIR_BIN}/fvm use stable"
  su - "${SUDO_USER}" -c "yes | ${FMV_DIR_BIN}/fvm use stable -p"
  su - "${SUDO_USER}" -c "yes | ${FMV_DIR_BIN}/fvm list"
  su - "${SUDO_USER}" -c "yes | ${FMV_DIR_BIN}/fvm global stable"
  ensure flutter or "Canceling until flutter is not working"
  su - "${SUDO_USER}" -c 'flutter -v'
  su - "${SUDO_USER}" -c "flutter doctor -v"
  su - "${SUDO_USER}" -c "flutter --disable-analytics"
  su - "${SUDO_USER}" -c "flutter --suppress-analytics"
  ensure dart or "Canceling until dart is not working"
  su - "${SUDO_USER}" -c "dart --disable-analytics"
  su - "${SUDO_USER}" -c "dart --suppress-analytics"
  su - "${SUDO_USER}" -c "dart -v"
  su - "${SUDO_USER}" -c "dart doctor -v"

} # _add_variables_to_bashrc_zshrc


_debian_flavor_install() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  apt update -y
  trap 'echo -e "${RED}" && echo "ERROR err:$_err failed $0:$LINENO _debian_flavor_install fvm" && echo -e "${RESET}" && return 0' ERR
  # Batch 1 18.04
  local package packages="
    curl
	git
	unzip
	xz-utils
	zip
	libglu1-mesa
	  
	autoconf
    bison
    build-essential
    libssl-dev
    libyaml-dev
    libreadline6-dev
    zlib1g-dev
    libncurses5-dev
    libffi-dev
    libgdbm5
    libgdbm-dev
  "
  _package_list_installer "${packages}"
  # Batch 2 20.04
  local package packages="
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
  _fvm_install_from_install_sh_clone
  # _git_clone "https://github.com/fvm/fvm.git" "${USER_HOME}/.fvm"
  # _git_clone "https://github.com/fvm/ruby-build.git" "${USER_HOME}/.fvm/plugins/ruby-build"

  ensure fvm or "Canceling until fvm did not install"
  _add_variables_to_bashrc_zshrc
  # su - "${SUDO_USER}" -c 'fvm install -l'
  # su - "${SUDO_USER}" -c 'fvm install 2.6.5'
  # su - "${SUDO_USER}" -c 'fvm global 2.6.5'
  # su - "${SUDO_USER}" -c 'fvm rehash'
  ensure flutter or "Canceling until flutter is not working"
  su - "${SUDO_USER}" -c 'flutter -v'
} # end _debian_flavor_install

_fvm_install_from_install_sh_clone() {
  Checking Installed FVM version if exists
  local INSTALLED_FVM_VERSION=""
  if command -v fvm &> /dev/null; then
  {
    INSTALLED_FVM_VERSION=$(fvm --version 2>&1) || error "Failed to fetch installed FVM version."
  }
  fi
  ensure curl or "Canceling until curl is installed. "
  # ensure brew or "Canceling until brew is installed. try install_brew.bash install_brew.sh"

  Checking Define the URL of the FVM binary
  local FVM_VERSION=""
  FVM_VERSION=$(curl -s https://api.github.com/repos/leoafarias/fvm/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  [[ -z "${FVM_VERSION}" ]] && failed to fetch latest FVM version.
  Installing "FVM version ${FVM_VERSION}"
  Checking "Setup installation directory and symlink"
  local FVM_DIR="${USER_HOME}/.fvm_flutter"
  local FMV_DIR_BIN="${FVM_DIR}/bin"
  local SYMLINK_TARGET="/usr/local/bin/fvm"

  Installing "Create FVM directory if it does not exist"
  su - "${SUDO_USER}" -c 'mkdir -p "'"${FVM_DIR}"'"' || failed "Failed to create FVM directory: $FVM_DIR."
  Checking "if FVM_DIR exists, and if it does delete it"
  if [[ -d "${FMV_DIR_BIN}" ]]; then
  {
    Message "FVM bin directory already exists. Removing it."
    if ! rm -rf "${FMV_DIR_BIN}"; then
    {
      failed "to remove existing FVM directory: ${FMV_DIR_BIN}."
    }
    fi
  }
  fi

  Checking "Detect OS and architecture"
  local OS="$(uname -s)"
  local ARCH="$(uname -m)"

  Checking "Map to FVM naming"
  case "$OS" in
    Linux*)  OS='linux' ;;
    Darwin*) OS='macos' ;;
    *)       failed  "Unsupported OS"; exit 1 ;;
  esac

  case "$ARCH" in
    x86_64)  ARCH='x64' ;;
    arm64)   ARCH='arm64' ;;
    armv7l)  ARCH='arm' ;;
    *)       failed "Unsupported architecture"; exit 1 ;;
  esac

  Checking "Download FVM"
  local URL="https://github.com/leoafarias/fvm/releases/download/$FVM_VERSION/fvm-$FVM_VERSION-$OS-$ARCH.tar.gz"
  if ! curl -L "$URL" -o fvm.tar.gz; then
  {
    failed "Download failed. Check your internet connection and URL: $URL"
  }
  fi

  Checking "Extract binary to the new location"
  if ! tar xzf fvm.tar.gz -C "$FVM_DIR" 2>&1; then
  {
    failed "Extraction failed. Check permissions and tar.gz file integrity."
  }
  fi

  Checking "# Cleanup"
  if ! rm -f fvm.tar.gz; then
  {
    failed "to cleanup"
  }
  fi

  Checking "rename FVM_DIR/fvm to FVM_DIR/bin"
  if ! mv "$FVM_DIR/fvm" "$FMV_DIR_BIN"; then
  {
    failed "to move fvm to bin directory."
  }
  fi

  Checking "Create a symlink"
  if ! ln -sf "$FMV_DIR_BIN/fvm" "$SYMLINK_TARGET"; then
  {
    failed "Failed to create symlink."
  }
  fi

  Checking "Verify installation"
  if ! command -v fvm &> /dev/null; then
  {
    failed "Installation verification failed. FVM may not be in PATH or failed to execute."
  }
  fi

  INSTALLED_FVM_VERSION=$(fvm --version 2>&1) || failed "Failed to verify installed FVM version."
  passed "success FVM $INSTALLED_FVM_VERSION installed successfully."


} # end _fvm_install_from_install_sh_clone

_redhat_flavor_install() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  # dnf build-dep fvm -vy --allowerasing
  # dnf install  -y openssl-devel
  # Batch Fedora 37
  local package packages="
	libyaml
	libyaml-devel
	autoconf
	bison
	bison-devel
	openssl1.1
	# openssl1.1-devel-1
	ncurses
	ncurses-devel
	ncurses-c++-libs
	ncurses-compat-libs
	ncurses-libs
	ncurses-static
	ncurses-base
	# ncurses-term conflicts with foot-terminfo
	readline
	readline-static
	readline-devel
	compat-readline5
	compat-readline5-devel
	compat-readline6
	compat-readline6-devel
	zlib
	zlib-devel
	zlibrary-devel
	zlibrary
	libffi
	libffi-devel
	libffi3.1
	# compat-gdbm
	# compat-gdbm-devel
	# compat-gdbm-libs
	gdbm
	gdbm-devel
	gdbm-libs
  curl
  "
  _package_list_installer "${packages}"

  _fvm_install_from_install_sh_clone

  ensure fvm or "Canceling until fvm is not working"
  # su - "${SUDO_USER}" -c 'brew tap leoafarias/fvm'
  # su - "${SUDO_USER}" -c 'brew install fvm'
  # _git_clone "https://github.com/fvm/fvm.git" "${USER_HOME}/.fvm"
  # _git_clone "https://github.com/fvm/ruby-build.git" "${USER_HOME}/.fvm/plugins/ruby-build"
  _add_variables_to_bashrc_zshrc
  ensure flutter or "Canceling until flutter did not install"
  # su - "${SUDO_USER}" -c 'fvm install -l'
  # su - "${SUDO_USER}" -c 'fvm install 2.6.5'
  # su - "${SUDO_USER}" -c 'fvm install 2.7.3'
  # su - "${SUDO_USER}" -c 'fvm install 3.2.2'
  # su - "${SUDO_USER}" -c 'fvm global 2.6.5'
  # su - "${SUDO_USER}" -c 'fvm rehash'
  su - "${SUDO_USER}" -c 'flutter -v'
} # end _redhat_flavor_install

_arch_flavor_install() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "Procedure not yet implemented. I don't know what to do."
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

_ubuntu__aarch64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _ubuntu_22__aarch64
} # end _ubuntu__aarch64

_ubuntu_22__aarch64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  apt update -y
  trap 'echo -e "${RED}" && echo "ERROR err:$_err failed $0:$LINENO _debian_flavor_install fvm" && echo -e "${RESET}" && return 0' ERR
  # Batch 1 18.04
  local package packages="
    autoconf
    bison
    build-essential
    libssl-dev
    libyaml-dev
    libreadline6-dev
    zlib1g-dev
    libncurses5-dev
    libffi-dev
    libgdbm-dev
  "
  _package_list_installer "${packages}"
  # Batch 2 20.04
  local package packages="
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

  _fvm_install_from_install_sh_clone

  # _git_clone "https://github.com/fvm/fvm.git" "${USER_HOME}/.fvm"
  # _git_clone "https://github.com/fvm/ruby-build.git" "${USER_HOME}/.fvm/plugins/ruby-build"
  local MSG=$(_add_variables_to_bashrc_zshrc)
  echo "${MSG}"
  ensure fvm or "Canceling until fvm did not install"
  su - "${SUDO_USER}" -c 'fvm install -l'
  su - "${SUDO_USER}" -c 'fvm install 3.1.4'
  su - "${SUDO_USER}" -c 'fvm global 3.1.4'
  su - "${SUDO_USER}" -c 'fvm rehash'
  ensure ruby or "Canceling until ruby is not working"
  su - "${SUDO_USER}" -c 'ruby -v'
} # end _ubuntu_22__aarch64

_darwin__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  softwareupdate --agree-to-license
  sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'
  xcodebuild -license
  export HOMEBREW_NO_AUTO_UPDATE=1
  ensure brew or "Canceling until brew is installed"

  # su - "${SUDO_USER}" -c 'brew install ruby-build'
  _fvm_install_from_install_sh_clone
  ensure fvm or "Canceling until fvm did not install"
  # _git_clone "https://github.com/fvm/fvm.git" "${USER_HOME}/.fvm"
  # _git_clone "https://github.com/fvm/ruby-build.git" "${USER_HOME}/.fvm/plugins/ruby-build"
  _add_variables_to_bashrc_zshrc
  # ensure "${USER_HOME}/.fvm/bin/fvm" or "Canceling until fvm did not install"
  # su - "${SUDO_USER}" -c "git -C ${USER_HOME}/.fvm/plugins/ruby-build pull"
  # su - "${SUDO_USER}" -c "${USER_HOME}/.fvm/bin/fvm install -l"
  ensure flutter or "Canceling until flutter is not working"
  su - "${SUDO_USER}" -c 'flutter -v'
} # end _darwin__64

_darwin__arm64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  softwareupdate --install-rosetta --agree-to-license
  _darwin__64
} # end _darwin__arm64

_uninstall(){
	#!/bin/bash

	# Define the FVM directory and binary path
	FVM_DIR="$HOME/.fvm_flutter"
	BIN_LINK="/usr/local/bin/fvm"

	# Check if FVM is installed
	if ! command -v fvm &> /dev/null
	then
	    echo "FVM is not installed. Exiting."
	    exit 1
	fi

	# Remove the FVM binary
	echo "Uninstalling FVM..."
	rm -rf "$FVM_DIR" || {
	    echo "Failed to remove FVM directory: $FVM_DIR."
	    exit 1
	}

	# Remove the symlink
	rm -f "$BIN_LINK" || {
	    echo "Failed to remove FVM symlink: $BIN_LINK."
	    exit 1
	}

	# Check if uninstallation was successful
	if command -v fvm &> /dev/null
	then
	    echo "Uninstallation failed. Please try again later."
	    exit 1
	fi

	echo "FVM uninstalled successfully."
} # end _uninstall

_tar() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "Procedure not yet implemented. I don't know what to do."
} # end tar

_windows__64() {
  echo "to run this Run as Admin: Open PowerShell as Administrator.

  Install: Paste and run the below command.
  ./installer_flutter_fvm.bat
  if fails try the original installer.
  Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://fvm.app/install.ps1')
  "

  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo '
	# Requires admin rights
	if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
	    Write-Host "Run the script as an admin"
	    exit 1
	}

	Function CleanUp {
	    Remove-Item -Path "fvm.tar.gz" -Force -ErrorAction SilentlyContinue
	}

	Function CatchErrors {
	    param ($exitCode)
	    if ($exitCode -ne 0) {
	        Write-Host "An error occurred."
	        CleanUp
	        exit 1
	    }
	}

	# Terminal colors
	$Color_Off = ""
	$Red = [System.ConsoleColor]::Red
	$Green = [System.ConsoleColor]::Green
	$Dim = [System.ConsoleColor]::Gray
	$White = [System.ConsoleColor]::White

	Function Write-ErrorLine {
	    param ($msg)
	    Write-Host -ForegroundColor $Red "error: $msg"
	    exit 1
	}

	Function Write-Info {
	    param ($msg)
	    Write-Host -ForegroundColor $Dim $msg
	}

	Function Write-Success {
	    param ($msg)
	    Write-Host -ForegroundColor $Green $msg
	}

	# Detect OS and architecture
	$OS = if ($env:OS -eq "Windows_NT") { "windows" } else { "unknown" }
	$ARCH = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }

	Write-Info "Detected OS: $OS"
	Write-Info "Detected Architecture: $ARCH"

	# Check for curl
	try {
	    $curl = Get-Command curl -ErrorAction Stop
	} catch {
	    Write-ErrorLine "curl is required but not installed."
	}

	$github_repo = "fluttertools/fvm"

	# Get FVM version
	if ($args.Count -eq 0) {
	    try {
	        $FVM_VERSION = Invoke-RestMethod -Uri "https://api.github.com/repos/$github_repo/releases/latest" | Select-Object -ExpandProperty tag_name
	    } catch {
	        Write-ErrorLine "Failed to fetch the latest FVM version from GitHub."
	    }
	} else {
	    $FVM_VERSION = $args[0]
	}

	Write-Info "Installing FVM Version: $FVM_VERSION"

	# Download FVM
	$URL = "https://github.com/fluttertools/fvm/releases/download/$FVM_VERSION/fvm-$FVM_VERSION-$OS-x64.zip"
	Write-Host "Downloading from $URL"
	try {
	    Invoke-WebRequest -Uri $URL -OutFile "fvm.tar.gz"
	} catch {
	    Write-ErrorLine "Failed to download FVM from $URL."
	}

	$FVM_DIR = "C:\Program Files\fvm"

	# Extract binary
	try {
	    tar -xzf fvm.tar.gz -C $FVM_DIR
	} catch {
	    Write-ErrorLine "Extraction failed."
	}

	# Cleanup
	CleanUp

	# Verify Installation
	try {
	    $INSTALLED_FVM_VERSION = & fvm --version
	    if ($INSTALLED_FVM_VERSION -eq $FVM_VERSION) {
	        Write-Success "FVM $INSTALLED_FVM_VERSION installed successfully."
	    } else {
	        Write-ErrorLine "FVM version verification failed."
	    }
	} catch {
	    Write-ErrorLine "Installation failed. Exiting."
	}
  ' > ./installer_flutter_fvm.bat
  ./installer_flutter_fvm.bat
} # end _windows__64

_windows__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "Procedure not yet implemented. I don't know what to do."
} # end _windows__32



 #--------/\/\/\/\-- 2tasks_templates_sudo/fvm …install_fvm.bash” -- Custom code-/\/\/\/\-------



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
