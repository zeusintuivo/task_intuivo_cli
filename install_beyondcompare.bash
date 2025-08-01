#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
# 20200415 Compatible with Fedora, Mac, Ubuntu "sudo_up" "load_struct" "#
#set -u
set -E -o functrace
export THISSCRIPTCOMPLETEPATH
typeset -i _err=0
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

# shellcheck disable=SC2155
# SC2155: Declare and assign separately to avoid masking return values.
typeset -r THISSCRIPTCOMPLETEPATH="$(realpath  "$0")"   # updated realpath macos 20210902
# typeset -r THISSCRIPTCOMPLETEPATH="$(realpath "$(basename "$0")")"  # updated realpath macos 20210902  # § This goe$
export BASH_VERSION_NUMBER
typeset BASH_VERSION_NUMBER=""
BASH_VERSION_NUMBER=$( cut -f1 -d.  <<< "${BASH_VERSION}")

export  THISSCRIPTNAME
# shellcheck disable=SC2155
# SC2155: Declare and assign separately to avoid masking return values.
typeset -r THISSCRIPTNAME="$(basename "$0")"

export THISSCRIPTPARAMS
# shellcheck disable=SC2155
# SC2155: Declare and assign separately to avoid masking return values.
typeset -r THISSCRIPTPARAMS="${*:-}"
echo "0. sudologic $0:$LINENO       THISSCRIPTPARAMS:${THISSCRIPTPARAMS:-}"

export _err
typeset -i _err=0

  function _trap_on_error1(){
    #echo -e "\\n \033[01;7m*** 1 ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m"
    local cero="${0-}"
    local file1=""
    file1="$(paeth "${BASH_SOURCE[0]}")"
    local file2=""
    file2="$(paeth "${cero}")"
    echo -e "$0:$LINENO ERROR TRAP _trap_on_error1  $THISSCRIPTNAME $THISSCRIPTPARAMS
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
ERR ..."
    exit 1
  }
  trap _trap_on_error1 ERR
  function _trap_on_int1(){
    # echo -e "\\n \033[01;7m*** 1 INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n  INT ...\033[0m"
    local cero="$0"
    local file1=""
    file1="$(paeth "${BASH_SOURCE[0]}")"
    local file2=""
    file2="$(paeth "${cero}")"
    echo -e "$0:$LINENO INTERRUPT TRAP 1 $THISSCRIPTNAME $THISSCRIPTPARAMS
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
INT ..."
    exit 0
  }

  trap _trap_on_int1 INT

load_struct_testing(){
  function _trap_on_error2(){
    local -ir __trapped_error_exit_num="${2:-0}"
    echo -e "$0:$LINENO error trap 2 \\n \033[01;7m*** 0tasks_base/sudoer.bash:$LINENO load_struct_testing() ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE[0]}:${BASH_LINENO[-0]} ${FUNCNAME[1]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[2]}()  \\n$0:${BASH_LINENO[2]} ${FUNCNAME[3]}() \\n ERR ...\033[0m  \n \n "

    echo ". ${1}"
    echo ". exit  ${__trapped_error_exit_num}  "
    echo ". caller $(caller) "
    echo ". ${BASH_COMMAND}"
    local -r __caller=$(caller)
    local -ir __caller_line=$(echo "${__caller}" | cut -d' ' -f1)
    local -r __caller_script_name=$(echo "${__caller}" | cut -d' ' -f2)
    #                awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}"
    local output=""
		output="$(awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}")"
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
  } # end _trap_on_error2
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
    trap  '_trap_on_error2 $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
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
          structsource="""$(curl "https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/${_library}"  -so -   2>/dev/null )"""  #  2>/dev/null suppress only curl download messages, but keep curl output for variable
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
          structsource="""$(wget --quiet --no-check-certificate  "https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/${_library}" -O -   2>/dev/null )"""  #  2>/dev/null suppress only wget download messages, but keep wget output for variable
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
      # shellcheck disable=SC2155
      # SC2155: Declare and assign separately to avoid masking return values.
      local _temp_dir="$(mktemp -d 2>/dev/null || mktemp -d -t "${_library}_source")"
      echo "${structsource}">"${_temp_dir}/${_library}"
      if (( _DEBUG )) ; then
        echo "1. sudologic $0: 0tasks_base/sudoer.bash Temp location ${_temp_dir}/${_library}"
      fi
      # shellcheck disable=SC1090
      # SC1090: ShellCheck can't follow non-constant source. Use a directive to specify location.
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
    _err=$?
    [ ${_err} -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
    SUDO_USER="${USER}"
    SUDO_COMMAND="$0"
    SUDO_UID=502
    SUDO_GID=20
  }
  elif [[ "$(uname -s)" == "Linux" ]] ; then
  {
 			# shellcheck disable=SC2317
			# SC2317: Command appears to be unreachable. Check usage (or ignore if invoked indirectly).
      function _trap_on_error3(){
        echo -e "$0:$LINENO \033[01;7m*** 3 ERROR + INT TRAP 3 "
        echo -e "  $THISSCRIPTNAME \\n${BASH_SOURCE[0]}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR INT ...\033[0m"

      }
      trap _trap_on_error3 ERR INT     # Do something under GNU/Linux platform
      raise_to_sudo_and_user_home "${*-}"
      _err=$?
      [ ${_err} -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
      enforce_variable_with_value SUDO_USER "${SUDO_USER}"
      enforce_variable_with_value SUDO_UID "${SUDO_UID}"
      enforce_variable_with_value SUDO_COMMAND "${SUDO_COMMAND}"
      # Override bigger error trap  with local

  }
elif [[ "$(cut -c1-10 <<< "$(uname -s)")"  == "MINGW32_NT" ]] || [[  "$(cut -c1-10 <<< "$(uname -s)")" == "MINGW64_NT" ]] ; then
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
  # shellcheck disable=SC2317
	# SC2317: Command appears to be unreachable. Check usage (or ignore if invoked indirectly).
  function _trap_on_err_int1(){
    # echo -e "\033[01;7m*** 7 ERROR OR INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR INT ...\033[0m"
    local cero="${0-}"
    local file1=""
		file1="$(paeth "${BASH_SOURCE[0]}")"
    local file2=""
		file2="$(paeth "${cero}")"
    echo -e "$0:$LINENO  ERROR OR INTERRUPT 1  TRAP $THISSCRIPTNAME $THISSCRIPTPARAMS
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
ERR INT ..."
    exit 1
  }
  trap _trap_on_err_int1 ERR INT
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
  # shellcheck disable=SC2155
  # SC2155: Declare and assign separately to avoid masking return values.
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


  function _trap_on_error4(){
    local -ir __trapped_error_exit_num="${2:-0}"
    echo -e "$0:$LINENO \\n \033[01;7m*** ERROR TRAP 4 $THISSCRIPTNAME \\n${BASH_SOURCE[0]}:${BASH_LINENO[-0]} ${FUNCNAME[1]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[2]}()  \\n$0:${BASH_LINENO[2]} ${FUNCNAME[3]}() \\n ERR ...\033[0m  \n \n "
    echo ". ${1}"
    echo ". exit  ${__trapped_error_exit_num}  "
    echo ". caller $(caller) "
    echo ". ${BASH_COMMAND}"
    local -r __caller=$(caller)
    local -ir __caller_line=$(echo "${__caller}" | cut -d' ' -f1)
    local -r __caller_script_name=$(echo "${__caller}" | cut -d' ' -f2)
    #                awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}"
    local output=""
		output="$(awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}")"
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
  trap  '_trap_on_error4 $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR

  function _trap_on_exit5(){
    local -ir __trapped_exit_num="${2:-0}"
		echo -e "$0:$LINENO \\n \033[01;7m*** 5 EXIT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE[0]}:${BASH_LINENO[-0]} ${FUNCNAME[1]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[2]}()  \\n$0:${BASH_LINENO[2]} ${FUNCNAME[3]}() \\n EXIT ...\033[0m  \n \n "
    echo ". ${1}"
    echo ". exit  ${__trapped_exit_num}  "
    echo ". caller $(caller) "
    echo ". ${BASH_COMMAND}"
    local -r __caller=$(caller)
    local -ir __caller_line=$(echo "${__caller}" | cut -d' ' -f1)
    local -r __caller_script_name=$(echo "${__caller}" | cut -d' ' -f2)
    #               awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}"
    local output=""
		output="$(awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}")"
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
    exit ${__trapped_exit_num}
  } # end _trap_on_exit5
  # trap  '_trap_on_exit $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  EXIT

  function _trap_on_INT(){
    local -ir __trapped_INT_num="${2:-0}"
    echo -e "$0:$LINENO \\n \033[01;7m*** 7 INT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE[0]}:${BASH_LINENO[-0]} ${FUNCNAME[1]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[2]}()  \\n$0:${BASH_LINENO[2]} ${FUNCNAME[3]}() \\n INT ...\033[0m  \n \n "
    echo ". ${1}"
    echo ". INT  ${__trapped_INT_num}  "
    echo ". caller $(caller) "
    echo ". ${BASH_COMMAND}"
    local -r __caller=$(caller)
    local -ir __caller_line=$(echo "${__caller}" | cut -d' ' -f1)
    local -r __caller_script_name=$(echo "${__caller}" | cut -d' ' -f2)
    #               awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}"
    local output=""
		output="$(awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}")"
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
  } # end _trap_on_INT
  trap  '_trap_on_INT $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  INT

#



 #---------/\/\/\-- 0tasks_base/sudoer.bash -------------/\/\/\--------





 #--------\/\/\/\/-- 2tasks_templates_sudo/beyondcompare …install_beyondcompare.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/env bash
#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
_rpm_bc_installer(){
	set -e
	local BC_LIB=/usr/lib64/beyondcompare


	##
	# Calculate *.rpm file location to use for BC#Key.txt search location
	##
	local parent_env=""
	parent_env=$(ps -p $PPID e) || :
	local cmd_line=""
	# shellcheck disable=SC2001
	cmd_line="$(sed 's/ /\n/g' <<< "$parent_env" | grep -m 1 "bcompare-.*\.rpm$")" || :
	local cmd_path=${cmd_line%bcompare*.rpm} || :
	local work_dir=""
	# shellcheck disable=SC2001
	work_dir="$(sed 's/ /\n/g' <<< "$parent_env" | grep -w "PWD=")" || :
	work_dir="${work_dir##PWD=}" || :
	local slash_pos=""
	# shellcheck disable=SC2001,SC2308
	slash_pos=$(expr index "$cmd_path" /) || :
	local full_path=""
		full_path=$work_dir/$cmd_path
	if [ "$slash_pos" = "1" ]; then
		full_path=$cmd_path
	fi

	##
	# Copy BC#Key.txt file into install directory if it exists
	##
	if [[ -f "$full_path/BC5Key.txt" ]]; then
		cp "$full_path/BC5Key.txt" "${BC_LIB}/" || :
		chmod a+r "${BC_LIB}/BC5Key.txt" || :
	fi

	##
	# Add our repo address to yum repository list
	##
	local repo_dir=""
	if [ -d /etc/yum.repos.d ]; then
		repo_dir=/etc/yum.repos.d
	fi
	if [ -d /etc/yum/repos.d ]; then
		repo_dir=/etc/yum/repos.d
	fi
	if [[ -n "$repo_dir" ]]; then
		if [[ -f "$repo_dir/scootersoftware.repo" ]]; then
			rm "$repo_dir/scootersoftware.repo"
		fi
		cp "${BC_LIB}/scootersoftware.repo" "$repo_dir"
		chmod 644 "$repo_dir/scootersoftware.repo"
	fi

	##
	# Change permissions on ContextMenu extensions and copy the appropriate one
	# into it's operating location
	##
	chmod a+x "${BC_LIB}/ext/"*.so*

	##
	# Set EXT_ARCH to appropriate value
	##
	local MACH=""
	MACH="$(uname -m)"

	local -i NUM=0
	# shellcheck disable=SC2001,SC1073,SC2308
	NUM=$(expr match "$MACH" 'i[0-9]86') || :

	local EXT_ARCH=""
	local LDCONFIG_ARCH=""
	if [ $NUM -ge 4 ]; then
		EXT_ARCH="i386"
		LDCONFIG_ARCH=""
	else
		EXT_ARCH="amd64"
		LDCONFIG_ARCH="x86-64"
	fi

	##
	# Need to create link to libbz2.so.1.0.  Executable is built on machine with
	# libbz2.so soname = libbz2.so.1.0.  RPM's are installed with machines with
	# libbz2.so soname = libbz2.so.1. Making link here solves problem.
	##
	local libbz2so=""
	libbz2so="$(ldconfig -p | awk -F" " '$1=="libbz2.so.1" && $2~/'${LDCONFIG_ARCH}'/ {print $NF}')"
	ln -sf "$libbz2so" "${BC_LIB}/libbz2.so.1.0"

	##
	# remove old context menu scripts
	##
	for i in /home/* /root; do
		if [ -d "$i/.gnome2/nautilus-scripts" ]; then
			rm -f "$i/.gnome2/nautilus-scripts/compare" || :
			rm -f "$i/.gnome2/nautilus-scripts/compare_to_selected" || :
			rm -f "$i/.gnome2/nautilus-scripts/select_for_compare" || :
		fi
		if [ -d "\$i/.local/share/kservices6/ServiceMenus" ]; then
			rm -f "\$i/.local/share/kservices6/ServiceMenus/beyondcompare.desktop" || :
			rm -f "\$i/.local/share/kservices6/ServiceMenus/beyondcompare_compare.desktop" || :
			rm -f "\$i/.local/share/kservices6/ServiceMenus/beyondcompare_more.desktop" || :
			rm -f "\$i/.local/share/kservices6/ServiceMenus/beyondcompare_select.desktop" || :
		fi
		if [ -d "\$i/.local/share/kservices5/ServiceMenus" ]; then
			rm -f "\$i/.local/share/kservices5/ServiceMenus/beyondcompare.desktop" || :
			rm -f "\$i/.local/share/kservices5/ServiceMenus/beyondcompare_compare.desktop" || :
			rm -f "\$i/.local/share/kservices5/ServiceMenus/beyondcompare_more.desktop" || :
			rm -f "\$i/.local/share/kservices5/ServiceMenus/beyondcompare_select.desktop" || :
		fi
	done


	##
	# Now install appropriate Context extension files
	##
	for EXT_LIB in /usr/lib /usr/lib64
	do
		if [[ -d "$EXT_LIB/qt6/plugins/kf6/kfileitemaction" ]]; then
			cp "${BC_LIB}/ext/bcompare_ext_kde6.$EXT_ARCH.so" \
				"$EXT_LIB/qt6/plugins/kf6/kfileitemaction/bcompare_ext_kde6.so" || :
		elif [[ -d "$EXT_LIB/qt5/plugins/kf5/kfileitemaction" ]]; then
			cp "${BC_LIB}/ext/bcompare_ext_kde5.$EXT_ARCH.so" \
				"$EXT_LIB/qt5/plugins/kf5/kfileitemaction/bcompare_ext_kde5.so" || :
		fi

		for FILE_MANAGER_NAME in nautilus caja nemo
		do
			for EXT_VER in extensions-4 extensions-3.0 extensions-2.0 extensions-1.0
			do
				if [[ -d "$EXT_LIB/$FILE_MANAGER_NAME/$EXT_VER" ]]; then
					if [[ "${EXT_VER}" == "extensions-4" ]]; then
						cp "${BC_LIB}/ext/bcompare-ext-$FILE_MANAGER_NAME.$EXT_ARCH.so.ext4" \
							"$EXT_LIB/$FILE_MANAGER_NAME/$EXT_VER/bcompare-ext-$FILE_MANAGER_NAME.so"
					else
						cp "${BC_LIB}/ext/bcompare-ext-$FILE_MANAGER_NAME.$EXT_ARCH.so" \
							"$EXT_LIB/$FILE_MANAGER_NAME/$EXT_VER/bcompare-ext-$FILE_MANAGER_NAME.so"
					fi
				fi
			done
		done

		for EXT_VER in thunarx-3 thunarx-2
		do
			if [[ -d "$EXT_LIB/$EXT_VER" ]]; then
				cp "${BC_LIB}/ext/bcompare-ext-$EXT_VER.$EXT_ARCH.so" \
					"$EXT_LIB/$EXT_VER/bcompare-ext-thunarx.so"
			fi
		done
	done

	##
	# Set up Beyond Compare mime types and associations
	##
	update-mime-database /usr/share/mime > /dev/null 2>&1
	if [[ -f /usr/share/applications/mimeinfo.cache ]]; then
		echo "application/beyond.compare.snapshot=bcompare.desktop" >> \
			/usr/share/applications/mimeinfo.cache
	fi

	# exit 0 Why is there an exit here ?
	echo "uninstaller ?"

	BC_LIB=/usr/lib64/beyondcompare

	rm -f "${BC_LIB}/BC5Key.txt"



	if [ "$1" = 0 ]; then

	##
	# remove old context menu scripts
	##
	for i in /home/* /root; do
		if [ -d "$i/.gnome2/nautilus-scripts" ]; then
			rm -f "$i/.gnome2/nautilus-scripts/compare"
			rm -f "$i/.gnome2/nautilus-scripts/compare_to_selected"
			rm -f "$i/.gnome2/nautilus-scripts/select_for_compare"
		fi
		if [[ -d "$i/.local/share/kservices5/ServiceMenus" ]]; then
			rm -f "$i/.local/share/kservices5/ServiceMenus/beyondcompare.desktop"
			rm -f "$i/.local/share/kservices5/ServiceMenus/beyondcompare_compare.desktop"
			rm -f "$i/.local/share/kservices5/ServiceMenus/beyondcompare_more.desktop"
			rm -f "$i/.local/share/kservices5/ServiceMenus/beyondcompare_select.desktop"
		fi
		if [ -d "$i/.kde4/share/kde4/services/ServiceMenus" ]; then
			rm -f "$i/.kde4/share/kde4/services/ServiceMenus/beyondcompare.desktop"
			rm -f "$i/.kde4/share/kde4/services/ServiceMenus/beyondcompare_compare.desktop"
			rm -f "$i/.kde4/share/kde4/services/ServiceMenus/beyondcompare_more.desktop"
			rm -f "$i/.kde4/share/kde4/services/ServiceMenus/beyondcompare_select.desktop"
		fi
		if [ -d "$i/.kde/share/kde4/services/ServiceMenus" ]; then
			rm -f "$i/.kde/share/kde4/services/ServiceMenus/beyondcompare.desktop"
			rm -f "$i/.kde/share/kde4/services/ServiceMenus/beyondcompare_compare.desktop"
			rm -f "$i/.kde/share/kde4/services/ServiceMenus/beyondcompare_more.desktop"
			rm -f "$i/.kde/share/kde4/services/ServiceMenus/beyondcompare_select.desktop"
		fi
		if [ -d "$i/.kde/share/apps/konqueror/servicemenus" ]; then
			rm -f "$i/.kde/share/apps/konqueror/servicemenus/beyondcompare.desktop"
			rm -f "$i/.kde/share/apps/konqueror/servicemenus/beyondcompare_compare.desktop"
			rm -f "$i/.kde/share/apps/konqueror/servicemenus/beyondcompare_more.desktop"
			rm -f "$i/.kde/share/apps/konqueror/servicemenus/beyondcompare_select.desktop"
		fi
	done

	##
	# Remove context extensions
	##
	for EXT_LIB in /usr/lib /usr/lib64
	do
		if [[ -d "$EXT_LIB/qt6/plugins/kf6/kfileitemaction" ]]; then
			rm -f "$EXT_LIB/qt6/plugins/kf6/kfileitemaction/bcompare_ext_kde6.so"
		elif [[ -d "$EXT_LIB/qt5/plugins/kf5/kfileitemaction" ]]; then
			rm -f "$EXT_LIB/qt5/plugins/kf5/kfileitemaction/bcompare_ext_kde5.so"
		elif [[ -d "$EXT_LIB/qt5/plugins" ]]; then
			rm -f "$EXT_LIB/qt5/plugins/bcompare_ext_kde.so"
			rm -f /usr/share/kservices5/bcompare_ext_kde.desktop
		fi
		if [[ -d "$EXT_LIB/kde4" ]]; then
			rm -f "$EXT_LIB/kde4/bcompare_ext_konq.so"
			rm -f /usr/share/kde4/services/bcompare_ext_konq.desktop
			rm -f "$EXT_LIB/kde4/bcompare_ext_kde.so"
			rm -f /usr/share/kde4/services/bcompare_ext_kde.desktop
		fi

		for FILE_MANAGER_NAME in nautilus caja nemo
		do
			for EXT_VER in extensions-4 extensions-3.0 extensions-2.0 extensions-1.0
			do
				if [[ -d "$EXT_LIB/$FILE_MANAGER_NAME/$EXT_VER" ]]; then
					rm -f "$EXT_LIB/$FILE_MANAGER_NAME/$EXT_VER/bcompare-ext-$FILE_MANAGER_NAME.so"
				fi
			done
		done

		for EXT_VER in thunarx-3 thunarx-2 thunarx-1
		do
			if [[ -d "$EXT_LIB/$EXT_VER" ]]; then
				rm -f "$EXT_LIB/$EXT_VER/bcompare-ext-thunarx.so"
			fi
		done
	done
	fi

	##
	# Update mime types after Beyond Compare types are removed
	##
	update-mime-database /usr/share/mime > /dev/null 2>&1

	exit 0


}
_version() {
	# fedora_32 https://www.scootersoftware.com/bcompare-4.3.3.24545.i386.rpm
	# https://www.scootersoftware.com/bcompare-4.3.3.24545.x86_64.rpm
	# zz=dl4&platform=mac, zz=dl4&platform=linux, zz=dl4&platform=win

	local PLATFORM="${1}"
	local PATTERN="${2}"
	# THOUGHT: local CODEFILE=$(curl -d "zz=dl4&platform=linux" -H "Content-Type: application/x-www-form-urlencoded" -X POST  -sSLo -  https://www.scootersoftware.com/download.php  2>&1;) # suppress only wget download messages, but keep wget output for variable
	local CODEFILE=""
	CODEFILE="$(curl -d "zz=dl4&platform=${PLATFORM}" -H "Content-Type: application/x-www-form-urlencoded" -X POST  -sSLo -  https://www.scootersoftware.com/download.php  2>&1;)" # suppress only wget download messages, but keep wget output for variable
	# THOUGHT: local CODELASTESTBUILD=$(echo $CODEFILE | sed s/\</\\n\</g | grep "bcompare*.*.*.*.x86_64.rpm" | sed s/\"/\\n/g | grep "/" | cuet "/")
	# local CODELASTESTBUILD=$(echo $CODEFILE | sed s/\</\\n\</g | grep "${PATTERN}" | sed s/\"/\\n/g | grep "/" | cüt "/")
	local CODELASTESTBUILD=""
	# shellcheck disable=SC2001
	CODELASTESTBUILD="$(sed s/\</\\n\</g <<< "$CODEFILE" | grep "${PATTERN}" | sed s/\"/\\n/g | grep "/" | cüt "/files/")"
	# fedora 32 local CODELASTESTBUILD=$(echo $CODEFILE | sed s/\</\\n\</g | grep "bcompare*.*.*.*.i386.rpm" | sed s/\"/\\n/g | grep "/" | cuet "/")
	wait
	[[ -z "${CODELASTESTBUILD}" ]] && failed "Beyond Compare Version not found! :${CODELASTESTBUILD}:"



	# enforce_variable_with_value USER_HOME "${USER_HOME}"
	# enforce_variable_with_value CODELASTESTBUILD "${CODELASTESTBUILD}"

	local CODENAME="${CODELASTESTBUILD}"
	echo "${CODELASTESTBUILD}"
	unset PATTERN
	unset PLATFORM
	unset CODEFILE
	unset CODELASTESTBUILD
} # end _version

_version_test(){
	local CODENAME=$(_version "linux" "bcompare*.*.*.*.x86_64.rpm")
	Checking "CODENAME:${CODENAME}"
	enforce_variable_with_value CODENAME "${CODENAME}"
	exit 0
} # end _version_test
#_version_test

_darwin__64() {
	# sudo_it
	# export USER_HOME="/Users/${SUDO_USER}"
	enforce_variable_with_value USER_HOME "${USER_HOME}"

	local CODENAME=""
	CODENAME=$(_version "mac" "BCompareOSX*.*.*.*.zip")
	enforce_variable_with_value CODENAME "${CODENAME}"
	# THOUGHT        local CODENAME="BCompareOSX-4.3.3.24545.zip"
	local URL="https://www.scootersoftware.com/${CODENAME}"

	# local TARGET_URL
	# TARGET_URL="${CODENAME}|Beyond Compare.app|${URL}"
	# enforce_variable_with_value TARGET_URL "${TARGET_URL}"
	# _install_dmgs_list "${TARGET_URL}"
	local DOWNLOADFOLDER="$USER_HOME/Downloads"
	enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
	cd "${DOWNLOADFOLDER}"
	echo _download_mac
	_download_mac "${URL}" "${DOWNLOADFOLDER}"
	local APPDIR="Beyond Compare.app"    # same as  $(basename "${APPDIR}")
	echo _remove_dmgs_app_if_exists
	_remove_dmgs_app_if_exists "${APPDIR}"
	echo _process_dmgs_dmg_or_zip
	_process_dmgs_dmg_or_zip "zip" "${DOWNLOADFOLDER}" "${CODENAME}" "${APPDIR}" "${CODENAME}"
	echo directory_exists_with_spaces
	directory_exists_with_spaces "/Applications/${APPDIR}"
	ls -d "/Applications/${APPDIR}"

	_trust_dmgs_application "${APPDIR}"
	ln -s /Applications/Beyond\ Compare.app/Contents/MacOS/bcomp /usr/local/bin/bcompare
	ln -s /Applications/Beyond\ Compare.app/Contents/MacOS/bcomp /usr/local/bin/bcomp
	# sudo hdiutil attach ${CODENAME}
	# sudo cp -R /Volumes/Beyond\ Compare/Beyond\ Compare.app /Applications/
	# sudo hdiutil detach /Volumes/Beyond \ Compare
} # end _darwin__64

_debian_flavor_install() {
	# sudo_it
	trap 'echo -e "${RED}" && echo -e "ERROR failed \n$0:$LINENO _debian_flavor_install beyondcomapre" && echo -e "${RESET}" && return 0' ERR

	# export USER_HOME="/home/${SUDO_USER}"
	enforce_variable_with_value USER_HOME "${USER_HOME}"
	enforce_variable_with_value SUDO_USER "${SUDO_USER}"
	# THOUGHT          local CODENAME="bcompare-4.3.3.24545_amd64.deb"
	local CODENAME=""
	CODENAME=$(_version "linux" "bcompare-*.*.*.*amd64.deb")
	enforce_variable_with_value CODENAME "${CODENAME}"
	local TARGET_URL="https://www.scootersoftware.com/${CODENAME}"
	enforce_variable_with_value TARGET_URL "${TARGET_URL}"
	local DOWNLOADFOLDER=""
	DOWNLOADFOLDER="$(_find_downloads_folder)"
	enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
	cd "${DOWNLOADFOLDER}"
	_download_mac "${TARGET_URL}" "${DOWNLOADFOLDER}"
	dpkg -i ${CODENAME}
} # end _debian_flavor_install

_package_list_installer() {
	local package packages="${*-}"
	trap 'echo -e "${RED}" && echo -e "ERROR failed \n$0:$LINENO _package_list_installer rbenv" && echo -e "${RESET}" && return 0' ERR

	if ! install_requirements "linux" "${packages}" ; then
	{
		warning "installing requirements. ${CYAN} attempting to install one by one"
		while read -r package; do
		{
			[[ -z ${package} ]] && continue
			install_requirements "linux" "${package}"
			_err=$?
			if [ ${_err} -gt 0 ] ; then
			{
					failed to install requirements "${package}"
			}
			fi
		}
		done <<< "${packages}"
  }
	fi
} # end _package_list_installer

_ubuntu__64() {
	trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO _ubuntu__64 beyondcomapre" && echo -e "${RESET}" && return 0' ERR

	local package packages="
	poppler-utils
	"
	_package_list_installer "${packages}"
	_debian_flavor_install
} # end _ubuntu__64

_ubuntu__aarch64() {
	trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
	local package packages="
	poppler-utils
	"
	_package_list_installer "${packages}"

	_debian_flavor_install
} # end _ubuntu__aarch64

_ubuntu_22__aarch64() {
	trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
	local package packages="
	poppler-utils
	"
	_package_list_installer "${packages}"
	_debian_flavor_install
} # end _ubuntu_22__aarch64

_ubuntu__32() {
	#sudo_it
	# export USER_HOME="/Users/${SUDO_USER}"
	enforce_variable_with_value USER_HOME "${USER_HOME}"
	# _linux_prepare
	# THOUGHT local CODENAME="bcompare-4.3.3.24545_i386.deb"
	local CODENAME=""
	CODENAME=$(_version "linux" "bcompare-*.*.*.*i386.deb")
	enforce_variable_with_value CODENAME "${CODENAME}"
	local TARGET_URL="https://www.scootersoftware.com/${CODENAME}"
	enforce_variable_with_value TARGET_URL "${TARGET_URL}"

	local DOWNLOADFOLDER=""
	DOWNLOADFOLDER="$(_find_downloads_folder)"
	enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
	cd "${DOWNLOADFOLDER}"
	_download_mac "${TARGET_URL}" "${DOWNLOADFOLDER}"
	sudo dpkg -i ${CODENAME}
} # end _ubuntu__32

_fedora__32() {
	#sudo_it
	# export USER_HOME="/Users/${SUDO_USER}"
	enforce_variable_with_value USER_HOME "${USER_HOME}"
	# _linux_prepare
	local CODENAME=""
	CODENAME=$(_version "linux" "bcompare*.*.*.*.i386.rpm")
	enforce_variable_with_value CODENAME "${CODENAME}"
	# THOUGHT                          bcompare-4.3.3.24545.i386.rpm
	local TARGET_URL="https://www.scootersoftware.com/${CODENAME}"
	enforce_variable_with_value TARGET_URL "${TARGET_URL}"
	local DOWNLOADFOLDER=""
	DOWNLOADFOLDER="$(_find_downloads_folder)"
	enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
	cd "${DOWNLOADFOLDER}"
	_download "${TARGET_URL}" "${USER_HOME}/Downloads" "${CODENAME}"
	file_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
	ensure rpm or "Canceling Install. Could not find rpm command to execute install"
	# provide error handling , once learned goes here. LEarn under if, once learned here.
	# Start loop while ERROR flag in case needs to try again, based on error
	_try "rpm --import https://www.scootersoftware.com/RPM-GPG-KEY-scootersoftware"
	local msg=""
	msg=$(_try "rpm -ivh \"${DOWNLOADFOLDER}/${CODENAME}\"" )
	local ret=$?
	if [ $ret -gt 0 ] ; then
		{
			failed "${ret}:${msg}"
			# add error handling knowledge while learning.
		}
else
	{
		passed Install with RPM success!
	}
	fi
	ensure bcompare or "Failed to install Beyond Compare"
	rm -f "${DOWNLOADFOLDER}/${CODENAME}"
	file_does_not_exist_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
} # end _fedora__32

_centos__64() {
	_fedora__64
} # end _centos__64

_fedora__64() {
	#sudo_it
	# export USER_HOME="/Users/${SUDO_USER}"
	enforce_variable_with_value USER_HOME "${USER_HOME}"
	# _linux_prepare
	local CODENAME=""
	CODENAME=$(_version "linux" "bcompare*.*.*.*.x86_64.rpm")
	Checking "_version:${CODENAME}"
	enforce_variable_with_value CODENAME "${CODENAME}"
	# THOUGHT  https://www.scootersoftware.com/bcompare-4.3.3.24545.x86_64.rpm
	local TARGET_URL=""
	# shellcheck disable=SC2001
	TARGET_URL="$(sed 's@//@/@g' <<<"www.scootersoftware.com/files/${CODENAME}")"
	TARGET_URL="https://${TARGET_URL}"
	Checking "TARGET_URL:${TARGET_URL}"
	enforce_variable_with_value TARGET_URL "${TARGET_URL}"
	local DOWNLOADFOLDER=""
	"$(_find_downloads_folder)"
	enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
	cd "${DOWNLOADFOLDER}"
	_do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
	_install_rpm "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}" 0

	ensure bcompare or "Failed to install Beyond Compare"
	rm -f "${DOWNLOADFOLDER}/${CODENAME}"
	file_does_not_exist_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
} # end _fedora__64

_fedora_37__64() {
	trap 'echo Error:$?' ERR INT
	local _parameters="${*-}"
	local -i _err=0
	_fedora__64 "${_parameters-}"
	_err=$?
	if [ ${_err} -gt 0 ] ; then
	{
		failed "struct_testing:$LINENO $0:$LINENO while running callsomething above _err:${_err}"
	}
	fi
} # end _fedora_37__64

_mingw__64() {
	# sudo_it
	export USER_HOME="/Users/${SUDO_USER}"
	enforce_variable_with_value USER_HOME "${USER_HOME}"
	# _linux_prepare
	local CODENAME=""
	CODENAME=$(_version "win" "BCompare*.*.*.*.exe")
	# THOUGHT        local CODENAME="BCompare-4.3.3.24545.exe"
	local URL="https://www.scootersoftware.com/${CODENAME}"
	cd "$HOMEDIR"
	cd Downloads
	curl -O "$URL"
	${CODENAME}
} # end _mingw__64

_mingw__32() {
	_linux_prepare
	local CODENAME=""
	CODENAME=$(_version "win" "BCompare*.*.*.*.exe")
	# THOUGHT        local CODENAME="BCompare-4.3.3.24545.exe"
	local URL="https://www.scootersoftware.com/${CODENAME}"
	cd "$HOMEDIR"
	cd Downloads
	curl -O "$URL"
	${CODENAME}
} # end

_main() {
	determine_os_and_fire_action
} # end _main

_main

echo ":)"



 #--------/\/\/\/\-- 2tasks_templates_sudo/beyondcompare …install_beyondcompare.bash” -- Custom code-/\/\/\/\-------



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
