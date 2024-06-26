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





 #--------\/\/\/\/-- tasks_templates_sudo/mysql …install_mysql.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/bash


_get_mac_version(){
  # REF: https://superuser.com/questions/75166/how-to-find-out-mac-os-x-version-from-terminal
  # local MAJOR_MAC_VERSION=$(sw_vers -productVersion | awk -F '.' '{print $1 "." $2}')
  ensure sw_vers or "Failed to get info program sw_vers"
  local _version_info="$(sw_vers -productVersion)"
  enforce_parameter_with_value 1 _version_info   "${_version_info}"  "10.14.6"
  local _major=$(cut -d '.' -f 1,2 <<< "${_version_info}")
  enforce_parameter_with_value 2 _major          "${_major}"         "10.14"
  local os_vers=( ${_version_info//./ } )

  local os_vers_major="${os_vers[0]}"
  local os_vers_minor="${os_vers[1]}"
  local os_vers_patch="${os_vers[2]}"
  local os_vers_build=$(sw_vers -buildVersion)

  # Sample semver output
  # echo "${os_vers_major}.${os_vers_minor}.${os_vers_patch}+${os_vers_build}"
  # expected 10.12.6+16G29
  echo "${_major}"
  return 0
} # end _get_mac_version

_install_dmgs_list() {
  Comment start $0$1 _install_dmgs_list
  local installlist one  target_name target_url target_app app_name extension
  local _major_version1=$(_get_mac_version )
  local _major_version=$(_get_mac_version | tail -1 )
  enforce_parameter_with_value 1 _major_version   "${_major_version}"  "10.14"
  echo "${_major_version1}"
  echo "_major_version:${_major_version}"
    case "${_major_version}" in
       "13"*) # Ventura 8.0.23 or newer
          installlist="
          mysql-workbench-community-8.0.31-macos-x86_64.dmg|MySQL Workbench community-8.0.31/MySQLWorkbench.app|https://cdn.mysql.com/archives/mysql-workbench/mysql-workbench-community-8.0.31-macos-x86_64.dmg
          "
          ;;
       "12"*) # Monterrey 8.0.23 or newer
          installlist="
          mysql-workbench-community-8.0.31-macos-x86_64.dmg|MySQL Workbench community-8.0.31/MySQLWorkbench.app|https://cdn.mysql.com/archives/mysql-workbench/mysql-workbench-community-8.0.31-macos-x86_64.dmg
          "
          ;;
       "11.1"*) # Big Sur mysql 8.0.23 or newer
          installlist="
          mysql-workbench-community-8.0.31-macos-x86_64.dmg|MySQL Workbench community-8.0.31/MySQLWorkbench.app|https://cdn.mysql.com/archives/mysql-workbench/mysql-workbench-community-8.0.31-macos-x86_64.dmg
          "
          ;;
        "10.15"*) # Catalina mysql 8.0.19 to 8.0.23
          installlist="
          mysql-workbench-community-8.0.22-macos-x86_64.dmg|MySQL Workbench community-8.0.22/MySQLWorkbench.app|https://cdn.mysql.com/archives/mysql-workbench/mysql-workbench-community-8.0.22-macos-x86_64.dmg
          "
          ;;
        "10.14"*) # Mojave mysql 8.0.1, mysql-workbench 8.0.13 to 8.0.21 #  8.0.22 says is 'compatible with Mojave' but Phisical tried on Mojave Mac flags as not
          installlist="
          mysql-workbench-community-8.0.21-macos-x86_64.dmg|MySQL Workbench community-8.0.21/MySQLWorkbench.app|https://cdn.mysql.com/archives/mysql-workbench/mysql-workbench-community-8.0.21-macos-x86_64.dmg
          mysql-8.0.18-macos10.14-x86_64.dmg|mysql-8.0.18-macos10.14-x86_64/mysql-8.0.18-macos10.14-x86_64.pkg|https://cdn.mysql.com/archives/mysql-8.0/mysql-8.0.18-macos10.14-x86_64.dmg
          "
          ;;
        "10.13"*) # High Sierra mysql 8.0.11 rc to 8.0.18
          installlist="
          mysql-workbench-community-8.0.11-macos-x86_64.dmg|MySQL Workbench community-8.0.11/MySQLWorkbench.app|https://cdn.mysql.com/archives/mysql-workbench/mysql-workbench-community-8.0.11-macos-x86_64.dmg
          "
          ;;
        "10.12"*)  # Sierra mysql 6.3.9 to 6.3.10
          installlist="
          mysql-workbench-community-6.3.10-macos-x86_64.dmg|MySQL Workbench community-6.3.10/MySQLWorkbench.app|https://cdn.mysql.com/archives/mysql-workbench/mysql-workbench-community-6.3.10-macos-x86_64.dmg
          "
          ;;
        "10.11"*) # El Capitan mysql 6.3.9 to 6.3.10
          installlist="
          mysql-workbench-community-6.3.9-macos-x86_64.dmg|MySQL Workbench community-6.3.9/MySQLWorkbench.app|https://cdn.mysql.com/archives/mysql-workbench/mysql-workbench-community-6.3.9-macos-x86_64.dmg
          "
          ;;
        "10.10"*) # Yosemite mysql. to 6.3.6
          installlist="
          mysql-workbench-community-6.3.6-macos-x86_64.dmg|MySQL Workbench community-6.3.6/MySQLWorkbench.app|https://cdn.mysql.com/archives/mysql-workbench/mysql-workbench-community-6.3.6-macos-x86_64.dmg
          "
          ;;
        *)
          warning "Platform $OSTYPE not supported"
          installlist="
          mysql-workbench-community-8.0.31-macos-x86_64.dmg|MySQL Workbench community-8.0.31/MySQLWorkbench.app|https://cdn.mysql.com/archives/mysql-workbench/mysql-workbench-community-8.0.31-macos-x86_64.dmg
          "
          ;;
    esac
    Installing "# $installlist"
  # Installer dmg file. |       installer file once mounted. |.  location from url to download  |
  Checking dmgs apps
  while read -r one ; do
  {
    if [[ -n "${one}" ]] ; then
    {

      target_name="$(echo "${one}" | cut -d'|' -f1)"
      extension="$(echo "${target_name}" | rev | cut -d'.' -f 1 | rev)"
      target_app="$(echo "${one}" | cut -d'|' -f2)"
      app_name="$(echo "$(basename "${target_app}")")"
      target_url="$(echo "${one}" | cut -d'|' -f3-)"
      if [[ -n "${target_name}" ]] ; then
      {
        if [[ -n "${target_url}" ]] ; then
        {
          if [[ ! -d "/Applications/${app_name}" ]] ; then
          {
            Installing "${app_name}"
            _install_dmgs_dmg__64 "${target_name}" "${target_app}" "${target_url}"
          }
          else
          {
            passed  "/Applications/${app_name}"  --skipping already installed
          }
          fi
        }
        fi
      }
      fi
    }
    fi
  }
  done <<< "$(echo "${installlist}" | grep -vE '^#' | grep -vE '^\s+#')"

  Comment end $0$1 _install_dmgs_list
  return 0
} # end _install_dmgs_list

_debian_flavor_install() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _debian_flavor_install

_redhat_flavor_install() {
  echo "Procedure not yet implemented. I don't know what to do."
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
  Installing ## macOS MySQL From dmg

  _install_dmgs_list
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



 #--------/\/\/\/\-- tasks_templates_sudo/mysql …install_mysql.bash” -- Custom code-/\/\/\/\-------


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo "🥦"
exit 0
