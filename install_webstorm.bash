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
          echo "$0: tasks_base/sudoer.bash Loading locally"
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
            echo "$0: tasks_base/sudoer.bash Loading ${_library} from the net using curl "
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
            echo "$0: tasks_base/sudoer.bash Loading ${_library} from the net using wget "
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





 #--------\/\/\/\/-- tasks_templates_sudo/webstorm …install_webstorm.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
set -E -o functrace
_version() {
  local -i _err=0
  trap '[[ -z "$FUNCNAME" ]] && echo -e "${RED}ERROR failed ${#FUNCNAME[@]} $BASH_SOURCE:$LINENO \t\t\t  function:$FUNCNAME ${RESET}" && exit 0 || [[ -n "$FUNCNAME" ]] && echo -e "${RED}ERROR failed ${#FUNCNAME[@]} $BASH_SOURCE:$LINENO \t\t\t  function:$FUNCNAME ${RESET}" && return 1 ' ERR
  trap '[[ -z "$FUNCNAME" ]] && exit 0 || [[ -n "$FUNCNAME" ]] && echo -e "${PURPLE}INTERRUPTED ${YELLOW} ${#FUNCNAME[@]} $BASH_SOURCE:$LINENO \t\t\t function:$FUNCNAME ${RESET}" && return 1 ' INT
  local PLATFORM="${1}" # mac windows linux
  local PATTERN="${2}"
  local -i _err=0
  # THOUGHT:   https://download-cf.jetbrains.com/webstorm/WebStorm-2020.3.dmg
  local CODEFILE=""
  if [ -f step2_failed_CODELASTESTBUILD_was_empty.html ] ; then
  {
    CODEFILE="$(<step2_failed_CODELASTESTBUILD_was_empty.html)"
  }
  else
  {
    # older than 2023 CODEFILE="""$(wget --quiet --no-check-certificate  https://www.jetbrains.com/webstorm/ -O -  2>/dev/null )""" # suppress only wget download messages, but keep wget output for variable
    # CODEFILE="""$(wget --quiet --no-check-certificate  https://www.jetbrains.com/webstorm/download/\#section\=${PLATFORM} -O -  2>/dev/null )""" # suppress only wget download messages, but keep wget output for variable
    CODEFILE="""$(wget --quiet --no-check-certificate  https://data.services.jetbrains.com/products\?platform\=${PLATFORM} -O -  2>/dev/null )""" # suppress only wget download messages, but keep wget output for variable
  }
  fi
  _err=$?
  wait
  if [ -z "${CODEFILE}" ] || [ ${_err} -gt 0 ] ; then
  {
    echo "$BASH_SOURCE:$LINENO function:$FUNCNAME variable is empty CODEFILE"
    return 1  # here one is for error
  }
  fi
  enforce_variable_with_value CODEFILE "${CODEFILE}"
  local CODELASTESTBUILD=$(echo "${CODEFILE}" \
 | sed s/\</\\n\</g \
 | sed s/\>/\>\\n/g \
 | sed "s/&apos;/\'/g" \
 | sed 's/&nbsp;/ /g' \
 | sed 's/,/\n/g' | grep WebStorm | grep -v aarch64  | grep tar.gz | grep link | head -1 | sed 's/"/\n/g' | grep https \
 | tail -1 )
# | grep  "linux" | sed s/\ /\\n/g | grep href | sed 's/"/\n/g' | grep linux \
# | sed s/\ /\\n/g \
# | grep  "New in WebStorm ${PATTERN}" \
# | grep "What&apos;s New in&nbsp;WebStorm&nbsp;" | sed 's/\;/\;'\\n'/g' | sed s/\</\\n\</g  )
  _err=$?
  wait
  if [ -z "${CODELASTESTBUILD}" ] || [ ${_err} -gt 0 ] ; then
  {
    echo "${CODEFILE}" > step2_failed_CODELASTESTBUILD_was_empty.html
    echo "$BASH_SOURCE:$LINENO function:$FUNCNAME variable is empty CODELASTESTBUILD _err:$_err"
    echo '
    wget --quiet --no-check-certificate https://data.services.jetbrains.com/products\?platform\=${PLATFORM} -O - > step2_failed_CODELASTESTBUILD_was_empty.html 
    cat step2_failed_CODELASTESTBUILD_was_empty.html \
   | sed s/\</\\n\</g  \
   | sed s/\>/\>\\n/g  \ '
   echo "   | sed \"s/&apos;/'/g\" \\
   | sed 's/&nbsp;/ /g' \\
   "
   # | grep  \"New in WebStorm ${PATTERN}\" \\
   # echo " | sed s/\\ /\\\\n/g \\
   # echo "   | grep  linux | sed s/\ /\\n/g | grep href \\ "
   # echo "   | sed 's/\"/\n/g' | grep linux  \\
   echo "    | sed 's/,/\n/g' | grep WebStorm | grep -v aarch64  | grep tar.gz | grep link | head -1 | sed 's/\"/\n/g' | grep https \\ 
   | tail -1
   "

    return 1  # here one is for error
  }
  fi
  enforce_variable_with_value CODELASTESTBUILD "${CODELASTESTBUILD}"
  _err=$?
  if [ -z "${CODELASTESTBUILD}" ] || [ ${_err} -gt 0 ] ; then
  {
    return 1  # here one is for error
  }
  fi
  rm -rf step2_failed_CODELASTESTBUILD_was_empty.html
  local CODENAME=""
  case ${PLATFORM} in
  mac)
    # older than 2023 CODENAME="https://download-cf.jetbrains.com/webstorm/WebStorm-${CODELASTESTBUILD}.dmg"
    # CODENAME="https:${CODELASTESTBUILD}"
    CODENAME="${CODELASTESTBUILD}"
    ;;

  windows)
    # older than 2023 CODENAME="https://download-cf.jetbrains.com/webstorm/WebStorm-${CODELASTESTBUILD}.exe"
    # older than 2023 CODENAME="https://download-cf.jetbrains.com/webstorm/WebStorm-${CODELASTESTBUILD}.win.zip"
    # CODENAME="https:${CODELASTESTBUILD}"
    CODENAME="${CODELASTESTBUILD}"
    ;;

  linux)
    # older than 2023 CODENAME="https://download-cf.jetbrains.com/webstorm/WebStorm-${CODELASTESTBUILD}.tar.gz"
    # CODENAME="https:${CODELASTESTBUILD}"
    CODENAME="${CODELASTESTBUILD}"
    ;;

  *)
    CODENAME=""
    ;;
  esac
  enforce_variable_with_value CODENAME "${CODENAME}"
  _err=$?
  if [ -z "${CODENAME}" ] || [ ${_err} -gt 0 ] ; then
  {
    echo "$BASH_SOURCE:$LINENO function:$FUNCNAME variable is empty CODELASTESTBUILD _err:$_err"
    return 1  # here one is for error
  }
  fi
  unset PATTERN
  unset PLATFORM
  unset CODEFILE
  unset CODELASTESTBUILD
  echo "${CODENAME}"
  return 0
} # end _version
function _unzip(){
  # Sample use
  #
  #     _unzip "${DOWNLOADFOLDER}" "${UNZIPDIR}" "${CODENAME}"
  #
  local DOWNLOADFOLDER="${1}"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"

  local UNZIPDIR="${2}"
  enforce_variable_with_value UNZIPDIR "${UNZIPDIR}"

  local CODENAME="${3}"
  enforce_variable_with_value CODENAME "${CODENAME}"

  file_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
  if  it_exists_with_spaces "${DOWNLOADFOLDER}${UNZIPDIR}" ; then
  {
    rm -rf "${DOWNLOADFOLDER}${UNZIPDIR}"
    directory_does_not_exist_with_spaces "${DOWNLOADFOLDER}${UNZIPDIR}"
  }
  fi

  ensure tar or "Canceling Install. Could not find tar command to execute unzip"
  ensure awk or "Canceling Install. Could not find awk command to execute unzip"
  ensure pv or "Canceling Install. Could not find pv command to execute unzip"
  ensure du or "Canceling Install. Could not find du command to execute unzip"
  ensure gzip or "Canceling Install. Could not find gzip command to execute unzip"
  ensure gio or "Canceling Install. Could not find gio command to execute unzip"
  ensure update-mime-database or "Canceling Install. Could not find update-mime-database command to execute unzip"
  ensure update-desktop-database or "Canceling Install. Could not find update-desktop-database command to execute unzip"
  ensure touch or "Canceling Install. Could not find touch command to execute unzip"

  # provide error handling , once learned goes here. LEarn under if, once learned here.
  # Start loop while ERROR flag in case needs to try again, based on error
  cd "${DOWNLOADFOLDER}"
  #_try "tar xvzf  \"${DOWNLOADFOLDER}/${CODENAME}.tar.gz\"--directory=${DOWNLOADFOLDER}"
  # GROw bar with tar Progress bar tar REF: https://superuser.com/questions/168749/is-there-a-way-to-see-any-tar-progress-per-file
  # Compress tar cvfj big-files.tar.bz2 folder-with-big-files
  # Compress tar cf - ${DOWNLOADFOLDER}/${CODENAME}.tar.gz --directory=${DOWNLOADFOLDER} -P | pv -s $(du -sb ${DOWNLOADFOLDER}/${CODENAME}.tar.gz | awk '{print $1}') | gzip > big-files.tar.gz
  # Extract tar Progress bar REF: https://coderwall.com/p/l_m2yg/tar-untar-on-osx-linux-with-progress-bars
  # Extract tar sample pv file.tgz | tar xzf - -C target_directory
  # Working simplme tar:  tar xvzf ${DOWNLOADFOLDER}/${CODENAME}.tar.gz --directory=${DOWNLOADFOLDER}
  local -i ret=$?
  Comment "pv \"${DOWNLOADFOLDER}${CODENAME}\"  | tar xzf - -C \"${DOWNLOADFOLDER}${UNZIPDIR}\""
  pv "${DOWNLOADFOLDER}${CODENAME}"  | tar xzf - -C "${DOWNLOADFOLDER}${UNZIPDIR}"
  ret=$?
  #local msg=$(_try "tar xvzf  \"${DOWNLOADFOLDER}/${CODENAME}.tar.gz\" --directory=${DOWNLOADFOLDER} " )
  #  tar xvzf file.tar.gz
  # Where,
  # x: This option tells tar to extract the files.
  # v: The “v” stands for “verbose.” This option will list all of the files one by one in the archive.
  # z: The z option is very important and tells the tar command to uncompress the file (gzip).
  # f: This options tells tar that you are going to give it a file name to work with.
  local msg
  local folder_date
  if [ $ret -gt 0 ] ; then
  {
    failed "${ret}:${msg}"
    # add error handling knowledge while learning.
  }
  else
  {
    passed Install with Untar Unzip success!
  }
  fi

  # local NEWDIRCODENAME=$(ls -1tr "${DOWNLOADFOLDER}/"  | tail  -1)
  # local FROMUZIPPED="${DOWNLOADFOLDER}/${NEWDIRCODENAME}"
  # directory_exists_with_spaces  "${FROMUZIPPED}"
  # directory_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"

} # end _unzip
_backup_current_target_and_remove_if_exists(){
  # Sample use
  #
  #     _backup_current_target_and_remove_if_exists "${TARGETFOLDER}"
  #     _backup_current_target_and_remove_if_exists "${TARGETFOLDER}"
  #
  local TARGETFOLDER="${1}"
  enforce_variable_with_value TARGETFOLDER "${TARGETFOLDER}"

  if  it_exists_with_spaces "${TARGETFOLDER}/webstorm" ; then
  {
     local folder_date=$(date +"%Y%m%d")
     if  it_exists_with_spaces "${TARGETFOLDER}/webstorm_${folder_date}" ; then
     {
       warning "A backup already exists for today ${ret}:${msg} \n ... adding time"
       folder_date=$(date +"%Y%m%d%H%M")
     }
     fi
     local msg=$(mv "${TARGETFOLDER}/webstorm" "${TARGETFOLDER}/webstorm_${folder_date}")
     local ret=$?
     if [ $ret -gt 0 ] ; then
     {
       warning failed to move backup "${ret}:${msg} \n"
     }
     fi
     directory_exists_with_spaces "${TARGETFOLDER}/webstorm_${folder_date}"
     file_does_not_exist_with_spaces "${TARGETFOLDER}/webstorm"
  }
  fi
} # end _backup_current_target_and_remove_if_exists
_install_to_target(){
  # Sample use
  #
  #     _install_to_target "${TARGETFOLDER}" "${FROM_DOWNLOADEDFOLDER_UNZIPPED}"
  #
  local TARGETFOLDER="${1}"
  Comment enforce_variable_with_value TARGETFOLDER "${TARGETFOLDER}"
  enforce_variable_with_value TARGETFOLDER "${TARGETFOLDER}"

  local FROM_DOWNLOADEDFOLDER_UNZIPPED="${2}"
  Comment enforce_variable_with_value FROM_DOWNLOADEDFOLDER_UNZIPPED "${FROM_DOWNLOADEDFOLDER_UNZIPPED}"
  enforce_variable_with_value FROM_DOWNLOADEDFOLDER_UNZIPPED "${FROM_DOWNLOADEDFOLDER_UNZIPPED}"

  mkdir -p "${TARGETFOLDER}"
  directory_exists_with_spaces "${TARGETFOLDER}"
  directory_exists_with_spaces "${FROM_DOWNLOADEDFOLDER_UNZIPPED}"

  mv "${FROM_DOWNLOADEDFOLDER_UNZIPPED}" "${TARGETFOLDER}/webstorm"
  _err=$?
  if [ $ret -gt 0 ] ; then
   {
     failed to move "${FROM_DOWNLOADEDFOLDER_UNZIPPED}" to "${TARGETFOLDER}/webstorm"  "${ret}:${msg} \n"
   }
   fi
  directory_exists_with_spaces "${TARGETFOLDER}/webstorm"
  directory_exists_with_spaces "${TARGETFOLDER}/webstorm/bin"
} # end _install_to_target
_add_mine_associacions_and_browser_click_to_open (){
  # Sample use
  #
  #     _add_mine_associacions_and_browser_click_to_open "${TARGETFOLDER}" "${LOCALSHAREFOLDER}"  "${LOGGERFOLDER}"
  #     _add_mine_associacions_and_browser_click_to_open "${TARGETFOLDER}" "${USER_HOME}/.local/share" $USER_HOME/_/work"
  #
  local TARGETFOLDER="${1}"
  enforce_variable_with_value TARGETFOLDER "${TARGETFOLDER}"
  local LOCALSHAREFOLDER="${2}"
  enforce_variable_with_value LOCALSHAREFOLDER "${LOCALSHAREFOLDER}"
  local LOGGERFOLDER="${3}"
  enforce_variable_with_value LOGGERFOLDER "${LOGGERFOLDER}"

  mkdir -p "${LOCALSHAREFOLDER}/applications"
  directory_exists_with_spaces "${LOCALSHAREFOLDER}/applications"
  mkdir -p "${LOCALSHAREFOLDER}/mime/packages"
  directory_exists_with_spaces "${LOCALSHAREFOLDER}/mime/packages"
  file_exists_with_spaces "${TARGETFOLDER}/webstorm/bin/webstorm.sh"
  chown $SUDO_USER:$SUDO_USER -R "${TARGETFOLDER}/webstorm"
  # Now Proceed to register REF:  https://gist.github.com/c80609a/752e566093b1489bd3aef0e56ee0426c
  ensure cat or "Failed to use cat command does not exists"
  ensure xdg-mime or "Failed to install run xdg-mime"

   cat << EOF > ${TARGETFOLDER}/webstorm/bin/mine-open.rb
#!/usr/bin/env ruby

# ${TARGETFOLDER}/webstorm/bin/mine-open.rb
# script opens URL in format webstorm://open?file=%{file}:%{line} in WebStorm

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
  file_exists_with_spaces "${TARGETFOLDER}/webstorm/bin/mine-open.rb"
  chown $SUDO_USER:$SUDO_USER -R "${TARGETFOLDER}/webstorm/bin/mine-open.rb"
  chmod +x ${TARGETFOLDER}/webstorm/bin/mine-open.rb


    cat << EOF > ${TARGETFOLDER}/webstorm/bin/mine-open.sh
#!/usr/bin/env bash
#encoding: UTF-8
# ${TARGETFOLDER}/webstorm/bin/mine-open.sh
# script opens URL in format webstorm://open?file=%{file}:%{line} in WebStorm

echo "\${@}"
echo "\${@}" >>  ${LOGGERFOLDER}/requested.log
${TARGETFOLDER}/webstorm/bin/mine-open.rb \${@}
filetoopen=\$(${TARGETFOLDER}/webstorm/bin/mine-open.rb "\${@}")
echo filetoopen "\${filetoopen}"
echo "\${filetoopen}" >>  ${LOGGERFOLDER}/requestedfiletoopen.log
mine "\${filetoopen}"

EOF
  mkdir -p ${LOGGERFOLDER}/
  directory_exists_with_spaces ${LOGGERFOLDER}/
  chown $SUDO_USER:$SUDO_USER ${LOGGERFOLDER}/
  touch ${LOGGERFOLDER}/requestedfiletoopen.log
  file_exists_with_spaces ${LOGGERFOLDER}/requestedfiletoopen.log
  chown $SUDO_USER:$SUDO_USER -R ${LOGGERFOLDER}/requestedfiletoopen.log
  file_exists_with_spaces "${TARGETFOLDER}/webstorm/bin/mine-open.sh"
  chown $SUDO_USER:$SUDO_USER -R "${TARGETFOLDER}/webstorm/bin/mine-open.sh"
  chmod +x ${TARGETFOLDER}/webstorm/bin/mine-open.sh

 cat << EOF > ${LOCALSHAREFOLDER}/mime/packages/application-x-mine.xml
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-mine">
    <comment>new mime type</comment>
    <glob pattern="*.x-mine;*.rb;*.html;*.html.erb;*.js.erb;*.html.haml;*.js.haml;*.erb;*.haml;*.js"/>
  </mime-type>
</mime-info>
EOF
  file_exists_with_spaces "${LOCALSHAREFOLDER}/mime/packages/application-x-mine.xml"
  chown $SUDO_USER:$SUDO_USER -R "${LOCALSHAREFOLDER}/mime/packages/application-x-mine.xml"




  cat << EOF > ${LOCALSHAREFOLDER}/applications/jetbrains-webstorm.desktop
# ${LOCALSHAREFOLDER}/applications/jetbrains-webstorm.desktop
[Desktop Entry]
Encoding=UTF-8
Version=2019.3.2
Type=Application
Name=WebStorm
Icon=${TARGETFOLDER}/webstorm/bin/webstorm.svg
Exec="${TARGETFOLDER}/webstorm/bin/webstorm.sh" %f
MimeType=application/x-mine;text/x-mine;text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;x-directory/normal;inode/directory;
Comment=The Most Intelligent Ruby and Rails IDE
Categories=Development;IDE;
Terminal=true
StartupWMClass=jetbrains-webstorm
EOF
  file_exists_with_spaces "${LOCALSHAREFOLDER}/applications/jetbrains-webstorm.desktop"
  chown $SUDO_USER:$SUDO_USER -R "${LOCALSHAREFOLDER}/applications/jetbrains-webstorm.desktop"


  cat << EOF > ${LOCALSHAREFOLDER}/applications/mimeinfo.cache
# ${LOCALSHAREFOLDER}/applications/mimeinfo.cache

[MIME Cache]
x-scheme-handler/webstorm=mine-open.desktop;
EOF
  file_exists_with_spaces "${LOCALSHAREFOLDER}/applications/mimeinfo.cache"
  chown $SUDO_USER:$SUDO_USER -R "${LOCALSHAREFOLDER}/applications/mimeinfo.cache"

  cat << EOF > ${LOCALSHAREFOLDER}/applications/mine-open.desktop
# ${LOCALSHAREFOLDER}/applications/mine-open.desktop
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Terminal=true
Exec="${TARGETFOLDER}/webstorm/bin/mine-open.sh" %f
MimeType=application/webstorm;x-scheme-handler/webstorm;
Name=MineOpen
Comment=BetterErrors
EOF
  file_exists_with_spaces "${LOCALSHAREFOLDER}/applications/mine-open.desktop"
  chown $SUDO_USER:$SUDO_USER -R "${LOCALSHAREFOLDER}/applications/mine-open.desktop"

  # xdg-mime default jetbrains-webstorm.desktop text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;x-directory/normal;inode/directory;
  # xdg-mime default mine-open.desktop x-scheme-handler/webstorm
  # msg=$(_try "xdg-mime default mine-open.desktop x-scheme-handler/webstorm" )
  su - "${SUDO_USER}" -c "xdg-mime default mine-open.desktop x-scheme-handler/webstorm"
  su - "${SUDO_USER}" -c "xdg-mime default mine-open.desktop text/webstorm"
  su - "${SUDO_USER}" -c "xdg-mime default mine-open.desktop application/webstorm"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-webstorm.desktop x-scheme-handler/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-webstorm.desktop text/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-webstorm.desktop application/x-mine"

  #   cat << EOF > $USER_HOME/.config/mimeapps.list
  #   cat << EOF > ${LOCALSHAREFOLDER}/applications/mimeapps.list
  # [Default Applications]
  # x-scheme-handler/webstorm=mine-open.desktop
  # text/webstorm=mine-open.desktop
  # application/webstorm=mine-open.desktop
  # x-scheme-handler/x-mine=jetbrains-webstorm.desktop
  # text/x-mine=jetbrains-webstorm.desktop
  # application/x-mine=jetbrains-webstorm.desktop

  # [Added Associations]
  # x-scheme-handler/webstorm=mine-open.desktop;
  # text/webstorm=mine-open.desktop;
  # application/webstorm=mine-open.desktop;
  # x-scheme-handler/x-mine=jetbrains-webstorm.desktop;
  # text/x-mine=jetbrains-webstorm.desktop;
  # application/x-mine=jetbrains-webstorm.desktop;
  # EOF
  #   file_exists_with_spaces "${LOCALSHAREFOLDER}/applications/mimeapps.list"
  #   file_exists_with_spaces "$USER_HOME/.config/mimeapps.list"
  ln -fs "$USER_HOME/.config/mimeapps.list" "${LOCALSHAREFOLDER}/applications/mimeapps.list"
  softlink_exists_with_spaces "${LOCALSHAREFOLDER}/applications/mimeapps.list>$USER_HOME/.config/mimeapps.list"
  chown $SUDO_USER:$SUDO_USER -R  "${LOCALSHAREFOLDER}/applications/mimeapps.list"

  file_exists_with_spaces "${TARGETFOLDER}/webstorm/bin/mine-open.sh"

  su - "${SUDO_USER}" -c "xdg-mime query default x-scheme-handler/webstorm"
  su - "${SUDO_USER}" -c "xdg-mime query default x-scheme-handler/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime query default text/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime query default application/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime query default text/webstorm"
  su - "${SUDO_USER}" -c "xdg-mime query default application/webstorm"
  msg=$(_try "su - \"${SUDO_USER}\" -c \"xdg-mime query default x-scheme-handler/webstorm\"")
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
  su - "${SUDO_USER}" -c "update-mime-database \"${LOCALSHAREFOLDER}/mime\""
  su - "${SUDO_USER}" -c "update-desktop-database \"${LOCALSHAREFOLDER}/applications\""
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

  su - "${SUDO_USER}" -c "gio mime x-scheme-handler/webstorm"
  su - "${SUDO_USER}" -c "gio mime x-scheme-handler/x-mine"
  su - "${SUDO_USER}" -c "gio mime text/x-mine"
  su - "${SUDO_USER}" -c "gio mime application/x-mine"
  su - "${SUDO_USER}" -c "gio mime text/webstorm"
  su - "${SUDO_USER}" -c "gio mime application/webstorm"
  su - "${SUDO_USER}" -c "rm test12345.rb"
  su - "${SUDO_USER}" -c "rm test12345.erb"
  su - "${SUDO_USER}" -c "rm test12345.js.erb"
  su - "${SUDO_USER}" -c "rm test12345.html.erb"
  su - "${SUDO_USER}" -c "rm test12345.haml"
  su - "${SUDO_USER}" -c "rm test12345.js.haml"
  su - "${SUDO_USER}" -c "rm test12345.html.haml"
  echo " "
  echo "HINT: Add this to your config/initializers/better_errors.rb file "
  echo "better_errors.rb
  # ... /path_to_ruby_project/ ... /config/initializers/better_errors.rb

  if defined?(BetterErrors)
    BetterErrors.editor = \"webstorm://open?file=%{file}:%{line}\"
    BetterErrors.editor = \"x-mine://open?file=%{file}:%{line}\"
  end
  "
} # end _add_mine_associacions_and_browser_click_to_open

_darwin__64() {
  verify_is_installed "
    wget
  "
  local -i _err=$?
  local CODENAME=$(_version "mac" "*.*")
  _err=$?
  echo "$0:$LINENO DEBUG: CODENAME:${CODENAME}";
  [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! $0:$LINENO  _version:$_err  \n \n  " && exit 1
  if [ -z "${CODENAME}" ] || [ ${_err} -gt 0 ] ; then
  {
    return 1  # here one is for error
  }
  fi

  local TARGET_URL="$(echo -en "${CODENAME}" | tail -1)"
  CODENAME="$(basename "${TARGET_URL}" )"
  local VERSION="$(echo -en "${CODENAME}" | sed 's/WebStorm-//g' | sed 's/.dmg//g' )"
  enforce_variable_with_value VERSION "${VERSION}"
  local UNZIPDIR="$(echo -en "${CODENAME}" | sed 's/'"${VERSION}"'//g' | sed 's/.dmg//g'| sed 's/-//g')"
  local APPDIR="$(echo -en "${CODENAME}" | sed 's/'"${VERSION}"'//g' | sed 's/.dmg//g'| sed 's/-//g').app"
  # echo "${CODENAME}";
  # echo "${URL}";
  echo "$0:$LINENO CODENAME: ${CODENAME}"
  enforce_variable_with_value CODENAME "${CODENAME}"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  enforce_variable_with_value HOME "${HOME}"
  echo "$0:$LINENO UNZIPDIR: ${UNZIPDIR}"
  enforce_variable_with_value UNZIPDIR "${UNZIPDIR}"
  echo "$0:$LINENO APPDIR: ${APPDIR}"
  enforce_variable_with_value APPDIR "${APPDIR}"
  local DOWNLOADFOLDER="${HOME}/Downloads"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  directory_exists_with_spaces "${DOWNLOADFOLDER}"
  # _do_not_downloadtwice
  if it_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}" ; then
  {
    file_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
  }
  else
  {
    cd "${DOWNLOADFOLDER}"
    _download "${TARGET_URL}" "${DOWNLOADFOLDER}"  ${CODENAME}
    file_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
  }
  fi
  if  it_exists_with_spaces "/Applications/${APPDIR}" ; then
  {
    echo Remove  unzipped "/Applications/${APPDIR}"
    sudo rm -rf  "/Applications/${APPDIR}"
    directory_does_not_exist_with_spaces  "/Applications/${APPDIR}"
  }
  fi
  echo Attaching dmg downloaded
  sudo hdiutil attach "${DOWNLOADFOLDER}/${CODENAME}"
  ls "/Volumes"
  directory_exists_with_spaces "/Volumes/${UNZIPDIR}"
  directory_exists_with_spaces "/Volumes/${UNZIPDIR}/${APPDIR}"
  echo "sudo  cp -R /Volumes/${UNZIPDIR}/${APPDIR} /Applications/"
  sudo  cp -R /Volumes/${UNZIPDIR}/${APPDIR} /Applications/
  ls -d "/Applications/${APPDIR}"
  directory_exists_with_spaces "/Applications/${APPDIR}"
  sudo hdiutil detach "/Volumes/${UNZIPDIR}"
} # end _darwin__64

_ubuntu__64() {
  local -i _err=$?
  local CODENAME=$(_version "linux" "WebStorm-*.*.*.*amd64.deb")
  _err=$?
  echo "DEBUG: CODENAME:${CODENAME}";
  [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! $0:$LINENO  _version:$_err  \n \n  " && exit 1
  if [ -z "${CODENAME}" ] || [ ${_err} -gt 0 ] ; then
  {
    return 1  # here one is for error
  }
  fi

  # THOUGHT          local CODENAME="WebStorm-4.3.3.24545_amd64.deb"
  local URL="https://download-cf.jetbrains.com/webstorm/${CODENAME}"
  cd $USER_HOME/Downloads/
  _download "${URL}"
  _err=$?
  wait
  if [ ${_err} -gt 0 ] ; then
  {
    return 1  # here one is for error
  }
  fi
  sudo dpkg -i ${CODENAME}
} # end _ubuntu__64

_ubuntu__32() {
  local -i _err=$?
  local CODENAME=$(_version "linux" "WebStorm-*.*.*.*i386.deb")
  _err=$?
  echo "DEBUG: CODENAME:${CODENAME}";
  [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! $0:$LINENO  _version:$_err  \n \n  " && exit 1
  if [ -z "${CODENAME}" ] || [ ${_err} -gt 0 ] ; then
  {
    return 1  # here one is for error
  }
  fi
  # THOUGHT local CODENAME="WebStorm-4.3.3.24545_i386.deb"
  local URL="https://download-cf.jetbrains.com/webstorm/${CODENAME}"
  cd $USER_HOME/Downloads/
  _download "${URL}"
  _err=$?
  wait
  if [ ${_err} -gt 0 ] ; then
  {
    return 1  # here one is for error
  }
  fi
  sudo dpkg -i ${CODENAME}
} # end _ubuntu__32

_fedora__32() {
  local -i _err=$?
  local CODENAME=$(_version "linux" "WebStorm*.*.*.*.i386.rpm")
  _err=$?
  echo "DEBUG: CODENAME:${CODENAME}";
  [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! $0:$LINENO  _version:$_err  \n \n  " && exit 1
  if [ -z "${CODENAME}" ] || [ ${_err} -gt 0 ] ; then
  {
    return 1  # here one is for error
  }
  fi
  # THOUGHT                          WebStorm-4.3.3.24545.i386.rpm
  local TARGET_URL="https://download-cf.jetbrains.com/webstorm/${CODENAME}"
  file_exists_with_spaces $USER_HOME/Downloads
  enforce_variable_with_value CODENAME "${CODENAME}"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  cd $USER_HOME/Downloads
  _download "${TARGET_URL}" $USER_HOME/Downloads  ${CODENAME}
  file_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}"
  ensure tar or "Canceling Install. Could not find tar command to execute unzip"

  # provide error handling , once learned goes here. LEarn under if, once learned here.
  # Start loop while ERROR flag in case needs to try again, based on error
  _try "rpm --import https://download-cf.jetbrains.com/webstorm/RPM-GPG-KEY-scootersoftware"
  local msg=$(_try "rpm -ivh \"$USER_HOME/Downloads/${CODENAME}\"" )
  local -i ret=$?
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
  ensure WebStorm or "Failed to install WebStorm"
  rm -f "$USER_HOME/Downloads/${CODENAME}"
  file_does_not_exist_with_spaces "$USER_HOME/Downloads/${CODENAME}"
} # end _fedora__32

_centos__64() {
  _fedora__64 "${*}"
} # end _centos__64

_fedora_37__64() {
  _fedora__64 "${*}"
} # end _fedora_37__64

_fedora_39__64() {
  _fedora__64 "${*}"
} # end _fedora_39__64

_fedora__64() {
  local -i _err=0
  trap 'pkill wget && exit 0' EXIT
  trap '[[ -z "$FUNCNAME" ]] && echo -e "${RED}ERROR failed ${#FUNCNAME[@]} $BASH_SOURCE:$LINENO \t\t\t  function:$FUNCNAME ${RESET}" && exit 0 || [[ -n "$FUNCNAME" ]] && echo -e "${RED}ERROR failed ${#FUNCNAME[@]} $BASH_SOURCE:$LINENO \t\t\t  function:$FUNCNAME ${RESET}" && return 1 ' ERR
  trap '[[ -z "$FUNCNAME" ]] && exit 0 || [[ -n "$FUNCNAME" ]] && echo -e "${PURPLE}INTERRUPTED ${YELLOW241} ${#FUNCNAME[@]} $BASH_SOURCE:$LINENO \t\t\t function:$FUNCNAME ${RESET}" && return 1 ' INT
  local CODENAME=""
  local found_tar=$(ls -hctr1 "${USER_HOME}"/Downloads/WebStorm*.* | grep WebStorm | grep tar.gz  | tail -1)
  _err=$?
  local TARGET_URL=""
  if [[ -n "${found_tar}" ]] && [ ${_err} -eq 0 ] ; then
  {
    Comment "found a zip to install :$found_tar"
    CODENAME="$(basename "${found_tar}" )"
    DOWNLOADFOLDER="${USER_HOME}/Downloads/"
  }
  else
  {
    Comment "Calling _version to get lastest version from website https://data.services.jetbrains.com/products?platform\=linux "
    CODENAME="$(_version "linux" "*.*")"
    _err=$?
    Comment  "$0:$LINENO DEBUG: CODENAME:„„„${CODENAME}”””";
    if [[ -z "${CODENAME}" ]] ; then
    {
      echo -e "${RED}\nERROR $0:$LINENO  CODENAME is empty function _fedora__64()  \n${RESET}   "
      return 1 # one is for error
    }
    fi
    CODENAME=$(tail -1 <<< "${CODENAME}")
    if [ ${_err} -gt 0 ] ; then
    {
      echo -e "\n \n${RED}ERROR! $0:$LINENO function return error function _fedora__64()  function _version:$_err  \n \n ${RESET}  "
      return 1  # here one is for error
    }
    fi

    TARGET_URL="$(echo "${CODENAME}" | tail -1)"
    CODENAME="$(basename "${TARGET_URL}" )"
    # CODENAME="WebStorm-2024.1.2.tar.gz"
    DOWNLOADFOLDER="$(_find_downloads_folder)"
    _err=$?
    wait
    if [ ${_err} -gt 0 ] ; then
    {
      return 1  # here one is for error
    }
    fi

    Comment enforce_variable_with_value CODENAME "${CODENAME}"
    Comment enforce_variable_with_value TARGET_URL "${TARGET_URL}"
    Comment enforce_variable_with_value HOME "${HOME}"
    Comment enforce_variable_with_value USER_HOME "${USER_HOME}"

    enforce_variable_with_value CODENAME "${CODENAME}"
    enforce_variable_with_value TARGET_URL "${TARGET_URL}"
    enforce_variable_with_value HOME "${HOME}"
    enforce_variable_with_value USER_HOME "${USER_HOME}"

    Comment enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
    enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"

    # _remove_if_corrypted_zipfile_folder?
    if it_exists_with_spaces /tmp/corrupted.tar.gzeraseit ; then
    {
      if it_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"; then
      {
        passed Removing Corrupted zip file
        rm "${DOWNLOADFOLDER}/${CODENAME}"
        file_does_not_exist_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
        rm  /tmp/corrupted.tar.gzeraseit
      }
      fi
    }
    fi
    Comment "_do_not_downloadtwice \"${TARGET_URL}\" \"${DOWNLOADFOLDER}\"  \"${CODENAME}\""
    _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
    _err=$?
    wait
    if [ ${_err} -gt 0 ] ; then
    {
      return 1  # here one is for error
    }
    fi
  }
  fi
  local UNZIPDIR="$(echo "${CODENAME}" | sed 's/.tar.gz//g' )"
  Comment enforce_variable_with_value UNZIPDIR "${UNZIPDIR}"
  enforce_variable_with_value UNZIPDIR "${UNZIPDIR}"

  local TARGETFOLDER="${USER_HOME}/_/software"
  Comment enforce_variable_with_value TARGETFOLDER "${TARGETFOLDER}"
  enforce_variable_with_value TARGETFOLDER "${TARGETFOLDER}"

  Comment "_unzip \"${DOWNLOADFOLDER}\" \"${UNZIPDIR}\" \"${CODENAME}\""
  if _unzip "${DOWNLOADFOLDER}" "${UNZIPDIR}" "${CODENAME}" ; then
  {
    Comment "unzipping failed. Downloading again"
    rm -rf "${DOWNLOADFOLDER}/${UNZIPDIR}"
  }
  fi
  Comment "_backup_current_target_and_remove_if_exists \"${TARGETFOLDER}\""
  _backup_current_target_and_remove_if_exists "${TARGETFOLDER}"
  _err=$?
  wait
  if [ ${_err} -gt 0 ] ; then
  {
    return 1  # here one is for error
  }
  fi
  Comment "_install_to_target \"${TARGETFOLDER}\" \"${DOWNLOADFOLDER}/${UNZIPDIR}\""
  _install_to_target "${TARGETFOLDER}" "${DOWNLOADFOLDER}/${UNZIPDIR}"
  _err=$?
  wait
  if [ ${_err} -gt 0 ] ; then
  {
    return 1  # here one is for error
  }
  fi

  # _remove_unzipped_folder?
  rm "${DOWNLOADFOLDER}/${UNZIPDIR}"
  _err=$?
  wait
  if [ ${_err} -gt 0 ] ; then
  {
    return 1  # here one is for error
  }
  fi
  directory_does_not_exist_with_spaces "${DOWNLOADFOLDER}/${UNZIPDIR}"

  # _remove_downloaded_file?
  rm "${DOWNLOADFOLDER}/${CODENAME}"
  _err=$?
  wait
  if [ ${_err} -gt 0 ] ; then
  {
    return 1  # here one is for error
  }
  fi
  file_does_not_exist_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"

  Comment "_add_mine_associacions_and_browser_click_to_open \"${TARGETFOLDER}\" \"${USER_HOME}/.local/share\" \"${USER_HOME}/_/work\""
  _add_mine_associacions_and_browser_click_to_open "${TARGETFOLDER}" "${USER_HOME}/.local/share" "${USER_HOME}/_/work"
  Comment "end _fedora__64"

} # end _fedora__64

_mingw__64() {
    local CODENAME=$(_version "win" "WebStorm*.*.*.*.exe")
    # THOUGHT        local CODENAME="WebStorm-4.3.3.24545.exe"
    local URL="https://download-cf.jetbrains.com/webstorm/${CODENAME}"
    cd $HOMEDIR
    cd Downloads
    curl -O $URL
    ${CODENAME}
} # end _mingw__64

_mingw__32() {
    local CODENAME=$(_version "win" "WebStorm*.*.*.*.exe")
    # THOUGHT        local CODENAME="WebStorm-4.3.3.24545.exe"
    local URL="https://download-cf.jetbrains.com/webstorm/${CODENAME}"
    cd $HOMEDIR
    cd Downloads
    curl -O $URL
    ${CODENAME}
} # end



 #--------/\/\/\/\-- tasks_templates_sudo/webstorm …install_webstorm.bash” -- Custom code-/\/\/\/\-------



 #--------\/\/\/\/--- tasks_base/main.bash ---\/\/\/\/-------
_main() {
  determine_os_and_fire_action "${*:-}"
} # end _main

echo params "${*:-}"
_main "${*:-}"

echo "🥦"
exit 0
