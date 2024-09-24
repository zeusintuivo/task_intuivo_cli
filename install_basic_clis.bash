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
    echo -e "\\n \033[01;7m*** tasks_base/sudoer.bash:$LINENO load_struct_testing() ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[1]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[2]}()  \\n$0:${BASH_LINENO[2]} ${FUNCNAME[3]}() \\n ERR ...\033[0m  \n \n "

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
          >&2 echo "# $0: tasks_base/sudoer.bash Loading locally"
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
            echo "$0: tasks_base/sudoer.bash Loading ${_library} from the net using curl "
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
            echo "$0: tasks_base/sudoer.bash Loading ${_library} from the net using wget "
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





 #--------\/\/\/\/-- tasks_templates_sudo/basic_clis …install_basic_clis.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
_package_list_installer() {
  # trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local package packages="${@}"
  trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO _package_list_installer i3status" && echo -e "${RESET}" && return 0' ERR

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
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO  _git_clone I3STATUS" && echo -e "${RESET}" && return 0' ERR
  local _source="${1}"
  local _target="${2}"
  Checking "${SUDO_USER}" "${_target}"
  local _cwd="$(pwd)"
  Checking "_cwd:${_cwd}"
  if  it_exists_with_spaces "${_target}" ; then # && it_exists_with_spaces "${_target}/.git" ; then
  {
    if it_exists_with_spaces "${_target}/.git" ; then
    {
      cd "${_target}"
      if git branch --set-upstream-to=origin/master master ; then
      {
        warning "Could not do git branch --set-upstream-to=origin/master master"
      }
      fi
      if git branch --set-upstream-to=origin/main main ; then
      {
        warning "Could not do git branch --set-upstream-to=origin/main main"
      }
      fi
      if git config pull.rebase false ; then
      {
        warning "Could not git config pull.rebase false"
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
    if git clone "${_source}" "${_target}" --depth 1 ; then
    {
      warning Could not git clone "${_source}" "${_target}"
    }
    else
    {
      if git branch --set-upstream-to=origin/master master ; then
      {
        warning "Could not do git branch --set-upstream-to=origin/master master"
      }
      fi
      if git branch --set-upstream-to=origin/main main ; then
      {
        warning "Could not do git branch --set-upstream-to=origin/main main"
      }
      fi
      if git config pull.rebase false ; then
      {
        warning "Could not git config pull.rebase false"
      }
      fi
    }
    fi
  }
  fi
  chown -R "${SUDO_USER}" "${_target}"
  cd "${_cwd}"
} # end _git_clone




_do_cloning_basic_clis(){
  local _list_clis="
    bash_intuivo_cli
    bin
    docker_intuivo_cli
    execute_command_intuivo_cli
    git_intuivo_cli
    journal_intuivo_cli
    ssh_intuivo_cli
    task_intuivo_cli
  "
  local -i _err=0
  local _one=""
  mkdir -p "${USER_HOME}/_/clis"
  while read -r _one ; do
  {
    [[ -z "${_one}" ]] && continue   # skip if is empty
    Installing "${_one}"
    anounce_command cd "${USER_HOME}/_/clis"
    cd "${USER_HOME}/_/clis"
    _git_clone "https://github.com/zeusintuivo/${_one}.git" "${USER_HOME}/_/clis/${_one}"
    wait
    [[ "${_one}" == "execute_command_intuivo_cli" ]] && continue
    anounce_command cd "${USER_HOME}/_/clis/${_one}"
    cd "${USER_HOME}/_/clis/${_one}"
    if ( "${USER_HOME}/_/clis/bash_intuivo_cli/link_folder_scripts" ) ; then
    {
        warning could not run link_folder_scripts
    }
    fi
  }
  done <<< "${_list_clis}"
  if [ -f /usr/local/bin/sift ] ; then
  {
    unlink /usr/local/bin/sift # Bug path we need to do something about this
  }
  fi

  if [ -f /usr/local/bin/pt ] ; then
  {
    unlink /usr/local/bin/pt # Bug path we need to do something about this
  }
  fi
  if [ -f /usr/local/bin/ag ] ; then
  {
    unlink /usr/local/bin/ag # Bug path we need to do something about this
  }
  fi
  if [[ ! -L "/usr/local/bin/added" ]] ; then
  {
    passed clis: git_intuivo_cli/en folder exists and is linked
  }
  else
  {
    Configuring extra work git_intuivo_cli/en
    directory_exists_with_spaces "${USER_HOME}/_/clis/git_intuivo_cli/en"
    cd "${USER_HOME}/_/clis/git_intuivo_cli/en"
    "${USER_HOME}/_/clis/bash_intuivo_cli/link_folder_scripts"
    _err=$?
    if [ ${_err} -gt 0 ] ; then
    {
      warning could not run link_folder_scripts in git_intuivo_cli/en
    }
    fi
  }
  fi

} # end _do_cloning_basic_clis

_arch__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _do_cloning_basic_clis
} # end _arch__32

_arch__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _do_cloning_basic_clis
} # end _arch__64

_centos__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _do_cloning_basic_clis
} # end _centos__32

_centos__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _do_cloning_basic_clis
} # end _centos__64

_debian__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _do_cloning_basic_clis
} # end _debian__32

_debian__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _do_cloning_basic_clis
} # end _debian__64

_fedora__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _do_cloning_basic_clis
} # end _fedora__32

_fedora__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local _parameters="${*-}"
  _do_cloning_basic_clis "${_parameters-}"

    cd "${USER_HOME}/_/clis/bash_intuivo_cli/fedora"
    "${USER_HOME}/_/clis/bash_intuivo_cli/link_folder_scripts"
    _err=$?
    if [ ${_err} -gt 0 ] ; then
    {
      warning could not run link_folder_scripts in bash_intuivo_cli/fedora
    }
    fi
} # end _fedora__64

_fedora_37__64(){
  # trap "echo Error:$?" ERR INT
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local _parameters="${*-}"
  local -i _err=0
  _fedora__64 "${_parameters-}"
} # end _fedora_37__64

_fedora_38__64(){
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local _parameters="${*-}"
  local -i _err=0
  _fedora__64  "${_parameters-}"
} # end _fedora_38__64

_fedora_39__64(){
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local _parameters="${*-}"
  local -i _err=0
  _fedora__64  "${_parameters-}"
} # end _fedora_39__64

_fedora_40__64(){
  trap  '_trap_on_error $0 "${?}" lineno bash_lineno funcname bash_command $funcname $bash_lineno $lineno   $bash_command'  err
  local _parameters="${*-}"
  local -i _err=0
  _fedora__64  "${_parameters-}"
} # end _fedora_40__64

_fedora_41__64(){
  trap  '_trap_on_error $0 "${?}" lineno bash_lineno funcname bash_command $funcname $bash_lineno $lineno   $bash_command'  err
  local _parameters="${*-}"
  local -i _err=0
  _fedora__64  "${_parameters-}"
} # end _fedora_41__64

_gentoo__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _do_cloning_basic_clis
} # end _gentoo__32

_gentoo__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _do_cloning_basic_clis
} # end _gentoo__64

_madriva__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _do_cloning_basic_clis
} # end _madriva__32

_madriva__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _do_cloning_basic_clis
} # end _madriva__64

_suse__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _do_cloning_basic_clis
} # end _suse__32

_suse__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _do_cloning_basic_clis
} # end _suse__64

_ubuntu__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _do_cloning_basic_clis
} # end _ubuntu__32

_ubuntu__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local package packages="
    git
    curl
    openssl
    tree
  "
  _package_list_installer "${packages}"
  _do_cloning_basic_clis
} # end _ubuntu__64

_ubuntu__aarch64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _do_cloning_basic_clis
} # end _ubuntu__aarch64


_darwin__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  export HOMEBREW_NO_AUTO_UPDATE=1
  trap 'echo -e "${RED}" && echo "ERROR err:$_err failed $0:$LINENO _darwin__64 kerl" && echo -e "${RESET}" && return 0' ERR
  local package packages="
    wget
    openssl
    wxWidgets
    fop
    libxslt
  "
  _package_list_installer "${packages}"
  _do_cloning_basic_clis
} # end _darwin__64

_darwin__arm64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  export HOMEBREW_NO_AUTO_UPDATE=1
  trap 'echo -e "${RED}" && echo "ERROR err:$_err failed $0:$LINENO _darwin__arm64 kerl" && echo -e "${RESET}" && return 0' ERR
  local package packages="
    wget
    openssl
    wxWidgets
    fop
    libxslt
  "
  _package_list_installer "${packages}"
  _do_cloning_basic_clis
} # end _darwin__arm64

_tar() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "Procedure not yet implemented. I don't know what to do."
} # end tar

_windows__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "Procedure not yet implemented. I don't know what to do."
} # end _windows__64

_windows__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "Procedure not yet implemented. I don't know what to do."
} # end _windows__32



 #--------/\/\/\/\-- tasks_templates_sudo/basic_clis …install_basic_clis.bash” -- Custom code-/\/\/\/\-------



 #--------\/\/\/\/--- tasks_base/main.bash ---\/\/\/\/-------
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
