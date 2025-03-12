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





 #--------\/\/\/\/-- 2tasks_templates_sudo/phpstorm …install_phpstorm.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#

_version() {
  # https://download.jetbrains.com/webide/PhpStorm-2019.3.4.tar.gz
  # https://download-cf.jetbrains.com/webide/PhpStorm-2019.3.4.tar.gz
  # https://download.jetbrains.com/webide/PhpStorm-2020.2.0.tar.gz
  # https://download.jetbrains.com/webide/PhpStorm-2021.3.2.tar.gz
  local PLATFORM="${1}" # mac windows linux
  local PATTERN="${2}"
  # https://www.jetbrains.com/phpstorm/download/#section=linux
  # local CODEFILE="""$(wget --quiet --no-check-certificate https://www.jetbrains.com/phpstorm/download/#section=linux -O -  2>/dev/null )""" # suppress only wget download messages, but keep wget output for variable
  # local CODEFILE="""$(wget --quiet --no-check-certificate https://www.jetbrains.com/phpstorm/download/other.html -O -  2>/dev/null )""" # suppress only wget download messages, but keep wget output for variable
  local CODEFILE="""$(wget --quiet --no-check-certificate https://www.jetbrains.com/phpstorm/whatsnew/ -O -  2>/dev/null )""" # suppress only wget download messages, but keep wget output for variable
  # echo "PATTERN:${PATTERN}"
  # local CODEFILE=$(curl -d "zz=dl4&platform=${PLATFORM}" -H "Content-Type: application/x-www-form-urlencoded" -X POST  -sSLo -  https://www.jetbrains.com/phpstorm/download/\#section=linux  2>&1;) # suppress only wget download messages, but keep wget output for variable
  # echo "$CODEFILE" | sed s/\</\\n\</g | sed s/\>/\>\\n/g| sed 's/:/\n/g' | grep "PhpStorm"
  # echo "$CODEFILE" | sed s/\</\\n\</g | sed s/\>/\>\\n/g  | grep "New in PhpStorm" | grep "New" | grep "2021"


  # echo "$CODEFILE" | sed s/\</\\n\</g | sed s/\>/\>\\n/g | sed 's/,/\n/g'  | grep '"version"'  | cut -d'"' -f4
  # echo "$CODEFILE"  | phantomjs  --- crashes

  # local CODELASTESTBUILD=$(echo $CODEFILE | sed s/\</\\n\</g | grep "${PATTERN}" | sed s/\"/\\n/g | grep "/" | cüt "/")
  local CODELASTESTBUILD=$(echo "$CODEFILE" | sed s/\</\\n\</g | sed s/\>/\>\\n/g | sed 's/,/\n/g'  | grep '"version"'  | cut -d'"' -f4)
  # fedora 32 local CODELASTESTBUILD=$(echo $CODEFILE | sed s/\</\\n\</g | grep "PhpStorm*.*.*.*.i386.rpm" | sed s/\"/\\n/g | grep "/" | cüt "/")
  wait
  # [[ -z "${CODELASTESTBUILD}" ]] && failed "PhpStorm Version not found! :${CODELASTESTBUILD}:"


  enforce_variable_with_value USER_HOME "${USER_HOME}"
  enforce_variable_with_value CODELASTESTBUILD "${CODELASTESTBUILD}"

  local CODENAME="${CODELASTESTBUILD}"
  echo "${CODELASTESTBUILD}"
  unset PATTERN
  unset PLATFORM
  unset CODEFILE
  unset CODELASTESTBUILD
} # end _version

_darwin__64() {
    local CODENAME=$(_version "mac" "PhpStormOSX*.*.*.*.zip")
    # THOUGHT        local CODENAME="PhpStormOSX-4.3.3.24545.zip"
    local URL="https://download-cf.jetbrains.com/webide/${CODENAME}"
    local DOWNLOAD_FOLDER="$(_find_downloads_folder)"
    enforce_variable_with_value DOWNLOAD_FOLDER "${DOWNLOAD_FOLDER}"
    cd ${DOWNLOAD_FOLDER}/
    _download "${URL}"
    unzip ${CODENAME}
    sudo hdiutil attach ${CODENAME}
    sudo cp -R /Volumes/Beyond\ Compare/Beyond\ Compare.app /Applications/
    sudo hdiutil detach /Volumes/Beyond \ Compare
} # end _darwin__64

_ubuntu__64() {
    local CODENAME=$(_version "linux" "PhpStorm-*.*.*.*amd64.deb")
    # THOUGHT          local CODENAME="PhpStorm-4.3.3.24545_amd64.deb"
    local URL="https://download-cf.jetbrains.com/webide/${CODENAME}"
    enforce_variable_with_value DOWNLOAD_FOLDER "${DOWNLOAD_FOLDER}"
    cd ${DOWNLOAD_FOLDER}/
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
    _xdebug_add
} # end _ubuntu__64

_ubuntu__32() {
    local CODENAME=$(_version "linux" "PhpStorm-*.*.*.*i386.deb")
    # THOUGHT local CODENAME="PhpStorm-4.3.3.24545_i386.deb"
    local URL="https://download-cf.jetbrains.com/webide/${CODENAME}"
    local DOWNLOAD_FOLDER="$(_find_downloads_folder)"
    enforce_variable_with_value DOWNLOAD_FOLDER "${DOWNLOAD_FOLDER}"
    cd ${DOWNLOAD_FOLDER}/
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
    _xdebug_add
} # end _ubuntu__32

_fedora__32() {
  local CODENAME
  CODENAME=$(_version "linux" "PhpStorm*.*.*.*.i386.rpm")
  # THOUGHT                          PhpStorm-4.3.3.24545.i386.rpm
  local TARGET_URL="https://download-cf.jetbrains.com/webide/${CODENAME}"
  local DOWNLOAD_FOLDER
  DOWNLOAD_FOLDER="$(_find_downloads_folder)"
  enforce_variable_with_value DOWNLOAD_FOLDER "${DOWNLOAD_FOLDER}"
  file_exists_with_spaces "${DOWNLOAD_FOLDER}"
  cd "${DOWNLOAD_FOLDER}" || return 1
  _download "${TARGET_URL}"
  file_exists_with_spaces "${DOWNLOAD_FOLDER}/${CODENAME}"
  ensure tar or "Canceling Install. Could not find tar command to execute unzip"

  # provide error handling , once learned goes here. LEarn under if, once learned here.
  # Start loop while ERROR flag in case needs to try again, based on error
  _try "rpm --import https://download-cf.jetbrains.com/webide/RPM-GPG-KEY-scootersoftware"
  local msg=$(_try "rpm -ivh \"${DOWNLOAD_FOLDER}/${CODENAME}\"" )
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
  ensure PhpStorm or "Failed to install Beyond Compare"
  rm -f "${DOWNLOAD_FOLDER}/${CODENAME}"
  file_does_not_exist_with_spaces "${DOWNLOAD_FOLDER}/${CODENAME}"
  _xdebug_add
} # end _fedora__32

_centos__64() {
  _fedora__64
} # end _centos__64

_fedora__64() {
  local TARGETFOLDER="${USER_HOME}/_/software"
  enforce_variable_with_value TARGETFOLDER "${TARGETFOLDER}"

  local _target_dir_install="${TARGETFOLDER}/phpstorm"
  enforce_variable_with_value _target_dir_install "${_target_dir_install}"
  # _linux_prepare
  # Lives Samples
  # https://download.jetbrains.com/webide/PhpStorm-2019.3.4.tar.gz
  # https://download-cf.jetbrains.com/webide/PhpStorm-2019.3.4.tar.gz
  # https://download.jetbrains.com/webide/PhpStorm-2021.3.2.tar.gz
  local CODENAME
  CODENAME=$(_version "linux" "PhpStorm-*.*.*.tar.gz")
  # echo "CODENAME:${CODENAME}"
  enforce_variable_with_value CODENAME "${CODENAME}"

  CODENAME="PhpStorm-${CODENAME}"
  passed "CODENAME:${CODENAME}"
  local TARGET_URL="https://download-cf.jetbrains.com/webide/${CODENAME}.tar.gz"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  local DOWNLOAD_FOLDER
  DOWNLOAD_FOLDER="$(_find_downloads_folder)"
  enforce_variable_with_value DOWNLOAD_FOLDER "${DOWNLOAD_FOLDER}"

  _xdebug_add
  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOAD_FOLDER}"  "${CODENAME}.tar.gz"
  _untar_gz_download "${DOWNLOAD_FOLDER}"  "${DOWNLOAD_FOLDER}/${CODENAME}.tar.gz"
  _move_to_target_dir "${DOWNLOAD_FOLDER}" "${_target_dir_install}" "${TARGETFOLDER}"

  [ -e "${DOWNLOAD_FOLDER}/${CODENAME}.tar.gz" ] && rm "${DOWNLOAD_FOLDER}/${CODENAME}.tar.gz"
  directory_does_not_exist_with_spaces "${DOWNLOAD_FOLDER}/${CODENAME}.tar.gz"


  directory_exists_with_spaces "${_target_dir_install}/bin"
  mkdir -p "$USER_HOME/.local/share/applications"
  directory_exists_with_spaces "$USER_HOME/.local/share/applications"
  mkdir -p "$USER_HOME/.local/share/mime/packages"
  directory_exists_with_spaces "$USER_HOME/.local/share/mime/packages"
  file_exists_with_spaces "${_target_dir_install}/bin/phpstorm.sh"

  chown "${SUDO_USER}":"${SUDO_USER}" -R "${_target_dir_install}"
  
  _create_pstorm_open_rb "${_target_dir_install}"
  _create_pstorm_open_sh "${_target_dir_install}"
  _create_application_x_pstorm_xml "${_target_dir_install}"
  _create_jetbrains_phpstorm_desktop "${_target_dir_install}"
  _create_phpstorm_mimeinfo_cache  "${_target_dir_install}"
  _register_xdg_mime
  _create_mimeapps_list "${_target_dir_install}"
  _check_xdg_mime "${_target_dir_install}"
  _update_mime_database
  _test_mime_updates
  _xdebug_add
} # end _fedora__64

_create_pstorm_open_rb() {
  local _target_dir_install="${*}"
  # Now Proceed to register REF:  https://gist.github.com/c80609a/752e566093b1489bd3aef0e56ee0426c
  ensure cat or "Failed to use cat command does not exists"
  ensure xdg-mime or "Failed to install run xdg-mime"

   cat << EOF > "${_target_dir_install}/bin/pstorm-open.rb"
#!/usr/bin/env ruby

# ${_target_dir_install}/bin/pstorm-open.rb
# script opens URL in format phpstorm://open?file=%{file}:%{line} in phpstorm

require 'uri'

begin
    url = ARGV.first
    u = URI.parse(url)
    # puts u
    q = URI.decode_www_form(u.query)
    # puts q
    h = q.to_h
    # puts h
    file = h['file']
    line = h['line']
    # puts file
    # puts line
    if line
        arg = "#{file}:#{line}"
    else
        arg = "#{file}"
    end
rescue
    arg = ""
end
puts arg
EOF
  file_exists_with_spaces "${_target_dir_install}/bin/pstorm-open.rb"
  chown $SUDO_USER:$SUDO_USER -R "${_target_dir_install}/bin/pstorm-open.rb"
  chmod +x ${_target_dir_install}/bin/pstorm-open.rb
} # end _create_pstorm_open_rb

_create_pstorm_open_sh() {
  local _target_dir_install="${*}"
    cat << EOF > "${_target_dir_install}/bin/pstorm-open.sh"
#!/usr/bin/env bash
#encoding: UTF-8
# ${_target_dir_install}/bin/pstorm-open.sh
# script opens URL in format phpstorm://open?file=%{file}:%{line} in phpstorm

echo "spaceSpace"
echo "spaceSpace"
echo "spaceSpace"
echo "<\${@}> <--- There should be something here between <>"
echo "<\${*}> <--- There should be something here between <>"
echo "\${@}" >>  $USER_HOME/_/work/requested.log
last_line=\$(tail -1<<<\$(grep 'file='<$USER_HOME/_/work/requested.log))
${_target_dir_install}/bin/pstorm-open.rb \${last_line}
filetoopen=\$(${_target_dir_install}/bin/pstorm-open.rb "\${last_line}")
echo filetoopen "\${filetoopen}"
echo "\${filetoopen}" >>  $USER_HOME/_/work/requestedfiletoopen.log
pstorm "\${filetoopen}"

EOF
  mkdir -p $USER_HOME/_/work/
  directory_exists_with_spaces $USER_HOME/_/work/
  chown $SUDO_USER:$SUDO_USER $USER_HOME/_/work/
  touch $USER_HOME/_/work/requestedfiletoopen.log
  file_exists_with_spaces $USER_HOME/_/work/requestedfiletoopen.log
  chown $SUDO_USER:$SUDO_USER -R $USER_HOME/_/work/requestedfiletoopen.log
  file_exists_with_spaces "${_target_dir_install}/bin/pstorm-open.sh"
  chown $SUDO_USER:$SUDO_USER -R "${_target_dir_install}/bin/pstorm-open.sh"
  chmod +x ${_target_dir_install}/bin/pstorm-open.sh
} # end _create_pstorm_open_sh

_create_application_x_pstorm_xml() {
  local _target_dir_install="${*}"
 cat << EOF > $USER_HOME/.local/share/mime/packages/application-x-pstorm.xml
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-pstorm">
    <comment>new mime type</comment>
    <glob pattern="*.x-pstorm;*.rb;*.html;*.html.erb;*.js.erb;*.html.haml;*.js.haml;*.erb;*.haml;*.js"/>
  </mime-type>
</mime-info>
EOF
  file_exists_with_spaces "$USER_HOME/.local/share/mime/packages/application-x-pstorm.xml"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/.local/share/mime/packages/application-x-pstorm.xml"
} # end _create_application_x_pstorm_xml

_create_jetbrains_phpstorm_desktop() {
  local _target_dir_install="${*}"
  cat << EOF > $USER_HOME/.local/share/applications/jetbrains-phpstorm.desktop
# $USER_HOME/.local/share/applications/jetbrains-phpstorm.desktop
[Desktop Entry]
Encoding=UTF-8
Version=2020.2
Type=Application
Name=phpstorm
Icon=${_target_dir_install}/bin/phpstorm.svg
Exec=${_target_dir_install}/bin/phpstorm.sh %f
MimeType=application/x-pstorm;text/x-pstorm;text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;x-directory/normal;inode/directory;
Comment=The Most Intelligent Php IDE
Categories=Development;IDE;
Terminal=true
StartupWMClass=jetbrains-phpstorm
EOF
  file_exists_with_spaces "$USER_HOME/.local/share/applications/jetbrains-phpstorm.desktop"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/.local/share/applications/jetbrains-phpstorm.desktop"
} # end _create_jetbrains_phpstorm_desktop

_create_phpstorm_mimeinfo_cache() {
  local _target_dir_install="${*}"
  cat << EOF > $USER_HOME/.local/share/applications/phpstorm.mimeinfo.cache
# $USER_HOME/.local/share/applications/mimeinfo.cache

[MIME Cache]
x-scheme-handler/phpstorm=pstorm-open.desktop;
EOF
  file_exists_with_spaces "$USER_HOME/.local/share/applications/phpstorm.mimeinfo.cache"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/.local/share/applications/phpstorm.mimeinfo.cache"

  cat << EOF > $USER_HOME/.local/share/applications/pstorm-open.desktop
# $USER_HOME/.local/share/applications/pstorm-open.desktop
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Terminal=true
Exec=${_target_dir_install}/bin/pstorm-open.sh %f
MimeType=application/phpstorm;x-scheme-handler/phpstorm;
Name=PhpStormOpen
Comment=BetterErrors
EOF
  file_exists_with_spaces "$USER_HOME/.local/share/applications/pstorm-open.desktop"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/.local/share/applications/pstorm-open.desktop"
} # end _create_phpstorm_mimeinfo_cache

_register_xdg_mime() {
  # xdg-mime default jetbrains-phpstorm.desktop text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;x-directory/normal;inode/directory;
  # xdg-mime default pstorm-open.desktop x-scheme-handler/phpstorm
  # msg=$(_try "xdg-mime default pstorm-open.desktop x-scheme-handler/phpstorm" )
  su - "${SUDO_USER}" -c "xdg-mime default pstorm-open.desktop x-scheme-handler/phpstorm"
  su - "${SUDO_USER}" -c "xdg-mime default pstorm-open.desktop text/phpstorm"
  su - "${SUDO_USER}" -c "xdg-mime default pstorm-open.desktop application/phpstorm"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-phpstorm.desktop x-scheme-handler/x-pstorm"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-phpstorm.desktop text/x-pstorm"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-phpstorm.desktop application/x-pstorm"
} # end _register_xdg_mime

_create_mimeapps_list() {
  local _target_dir_install="${*}"
#   cat << EOF > $USER_HOME/.config/mimeapps.list
#   cat << EOF > $USER_HOME/.local/share/applications/mimeapps.list
# [Default Applications]
# x-scheme-handler/phpstorm=pstorm-open.desktop
# text/phpstorm=pstorm-open.desktop
# application/phpstorm=pstorm-open.desktop
# x-scheme-handler/x-pstorm=jetbrains-phpstorm.desktop
# text/x-pstorm=jetbrains-phpstorm.desktop
# application/x-pstorm=jetbrains-phpstorm.desktop

# [Added Associations]
# x-scheme-handler/phpstorm=pstorm-open.desktop;
# text/phpstorm=pstorm-open.desktop;
# application/phpstorm=pstorm-open.desktop;
# x-scheme-handler/x-pstorm=jetbrains-phpstorm.desktop;
# text/x-pstorm=jetbrains-phpstorm.desktop;
# application/x-pstorm=jetbrains-phpstorm.desktop;
# EOF
#   file_exists_with_spaces "$USER_HOME/.local/share/applications/mimeapps.list"
#   file_exists_with_spaces "$USER_HOME/.config/mimeapps.list"
  ln -fs "$USER_HOME/.config/mimeapps.list" "$USER_HOME/.local/share/applications/mimeapps.list"
  softlink_exists_with_spaces "$USER_HOME/.local/share/applications/mimeapps.list>$USER_HOME/.config/mimeapps.list"
  chown $SUDO_USER:$SUDO_USER -R  "$USER_HOME/.local/share/applications/mimeapps.list"
} # end _create_mimeapps_list

_check_xdg_mime() {
  local _target_dir_install="${*}"
  file_exists_with_spaces "${_target_dir_install}/bin/pstorm-open.sh"

  su - "${SUDO_USER}" -c "xdg-mime query default x-scheme-handler/phpstorm"
  su - "${SUDO_USER}" -c "xdg-mime query default x-scheme-handler/x-pstorm"
  su - "${SUDO_USER}" -c "xdg-mime query default text/x-pstorm"
  su - "${SUDO_USER}" -c "xdg-mime query default application/x-pstorm"
  su - "${SUDO_USER}" -c "xdg-mime query default text/phpstorm"
  su - "${SUDO_USER}" -c "xdg-mime query default application/phpstorm"
  msg=$(_try "su - \"${SUDO_USER}\" -c \"xdg-mime query default x-scheme-handler/phpstorm\"")
  ret=$?
  if [ $ret -gt 0 ] ; then
  {

    failed "${ret}:${msg} Install with xdg-mime scheme failed!"
  }
  else
  {
    passed Install with xdg-mime scheme success!
  }
  fi
} # end _create_mimeapps_list

_update_mime_database() {
  su - "${SUDO_USER}" -c "update-mime-database \"$USER_HOME/.local/share/mime\""
  su - "${SUDO_USER}" -c "update-desktop-database \"$USER_HOME/.local/share/applications\""
} # end _update_mime_database

_test_mime_updates() {  
  su - "${SUDO_USER}" -c "touch test12345.rb "
  su - "${SUDO_USER}" -c "gio info test12345.rb  | grep \"standard::content-type\""
  su - "${SUDO_USER}" -c "touch test12345.erb "
  su - "${SUDO_USER}" -c "gio info test12345.erb  | grep \"standard::content-type\""
  su - "${SUDO_USER}" -c "touch test12345.js.erb "
  su - "${SUDO_USER}" -c "gio info test12345.js.erb  | grep \"standard::content-type\""
  su - "${SUDO_USER}" -c "touch test12345.html.erb "
  su - "${SUDO_USER}" -c "gio info test12345.html.erb  | grep \"standard::content-type\""
  su - "${SUDO_USER}" -c "touch test12345.haml "
  su - "${SUDO_USER}" -c "gio info test12345.haml  | grep \"standard::content-type\""
  su - "${SUDO_USER}" -c "touch test12345.html.haml "
  su - "${SUDO_USER}" -c "gio info test12345.html.haml  | grep \"standard::content-type\""
  su - "${SUDO_USER}" -c "touch test12345.js.haml "
  su - "${SUDO_USER}" -c "gio info test12345.js.haml  | grep \"standard::content-type\""

  su - "${SUDO_USER}" -c "gio mime x-scheme-handler/phpstorm"
  su - "${SUDO_USER}" -c "gio mime x-scheme-handler/x-pstorm"
  su - "${SUDO_USER}" -c "gio mime text/x-pstorm"
  su - "${SUDO_USER}" -c "gio mime application/x-pstorm"
  su - "${SUDO_USER}" -c "gio mime text/phpstorm"
  su - "${SUDO_USER}" -c "gio mime application/phpstorm"
  su - "${SUDO_USER}" -c "rm test12345.rb"
  su - "${SUDO_USER}" -c "rm test12345.erb"
  su - "${SUDO_USER}" -c "rm test12345.js.erb"
  su - "${SUDO_USER}" -c "rm test12345.html.erb"
  su - "${SUDO_USER}" -c "rm test12345.haml"
  su - "${SUDO_USER}" -c "rm test12345.js.haml"
  su - "${SUDO_USER}" -c "rm test12345.html.haml"
  echo " "
} # end _test_mime_updates


_xdebug_add() {
  echo "HINT: Change xdebug.ini 
  
  from
   ; xdebug.file_link_format = \"xdebug://%f:%l\"
  to
   ; xdebug.file_link_format = \"phpstorm://open?file=%f:%l\"
  "
  Comment Attemping to find xdebug config 
  local _xdebug_config_filepath="$(php -i | grep xdebug.ini | cut -d, -f1)"
  if [[ -n "${_xdebug_config_filepath}" ]] ; then
  {
    passed "Found"
    Checking does "${_xdebug_config_filepath}" exists 
    ls -la "${_xdebug_config_filepath}" 
    if file_exists_with_spaces "${_xdebug_config_filepath}" ; then 
    {
      passed "Yes it exists"
      local _xdebug_ini_file_contents="$(<"${_xdebug_config_filepath}")"

      passed "Yes the key word file_link_format exists "
      local _xdebug_ini_file_contents="$(<"${_xdebug_config_filepath}")"
      Checking file "${_xdebug_ini_file_contents}" is not empty 
      if [[ -n "${_xdebug_ini_file_contents}" ]] ; then
      {
        passed file has lines  
        Checking if file contains \"; xdebug.file_link_format\" 
        if _if_contains  "${_xdebug_config_filepath}" "file_link_format" ; then
        {
          passed file was this code line ; xdebug.file_link_format
          if _if_contains  "${_xdebug_config_filepath}" "phpstorm" ; then
          {
            warning it looks that phpstorm word is already found inside
            warning Control it and add it manually to "${_xdebug_config_filepath}"
            Comment "\n; xdebug.file_link_format = \"phpstorm://open?file=%f:%l\""
            Comment I will not add
          }
          else 
          {
            passed it has no phpstorm word inside 
            Comment Attempting to add manually
            local one_line=""
            local new_file=""
            Message first comment out all current lines
            while read -r one_line; do
            {
              if [[ -z "${one_line}" ]] ; then
              {
                new_file="${new_file}\n${one_line}"
                continue
              }
              elif [[ "${one_line}" == *"file_link_format"* ]] ; then
              {
                new_file="${new_file}\n; ${one_line}"
                if [ ${added} -eq 0 ] ; then
                {
                  new_file="${new_file}\n; xdebug.file_link_format = \"phpstorm://open?file=%f:%l\""
                  added=1
                }
                fi
                continue
              } else {
                new_file="${new_file}\n${one_line}"
                continue
              }
              fi
            }
            done <<< "${_xdebug_ini_file_contents}"
            Message attempting to write file
            Comment backup current file 
            local _err=0
            local CURRENTDATE=$(date +%Y%m%d%H%M)
            cp "${_xdebug_config_filepath}" "${_xdebug_config_filepath}_bk_${CURRENTDATE}"
            _err=$?
            if [ ${_err} -gt 0 ] ; then
            {
              warning add it manually to "${_xdebug_config_filepath}"
              Comment "\n; xdebug.file_link_format = \"phpstorm://open?file=%f:%l\""
              failed to back up current file "${_xdebug_config_filepath}"
            }
            fi
            echo -e "${new_file}" > "${_xdebug_config_filepath}"
            _err=$?
            if [ ${_err} -gt 0 ] ; then
            {
              warning add it manually to "${_xdebug_config_filepath}"
              Comment "\n; xdebug.file_link_format = \"phpstorm://open?file=%f:%l\""
              failed to copy new content to file "${_xdebug_config_filepath}"
            }
            fi
          }
          fi
        } 
        else 
        {
          warning It does not contain this directive 
          Comment Just appending it 
          ersetze "; xdebug.file_link_format" "; ; xdebug.file_link_format"
          echo -e "; xdebug.file_link_format = \"phpstorm://open?file=%f:%l\"" >>"${_xdebug_config_filepath}"
        }
        fi
      }
      else
      {
        Message file has no lines but it exists
        warning file is empty then creating it 
        Comment and adding file_link_format
        echo -e "; xdebug.file_link_format = \"phpstorm://open?file=%f:%l\"" >"${_xdebug_config_filepath}"
      }
      fi
      Checking if the new change is There
      if _if_not_contains  "${_xdebug_config_filepath}" "phpstorm" ; then
      {
        warning add it manually to "${_xdebug_config_filepath}"
        Comment "\n; xdebug.file_link_format = \"phpstorm://open?file=%f:%l\""
        failed to write  "${_xdebug_config_filepath}"
      }
      fi
    }
    fi
  }
  fi
} # end _xdebug_add

_mingw__64() {
    local CODENAME=$(_version "win" "PhpStorm*.*.*.*.exe")
    # THOUGHT        local CODENAME="PhpStorm-4.3.3.24545.exe"
    local URL="https://download-cf.jetbrains.com/webide/${CODENAME}"
    cd $HOMEDIR
    local DOWNLOAD_FOLDER="$(_find_downloads_folder)"
    enforce_variable_with_value DOWNLOAD_FOLDER "${DOWNLOAD_FOLDER}"
    cd "${DOWNLOAD_FOLDER}"
    curl -O $URL
    ${CODENAME}
} # end _mingw__64

_mingw__32() {
    local CODENAME=$(_version "win" "PhpStorm*.*.*.*.exe")
    # THOUGHT        local CODENAME="PhpStorm-4.3.3.24545.exe"
    local URL="https://download-cf.jetbrains.com/webide/${CODENAME}"
    cd $HOMEDIR
    local DOWNLOAD_FOLDER="$(_find_downloads_folder)"
    enforce_variable_with_value DOWNLOAD_FOLDER "${DOWNLOAD_FOLDER}"
    cd "${DOWNLOAD_FOLDER}"
    curl -O $URL
    ${CODENAME}
} # end


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo ":)"



 #--------/\/\/\/\-- 2tasks_templates_sudo/phpstorm …install_phpstorm.bash” -- Custom code-/\/\/\/\-------



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
