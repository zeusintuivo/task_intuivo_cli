#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
# 20200415 Compatible with Fedora, Mac, Ubuntu "sudo_up" "load_struct" "#

set -E -o functrace
export THISSCRIPTCOMPLETEPATH
typeset -r THISSCRIPTCOMPLETEPATH="$(realpath  "$0")"   # updated realpath macos 20210902
export BASH_VERSION_NUMBER
typeset BASH_VERSION_NUMBER=$(echo $BASH_VERSION | cut -f1 -d.)

export  THISSCRIPTNAME
typeset -r THISSCRIPTNAME="$(basename "$0")"

export _err
typeset -i _err=0

  function _trap_on_error(){
    #echo -e "\\n \033[01;7m*** ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m"
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
    # echo -e "\\n \033[01;7m*** INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n  INT ...\033[0m"
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
  function load_library(){
    local _library="${1:struct_testing}"
    if [[ -z "${1}" ]] ; then
    {
       echo "Must call with name of library example: struct_testing execute_command"
       exit 1
    }
    fi
    trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
      local provider="$HOME/_/clis/execute_command_intuivo_cli/${_library}"
      local _err=0 structsource
      if [   -e "${provider}"  ] ; then
        if (( DEBUG )) ; then
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
          if (( DEBUG )) ; then
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
          if (( DEBUG )) ; then
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
          echo -e "\n \n  ERROR! Loading ${_library} could not find wget or curl to download  \n \n "
          exit 69
        fi
      fi
      if [[ -z "${structsource}" ]] ; then
      {
        echo -e "\n \n  ERROR! Loading ${_library} into ${_library}_source did not download or is empty " 
        exit 1
      }
      fi
      local _temp_dir="$(mktemp -d 2>/dev/null || mktemp -d -t "${_library}_source")"
      echo "${structsource}">"${_temp_dir}/${_library}"
      if (( DEBUG )) ; then
        echo "$0: tasks_base/sudoer.bash Temp location ${_temp_dir}/${_library}"
      fi
      source "${_temp_dir}/${_library}"
      _err=$?
      if [ $_err -gt 0 ] ; then
      {
        echo -e "\n \n  ERROR! Loading ${_library}. Occured while running 'source' err:$_err  \n \n  "
        exit 1
      }
      fi
      if  ! typeset -f passed >/dev/null 2>&1; then
        echo -e "\n \n  ERROR! Loading ${_library}. Passed was not loaded !!!  \n \n "
        exit 69;
      fi
      return $_err
  } # end load_library
  load_library "struct_testing"
  load_library "execute_command"
} # end load_struct_testing
load_struct_testing

 _err=$?
if [ $_err -ne 0 ] ; then
{
  echo -e "\n \n  ERROR FATAL! load_struct_testing_wget !!! returned:<$_err> \n \n  "
  exit 69;
}
fi

export sudo_it
function sudo_it() {
  raise_to_sudo_and_user_home
  local _err=$?
  if (( DEBUG )) ; then
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
  if (( DEBUG )) ; then
    Comment _err:${_err}
  fi
  enforce_variable_with_value SUDO_USER "${SUDO_USER}"
  enforce_variable_with_value SUDO_UID "${SUDO_UID}"
  enforce_variable_with_value SUDO_COMMAND "${SUDO_COMMAND}"
  # Override bigger error trap  with local
  function _trap_on_err_int(){
    # echo -e "\033[01;7m*** ERROR OR INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR INT ...\033[0m"
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
  if (( DEBUG )) ; then
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
  if (( DEBUG )) ; then
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
if (( DEBUG )) ; then
  passed "Caller user identified:${SUDO_USER}"
fi
  if (( DEBUG )) ; then
    Comment DEBUG_err?:${?}
  fi
if (( DEBUG )) ; then
  passed "Home identified:${USER_HOME}"
fi
  if (( DEBUG )) ; then
    Comment DEBUG_err?:${?}
  fi
directory_exists_with_spaces "${USER_HOME}"



 #---------/\/\/\-- tasks_base/sudoer.bash -------------/\/\/\--------





 #--------\/\/\/\/-- tasks_templates_sudo/signal …install_signal.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
_debian_flavor_install() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _debian_flavor_install

# shellcheck disable=SC2120
_redhat_flavor_install() {
  trap  '_mitrapo_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR INT
  set -xE
  source /etc/os-release
  Comment Based on OpenSuse Repos REF: https://build.opensuse.org/repositories/network:im:signal
  Testing "$0 $1 $LINENO ${FUNCNAME[-0]}()"

  local _url="https://download.opensuse.org/repositories/network:/im:/signal/Fedora_${VERSION_ID}/x86_64/"
  enforce_variable_with_value _url "${_url}"

  # get list of packages
  local _list="$(curl -sSL "${_url}"  | grep rpm | grep name | cut -d\" -f4 | cut -c3- | grep -v debug | sed 's/[\^]/%5e/g')"
  enforce_variable_with_value _list "${_list}"

  # get list of other packages I did not consider in my first equation
  local _other _others="$(grep -v "nodejs-electron" <<< "${_list}" | grep -v "nodejs-electron-devel" | grep -v "libringrtc" | grep -v "esbuild-" | grep -v "app-builder" | grep -v "signal-desktop" )"
  while read -r _other ; do
  {
    [ -z "${_other}" ] && continue
    enforce_variable_with_value _other "${_other}"
    dnf install "${_url}${_other}" -y
  } 
  done <<< "${_others}"

  local _list_node="$(grep "nodejs-electron" <<< "${_list}" | grep -v "nodejs-electron-devel" )"
  enforce_variable_with_value _list_node "${_list_node}"
  dnf install "${_url}${_list_node}" -y

  local _list_node_devel="$(grep "nodejs-electron-devel" <<< "${_list}")"
  enforce_variable_with_value _list_node_devel "${_list_node_devel}"
  dnf install "${_url}${_list_node_devel}"  -y

  local _list_rtc="$(grep "libringrtc" <<< "${_list}")"
  enforce_variable_with_value _list_rtc "${_list_rtc}"
  dnf install "${_url}${_list_rtc}" -y

  local _list_esbuild="$(grep "esbuild-" <<< "${_list}")"
  enforce_variable_with_value _list_esbuild "${_list_esbuild}"
  dnf install "${_url}${_list_esbuild}" -y

  local _list_app="$(grep "app-builder" <<< "${_list}")"
  enforce_variable_with_value _list_app "${_list_app}"
  curl -sSLO "${_url}${_list_app}"
  dnf install ./"${_list_app}" -y
  rm ./"${_list_app}"

  local _list_signal="$(grep "signal-desktop" <<< "${_list}")"
  enforce_variable_with_value _list_signal "${_list_signal}"
  dnf install "${_url}${_list_signal}" -y
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
  # _redhat_flavor_install
  source /etc/os-release
  case ${VERSION_ID} in
    36|37) _fedora__64_${VERSION_ID};;
    *)	   _redhat_flavor_install;;
  esac
} # end _fedora__64

_fedora__64_36() {
  trap  '_mitrapo_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR INT
  Comment Based on OpenSuse Repos REF: https://build.opensuse.org/repositories/network:im:signal
  local _url="https://download.opensuse.org/repositories/network:/im:/signal/Fedora_36/x86_64/"
  dnf install ${_url}nodejs-electron-devel-21.3.0-2.4.x86_64.rpm  ${_url}nodejs-electron-21.3.0-2.4.x86_64.rpm -y
  dnf install ${_url}signal-libringrtc-2.21.2-2.1.x86_64.rpm ${_url}libheif1-1.13.0-35.1.x86_64.rpm ${_url}libheif-devel-1.13.0-35.1.x86_64.rpm -vy
  dnf install ${_url}gdk-pixbuf-loader-libheif-1.13.0-35.1.x86_64.rpm -vy
  dnf install ${_url}esbuild-0.15.11-4.1.x86_64.rpm -vy
  curl -sSLO ${_url}app-builder-3.4.2%5e20220309g4e2aa6a1-5.116.x86_64.rpm
  dnf install ./app-builder-3.4.2%5e20220309g4e2aa6a1-5.116.x86_64.rpm -vy
  rm ./app-builder-3.4.2%5e20220309g4e2aa6a1-5.116.x86_64.rpm
  dnf install ${_url}signal-desktop-5.63.1-3.1.x86_64.rpm -vy
  echo "Procedure not yet implemented. I don't know what to do."
} # end _fedora__64_36

function _mitrapo_on_error() {
  echo $LINENO _mitrapo_on_error
  local -ir __trapped_error_exit_num="${2:-0}"
  echo -e "\\n \033[01;7m*** ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m\n \n "
  echo ". ${1}"
  echo ". exit  ${__trapped_error_exit_num}  "
  echo ". caller $(caller) "
  echo ". ${BASH_COMMAND}"
  local -r __caller=$(caller)
  local -ir __caller_line=$(echo "${__caller}" | cut -d' ' -f1)
  local -r __caller_script_name=$(echo "${__caller}" | cut -d' ' -f2)
  awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}"

  $(eval ${BASH_COMMAND}  2>&1; )
  echo -e " ☠ ${LIGHTPINK} Offending message:  ${__bash_error} ${RESET}"  >&2
  exit 1
} # end _mitrapo_on_error

_fedora__64_37() {
  trap  '_mitrapo_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR INT
  set -xE
  source /etc/os-release
  Comment Based on OpenSuse Repos REF: https://build.opensuse.org/repositories/network:im:signal
  Testing "$0 $1 $LINENO ${FUNCNAME[-0]}()"

  local _url="https://download.opensuse.org/repositories/network:/im:/signal/Fedora_${VERSION_ID}/x86_64/"
  enforce_variable_with_value _url "${_url}"

  local _list="$(curl -sSL "${_url}"  | grep rpm | grep name | cut -d\" -f4 | cut -c3- | grep -v debug | sed 's/[\^]/%5e/g')"
  enforce_variable_with_value _list "${_list}"

  local _list_node="$(grep "nodejs-electron" <<< "${_list}" | grep -v "nodejs-electron-devel" )"
  enforce_variable_with_value _list_node "${_list_node}"
  dnf install "${_url}${_list_node}" -y

  local _list_node_devel="$(grep "nodejs-electron-devel" <<< "${_list}")"
  enforce_variable_with_value _list_node_devel "${_list_node_devel}"
  dnf install "${_url}${_list_node_devel}"  -y

  local _list_rtc="$(grep "libringrtc" <<< "${_list}")"
  enforce_variable_with_value _list_rtc "${_list_rtc}"
  dnf install "${_url}${_list_rtc}" -y

  local _list_esbuild="$(grep "esbuild-" <<< "${_list}")"
  enforce_variable_with_value _list_esbuild "${_list_esbuild}"
  dnf install "${_url}${_list_esbuild}" -y

  local _list_app="$(grep "app-builder" <<< "${_list}")"
  enforce_variable_with_value _list_app "${_list_app}"
  curl -sSLO "${_url}${_list_app}"
  dnf install ./"${_list_app}" -y
  rm ./"${_list_app}"

  local _list_signal="$(grep "signal-desktop" <<< "${_list}")"
  enforce_variable_with_value _list_signal "${_list_signal}"
  dnf install "${_url}${_list_signal}" -y
} # end _fedora__64_37

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
  echo "Procedure not yet implemented. I don't know what to do."
} # end _darwin__64

_tar() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end tar

_windows__64() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _windows__64

_windows__32() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _windows__32



 #--------/\/\/\/\-- tasks_templates_sudo/signal …install_signal.bash” -- Custom code-/\/\/\/\-------


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo "🥦"
exit 0
