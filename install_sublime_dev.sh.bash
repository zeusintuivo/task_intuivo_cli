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
		echo -e "\\n \033[01;7m*** 0tasks_base/sudoer.bash:$LINENO load_struct_testing() ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[1]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[2]}()  \\n$0:${BASH_LINENO[2]} ${FUNCNAME[3]}() \\n ERR ...\033[0m  \n \n "

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
          echo "$0: 0tasks_base/sudoer.bash Loading locally"
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
            echo "$0: 0tasks_base/sudoer.bash Loading ${_library} from the net using curl "
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
            echo "$0: 0tasks_base/sudoer.bash Loading ${_library} from the net using wget "
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



 #---------/\/\/\-- 0tasks_base/sudoer.bash -------------/\/\/\--------





 #--------\/\/\/\/-- 2tasks_templates_sudo/sublime_dev.sh …install_sublime_dev.sh.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#

_version() {
    trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
    local -i _err
    # local _sublime_version_page=$(curl -L https://www.sublimetext.com/3dev  2>/dev/null )  # suppress only wget download messages, but keep wget output for variable
    # set -x
    local _sublime_version_page=""
    _sublime_version_page=$(curl -L https://www.sublimetext.com/3dev  2>&1 )  # stout and stderr both get
    _err=$?
    if [ $_err -eq 6 ] ;  then # curl: (6) Could not resolve host:
    {
      >&2 echo -e "ERROR Failed to Connect to Internet. Check your connection or Site not found. "
      exit $_err
    }
    elif [ $_err -ne 0 ] ;  then
    {
      >&2 echo -e "ERROR There was an error doing command Curl to download  Err:$_err "
      exit $_err
    }
    fi
    local _sublime_string=$(echo "${_sublime_version_page}" | sed -n "/<p\ class=\"latest\">/,/<\/div>/p" | head -1)  # suppress only wget download messages, but keep wget output for variable
    _err=$?
    # echo -e "_sublime_string> ${_sublime_string} \n"
    # exit 0
    local _sublime_build_line=$(echo "${_sublime_string}" | grep "Build ....")
    _err=$?
    # echo -e "----------------err> ${_err} \n"
    # echo -e "_sublime_build_line> ${_sublime_build_line} \n"
    # exit 0
    if [ -z "${_sublime_build_line}" ] ; then
    {
        echo "ERROR when doing check of line string from website. Got nothing"
        echo "    _sublime_string: <${_sublime_string}>"
        echo "                      0123456789 123456789 123456789 123456789 123456789 123456789 1234567889 123456789 123456789 123456789 123456789 "
        echo "                                1         2         3         4         5         6          7         8         9        10        11"
        echo "_sublime_build_line: <${_sublime_build_line}>"
        failed "Error"
        exit 69;
    }
    else
    {
        local __online_version_from_page=$(echo "${_sublime_build_line}" | cut -c42-45)
        wait
        [[ -z "${__online_version_from_page}" ]] && failed "Sublime Version not found!"
        echo "${__online_version_from_page}"
    }
    fi
    # exit 0
    return 0
} # end _version

download_sublime(){
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  # sample https://download.sublimetext.com/sublime-text_build-3133_amd64.deb
  # sample https://download.sublimetext.com/sublime_text_3_build_3211_x64.tar.bz2
  # https://download.sublimetext.com/sublime-text-3210-1.x86_64.rpm
  # https://download.sublimetext.com/sublime_text_3_build_3210_x32.tar.bz2
  # https://download.sublimetext.com/sublime_text_3_build_3211_x64.tar.bz2
  local target_url="https://download.sublimetext.com/${1}"

  _download "${target_url}" $USER_HOME/Downloads  ${1}

  # if ( command -v wget >/dev/null 2>&1; ) ; then
  #   wget --directory-prefix="${USER_HOME}/Downloads/" --quiet --no-check-certificate "${target_url}" 2>/dev/null
  #
  #   # echo -e "\e[7m*** Downloading file to temp location...\e[0m"
  #   # # REF: about :> http://unix.stackexchange.com/questions/37507/what-does-do-here
  #   # :> wgetrc   # here :> equals to Equivalent to the following: cat /dev/null > wgetrc which Nulls out the file called "wgetrc" in the current directory. As in creates an empty file "wgetrc" if one doesn't exist or overwrites one with nothing if it does.
  #   # echo "noclobber = off" >> wgetrc
  #   # echo "dir_prefix = ." >> wgetrc
  #   # echo "dirstruct = off" >> wgetrc
  #   # echo "verbose = on" >> wgetrc
  #   # echo "progress = bar:default" >> wgetrc
  #   # echo "tries = 3" >> wgetrc
  #
  #   # WGETRC=wgetrc wget --quiet --no-check-certificate "${target_url}" 2>/dev/null   # suppress only wget download messages, but keep wget output for variable
  #   # echo -e "\e[7m*** Download completed.\e[0m"
  #   # rm -f wgetrc
  # elif ( command -v curl >/dev/null 2>&1; ); then
  #   curl -O "${target_url}" 2>/dev/null   # suppress only wget download messages, but keep wget output for variable
  # else
  #   failed "I cannot find wget or curl to download! ${target_url}"
  # fi
}

download_install_package_control(){
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  # Package Control - The Sublime Text Package Manager: https://sublime.wbond.net
  local __pc_dir_opt_s_p__=/opt/sublime_text/Packages/
  local __pc_dir_config_s_ip__="${USER_HOME}"/.config/sublime-text-3/Installed\ Packages/
  local __pc_download_filename__=Package\ Control.sublime-package
  local target_url="https://packagecontrol.io/Package%20Control.sublime-package"
	local CODENAME="Package Control.sublime-package"
	local CODENAMECHECK="Package\ Control.sublime-package"
  it_does_not_exist_with_spaces "${__pc_dir_opt_s_p__}" && mkdir  -p "${__pc_dir_opt_s_p__}"
  it_does_not_exist_with_spaces "${__pc_dir_opt_s_p__}" && mkdir -p "${__pc_dir_config_s_ip__}"
  directory_exists_with_spaces "${__pc_dir_opt_s_p__}"
  directory_exists_with_spaces "${__pc_dir_config_s_ip__}"

  if [ ! -e "${__pc_dir_opt_s_p__}" ] ; then
    failed "I cannot find target directory where sublime is installed or Packages folder! ${__pc_dir_opt_s_p__}"
  fi
  local DOWNLOADFOLDER="$(_find_downloads_folder)"
	_do_not_downloadtwice "${target_url}" "${DOWNLOADFOLDER}"  "${CODENAME}"

  local __pc_download_filepath__="${DOWNLOADFOLDER}/${CODENAME}"
	# directory_does_not_exist_with_spaces "${__pc_download_filepath__}"
  if it_does_not_exist_with_spaces "${__pc_download_filepath__}" ; then
    failed "I cannot find target downloaded where the Packages was supposed to be! ${__pc_download_filepath__}"
  fi
  file_exists_with_spaces "${__pc_download_filepath__}"


  if it_exists_with_spaces "${__pc_dir_config_s_ip__}/${__pc_download_filename__}" ; then
    rm -rf "${__pc_dir_config_s_ip__}/${__pc_download_filename__}"
  fi
  cp -R "${__pc_download_filepath__}"  "${__pc_dir_config_s_ip__}"

  if it_exists_with_spaces "${__pc_dir_opt_s_p__}/${__pc_download_filename__}" ; then
    rm -rf "${__pc_dir_opt_s_p__}/${__pc_download_filename__}"
  fi
  cp -R "${__pc_download_filepath__}"  "${__pc_dir_opt_s_p__}"
  rm -rf "${__pc_download_filepath__}"
  if it_exists_with_spaces "${__pc_dir_config_s_ip__}/${__pc_download_filename__}/${__pc_download_filename__}" ; then
    mv "${__pc_dir_config_s_ip__}/${__pc_download_filename__}/${__pc_download_filename__}" "${__pc_dir_config_s_ip__}/${__pc_download_filename__}/${__pc_download_filename__}m"
    mv "${__pc_dir_config_s_ip__}/${__pc_download_filename__}/${__pc_download_filename__}m" "${__pc_dir_config_s_ip__}/"
    rm -rf "${__pc_dir_config_s_ip__}/${__pc_download_filename__}m"
    mv "${__pc_dir_config_s_ip__}/${__pc_download_filename__}m" "${__pc_dir_config_s_ip__}/${__pc_download_filename__}"

  fi
  chown -R "${SUDO_USER}" "${__pc_dir_config_s_ip__}"
} # end download_install_package_control

add_to_applications_list(){
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  # Add to applications list
  directory_exists "
  ${USER_HOME}/.local/share/applications/
  /opt/sublime_text/Icon/128x128/
  /usr/share/applications/
  "


  #Creando archivo .desktop
  echo -e "\e[7m*** Creating .desktop file (for easy launch and associate to Sublime Text 3)...\e[0m"
  echo "[Desktop Entry]
  Version=1.0
  Type=Application
  Name=Sublime Text 3 DEV
  GenericName=Text Editor
  Comment=Sophisticated text editor for code, markup and prose
  #Exec=/opt/sublime_text/sublime_text %F
  Exec=sublime-text-3 %F
  Terminal=false
  MimeType=text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;x-directory/normal;inode/directory;
  Icon=sublime-text-3
  Categories=TextEditor;Development;
  StartupNotify=true
  Actions=Window;Document;
  [Desktop Action Window]
  Name=New Window
  Exec=/opt/sublime_text/sublime_text -n
  OnlyShowIn=Unity;
  [Desktop Action Document]
  Name=New File
  Exec=/opt/sublime_text/sublime_text --command new_file
  OnlyShowIn=Unity;" > /usr/share/applications/"Sublime Text 3.desktop"

  cat << EOF > $USER_HOME/.local/share/applications/sublime.desktop
  [Desktop Entry]
  Name=Sublime Text Dev
  Exec=subl %F
  MimeType=text/plain;
  Terminal=false
  Type=Application
  Icon=/opt/sublime_text/Icon/128x128/sublime-text.png
  Categories=Utility;TextEditor;Development;
EOF
} # end add_to_applications_list

_darwin__arm64() {
  _darwin__64
} # end _darwin__arm64

_darwin__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
    local __online_version_from_page=$(_version)
    local SUBLIMENAME="Sublime%20Text%20Build%20${__online_version_from_page}.dmg"
    local SUBLIMENAME_4_HDUTIL="Sublime Text Build ${__online_version_from_page}.dmg"
    wait
    cd ~/Downloads/
    [ ! -e "${SUBLIMENAME_4_HDUTIL}" ] || download_sublime "${SUBLIMENAME}"
    echo "${pwd}"
    echo "${SUBLIMENAME_4_HDUTIL}"
    ls -la "${SUBLIMENAME_4_HDUTIL}"
    wait
    sudo hdiutil attach "${SUBLIMENAME_4_HDUTIL}"
    wait
    sudo cp -R /Volumes/Sublime\ Text/Sublime\ Text.app /Applications/
    wait
    sudo hdiutil detach /Volumes/Sublime\ Text
    wait
} # end _darwin__64

add_rpm_gpg_key_and_add_install_repository() {
    if  is_not_included "sublime-text" "$(dnf repolist)" ; then
    {
      sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
      # Stable
      # sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
      # Dev
      sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/dev/x86_64/sublime-text.repo
    }
    fi
} # add_rpm_gpg_key_and_add_install_repository

_centos__64() {
  _fedora__64
} # end _centos__64

_fedora__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local -i __online_version_from_page=$(_version)
  passed $__online_version_from_page
  if command -v "subl" >/dev/null 2>&1 ; then
  {
    local -i __current_version=$(subl --version | cüt "Sublime Text Build")
    passed $__current_version
    if [ $__current_version -gt $__online_version_from_page ] ; then
    {
      failed installed version is higher than online version
      exit 69
    }
    fi
  }
  fi
  local SUBLIMENAME="sublime-text-${__online_version_from_page}-1.x86_64.rpm"
  passed $SUBLIMENAME
  local CODENAME=$SUBLIMENAME
  # Sample https://download.sublimetext.com/sublime-text-3210-1.x86_64.rpm
  local TARGET_URL="https://download.sublimetext.com/${CODENAME}"
  passed $TARGET_URL
  if  it_exists_with_spaces "$USER_HOME/${CODENAME}" ; then
  {
    file_exists_with_spaces "$USER_HOME/${CODENAME}"
  }
  else
  {
    file_exists_with_spaces $USER_HOME/Downloads
    cd $USER_HOME
    _download "${TARGET_URL}" "$USER_HOME/"  "${CODENAME}"
    file_exists_with_spaces "$USER_HOME/${CODENAME}"
  }
  fi


  add_rpm_gpg_key_and_add_install_repository
  sudo dnf -y install "$USER_HOME/${CODENAME}"
  if  it_exists_with_spaces "$USER_HOME/${CODENAME}" ; then
  {
    rm -rf "$USER_HOME/${CODENAME}"
    directory_does_not_exist_with_spaces "$USER_HOME/${CODENAME}"
  }
  fi
  download_install_package_control
  add_to_applications_list
exit 0
  file_exists "
    /opt/sublime_text/sublime_text
  "

  wait
  if it_exists "${SUBLIMENAME}"; then
      rm -f "${SUBLIMENAME}"
  fi

    verify_is_installed "subl"

    passed ""
    passed "Sublime Text 3 installed successfully!"
    passed "Run with: subl"
    passed "\e[7m*** That's all. Have fun Sublime Texting ;)\e[0m"

} # end _fedora__64

_fedora__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
    local __online_version_from_page=$(_version)
    local SUBLIMENAME="sublime_text_3_build_${__online_version_from_page}_x32.tar.bz2"
    wait
    cd $USER_HOME/Downloads/
    download_sublime "${SUBLIMENAME}"
    wait

    if tar -xf "${SUBLIMENAME}" --directory=$USER_HOME; then
      sudo mv $USER_HOME/sublime_text/ /opt/
      sudo ln -s /opt/sublime_text/sublime_text /usr/bin/subl
    fi
    rm "${SUBLIMENAME}"

    download_install_package_control
    add_to_applications_list

    file_exists "
    /opt/sublime_text/sublime_text
    "

    softlink_exists "
    subl>/opt/sublime_text/sublime_text
    "
    wait
    passed ""
    passed "Sublime Text 3 installed successfully!"
    passed "Run with: subl"

} # end _fedora__32

_ubuntu__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
    local __online_version_from_page=$(_version)
    echo " version ${__online_version_from_page}"
    local SUBLIMENAME="sublime-text_build-${__online_version_from_page}_amd64.deb"
    echo " looking for file ${SUBLIMENAME} online"
    wait
    echo "changing to Downloads folder  ~/Downloads/"
    cd ~/Downloads/
    echo "downloading ${SUBLIMENAME}"
    download_sublime "${SUBLIMENAME}"
    wait
    echo "installing "
    sudo dpkg -i ${SUBLIMENAME}
    wait
} # end _ubuntu__64

_linux__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
    local __online_version_from_page=$(_version)
    local SUBLIMENAME="sublime-text_build-${__online_version_from_page}_i386.deb"
    wait
    cd ~/Downloads/
    download_sublime "${SUBLIMENAME}"
    wait
    sudo dpkg -i ${SUBLIMENAME}
    wait
} # end _linux__32

_windows__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
    local __online_version_from_page=$(curl -L https://www.sublimetext.com/3dev | sed -n "/<p\ class=\"latest\">/,/<\/div>/p" | head -1 | grep 'Build ....' | cut -c42-45)
    wait
    local SUBLIMENAME="Sublime%20Text%20Build%20${__online_version_from_page}%20x64%20Setup.exe"
    wait
    cd $USER_HOMEDIR
    cd Downloads
    curl -O https://download.sublimetext.com/${SUBLIMENAME}
    ${SUBLIMENAME}
    wait
} # end _windows__64

_windows__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
    local __online_version_from_page=$(curl -L https://www.sublimetext.com/3dev | sed -n "/<p\ class=\"latest\">/,/<\/div>/p" | head -1 | grep 'Build ....' | cut -c42-45)
    wait
    local SUBLIMENAME="Sublime%20Text%20Build%20${__online_version_from_page}%20Setup.exe"
    wait
    cd $USER_HOMEDIR
    cd Downloads
    curl -O https://download.sublimetext.com/${SUBLIMENAME}
    ${SUBLIMENAME}
    wait
} # end _windows__32



 #--------/\/\/\/\-- 2tasks_templates_sudo/sublime_dev.sh …install_sublime_dev.sh.bash” -- Custom code-/\/\/\/\-------



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
