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
    exec exit ${__trapped_error_exit_num}
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





 #--------\/\/\/\/-- 2tasks_templates_sudo/vim …install_vim.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/bash

_debian_flavor_install() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  anounce_command apt-get install vim -y
  HOMEBREW_FORCE_BREWED_CURL=1 curl -fkLo "${USER_HOME}/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  anounce_command chown -R  "${SUDO_USER}" "${USER_HOME}/.vim/"
  HOMEBREW_FORCE_BREWED_CURL=1 curl -fkLo "/root/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  HOMEBREW_FORCE_BREWED_CURL=1 curl -fkLo "/root/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  local content=""
	content="$(_write_vimrc)"
  touch "${USER_HOME}/.vimrc"
  touch "/root/.vimrc"

  echo "${content}" > "${USER_HOME}/.vimrc"
  echo "${content}" > "/root/.vimrc"

  chown -R "${SUDO_USER}" "${USER_HOME}/.vim/autoload/plug.vim"
  chown -R "${SUDO_USER}" "${USER_HOME}/.vimrc"
  # vim
  # vim -es -u vimrc -i NONE -c "PlugInstall" -c "qa"
  vim -c PlugInstall -c qa
  su - "${SUDO_USER}" -c 'vim -c PlugInstall -c qa'
  # su - "${SUDO_USER}" -c 'vim -es -u vimrc -i NONE -c "PlugInstall" -c "qa"'


  # neovim
  # nvim -es -u init.vim -i NONE -c "PlugInstall" -c "qa"

} # end _debian_flavor_install

_write_vimrc() {
  echo "
if v:lang =~ \"utf8$\" || v:lang =~ \"UTF-8$\"
set fileencodings=ucs-bom,utf-8,latin1
endif

set nocompatible        \" Use Vim defaults (much better!)
set bs=indent,eol,start         \" allow backspacing over everything in insert mode
\"set ai                 \" always set autoindenting on
\"set backup             \" keep a backup file
set viminfo='20,\\\"50    \" read/write a .viminfo file, do not store more
\" than 50 lines of registers
set history=50          \" keep 50 lines of command line history
set ruler               \" show the cursor position all the time
set ruler

\" Enable backspace buton
set backspace=indent,eol,start

\" Enable Control S
nnoremap <c-s> :w<CR> \" normal mode: save
inoremap <c-s> <Esc>:w<CR> \" insert mode: escape to normal and save
vnoremap <c-s> <Esc>:w<CR> \" visual mode: escape to normal and save

\" Enable Control X
nnoremap <c-x> :wq<CR> \" normal mode: save and exit
inoremap <c-x> <Esc>:wq<CR> \" insert mode: escape to normal and save and exit
vnoremap <c-x> <Esc>:wq<CR> \" visual mode: escape to normal and save and exit

\" Enable Control q
nnoremap <c-q> :q<CR> \" normal mode: quit
inoremap <c-q> <Esc>:q<CR> \" insert mode: escape to normal and quit
vnoremap <c-q> <Esc>:q<CR> \" visual mode: escape to normal and quit


\" Enable syntax highlighting
syntax on

\" tabs
set tabstop=2
set softtabstop=2 noexpandtab
set shiftwidth=2

\"
\"If you want tab characters in your file to appear 4 character cells wide:
\" set tabstop=4
\"
\" If your code requires use of actual tab characters these settings prevent unintentional insertion of spaces (these are the defaults, but you may want to set them defensively):
\"
\" set softtabstop=0 noexpandtab
\"
\"If you also want to use tabs for indentation, you should also set shiftwidth to be the same as tabstop:
\"
\" set shiftwidth=4
\"
\" To make any of these settings permanent add them to your vimrc.
\" If you want pressing the tab key to indent with 4 space characters:
\"
\" First, tell vim to use 4-space indents, and to intelligently use the tab key for indentation instead of for inserting tab characters (when at the beginning of a line):
\"
\" set shiftwidth=4 smarttab
\"
\" If you would also like vim to only use space caharacters, never tab characters:
\"
\" set expandtab
\"
\" Finally, I also recommend setting tab stops to be different from the indentation width, in order to reduce the chance of tab characters masquerading as proper indents:
\"
\" set tabstop=8 softtabstop=0
\"
\" To make any of these settings permanent add them to your vimrc.
\" More Details
\"
\"In case you need to make adjustments, or would simply like to understand what these options all mean, here is a breakdown of what each option means:
\"
\"    tabstop
\"
\"    The width of a hard tabstop measured in \"spaces\" -- effectively the (maximum) width of an actual tab character.
\"    shiftwidth
\"
\"   The size of an \"indent\". It is also measured in spaces, so if your code base indents with tab characters then you want shiftwidth to equal the number of tab characters times tabstop. This is also used by things like the =, > and < commands.
\"    softtabstop
\"
\"    Setting this to a non-zero value other than tabstop will make the tab key (in insert mode) insert a combination of spaces (and possibly tabs) to simulate tab stops at this width.
\"    expandtab
\"
\"    Enabling this will make the tab key (in insert mode) insert spaces instead of tab characters. This also affects the behavior of the retab command.
\"    smarttab
\"
\"    Enabling this will make the tab key (in insert mode) insert spaces or tabs to go to the next indent of the next tabstop when the cursor is at the beginning of a line (i.e. the only preceding characters are whitespace).
\"
\" For further details on any of these see :help 'optionname' in vim (e.g. :help 'tabstop')


\" Only do this part when compiled with support for autocommands
if has(\"autocmd\")
augroup redhat
autocmd!
\" In text files, always limit the width of text to 78 characters
\" autocmd BufRead *.txt set tw=78
\" When editing a file, always jump to the last cursor position
autocmd BufReadPost *
\\ if line(\"'\\\"\") > 0 && line (\"'\\\"\") <= line(\"$\") |
\\   exe \"normal! g'\\\"\" |
\\ endif
\" do not write swapfile on most commonly used directories for NFS mounts or USB sticks
autocmd BufNewFile,BufReadPre /media/*,/run/media/*,/mnt/* set directory=~/tmp,/var/tmp,/tmp
\" start with spec file template
autocmd BufNewFile *.spec 0r /usr/share/vim/vimfiles/template.spec
augroup END
endif

if has(\"cscope\") && filereadable(\"/usr/bin/cscope\")
set csprg=/usr/bin/cscope
set csto=0
set cst
set nocsverb
\" add any database in current directory
if filereadable(\"cscope.out\")
cs add \$PWD/cscope.out
\" else add database pointed to by environment
elseif \$CSCOPE_DB != \"\"
cs add \$CSCOPE_DB
endif
set csverb
endif


\" Switch syntax highlighting on, when the terminal has colors
\" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has(\"gui_running\")
syntax on
set hlsearch
endif

\" Enables filetype detection, loads ftplugin, and loads indent
\" (Not necessary on nvim and may not be necessary on vim 8.2+)
filetype plugin indent on

call plug#begin()
Plug 'dense-analysis/ale'

Plug 'gleam-lang/gleam.vim'
\" The default plugin directory will be as follows:
\"   - Vim (Linux/macOS): '~/.vim/plugged'
\"   - Vim (Windows): '~/vimfiles/plugged'
\"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
\" You can specify a custom plugin directory by passing it as the argument
\"   - e.g. 'call plug#begin('~/.vim/plugged')'
\"   - Avoid using standard Vim directory names like 'plugin'

\" Make sure you use single quotes

Plug 'preservim/nerdtree' |
            \\ Plug 'Xuyuanp/nerdtree-git-plugin' |
            \\ Plug 'PhilRunninger/nerdtree-buffer-ops' |
            \\ Plug 'ryanoasis/vim-devicons' |
            \\ Plug 'tiagofumo/vim-nerdtree-syntax-highlight' |
            \\ Plug 'PhilRunninger/nerdtree-visual-selection'
\" tree files


Plug 'mattn/emmet-vim'
\"Plug 'wincent/terminus'

\"           \\ Plug 'scrooloose/nerdtree-project-plugin' |

let g:NERDTreeGitStatusIndicatorMapCustom = {
                \\ 'Modified'  :'✹',
                \\ 'Staged'    :'✚',
                \\ 'Untracked' :'✭',
                \\ 'Renamed'   :'➜',
                \\ 'Unmerged'  :'═',
                \\ 'Deleted'   :'✖',
                \\ 'Dirty'     :'✗',
                \\ 'Ignored'   :'☒',
                \\ 'Clean'     :'✔︎',
                \\ 'Unknown'   :'?',
                \\ }


\" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
Plug 'junegunn/vim-easy-align'

\" Any valid git URL is allowed
\" Plug 'https://github.com/junegunn/vim-github-dashboard.git'

\" Multiple Plug commands can be written in a single line using | separators
\" Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

\" On-demand loading
\" Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
\" Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

\" Using a non-default branch
\" Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

\" Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
\" Plug 'fatih/vim-go', { 'tag': '*' }

\" Plugin options
\" Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

\" Plugin outside ~/.vim/plugged with post-update hook
\" Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

\" Unmanaged plugin (manually installed and updated)
\" Plug '~/my-prototype-plugin'

\" Initialize plugin system
\" - Automatically executes 'filetype plugin indent on' and 'syntax enable'.

\" Svelte Section https://github.com/evanleck/vim-svelte?ref=madewithsvelte.com
Plug 'othree/html5.vim'
Plug 'pangloss/vim-javascript'
Plug 'evanleck/vim-svelte', {'branch': 'main'}

\" Using vim-plug
Plug 'elixir-editors/vim-elixir'

\" Using colorschemes install
Plug 'morhetz/gruvbox'

call plug#end()

\" You can revert the settings after the call like so:
\"   filetype indent off   \" Disable file-type-specific indentation
\"   syntax off            \" Disable syntax highlighting
\"

\" Ale Plug Plugin choices:
\"  https://github.com/dense-analysis/ale
\"
\" Enable completion where available.
\" This setting must be set before ALE is loaded.
\"
\" You should not turn this setting on if you wish to use ALE as a completion
\" source for other completion plugins, like Deoplete.
let g:ale_completion_enabled = 1


\" Set this variable to 1 to fix files when you save them.
let g:ale_fix_on_save = 1


\" In ~/.vim/vimrc, or somewhere similar.
let g:ale_fixers = {
\\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\\   'javascript': ['biome'],
\\}
\" end


\" Using colorschemes activate
colorscheme gruvbox

"
} # _write_vimrc


_redhat_flavor_install() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  anounce_command dnf install vim -y
  HOMEBREW_FORCE_BREWED_CURL=1 curl -fkLo "${USER_HOME}/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  anounce_command chown -R  "${SUDO_USER}" "${USER_HOME}/.vim/"
  HOMEBREW_FORCE_BREWED_CURL=1 curl -fkLo "/root/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  local content=""
	content="$(_write_vimrc)"
  touch "${USER_HOME}/.vimrc"
  touch "/root/.vimrc"

  echo "${content}" > "${USER_HOME}/.vimrc"
  echo "${content}" > "/root/.vimrc"

  chown -R "${SUDO_USER}" "${USER_HOME}/.vim/autoload/plug.vim"
  chown -R "${SUDO_USER}" "${USER_HOME}/.vimrc"
  # vim
  # vim -es -u vimrc -i NONE -c "PlugInstall" -c "qa"
  vim -c PlugInstall -c qa
  su - "${SUDO_USER}" -c 'vim -c PlugInstall -c qa'
  # su - "${SUDO_USER}" -c 'vim -es -u vimrc -i NONE -c "PlugInstall" -c "qa"'


  # neovim
  # nvim -es -u init.vim -i NONE -c "PlugInstall" -c "qa"
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

_centos_8__64() {
  trap 'echo Error:$?' ERR INT
  local _parameters="${*-}"
  local -i _err=0
  callsomething "${_parameters-}"
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    failed "$0:$LINENO while running callsomething above _err:${_err}"
  }
  fi
} # end _centos_8__64

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
  trap 'echo Error:$?' ERR INT
  local _parameters="${*-}"
  local -i _err=0
  _redhat_flavor_install "${_parameters-}"
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    failed "struct_testing:$LINENO $0:$LINENO  while running callsomething above _err:${_err}"
  }
  fi
} # end _fedora__64

_fedora_39__64() {
  trap 'echo Error:$?' ERR INT
  local _parameters="${*-}"
  local -i _err=0
  _redhat_flavor_install "${_parameters-}"

  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    failed "struct_testing:$LINENO $0:$LINENO while running callsomething above _err:${_err}"
  }
  fi
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
  trap 'echo Error:$?' ERR INT
  local _parameters="${*-}"
  local -i _err=0
  _debian_flavor_install "${_parameters-}"
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    failed "$0:$LINENO  while running callsomething above _err:${_err}"
  }
  fi
} # end _ubuntu__aarch64

_darwin__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  anounce_command "su - '${SUDO_USER}' -c 'HOMEBREW_FORCE_BREWED_CURL=1 brew install vim'"
  anounce_command "HOMEBREW_FORCE_BREWED_CURL=1 curl -fkLo '${USER_HOME}/.vim/autoload/plug.vim' --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  anounce_command "chown -R '${SUDO_USER}' '${USER_HOME}/.vim/'"
  # anounce_command "HOMEBREW_FORCE_BREWED_CURL=1 curl -fkLo '/root/.vim/autoload/plug.vim' --create-dirs \
  #  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

  local content=""
	content="$(_write_vimrc)"
  touch "${USER_HOME}/.vimrc"
  # touch "/root/.vimrc"

  echo "${content}" > "${USER_HOME}/.vimrc"
  # echo "${content}" > "/root/.vimrc"

  anounce_command "chown -R '${SUDO_USER}' '${USER_HOME}/.vim/autoload/plug.vim'"
  anounce_command "chown -R '${SUDO_USER}' '${USER_HOME}/.vimrc'"
  # vim
  # vim -es -u vimrc -i NONE -c "PlugInstall" -c "qa"
  # anounce_command "vim -c PlugInstall -c qa"
  anounce "su - '${SUDO_USER}' -c 'vim -c PlugInstall -c qa'"
  su - "${SUDO_USER}" -c 'vim -c PlugInstall -c qa'
} # end _darwin__64

_darwin__arm64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  # anounce_command "su - '${SUDO_USER}' -c 'HOMEBREW_FORCE_BREWED_CURL=1 brew install vim'"
  # anounce_command "HOMEBREW_FORCE_BREWED_CURL=1 curl -fkLo '${USER_HOME}/.vim/autoload/plug.vim' --create-dirs \
   #  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  HOMEBREW_FORCE_BREWED_CURL=1 curl -fkLo "${USER_HOME}/.vim/autoload/plug.vim" --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  local content=""
	content="$(_write_vimrc)"
  touch "${USER_HOME}/.vimrc"
  # touch "/root/.vimrc"

  echo "${content}" > "${USER_HOME}/.vimrc"
  # echo "${content}" > "/root/.vimrc"

  chown -R "${SUDO_USER}" "${USER_HOME}/.vim"
  chown -R "${SUDO_USER}" "${USER_HOME}/.vimrc"
  # vim
  # vim -es -u vimrc -i NONE -c "PlugInstall" -c "qa"
  # vim -c PlugInstall -c qa
  su - "${SUDO_USER}" -c 'vim -c PlugInstall -c qa'
  # su - "${SUDO_USER}" -c 'vim -es -u vimrc -i NONE -c "PlugInstall" -c "qa"'


  # echo "_darwin__arm64 Procedure not yet implemented. I don't know what to do."
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



 #--------/\/\/\/\-- 2tasks_templates_sudo/vim …install_vim.bash” -- Custom code-/\/\/\/\-------



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
