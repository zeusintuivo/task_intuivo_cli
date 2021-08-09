#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
# 20200415 Compatible with Fedora, Mac, Ubuntu "sudo_up" "load_struct" "#
export realpath
function realpath() {
    local base dir f=$@;
    if [ -d "$f" ]; then
        base="";
        dir="$f";
    else
        base="/$(basename "$f")";
        dir=$(dirname "$f");
    fi;
    dir=$(cd "$dir" && /bin/pwd);
    echo "$dir$base"
}

set -E -o functrace
export THISSCRIPTCOMPLETEPATH
typeset -r THISSCRIPTCOMPLETEPATH="$(realpath  "$0")"
export BASH_VERSION_NUMBER
typeset BASH_VERSION_NUMBER=$(echo $BASH_VERSION | cut -f1 -d.)

export  THISSCRIPTNAME
typeset -r THISSCRIPTNAME="$(basename "$0")"

export _err
typeset -i _err=0
  function _trap_on_error(){
    echo -e "\\n \033[01;7m*** ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m"
    exit 1
  }
  trap _trap_on_error ERR
  function _trap_on_int(){
    echo -e "\\n \033[01;7m*** INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n  INT ...\033[0m"
    exit 0
  }

  trap _trap_on_int INT

load_struct_testing(){
  function _trap_on_error(){
    local -ir __trapped_error_exit_num="${2:-0}"
    echo -e "\\n \033[01;7m*** ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m  \n \n "
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
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
    local provider="$HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    local _err=0 structsource
    if [   -e "${provider}"  ] ; then
      echo "Loading locally"
      structsource="""$(<"${provider}")"""
      _err=$?
      [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. running 'source locally' returned error did not download or is empty err:$_err  \n \n  " && exit 1
    else
      if ( command -v curl >/dev/null 2>&1; )  ; then
        echo "Loading struct_testing from the net using curl "
        structsource="""$(curl https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing  -so -   2>/dev/null )"""  #  2>/dev/null suppress only curl download messages, but keep curl output for variable
        _err=$?
        [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. running 'curl' returned error did not download or is empty err:$_err  \n \n  " && exit 1
      elif ( command -v wget >/dev/null 2>&1; ) ; then
        echo "Loading struct_testing from the net using wget "
        structsource="""$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing -O -   2>/dev/null )"""  #  2>/dev/null suppress only wget download messages, but keep wget output for variable
        _err=$?
        [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. running 'wget' returned error did not download or is empty err:$_err  \n \n  " && exit 1
      else
        echo -e "\n \n  ERROR! Loading struct_testing could not find wget or curl to download  \n \n "
        exit 69
      fi
    fi
    [[ -z "${structsource}" ]] && echo -e "\n \n  ERROR! Loading struct_testing. structsource did not download or is empty " && exit 1
    local _temp_dir="$(mktemp -d 2>/dev/null || mktemp -d -t 'struct_testing_source')"
    echo "${structsource}">"${_temp_dir}/struct_testing"
    echo "Temp location ${_temp_dir}/struct_testing"
    source "${_temp_dir}/struct_testing"
    _err=$?
    [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. Occured while running 'source' err:$_err  \n \n  " && exit 1
    if  ! typeset -f passed >/dev/null 2>&1; then
      echo -e "\n \n  ERROR! Loading struct_testing. Passed was not loaded !!!  \n \n "
      exit 69;
    fi
    return $_err
} # end load_struct_testing
load_struct_testing

 _err=$?
[ $_err -ne 0 ]  && echo -e "\n \n  ERROR FATAL! load_struct_testing_wget !!! returned:<$_err> \n \n  " && exit 69;

export sudo_it
function sudo_it() {
  raise_to_sudo_and_user_home
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
  enforce_variable_with_value SUDO_USER "${SUDO_USER}"
  enforce_variable_with_value SUDO_UID "${SUDO_UID}"
  enforce_variable_with_value SUDO_COMMAND "${SUDO_COMMAND}"
  # Override bigger error trap  with local
  function _trap_on_error(){
    echo -e "\033[01;7m*** TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR INT ...\033[0m"
  }
  trap _trap_on_error ERR INT
} # end sudo_it

# _linux_prepare(){
  sudo_it
  [ $? -gt 0 ] && (failed to sudo_it raise_to_sudo_and_user_home  || exit 1)
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
passed "Caller user identified:${SUDO_USER}"
passed "Home identified:${USER_HOME}"
directory_exists_with_spaces "${USER_HOME}"
