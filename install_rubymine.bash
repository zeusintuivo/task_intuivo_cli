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

export _err
typeset -i _err=0

  function _trap_on_error(){
    #echo -e "\\n \033[01;7m*** 1 ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m"
    local cero="$0"
    local file1="$(paeth ${BASH_SOURCE})"
    local file2="$(paeth ${cero})"
    echo -e "ERROR TRAP $THISSCRIPTNAME
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
    echo -e "INTERRUPT TRAP $THISSCRIPTNAME
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
INT ..."
    exit 0
  }

  trap _trap_on_int INT

load_struct_testing(){
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
      raise_to_sudo_and_user_home
      [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
    SUDO_USER="${USER}"
    SUDO_COMMAND="$0"
    SUDO_UID=502
    SUDO_GID=20
  }
  elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]] ; then
  {
      # Do something under GNU/Linux platform
      raise_to_sudo_and_user_home
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
    echo -e " ERROR OR INTERRUPT  TRAP $THISSCRIPTNAME
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
ERR INT ..."
    exit 1
  }
  trap _trap_on_err_int ERR INT
} # end sudo_it

# _linux_prepare(){
  sudo_it
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



 #---------/\/\/\-- tasks_base/sudoer.bash -------------/\/\/\--------





 #--------\/\/\/\/-- tasks_templates_sudo/rubymine …install_rubymine.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
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
    exit ${__trapped_INT_num}
  }
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  
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


_version() {
  local PLATFORM="${1}" # mac windows linux
  local PATTERN="${2}"
  # THOUGHT:   https://download-cf.jetbrains.com/ruby/RubyMine-2020.3.dmg
  local CODEFILE="""$(wget --quiet --no-check-certificate  https://www.jetbrains.com/ruby/ -O -  2>/dev/null )""" # suppress only wget download messages, but keep wget output for variable
  # enforce_variable_with_value CODEFILE "${CODEFILE}"
  wait
  local CODELASTESTBUILD=$(echo "${CODEFILE}" | sed s/\>/\>\\n/g | sed "s/&apos;/\'/g" | sed 's/&nbsp;/ /g' | grep  "New in RubyMine ${PATTERN}" | sed s/\ /\\n/g | tail -1 ) # | grep "What&apos;s New in&nbsp;RubyMine&nbsp;" | sed 's/\;/\;'\\n'/g' | sed s/\</\\n\</g  )
  enforce_variable_with_value CODELASTESTBUILD "${CODELASTESTBUILD}"

  local CODENAME=""
  case ${PLATFORM} in
  mac)
    CODENAME="https://download-cf.jetbrains.com/ruby/RubyMine-${CODELASTESTBUILD}.dmg"
    ;;

  windows)
    CODENAME="https://download-cf.jetbrains.com/ruby/RubyMine-${CODELASTESTBUILD}.exe"
    CODENAME="https://download-cf.jetbrains.com/ruby/RubyMine-${CODELASTESTBUILD}.win.zip"
    ;;

  linux)
    CODENAME="https://download-cf.jetbrains.com/ruby/RubyMine-${CODELASTESTBUILD}.tar.gz"
    ;;

  *)
    CODENAME=""
    ;;
  esac
  enforce_variable_with_value CODENAME "${CODENAME}"
  unset PATTERN
  unset PLATFORM
  unset CODEFILE
  unset CODELASTESTBUILD
  echo "${CODENAME}"
  return 0
} # end _version

_darwin__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR

  verify_is_installed "
    wget
  "
  local _err=$?
  local CODENAME=$(_version "mac" "*.*")
  _err=$?
  echo "${CODENAME}";  # show either version or log with errors
  # exit on error
  [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! _version:$_err  \n \n  " && exit 1

  local TARGET_URL="$(echo -en "${CODENAME}" | tail -1)"
  CODENAME="$(basename "${TARGET_URL}" )"
  local VERSION="$(echo -en "${CODENAME}" | sed 's/RubyMine-//g' | sed 's/.dmg//g' )"
  enforce_variable_with_value VERSION "${VERSION}"
  local UNZIPDIR="$(echo -en "${CODENAME}" | sed 's/'"${VERSION}"'//g' | sed 's/.dmg//g'| sed 's/-//g')"
  local APPDIR="$(echo -en "${CODENAME}" | sed 's/'"${VERSION}"'//g' | sed 's/.dmg//g'| sed 's/-//g').app"
  # echo "${CODENAME}";
  # echo "${URL}";
  echo "CODENAME: ${CODENAME}"
  enforce_variable_with_value CODENAME "${CODENAME}"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  enforce_variable_with_value HOME "${HOME}"
  echo "UNZIPDIR: ${UNZIPDIR}"
  enforce_variable_with_value UNZIPDIR "${UNZIPDIR}"
  echo "APPDIR: ${APPDIR}"
  enforce_variable_with_value APPDIR "${APPDIR}"
  local DOWNLOADFOLDER="${HOME}/Downloads"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  directory_exists_with_spaces "${DOWNLOADFOLDER}"

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

_darwin__arm64() {
  _darwin__64  
} # end _darwin__arm64

_ubuntu__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR

  # _linux_prepare
  local CODENAME=$(_version "linux" "RubyMine-*.*.*.*amd64.deb")
  # THOUGHT          local CODENAME="RubyMine-4.3.3.24545_amd64.deb"
  local URL="https://download-cf.jetbrains.com/ruby/${CODENAME}"
  cd $USER_HOME/Downloads/
  _download "${URL}"
  sudo dpkg -i ${CODENAME}
} # end _ubuntu__64

_ubuntu__32() {
  local CODENAME=$(_version "linux" "RubyMine-*.*.*.*i386.deb")
  # THOUGHT local CODENAME="RubyMine-4.3.3.24545_i386.deb"
  local URL="https://download-cf.jetbrains.com/ruby/${CODENAME}"
  cd $USER_HOME/Downloads/
  _download "${URL}"
  sudo dpkg -i ${CODENAME}
} # end _ubuntu__32

_fedora__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR

  # _linux_prepare
  local CODENAME=$(_version "linux" "RubyMine*.*.*.*.i386.rpm")
  # THOUGHT                          RubyMine-4.3.3.24545.i386.rpm
  local TARGET_URL="https://download-cf.jetbrains.com/ruby/${CODENAME}"
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
  _try "rpm --import https://download-cf.jetbrains.com/ruby/RPM-GPG-KEY-scootersoftware"
  local msg=$(_try "rpm -ivh \"$USER_HOME/Downloads/${CODENAME}\"" )
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
  ensure RubyMine or "Failed to install RubyMine"
  rm -f "$USER_HOME/Downloads/${CODENAME}"
  file_does_not_exist_with_spaces "$USER_HOME/Downloads/${CODENAME}"
} # end _fedora__32

_centos__64() {
  _fedora__64
} # end _centos__64

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
  file_exists_with_spaces "${TARGETFOLDER}/rubymine/bin/rubymine.sh"
  chown $SUDO_USER:$SUDO_USER -R "${TARGETFOLDER}/rubymine"
  # Now Proceed to register REF:  https://gist.github.com/c80609a/752e566093b1489bd3aef0e56ee0426c
  ensure cat or "Failed to use cat command does not exists"
  ensure xdg-mime or "Failed to install run xdg-mime"

   cat << EOF > ${TARGETFOLDER}/rubymine/bin/mine-open.rb
#!/usr/bin/env ruby

# ${TARGETFOLDER}/rubymine/bin/mine-open.rb
# script opens URL in format rubymine://open?file=%{file}:%{line} in RubyMine

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
  file_exists_with_spaces "${TARGETFOLDER}/rubymine/bin/mine-open.rb"
  chown $SUDO_USER:$SUDO_USER -R "${TARGETFOLDER}/rubymine/bin/mine-open.rb"
  chmod +x ${TARGETFOLDER}/rubymine/bin/mine-open.rb


    cat << EOF > ${TARGETFOLDER}/rubymine/bin/mine-open.sh
#!/usr/bin/env bash
#encoding: UTF-8
# ${TARGETFOLDER}/rubymine/bin/mine-open.sh
# script opens URL in format rubymine://open?file=%{file}:%{line} in RubyMine

echo "\${@}"
echo "\${@}" >>  ${LOGGERFOLDER}/requested.log
${TARGETFOLDER}/rubymine/bin/mine-open.rb \${@}
filetoopen=\$(${TARGETFOLDER}/rubymine/bin/mine-open.rb "\${@}")
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
  file_exists_with_spaces "${TARGETFOLDER}/rubymine/bin/mine-open.sh"
  chown $SUDO_USER:$SUDO_USER -R "${TARGETFOLDER}/rubymine/bin/mine-open.sh"
  chmod +x ${TARGETFOLDER}/rubymine/bin/mine-open.sh

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




  cat << EOF > ${LOCALSHAREFOLDER}/applications/jetbrains-rubymine.desktop
# ${LOCALSHAREFOLDER}/applications/jetbrains-rubymine.desktop
[Desktop Entry]
Encoding=UTF-8
Version=2019.3.2
Type=Application
Name=RubyMine
Icon=${TARGETFOLDER}/rubymine/bin/rubymine.svg
Exec="${TARGETFOLDER}/rubymine/bin/rubymine.sh" %f
MimeType=application/x-mine;text/x-mine;text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;x-directory/normal;inode/directory;
Comment=The Most Intelligent Ruby and Rails IDE
Categories=Development;IDE;
Terminal=true
StartupWMClass=jetbrains-rubymine
EOF
  file_exists_with_spaces "${LOCALSHAREFOLDER}/applications/jetbrains-rubymine.desktop"
  chown $SUDO_USER:$SUDO_USER -R "${LOCALSHAREFOLDER}/applications/jetbrains-rubymine.desktop"


  cat << EOF > ${LOCALSHAREFOLDER}/applications/mimeinfo.cache
# ${LOCALSHAREFOLDER}/applications/mimeinfo.cache

[MIME Cache]
x-scheme-handler/rubymine=mine-open.desktop;
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
Exec="${TARGETFOLDER}/rubymine/bin/mine-open.sh" %f
MimeType=application/rubymine;x-scheme-handler/rubymine;
Name=MineOpen
Comment=BetterErrors
EOF
  file_exists_with_spaces "${LOCALSHAREFOLDER}/applications/mine-open.desktop"
  chown $SUDO_USER:$SUDO_USER -R "${LOCALSHAREFOLDER}/applications/mine-open.desktop"

  # xdg-mime default jetbrains-rubymine.desktop text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;x-directory/normal;inode/directory;
  # xdg-mime default mine-open.desktop x-scheme-handler/rubymine
  # msg=$(_try "xdg-mime default mine-open.desktop x-scheme-handler/rubymine" )
  su - "${SUDO_USER}" -c "xdg-mime default mine-open.desktop x-scheme-handler/rubymine"
  su - "${SUDO_USER}" -c "xdg-mime default mine-open.desktop text/rubymine"
  su - "${SUDO_USER}" -c "xdg-mime default mine-open.desktop application/rubymine"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-rubymine.desktop x-scheme-handler/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-rubymine.desktop text/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-rubymine.desktop application/x-mine"

  #   cat << EOF > $USER_HOME/.config/mimeapps.list
  #   cat << EOF > ${LOCALSHAREFOLDER}/applications/mimeapps.list
  # [Default Applications]
  # x-scheme-handler/rubymine=mine-open.desktop
  # text/rubymine=mine-open.desktop
  # application/rubymine=mine-open.desktop
  # x-scheme-handler/x-mine=jetbrains-rubymine.desktop
  # text/x-mine=jetbrains-rubymine.desktop
  # application/x-mine=jetbrains-rubymine.desktop

  # [Added Associations]
  # x-scheme-handler/rubymine=mine-open.desktop;
  # text/rubymine=mine-open.desktop;
  # application/rubymine=mine-open.desktop;
  # x-scheme-handler/x-mine=jetbrains-rubymine.desktop;
  # text/x-mine=jetbrains-rubymine.desktop;
  # application/x-mine=jetbrains-rubymine.desktop;
  # EOF
  #   file_exists_with_spaces "${LOCALSHAREFOLDER}/applications/mimeapps.list"
  #   file_exists_with_spaces "$USER_HOME/.config/mimeapps.list"
  ln -fs "$USER_HOME/.config/mimeapps.list" "${LOCALSHAREFOLDER}/applications/mimeapps.list"
  softlink_exists_with_spaces "${LOCALSHAREFOLDER}/applications/mimeapps.list>$USER_HOME/.config/mimeapps.list"
  chown $SUDO_USER:$SUDO_USER -R  "${LOCALSHAREFOLDER}/applications/mimeapps.list"

  file_exists_with_spaces "${TARGETFOLDER}/rubymine/bin/mine-open.sh"

  su - "${SUDO_USER}" -c "xdg-mime query default x-scheme-handler/rubymine"
  su - "${SUDO_USER}" -c "xdg-mime query default x-scheme-handler/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime query default text/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime query default application/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime query default text/rubymine"
  su - "${SUDO_USER}" -c "xdg-mime query default application/rubymine"
  msg=$(_try "su - \"${SUDO_USER}\" -c \"xdg-mime query default x-scheme-handler/rubymine\"")
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

  su - "${SUDO_USER}" -c "gio mime x-scheme-handler/rubymine"
  su - "${SUDO_USER}" -c "gio mime x-scheme-handler/x-mine"
  su - "${SUDO_USER}" -c "gio mime text/x-mine"
  su - "${SUDO_USER}" -c "gio mime application/x-mine"
  su - "${SUDO_USER}" -c "gio mime text/rubymine"
  su - "${SUDO_USER}" -c "gio mime application/rubymine"
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
    BetterErrors.editor = \"rubymine://open?file=%{file}:%{line}\"
    BetterErrors.editor = \"x-mine://open?file=%{file}:%{line}\"
  end
  "
} # end _add_mine_associacions_and_browser_click_to_open

_fedora__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  
  # _linux_prepare
  local CODENAME=$(_version "linux" "*.*")
  echo "${CODENAME}";
  local TARGET_URL="$(echo "${CODENAME}" | tail -1)"
  CODENAME="$(basename "${TARGET_URL}" )"
  local UNZIPDIR="$(echo "${CODENAME}" | sed 's/.tar.gz//g' )"
  enforce_variable_with_value CODENAME "${CODENAME}"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  enforce_variable_with_value HOME "${HOME}"
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  enforce_variable_with_value UNZIPDIR "${UNZIPDIR}"
  local DOWNLOADFOLDER="$(_find_downloads_folder)"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  local TARGETFOLDER="${USER_HOME}/_/software"
  enforce_variable_with_value TARGETFOLDER "${TARGETFOLDER}"
  local _target_dir_install="${TARGETFOLDER}/rubymine"
  enforce_variable_with_value _target_dir_install "${_target_dir_install}"

  # _remove_if_corrupted_zipfile_folder?
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
  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}.tar.gz"

  # file_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}.tar.gz"
  # if  it_exists_with_spaces "${DOWNLOADFOLDER}/${UNZIPDIR}" ; then
  # {
  #  rm -rf "${DOWNLOADFOLDER}/${UNZIPDIR}"
  #  directory_does_not_exist_with_spaces "${DOWNLOADFOLDER}/${UNZIPDIR}"
  # }
  # fi
  _unzip "${DOWNLOADFOLDER}" "${UNZIPDIR}" "${CODENAME}"
  _untar_gz_download "${DOWNLOADFOLDER}"  "${DOWNLOADFOLDER}/${CODENAME}.tar.gz"
  _backup_current  "${_target_dir_install}"
  _move_to_target_dir "${DOWNLOADFOLDER}" "${_target_dir_install}" "${TARGETFOLDER}"

  [ -e "${DOWNLOADFOLDER}/${CODENAME}.tar.gz" ] && rm "${DOWNLOADFOLDER}/${CODENAME}.tar.gz"
  directory_does_not_exist_with_spaces "${DOWNLOADFOLDER}/${CODENAME}.tar.gz"

  # _remove_downloaded_file?
  rm "${DOWNLOADFOLDER}/${CODENAME}"
  file_does_not_exist_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"

   _add_mine_associacions_and_browser_click_to_open "${TARGETFOLDER}" "${USER_HOME}/.local/share" "${USER_HOME}/_/work"


} # end _fedora__64

_mingw__64() {
    local CODENAME=$(_version "win" "*.*")
    # THOUGHT        local CODENAME="RubyMine-4.3.3.24545.exe"
    local URL="https://download-cf.jetbrains.com/ruby/${CODENAME}"
    cd $HOMEDIR
	  cd Downloads
    curl -O $URL
    ${CODENAME}
} # end _mingw__64

_mingw__32() {
    local CODENAME=$(_version "win" "*.*")
    # THOUGHT        local CODENAME="RubyMine-4.3.3.24545.exe"
    local URL="https://download-cf.jetbrains.com/ruby/${CODENAME}"
    cd $HOMEDIR
    cd Downloads
	  curl -O $URL
	  ${CODENAME}
} # end



 #--------/\/\/\/\-- tasks_templates_sudo/rubymine …install_rubymine.bash” -- Custom code-/\/\/\/\-------


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo "🥦"
exit 0
