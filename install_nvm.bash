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





 #--------\/\/\/\/-- 2tasks_templates_sudo/nvm …install_nvm.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#

_git_clone() {
  trap 'echo _git_clone chugging along ' ERR 
  local _source="${1}"
  local _target="${2}"
  Checking "${SUDO_USER}" "${_target}"
  pwd
  if  it_exists_with_spaces "${_target}" ; then # && it_exists_with_spaces "${_target}/.git" ; then
  {
    if it_exists_with_spaces "${_target}/.git" ; then
    {
      cd "${_target}"
      git checkout  "v0.30.2"
      if git config pull.rebase false ; then
      {
        warning Could not git config pull.rebase false
      }
      fi
      if git fetch ; then
      {
        warning Could not git fetch
      }
      fi
      if  git checkout .  ; then
      {
        warning Could not git checkout .
      }
      fi
      if git checkout master ; then
      {
        warning Could not git checkout master
      }
      fi
      if git pull ; then
      {
        warning Could not git pull
      }
      fi
      if git fetch --tags origin ; then
      {
        warning Could not git fetch --tags origin
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
  cd "${USER_HOME}/.nvm"
  mkdir -p "${USER_HOME}/.nvm/scripts"
  cp "${USER_HOME}/.nvm/nvm.sh" "${USER_HOME}/.nvm/scripts/nvm"
  chmod a+x "${USER_HOME}/.nvm/scripts/nvm"
  local NVM_SH_CONTENT='

# NVM
_find_nvm_node(){
  echo "'${USER_HOME}'/.nvm/versions/node/v$(<"'${USER_HOME}'/.nvm/alias/default")/bin"
}
if [[ -e "'${USER_HOME}'/.nvm" ]] ; then
{
  export NVM_DIR="'${USER_HOME}'/.nvm"
  [[ -d "'${USER_HOME}'/.nvm" ]] && export PATH="'${USER_HOME}'/.nvm:${PATH}"
  [[ -d "'${USER_HOME}'/.nvm/scripts" ]] && export PATH="'${USER_HOME}'/.nvm/scripts:${PATH}"
  [[ -d "'${USER_HOME}'/.nvm/versions/node" ]] && export PATH="$(_find_nvm_node):${PATH}"
  # [ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh"  # This loads nvm
  # bash_completion clashes with evm"s bash_completion enable if not using nvm
  # [ -s "${NVM_DIR}/bash_completion" ] && . "${NVM_DIR}/bash_completion"  # This loads nvm bash_completion
}
fi
[ -e "'${USER_HOME}'/.nvm/nvm.sh" ] && chmod a+x "'${USER_HOME}'/.nvm/nvm.sh"
[ -e "'${USER_HOME}'/.nvm/nvm.sh" ] && . "'${USER_HOME}'/.nvm/nvm.sh" # This loads nvm
[ -e "'${USER_HOME}'/.nvm/scripts/nvm" ] && . "'${USER_HOME}'/.nvm/scripts/nvm" # This loads nvm
'
  # trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO _add_variables_to_bashrc_zshrc nvm" && echo -e "${RESET}" && return 0' ERR
  echo "${NVM_SH_CONTENT}"
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
    _if_not_contains "${USER_HOME}/${INITFILE}"  "# NVM" ||  echo "${NVM_SH_CONTENT}" >> "${USER_HOME}/${INITFILE}"
    _if_not_contains "${USER_HOME}/${INITFILE}"  "nvm.sh" ||  echo "${NVM_SH_CONTENT}" >> "${USER_HOME}/${INITFILE}"
  }
  done <<< "${INITFILES}"


} # _add_variables_to_bashrc_zshrc


_install_nvm() {
    local -i ret
    local msg
    trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO _install_nvm nvm" && echo -e "${RESET}" && return 0' ERR

    [[  ! -e "${USER_HOME}/.config" ]] && mkdir -p "${USER_HOME}/.config"
    chown  -R "${SUDO_USER}" "${USER_HOME}/.config"
    [ -e "${USER_HOME}/.nvm/nvm.sh" ] && chmod a+x "${USER_HOME}/.nvm/nvm.sh" 
    [ -e "${USER_HOME}/.nvm/nvm.sh" ] && . "${USER_HOME}/.nvm/nvm.sh" # This loads nvm
    msg=$(nvm >/dev/null 2>&1)
    ret=$?

    if is_not_installed nvm ; then  # [ $ret -gt 0 ] ; then
    {
        Installing nvm Node Version Manager
        Installing  nvm setup
        su - "${SUDO_USER}" -c 'HOME='${USER_HOME}' curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash'

        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${USER_HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
        [ -s "${USER_HOME}/.nvm/nvm.sh" ] && \. "${USER_HOME}/.nvm/nvm.sh" # This loads nvm

        Configuring  nvm setup

        _if_not_contains "${USER_HOME}/.bash_profile" "NVM_DIR/nvm.sh" || echo '
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
'  >> "${USER_HOME}/.bash_profile"
        file_exists_with_spaces "${USER_HOME}/.bash_profile"

        _if_not_contains "${USER_HOME}/.bashrc" "NVM_DIR/nvm.sh" ||  echo '
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
'  >> "${USER_HOME}/.bashrc"

        file_exists_with_spaces "${USER_HOME}/.bashrc"

        _if_not_contains "${USER_HOME}/.zshrc" "NVM_DIR/nvm.sh" ||  echo '
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
'  >> "${USER_HOME}/.zshrc"

        file_exists_with_spaces "${USER_HOME}/.zshrc"

        msg=$(su - "${SUDO_USER}" -c 'nvm' >/dev/null 2>&1)
        ret=$?
        if [ $ret -gt 0 ] ; then
        {
            echo nvm second check failed "${ret}:${msg}"

        }
        else
        {
            passed that: nvm got installed
        }
        fi

    }
    else
    {
        passed that: nvm is installed
    }
    fi
} # end _install_nvm

_install_nvm_version(){
  local TARGETVERSION="${1}"
  trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO _install_nvm_version nvm" && echo -e "${RESET}" && return 0' ERR

    # chown -R $SUDO_USER:$(id -gn $SUDO_USER) "${USER_HOME}/.config"
    Configuring nvm node "${TARGETVERSION}"
    [ -e "${USER_HOME}/.nvm/nvm.sh" ] && chmod a+x "${USER_HOME}/.nvm/nvm.sh"
    [ -e "${USER_HOME}/.nvm/nvm.sh" ] && . "${USER_HOME}/.nvm/nvm.sh" # This loads nvm


    local VERSION12=$(nvm ls | grep "v${TARGETVERSION}" |tail -1 >/dev/null 2>&1 )
    if [[ -n "${VERSION12}" ]] ; then
    {
        if [[ "${VERSION12}" == *"not found"* ]] || [[ "${VERSION12}" == *"nvm help"* ]]  ; then
        {
            failed "Nvm command not found or failed! It should have been installed by this point."
        }
        fi
        if [[ "${VERSION12}" == *"v${TARGETVERSION}"* ]]  ; then
        {
            passed that: node "${TARGETVERSION}" installed. Version Found "${VERSION12}"
        }
        else
        {
            Installing node using nvm install  "${TARGETVERSION}"
          VERSION12=$(nvm ls | grep "v${TARGETVERSION}" |tail -1 >/dev/null 2>&1 )
            if [[ -n "${VERSION12}" ]] ; then
            {
                if [[ "${VERSION12}" == *"not found"* ]] || [[ "${VERSION12}" == *"nvm help"* ]]  ; then
                {
                    failed "Nvm command not found or failed! It should have been installed by this point."
                }
                fi
                if [[ "${VERSION12}" == *"v${TARGETVERSION}"* ]]  ; then
                {
                    passed "that: node ${TARGETVERSION} installed. Version Found ${VERSION12}"
                }
                else
                {
                    failed "to install node using nvm for version ${TARGETVERSION}"
                }
                fi
            }
            fi
        }
        fi
    }
    fi
    if [[ "${VERSION12}" == *"v${TARGETVERSION}"* ]]  ; then
    {
        passed that: node "${TARGETVERSION}" installed. Version Found "${VERSION12}"
    }
    else
    {
        Installing node using nvm install  "${TARGETVERSION}"
          VERSION12=$(nvm ls | grep "v${TARGETVERSION}" |tail -1 >/dev/null 2>&1 )
            if [[ -n "${VERSION12}" ]] ; then
            {
                if [[ "${VERSION12}" == *"not found"* ]] || [[ "${VERSION12}" == *"nvm help"* ]]  ; then
                {
                    failed "Nvm command not found or failed! It should have been installed by this point."
                }
                fi
                if [[ "${VERSION12}" == *"v${TARGETVERSION}"* ]]  ; then
                {
                    passed that: node "${TARGETVERSION}" installed. Version Found "${VERSION12}"
                }
                else
                {
                    failed to install node using nvm for version "${TARGETVERSION}"
                }
                fi
            }
            fi
        }
    fi
    Setting . nvm use "${TARGETVERSION}"
    # su - "${SUDO_USER}" -c '. "${USER_HOME}/.nvm/nvm.sh && "${USER_HOME}/.nvm/nvm.sh use "${TARGETVERSION}"'
    chown -R "${SUDO_USER}"  "${USER_HOME}/.nvm"
    chgrp -R "${SUDO_GRP}" "${USER_HOME}/.nvm"
    nvm install "${TARGETVERSION}"
    # su - "${SUDO_USER}" -c ''${USER_HOME}'/.nvm/nvm.sh && . '${USER_HOME}'/.nvm/nvm.sh && nvm use "${TARGETVERSION}"'
    # node --version
    #nvm use "${TARGETVERSION}"
} # end _install_nvm_version

_install_npm_utils() {
  trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO _install_nvm_version nvm" && echo -e "${RESET}" && return 0' ERR
  mkdir -p "${USER_HOME}/.npm"
  mkdir -p "${USER_HOME}/.nvm"
  chown -R "${SUDO_USER}" "${USER_HOME}/.npm"
  chown -R "${SUDO_USER}" "${USER_HOME}/.nvm"
  Installing "# Global node utils"
  is_not_installed nodemon  && npm i -g nodemon
  if  is_not_installed live-server  ; then
  {
    npm i -g live-server
  }
  fi
  # verify_is_installed live-server
  # verify_is_installed nodemon
  # is_not_installed jest &&  npm i -g jest
  # verify_is_installed jest
  # CHAINSTALLED=$(su - "${SUDO_USER}" -c 'npm -g info chai >/dev/null 2>&1')
  Checking info chai
  CHAINSTALLED=$(npm -g info chai >/dev/null 2>&1)
  if [[ -n "$CHAINSTALLED" ]] &&  [[ "$CHAINSTALLED" == *"npm ERR"* ]]  ; then
  {
    Installing npm chai
    npm i -g chai
  }
  fi
  # MOCHAINSTALLED=$(su - "${SUDO_USER}" -c 'npm -g info mocha >/dev/null 2>&1')
  Checking info mocha
  MOCHAINSTALLED=$(npm -g info mocha >/dev/null 2>&1)
  if [[ -n "$MOCHAINSTALLED" ]] &&  [[ "$MOCHAINSTALLED" == *"npm ERR"* ]]  ; then
  {
    npm i -g mocha
  }
  fi
  local ret msg
  # msg=$(su - "${SUDO_USER}" -c 'cds >/dev/null 2>&1')
  # ret=$?
  # if [ $ret -gt 0 ] ; then
  # {
   Installing --skipped npm cds
  #    npm i -g @sap/cds-dk
  #    msg=$(su - "${SUDO_USER}" -c 'cds')
  #    ret=$?
  #    if [ $ret -gt 0 ] ; then
  #    {
  #        echo failed "${ret}:${msg}"
  #    }
  #    else
  #    {
  #        passed that: cds got installed
  #    }
  #    fi
  # }
  # else
  # {
  #    passed that: cds is installed
  # }
  # fi
} # end _install_npm_utils


_debian_flavor_install() {
  _git_clone "https://github.com/nvm-sh/nvm.git" "${USER_HOME}/.nvm"
  cd "${USER_HOME}/.nvm"
  Installing older version that is compatible with old linux
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
  [ -e "${USER_HOME}/.nvm/nvm.sh" ] && chmod a+x "${USER_HOME}/.nvm/nvm.sh"
  [ -e "${USER_HOME}/.nvm/nvm.sh" ] && . "${USER_HOME}/.nvm/nvm.sh" # This loads nvm
  # \. "${USER_HOME}/.nvm/nvm.sh"
  local MSG=$(_add_variables_to_bashrc_zshrc)
  echo "${MSG}"

  #_checka_tools_commander
  _install_nvm
  _install_nvm_version 14.16.1
  _install_npm_utils
  if ( ! command -v cf >/dev/null 2>&1; ) ;  then
    su - "${SUDO_USER}" -c 'npm i -g cloudfoundry/tap/cf-cli@7'
  fi

  echo "Procedure not yet implemented. I don't know what to do."
} # end _debian_flavor_install

_redhat_flavor_install() {
  dnf build-dep nodejs -y --allowerasing
  _git_clone "https://github.com/nvm-sh/nvm.git" "${USER_HOME}/.nvm"
  cd "${USER_HOME}/.nvm"
    Installing older version that is compatible with old linux
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
  [ -e "${USER_HOME}/.nvm/nvm.sh" ] && chmod a+x "${USER_HOME}/.nvm/nvm.sh"
  [ -e "${USER_HOME}/.nvm/nvm.sh" ] && . "${USER_HOME}/.nvm/nvm.sh" # This loads nvm

  # \. "${USER_HOME}/.nvm/nvm.sh"
  local MSG=$(_add_variables_to_bashrc_zshrc)
  echo "${MSG}"
  # _checka_tools_commander
  _install_nvm
  _install_nvm_version 14.16.1
  _install_npm_utils
  if ( ! command -v cf >/dev/null 2>&1; ) ;  then
    su - "${SUDO_USER}" -c 'npm i -g cloudfoundry/tap/cf-cli@7'
  fi

} # end _redhat_flavor_install

_arch_flavor_install() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _readhat_flavor_install

_arch__32() {
  _arch_flavor_install
} # end _arch__32

_arch__64() {
  _arch_flavor_install
} # end _arch__64

_centos__32() {
  _redhat_flavor_install
} # end _centos__32

_centos__64() {
  _redhat_flavor_install
} # end _centos__64

_debian__32() {
  _debian_flavor_install
} # end _debian__32

_debian__64() {
  _debian_flavor_install
} # end _debian__64

_fedora__32() {
  _redhat_flavor_install
} # end _fedora__32

_fedora__64() {
  _redhat_flavor_install
} # end _fedora__64

_fedora_39__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  dnf build-dep nodejs -y --allowerasing
  _git_clone "https://github.com/nvm-sh/nvm.git" "${USER_HOME}/.nvm"
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  cd "${USER_HOME}/.nvm"
  # Installing older version that is compatible with old linux
  # git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
  [ -e "${USER_HOME}/.nvm/nvm.sh" ] && chmod a+x "${USER_HOME}/.nvm/nvm.sh"
  [ -e "${USER_HOME}/.nvm/nvm.sh" ] && . "${USER_HOME}/.nvm/nvm.sh" # This loads nvm

  _add_variables_to_bashrc_zshrc
  _install_npm_utils
  npm i -g pnpm
  nvm ls
} # end _fedora_39__64


_fedora_40__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  dnf build-dep nodejs -y --allowerasing
  _git_clone "https://github.com/nvm-sh/nvm.git" "${USER_HOME}/.nvm"
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  cd "${USER_HOME}/.nvm"
  # Installing older version that is compatible with old linux
  # git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
  [ -e "${USER_HOME}/.nvm/nvm.sh" ] && chmod a+x "${USER_HOME}/.nvm/nvm.sh"
  [ -e "${USER_HOME}/.nvm/nvm.sh" ] && . "${USER_HOME}/.nvm/nvm.sh" # This loads nvm

  _add_variables_to_bashrc_zshrc
  _install_npm_utils
  npm i -g pnpm
  nvm ls
} # end _fedora_40__64

_gentoo__32() {
  _redhat_flavor_install
} # end _gentoo__32

_gentoo__64() {
  _redhat_flavor_install
} # end _gentoo__64

_madriva__32() {
  _redhat_flavor_install
} # end _madriva__32

_madriva__64() {
  _redhat_flavor_install
} # end _madriva__64

_suse__32() {
  _redhat_flavor_install
} # end _suse__32

_suse__64() {
  _redhat_flavor_install
} # end _suse__64

_ubuntu__32() {
  _debian_flavor_install
} # end _ubuntu__32

_ubuntu__64() {
  _debian_flavor_install
} # end _ubuntu__64

_darwin__64() {
    trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _git_clone "https://github.com/nvm-sh/nvm.git" "${USER_HOME}/.nvm"
  cd "${USER_HOME}/.nvm"
  #  Installing older version that is compatible with old mac
  #git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
  #\. "${USER_HOME}/.nvm/nvm.sh"
  local MSG=$(_add_variables_to_bashrc_zshrc)
  echo "${MSG}"
  # _checka_tools_commander
  _install_nvm
  _install_nvm_version 14.16.1
  _install_npm_utils
  if ( ! command -v cf >/dev/null 2>&1; ) ;  then
    su - "${SUDO_USER}" -c 'npm i -g cloudfoundry/tap/cf-cli@7'
  fi
  # echo "Procedure not yet implemented. I don't know what to do."
} # end _darwin__64

_darwin__arm64() {
  _darwin__64
  # echo "Procedure not yet implemented. I don't know what to do."
} # end _darwin__arm64

_tar() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end tar

_windows__64() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _windows__64

_windows__32() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _windows__32



 #--------/\/\/\/\-- 2tasks_templates_sudo/nvm …install_nvm.bash” -- Custom code-/\/\/\/\-------



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
