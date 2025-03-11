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





 #--------\/\/\/\/-- 2tasks_templates_sudo/virtualbox …install_virtualbox.bash” -- Custom code -\/\/\/\/-------


#!/bin/bash
_debian__64(){
  _install_rpm "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}" 0
} # end __debian__64

_debian__32(){
  local TARGET_URL=https://prerelease.keybase.io/keybase_i386.deb
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  local CODENAME=$(basename "${TARGET_URL}")
  enforce_variable_with_value CODENAME "${CODENAME}"
  local DOWNLOADFOLDER="${USER_HOME}/Downloads"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
  _install_rpm "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}" 0
} # end __debian__64

_fedora__32() {
  local TARGET_URL=https://prerelease.keybase.io/keybase_i386.rpm
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  local CODENAME=$(basename "${TARGET_URL}")
  enforce_variable_with_value CODENAME "${CODENAME}"
  local DOWNLOADFOLDER="${USER_HOME}/Downloads"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
  _install_rpm "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}" 0
} # end _fedora__32

_fedora_40__64() {
  echo Fedora 29 REF: https://computingforgeeks.com/how-to-install-virtualbox-on-fedora-linux/
  echo Fedora 32 REF: https://tecadmin.net/install-oracle-virtualbox-on-fedora/
  echo Fedora 33 https://www.if-not-true-then-false.com/2010/install-virtualbox-with-yum-on-fedora-centos-red-hat-rhel/
  echo "$0:${LINENO} params ${*:-}"
	if [[ "${*-}" == *"--extension7"* ]] ; then
  {
		wget https://download.virtualbox.org/virtualbox/7.0.6/Oracle_VM_VirtualBox_Extension_Pack-7.0.6a-155176.vbox-extpack
	  VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-7.0.6a-155176.vbox-extpack
    wget https://download.virtualbox.org/virtualbox/7.0.6/VBoxGuestAdditions_7.0.6.iso
		exit 0
	}
	fi
	if [[ "${*-}" == *"--extension6"* ]] ; then
  {
	 # wget https://download.virtualbox.org/virtualbox/6.1.0_RC1/VirtualBox-6.1-6.1.0_RC1_134891_el6-1.x86_64.rpm
	 # dnf install ./VirtualBox-6.1-6.1.0_RC1_134891_el6-1.x86_64.rpm --allowerasing 
	 #	wget https://download.virtualbox.org/virtualbox/6.1.0_RC1/VirtualBoxSDK-6.1.0_RC1-134891.zip
	 # unzip VirtualBoxSDK-6.1.0_RC1-134891.zip
	 #	wget https://download.virtualbox.org/virtualbox/6.1.0_RC1/VBoxGuestAdditions_6.1.0_RC1.iso
	 # wget https://download.virtualbox.org/virtualbox/6.1.0_RC1/Oracle_VM_VirtualBox_Extension_Pack-6.1.0_RC1.vbox-extpack
	  # wget https://download.virtualbox.org/virtualbox/6.1.48/Oracle_VM_VirtualBox_Extension_Pack-6.1.48.vbox-extpack
		# VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-6.1.0_RC1.vbox-extpack
		# VBoxManage extpack uninstall Oracle_VM_VirtualBox_Extension_Pack-6.1.0_RC1.vbox-extpack
		VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-6.1.48.vbox-extpack
		exit 0
	}
 	fi
	if [[ "${*-}" == *"--reset"* ]] || [[ "${*-}" == *"--startover"* ]] || [[ "${*-}" == *"--restart"* ]] then 
	{
		echo "--reset --startover --restart " 
		echo "reseting now"
    rm "${USER_HOME}/.virtualboxinstallrebootsigned"
    rm "${USER_HOME}/.virtualboxinstallrebootsigned2"
    rm "${USER_HOME}/.virtualboxinstallreboot"
    rm /root/signed-modules
    rm /root/module-signing
  }
	fi
	dnf builddep libvpx-devel -y  --allowerasing
	dnf builddep dkms -y  --allowerasing 
  dnf builddep kernel-devel  -y  --allowerasing 
	if it_exists_with_spaces "/etc/yum.repos.d/virtualbox.repo" ; then
  {
    file_exists_with_spaces "/etc/yum.repos.d/virtualbox.repo"
  }
  else
  {
    cd "/etc/yum.repos.d/"
    wget http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo
    file_exists_with_spaces "/etc/yum.repos.d/virtualbox.repo"
  }
  fi
   install_requirements "linux" "
    # RedHat Flavor only
    binutils
    gcc
    make
    patch
    libgomp
    dkms
    qt5-qtx11extras
    libxkbcommon
    glibc-headers
    glibc-devel
    kernel-headers
    kernel-devel
    # compat-libvpx5
		libvpx-devel
    mokutil
		elfutils-libelf-devel 
 "
  is_not_installed pygmentize &&   dnf  -y install pygmentize
  if ( ! command -v pygmentize >/dev/null 2>&1; ) ;  then
    pip3 install pygments
  fi
  local groupsinstalled=$(dnf group list --installed)
  if [[ "${groupsinstalled}" = *"Development Tools"* ]] ; then
  {
    passed installed 'Development Tools'
  }
  else
  {
    dnf groupinstall 'Development Tools' -y
    dnf install @development-tools -y
  }
  fi
  # dnf install libxcrypt-compat -y # needed by Fedora 30 and up
  verify_is_installed "
    mokutil
    curl
    git
    file
    pip3
    pygmentize
    xclip
    tree
    ag
    ack
    pv
    nano
    vim

    gcc
    make
    modinfo
  "
  echo sudo dnf install VirtualBox-6.1 -y
  #install_requirements "linux" "
    # RedHat Flavor only
  #  VirtualBox-6.1
  #"
  #verify_is_installed "
  #VirtualBox
  #"
	if wget -P /etc/yum.repos.d/ https://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo ; then 
		{
		yes | dnf search virtualbox -y
	  dnf install VirtualBox -y
	  # dnf install VirtualBox-7.0 -y
  }
	fi
  Installing "usermod -aG vboxusers "\${USER}:${USER}" "
	usermod -aG vboxusers "${USER}"
	Installing "usermod -aG vboxusers "\${SUDO_USER}:${SUDO_USER}" "
	usermod -aG vboxusers "${SUDO_USER}"
  cd  "${USER_HOME}"
  if [ ! -f  "${USER_HOME}/.virtualboxinstallreboot" ] ; then
	{	
		[ ! -f  "${USER_HOME}/.virtualboxinstallreboot" ] && echo System will reboot now, after youpress any key
    [ ! -f  "${USER_HOME}/.virtualboxinstallreboot" ] &&  touch "${USER_HOME}/.virtualboxinstallreboot" && _pause  "reboot 1" && reboot
		echo System will reboot now, after you press any key
	  touch "${USER_HOME}/.virtualboxinstallreboot"
	  _pause  "reboot 1" 
		reboot
	  exit 0
	}
	fi
  export KERN_DIR=/usr/src/kernels/`uname -r`
  echo $KERN_DIR
  cd  "${USER_HOME}"
	if [ -f  "${USER_HOME}/.virtualboxinstallrebootsigned" ] && [ ! -d /root/signed-modules ] ; then 
	{
		rm -rf "${USER_HOME}/.virtualboxinstallrebootsigned"
	}
	fi
  if [ ! -f  "${USER_HOME}/.virtualboxinstallrebootsigned" ] ; then
  {
    mkdir -p /root/signed-modules
    cd /root/signed-modules
    openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=VirtualBox/"
    chmod 600 MOK.priv
		echo 3-
		echo 3-
    echo 3- Step number three if everything is going smooth this is the second reboot
		echo 3-
		echo Sign Mok REF: https://stackoverflow.com/questions/61248315/sign-virtual-box-modules-vboxdrv-vboxnetflt-vboxnetadp-vboxpci-centos-8
    echo 3-
	 	echo 3- NOTE: This command will ask you to 
		echo 3-                                    add a password, 
		echo 3-                                                     write 1234678 
	  echo 3-  	you need this password after the next reboot.
    echo 3-
		echo 3- 
	 	mokutil --import MOK.der

    echo REF: https://gist.github.com/reillysiemens/ac6bea1e6c7684d62f544bd79b2182a4
    local name="$(getent passwd $(whoami) | awk -F: '{print $5}')"
    local out_dir=/root/module-signing
    mkdir  -p  "${out_dir}"
    echo 3-
		echo 3- This command will ask you to add PEM key, for PEM Just press enter,  and input a password enter asd, you need this password after the next reboot.
    echo 3-
		echo 3-                            AGAIN: This command will ask you to
    echo 3-            add a password,
 	  echo 3-                            write 1234678
    echo 3-                                           you need this password after the next reboot.
    echo 3-
    echo 3-
		echo "3- openssl \
req \
-new \
-x509 \
-newkey \
rsa:2048 \
-keyout ${out_dir}/MOK.priv \
-outform DER \
-out ${out_dir}/MOK.der \
-days 36500 \
-subj /CN=${name}/"
		echo 3-
		echo 3-
    cd "${out_dir}"
    openssl \
        req \
        -new \
        -x509 \
        -newkey \
        rsa:2048 \
        -keyout ${out_dir}/MOK.priv \
        -outform DER \
        -out ${out_dir}/MOK.der \
        -days 36500 \
        -subj "/CN=${name}/"
    chmod 600 ${out_dir}/MOK.*
    echo "mokutil --import /root/module-signing/MOK.der"
    mokutil --import /root/module-signing/MOK.der
    echo 4-
    echo 4- Reboot your system and a blue screen appear, select Enroll MOK --> Continue --> put the previous password and your system will start.
    echo 4-
		echo 4- System will reboot now, after you press any key
		echo 4-
		echo 4-
		
    [ ! -f  "${USER_HOME}/.virtualboxinstallrebootsigned" ] && touch "${USER_HOME}/.virtualboxinstallrebootsigned"  && _pause "sign reboot 4" && reboot
  }
  fi
  if [ ! -f  "${USER_HOME}/.virtualboxinstallrebootsigned2" ] ; then
  {
      cd /root/signed-modules
      # need to sign the kernel modules (vboxdrv, vboxnetflt, vboxnetadp, vboxpci)
			local modules_to_be_signed_up="
vboxdrv
vboxguest
vboxnetadp
vboxnetflt
vboxsf
vboxvideo
vboxpci
"
    local _fileout=""
    cat <<EOF | tee /root/signed-modules/sign-virtual-box
#!/bin/bash
echo "File /root/signed-modules/sign-virtual-box:1"
echo 'REF: https://superuser.com/questions/1539756/virtualbox-6-fedora-30-efi-secure-boot-you-may-need-to-sign-the-kernel-modules'
echo 'Running :'\$0
set -u
set -E -o functrace
function _root_signed_modules_sign_virtual_box(){
  local one_mod_ko_file=""
  local -i _err=0
  local modfile=""
EOF
    local one=""
	  local onemod=""
	  local -i _err	
		local filenamesko=""
		local dirko=""
    while read -r one ; do
		{
			onemod=""
			dirko=""
			filenamesko=""
			[[ -z "${one-}" ]] && continue
			# test module 
			if modinfo -n "${one}" ; then
			{
				echo 'found'
				onemod="$(modinfo -n "${one}")"
		    _err=0
			}
		  else
			{
				echo 'not found'
				_err=1
			}
			fi
		  [ ${_err} -gt 0 ] && echo "Warning could not find module:${one}" && continue
      [[ -z "${onemod-}" ]] && continue
			
			# test dir
			if [[ -d "$(dirname "${onemod}")" ]] ; then 
			{
				echo 'found'
				dirko="$(dirname "${onemod}")"
		    _err=0
			}
		  else
			{
				echo 'not found'
				_err=1
			}
			fi
	    [ ${_err} -gt 0 ] && echo "Warning could not find dir for  module:${one}" && continue
      [[ -z "${dirko-}" ]] && continue
			
			# test files
			if ls "${filenamesko-}"/*.ko ; then
			{
				echo 'found'
			  filenamesko="$(ls "${dirko-}"/*.ko)"
		    _err=0
			}
		  else
			{
				echo 'not found'
				_err=1
			}
			fi
      [ ${_err} -gt 0 ] && echo "Warning could not find *.ko files for module:${one}" && continue
			[[ -z "${filenamesko-}" ]] && continue

      cat <<EOF | tee -a /root/signed-modules/sign-virtual-box
  local filenamesko="
${filenamesko}
"
  while read -r one_mod_ko_file ; do
  {
    [[ -z "\${one_mod_ko_file-}" ]] && continue
    echo "Signing \${one_mod_ko_file}"
    /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 \\
                                /root/signed-modules/MOK.priv \\
                                /root/signed-modules/MOK.der "\${one_mod_ko_file}"
  } 
  done <<< "\${filenamesko}"
EOF
			 
		}
	  done <<< "${modules_to_be_signed_up}"
cat <<EOF | tee -a /root/signed-modules/sign-virtual-box
} # end _root_signed_modules_sign_virtual_box

_root_signed_modules_sign_virtual_box \${*}


EOF

    echo REF: https://superuser.com/questions/1539756/virtualbox-6-fedora-30-efi-secure-boot-you-may-need-to-sign-the-kernel-modules
    chmod 700 /root/signed-modules/sign-virtual-box
    /root/signed-modules/sign-virtual-box

    echo "
    5- Reboot your system and a blue screen appear, select Enroll MOK --> Continue --> put the previous password and your system will start.
    "
    echo System will reboot now, after you press any key
    [ ! -f  "${USER_HOME}/.virtualboxinstallrebootsigned2" ] && touch "${USER_HOME}/.virtualboxinstallrebootsigned2"  && _pause "sign reboot 5" && reboot
  }
  fi


rm "${USER_HOME}/.virtualboxinstallrebootsigned"
rm "${USER_HOME}/.virtualboxinstallrebootsigned2"
rm "${USER_HOME}/.virtualboxinstallreboot"

  /usr/lib/virtualbox/vboxdrv.sh setup



# sudo dnf -y install @development-tools\
# sudo dnf -y install kernel-headers kernel-devel dkms elfutils-libelf-devel qt5-qtx11extras
# cat <<EOF | sudo tee /etc/yum.repos.d/virtualbox.repo \
# [virtualbox]\
# name=Fedora $releasever - $basearch - VirtualBox\
# baseurl=http://download.virtualbox.org/virtualbox/rpm/fedora/29/\$basearch\
# enabled=1\
# gpgcheck=1\
# repo_gpgcheck=1\
# gpgkey=https://www.virtualbox.org/download/oracle_vbox.asc\

# EOF

# sudo dnf search virtualbox
# yes | sudo dnf search virtualbox
# yes | sudo dnf -y install VirtualBox
# yes | sudo dnf -y install VirtualBox-6.0
# sudo usermod -a -G vboxusers $USER
# id $USER
# echo REF: https://computingforgeeks.com/how-to-install-virtualbox-on-fedora-linux/
# echo Start Virtual Box
# /sbin/vboxconfig
# sudo /sbin/vboxconfig
# dmesg
# sudo dnf -y update
# sudo dnf -y purge virtualbox
# sudo dnf -y remove VirtualBox
# sudo dnf -y uninstall VirtualBox
# sudo dnf -y remove VirtualBox
# sudo dnf -y remove VirtualBox-6.0-6.0.14_133895_fedora29-1.x86_64
# sudo dnf -y clean
# su - root /sbin/vboxconfig
# sudo /etc/init.d/vboxdrv setup
# sudo dnf -y install filezilla
# su

# /sbin/vboxconfig

# locate vbox{drv,netadp,netflt,pci}.ko

# modprobe vboxdrv

# dmesg

# virtualbox
# su

# KERN_DIR=/usr/src/kernels/`uname -r`

# export KERN_DIR

# virtualbox

# openssl req -config ./openssl.cnf         -new -x509 -newkey rsa:2048         -nodes -days 36500 -outform DER         -keyout "MOK.priv"         -out "MOK.der"

# ls

# ls -la

# pwd

# vim openssl.cnf

# openssl req -config ./openssl.cnf         -new -x509 -newkey rsa:2048         -nodes -days 36500 -outform DER         -keyout "MOK.priv"         -out "MOK.der"

# ls

# sudo mokutil --import MOK.der

# sudo cat /proc/keys

# kmodsign sha512 MOK.priv MOK.der module.ko

# module.ko

# hexdump -Cv module.ko | tail -n 5

# kmodsign

# openssl x509 -in MOK.der -inform DER -outform PEM -out MOK.pem

# sbsign --key MOK.priv --cert MOK.pem my_binary.efi --output my_binary.efi.signed

# kmodsign

# sudo dnf -y install kmodsign

# #!/bin/bash

# echo -n "Enter a Common Name to embed in the keys: "

# read NAME

# mokutil sha512 MOK.priv MOK.der module.ko

# keyctl list %:.system_keyring

cat << EOF > configuration_file.config
[ req ]
default_bits = 4096
distinguished_name = req_distinguished_name
prompt = no
string_mask = utf8only
x509_extensions = myexts

[ req_distinguished_name ]
O = Organization
CN = Organization signing key
emailAddress = E-mail address

[ myexts ]
basicConstraints=critical,CA:FALSE
keyUsage=digitalSignature
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid
EOF


# openssl req -x509 -new -nodes -utf8 -sha256 -days 36500 -batch -config configuration_file.config -outform DER -out public_key.der -keyout private_key.priv

openssl req -x509 -new -nodes -utf8 -sha256 -days 36500 -batch -config configuration_file.config -outform DER -out public_key.der -keyout private_key.priv

# mokutil -#-import

# ls

mokutil --import public_key.der

# make -C /usr/src/kernels/$(uname -r) M=$PWD modules

# perl /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 my_signing_key.priv my_signing_key_pub.dermy_module.ko

# perl /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 my_signing_key.priv my_signing_key_pub.der my_module.ko

# perl /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 my_signing_key.priv my_signing_key_pub.der my_module.ko

# mokutil

# mokutil --import

# modprobe -v vbox

# modprobe -v vboxsrv

# modprobe -v vboxsrv.sh

# lsmod | grep vbox


echo now login as root su
echo and run
echo "
su
KERN_DIR=/usr/src/kernels/`uname -r`
export KERN_DIR
/sbin/vboxconfig

"
_pause " Presiona tecla para terminar aqui "

} # end _fedora_40__64

_fedora_37__64() {
  trap "echo Error:$?" ERR INT
  local _parameters="${*-}"
  local -i _err=0
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    failed "while running callsomething above _err:${_err}"
  }
  fi
} # end _fedora_37__64

_fedora__64() {
  echo Fedora 29 REF: https://computingforgeeks.com/how-to-install-virtualbox-on-fedora-linux/
  echo Fedora 32 REF: https://tecadmin.net/install-oracle-virtualbox-on-fedora/
  echo Fedora 33 https://www.if-not-true-then-false.com/2010/install-virtualbox-with-yum-on-fedora-centos-red-hat-rhel/
  echo "$0:${LINENO} params ${*:-}"
	if [[ "${*-}" == *"--extension7"* ]] ; then
  {
		wget https://download.virtualbox.org/virtualbox/7.0.6/Oracle_VM_VirtualBox_Extension_Pack-7.0.6a-155176.vbox-extpack
	  VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-7.0.6a-155176.vbox-extpack
    wget https://download.virtualbox.org/virtualbox/7.0.6/VBoxGuestAdditions_7.0.6.iso
		exit 0
	}
	fi
	if [[ "${*-}" == *"--extension6"* ]] ; then
  {
	 # wget https://download.virtualbox.org/virtualbox/6.1.0_RC1/VirtualBox-6.1-6.1.0_RC1_134891_el6-1.x86_64.rpm
	 # dnf install ./VirtualBox-6.1-6.1.0_RC1_134891_el6-1.x86_64.rpm --allowerasing 
	 #	wget https://download.virtualbox.org/virtualbox/6.1.0_RC1/VirtualBoxSDK-6.1.0_RC1-134891.zip
	 # unzip VirtualBoxSDK-6.1.0_RC1-134891.zip
	 #	wget https://download.virtualbox.org/virtualbox/6.1.0_RC1/VBoxGuestAdditions_6.1.0_RC1.iso
	 # wget https://download.virtualbox.org/virtualbox/6.1.0_RC1/Oracle_VM_VirtualBox_Extension_Pack-6.1.0_RC1.vbox-extpack
	  # wget https://download.virtualbox.org/virtualbox/6.1.48/Oracle_VM_VirtualBox_Extension_Pack-6.1.48.vbox-extpack
		# VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-6.1.0_RC1.vbox-extpack
		# VBoxManage extpack uninstall Oracle_VM_VirtualBox_Extension_Pack-6.1.0_RC1.vbox-extpack
		VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-6.1.48.vbox-extpack
		exit 0
	}
 	fi
	if [[ "${*-}" == *"--reset"* ]] || [[ "${*-}" == *"--startover"* ]] || [[ "${*-}" == *"--restart"* ]] then 
	{
		echo "--reset --startover --restart " 
		echo "reseting now"
    rm "${USER_HOME}/.virtualboxinstallrebootsigned"
    rm "${USER_HOME}/.virtualboxinstallrebootsigned2"
    rm "${USER_HOME}/.virtualboxinstallreboot"
    rm /root/signed-modules
    rm /root/module-signing
  }
	fi
	dnf builddep libvpx-devel -y  --allowerasing
	dnf builddep dkms -y  --allowerasing 
  dnf builddep kernel-devel  -y  --allowerasing 
	if it_exists_with_spaces "/etc/yum.repos.d/virtualbox.repo" ; then
  {
    file_exists_with_spaces "/etc/yum.repos.d/virtualbox.repo"
  }
  else
  {
    cd "/etc/yum.repos.d/"
    wget http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo
    file_exists_with_spaces "/etc/yum.repos.d/virtualbox.repo"
  }
  fi
   install_requirements "linux" "
    # RedHat Flavor only
    binutils
    gcc
    make
    patch
    libgomp
    dkms
    qt5-qtx11extras
    libxkbcommon
    glibc-headers
    glibc-devel
    kernel-headers
    kernel-devel
    # compat-libvpx5
		libvpx-devel
    mokutil
		elfutils-libelf-devel 
 "
  is_not_installed pygmentize &&   dnf  -y install pygmentize
  if ( ! command -v pygmentize >/dev/null 2>&1; ) ;  then
    pip3 install pygments
  fi
  local groupsinstalled=$(dnf group list --installed)
  if [[ "${groupsinstalled}" = *"Development Tools"* ]] ; then
  {
    passed installed 'Development Tools'
  }
  else
  {
    dnf groupinstall 'Development Tools' -y
    dnf install @development-tools -y
  }
  fi
  # dnf install libxcrypt-compat -y # needed by Fedora 30 and up
  verify_is_installed "
    mokutil
    curl
    git
    file
    pip3
    pygmentize
    xclip
    tree
    ag
    ack
    pv
    nano
    vim

    gcc
    make
    modinfo
  "
  echo sudo dnf install VirtualBox-6.1 -y
  #install_requirements "linux" "
    # RedHat Flavor only
  #  VirtualBox-6.1
  #"
  #verify_is_installed "
  #VirtualBox
  #"
	if wget -P /etc/yum.repos.d/ https://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo ; then 
		{
		yes | dnf search virtualbox -y
	  dnf install VirtualBox-7.0 -y
  }
	fi
  Installing "usermod -aG vboxusers "\${USER}:${USER}" "
	usermod -aG vboxusers "${USER}"
	Installing "usermod -aG vboxusers "\${SUDO_USER}:${SUDO_USER}" "
	usermod -aG vboxusers "${SUDO_USER}"
  cd  "${USER_HOME}"
  if [ ! -f  "${USER_HOME}/.virtualboxinstallreboot" ] ; then
	{	
		[ ! -f  "${USER_HOME}/.virtualboxinstallreboot" ] && echo System will reboot now, after youpress any key
    [ ! -f  "${USER_HOME}/.virtualboxinstallreboot" ] &&  touch "${USER_HOME}/.virtualboxinstallreboot" && _pause  "reboot 1" && reboot
		echo System will reboot now, after you press any key
	  touch "${USER_HOME}/.virtualboxinstallreboot"
	  _pause  "reboot 1" 
		reboot
	  exit 0
	}
	fi
  export KERN_DIR=/usr/src/kernels/`uname -r`
  echo $KERN_DIR
  cd  "${USER_HOME}"
	if [ -f  "${USER_HOME}/.virtualboxinstallrebootsigned" ] && [ ! -d /root/signed-modules ] ; then 
	{
		rm -rf "${USER_HOME}/.virtualboxinstallrebootsigned"
	}
	fi
  if [ ! -f  "${USER_HOME}/.virtualboxinstallrebootsigned" ] ; then
  {
    mkdir -p /root/signed-modules
    cd /root/signed-modules
    openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=VirtualBox/"
    chmod 600 MOK.priv
		echo 3-
		echo 3-
    echo 3- Step number three if everything is going smooth this is the second reboot
		echo 3-
		echo Sign Mok REF: https://stackoverflow.com/questions/61248315/sign-virtual-box-modules-vboxdrv-vboxnetflt-vboxnetadp-vboxpci-centos-8
    echo 3-
	 	echo 3- NOTE: This command will ask you to 
		echo 3-                                    add a password, 
		echo 3-                                                     write 1234678 
	  echo 3-  	you need this password after the next reboot.
    echo 3-
		echo 3- 
	 	mokutil --import MOK.der

    echo REF: https://gist.github.com/reillysiemens/ac6bea1e6c7684d62f544bd79b2182a4
    local name="$(getent passwd $(whoami) | awk -F: '{print $5}')"
    local out_dir=/root/module-signing
    mkdir  -p  "${out_dir}"
    echo 3-
		echo 3- This command will ask you to add PEM key, for PEM Just press enter,  and input a password enter asd, you need this password after the next reboot.
    echo 3-
		echo 3-                            AGAIN: This command will ask you to
    echo 3-            add a password,
 	  echo 3-                            write 1234678
    echo 3-                                           you need this password after the next reboot.
    echo 3-
    echo 3-
		echo "3- openssl \
req \
-new \
-x509 \
-newkey \
rsa:2048 \
-keyout ${out_dir}/MOK.priv \
-outform DER \
-out ${out_dir}/MOK.der \
-days 36500 \
-subj /CN=${name}/"
		echo 3-
		echo 3-
    cd "${out_dir}"
    openssl \
        req \
        -new \
        -x509 \
        -newkey \
        rsa:2048 \
        -keyout ${out_dir}/MOK.priv \
        -outform DER \
        -out ${out_dir}/MOK.der \
        -days 36500 \
        -subj "/CN=${name}/"
    chmod 600 ${out_dir}/MOK.*
    echo "mokutil --import /root/module-signing/MOK.der"
    mokutil --import /root/module-signing/MOK.der
    echo 4-
    echo 4- Reboot your system and a blue screen appear, select Enroll MOK --> Continue --> put the previous password and your system will start.
    echo 4-
		echo 4- System will reboot now, after you press any key
		echo 4-
		echo 4-
		
    [ ! -f  "${USER_HOME}/.virtualboxinstallrebootsigned" ] && touch "${USER_HOME}/.virtualboxinstallrebootsigned"  && _pause "sign reboot 4" && reboot
  }
  fi
  if [ ! -f  "${USER_HOME}/.virtualboxinstallrebootsigned2" ] ; then
  {
      cd /root/signed-modules
      # need to sign the kernel modules (vboxdrv, vboxnetflt, vboxnetadp, vboxpci)
			local modules_to_be_signed_up="
vboxdrv
vboxguest
vboxnetadp
vboxnetflt
vboxsf
vboxvideo
vboxpci
"
    local _fileout=""
    cat <<EOF | tee /root/signed-modules/sign-virtual-box
#!/bin/bash
echo "File /root/signed-modules/sign-virtual-box:1"
echo 'REF: https://superuser.com/questions/1539756/virtualbox-6-fedora-30-efi-secure-boot-you-may-need-to-sign-the-kernel-modules'
echo 'Running :'\$0
set -u
set -E -o functrace
function _root_signed_modules_sign_virtual_box(){
  local one_mod_ko_file=""
  local -i _err=0
  local modfile=""
EOF
    local one=""
	  local onemod=""
	  local -i _err	
		local filenamesko=""
		local dirko=""
    while read -r one ; do
		{
			onemod=""
			dirko=""
			filenamesko=""
			[[ -z "${one-}" ]] && continue
			# test module 
			if modinfo -n "${one}" ; then
			{
				echo 'found'
				onemod="$(modinfo -n "${one}")"
		    _err=0
			}
		  else
			{
				echo 'not found'
				_err=1
			}
			fi
		  [ ${_err} -gt 0 ] && echo "Warning could not find module:${one}" && continue
      [[ -z "${onemod-}" ]] && continue
			
			# test dir
			if [[ -d "$(dirname "${onemod}")" ]] ; then 
			{
				echo 'found'
				dirko="$(dirname "${onemod}")"
		    _err=0
			}
		  else
			{
				echo 'not found'
				_err=1
			}
			fi
	    [ ${_err} -gt 0 ] && echo "Warning could not find dir for  module:${one}" && continue
      [[ -z "${dirko-}" ]] && continue
			
			# test files
			if ls "${filenamesko-}"/*.ko ; then
			{
				echo 'found'
			  filenamesko="$(ls "${dirko-}"/*.ko)"
		    _err=0
			}
		  else
			{
				echo 'not found'
				_err=1
			}
			fi
      [ ${_err} -gt 0 ] && echo "Warning could not find *.ko files for module:${one}" && continue
			[[ -z "${filenamesko-}" ]] && continue

      cat <<EOF | tee -a /root/signed-modules/sign-virtual-box
  local filenamesko="
${filenamesko}
"
  while read -r one_mod_ko_file ; do
  {
    [[ -z "\${one_mod_ko_file-}" ]] && continue
    echo "Signing \${one_mod_ko_file}"
    /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 \\
                                /root/signed-modules/MOK.priv \\
                                /root/signed-modules/MOK.der "\${one_mod_ko_file}"
  } 
  done <<< "\${filenamesko}"
EOF
			 
		}
	  done <<< "${modules_to_be_signed_up}"
cat <<EOF | tee -a /root/signed-modules/sign-virtual-box
} # end _root_signed_modules_sign_virtual_box

_root_signed_modules_sign_virtual_box \${*}


EOF

    echo REF: https://superuser.com/questions/1539756/virtualbox-6-fedora-30-efi-secure-boot-you-may-need-to-sign-the-kernel-modules
    chmod 700 /root/signed-modules/sign-virtual-box
    /root/signed-modules/sign-virtual-box

    echo "
    5- Reboot your system and a blue screen appear, select Enroll MOK --> Continue --> put the previous password and your system will start.
    "
    echo System will reboot now, after you press any key
    [ ! -f  "${USER_HOME}/.virtualboxinstallrebootsigned2" ] && touch "${USER_HOME}/.virtualboxinstallrebootsigned2"  && _pause "sign reboot 5" && reboot
  }
  fi


rm "${USER_HOME}/.virtualboxinstallrebootsigned"
rm "${USER_HOME}/.virtualboxinstallrebootsigned2"
rm "${USER_HOME}/.virtualboxinstallreboot"

  /usr/lib/virtualbox/vboxdrv.sh setup



# sudo dnf -y install @development-tools\
# sudo dnf -y install kernel-headers kernel-devel dkms elfutils-libelf-devel qt5-qtx11extras
# cat <<EOF | sudo tee /etc/yum.repos.d/virtualbox.repo \
# [virtualbox]\
# name=Fedora $releasever - $basearch - VirtualBox\
# baseurl=http://download.virtualbox.org/virtualbox/rpm/fedora/29/\$basearch\
# enabled=1\
# gpgcheck=1\
# repo_gpgcheck=1\
# gpgkey=https://www.virtualbox.org/download/oracle_vbox.asc\

# EOF

# sudo dnf search virtualbox
# yes | sudo dnf search virtualbox
# yes | sudo dnf -y install VirtualBox
# yes | sudo dnf -y install VirtualBox-6.0
# sudo usermod -a -G vboxusers $USER
# id $USER
# echo REF: https://computingforgeeks.com/how-to-install-virtualbox-on-fedora-linux/
# echo Start Virtual Box
# /sbin/vboxconfig
# sudo /sbin/vboxconfig
# dmesg
# sudo dnf -y update
# sudo dnf -y purge virtualbox
# sudo dnf -y remove VirtualBox
# sudo dnf -y uninstall VirtualBox
# sudo dnf -y remove VirtualBox
# sudo dnf -y remove VirtualBox-6.0-6.0.14_133895_fedora29-1.x86_64
# sudo dnf -y clean
# su - root /sbin/vboxconfig
# sudo /etc/init.d/vboxdrv setup
# sudo dnf -y install filezilla
# su

# /sbin/vboxconfig

# locate vbox{drv,netadp,netflt,pci}.ko

# modprobe vboxdrv

# dmesg

# virtualbox
# su

# KERN_DIR=/usr/src/kernels/`uname -r`

# export KERN_DIR

# virtualbox

# openssl req -config ./openssl.cnf         -new -x509 -newkey rsa:2048         -nodes -days 36500 -outform DER         -keyout "MOK.priv"         -out "MOK.der"

# ls

# ls -la

# pwd

# vim openssl.cnf

# openssl req -config ./openssl.cnf         -new -x509 -newkey rsa:2048         -nodes -days 36500 -outform DER         -keyout "MOK.priv"         -out "MOK.der"

# ls

# sudo mokutil --import MOK.der

# sudo cat /proc/keys

# kmodsign sha512 MOK.priv MOK.der module.ko

# module.ko

# hexdump -Cv module.ko | tail -n 5

# kmodsign

# openssl x509 -in MOK.der -inform DER -outform PEM -out MOK.pem

# sbsign --key MOK.priv --cert MOK.pem my_binary.efi --output my_binary.efi.signed

# kmodsign

# sudo dnf -y install kmodsign

# #!/bin/bash

# echo -n "Enter a Common Name to embed in the keys: "

# read NAME

# mokutil sha512 MOK.priv MOK.der module.ko

# keyctl list %:.system_keyring

cat << EOF > configuration_file.config
[ req ]
default_bits = 4096
distinguished_name = req_distinguished_name
prompt = no
string_mask = utf8only
x509_extensions = myexts

[ req_distinguished_name ]
O = Organization
CN = Organization signing key
emailAddress = E-mail address

[ myexts ]
basicConstraints=critical,CA:FALSE
keyUsage=digitalSignature
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid
EOF


# openssl req -x509 -new -nodes -utf8 -sha256 -days 36500 -batch -config configuration_file.config -outform DER -out public_key.der -keyout private_key.priv

openssl req -x509 -new -nodes -utf8 -sha256 -days 36500 -batch -config configuration_file.config -outform DER -out public_key.der -keyout private_key.priv

# mokutil -#-import

# ls

mokutil --import public_key.der

# make -C /usr/src/kernels/$(uname -r) M=$PWD modules

# perl /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 my_signing_key.priv my_signing_key_pub.dermy_module.ko

# perl /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 my_signing_key.priv my_signing_key_pub.der my_module.ko

# perl /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 my_signing_key.priv my_signing_key_pub.der my_module.ko

# mokutil

# mokutil --import

# modprobe -v vbox

# modprobe -v vboxsrv

# modprobe -v vboxsrv.sh

# lsmod | grep vbox


echo now login as root su
echo and run
echo "
su
KERN_DIR=/usr/src/kernels/`uname -r`
export KERN_DIR
/sbin/vboxconfig

"
_pause " Presiona tecla para terminar aqui "

} # end _fedora__64

_darwin__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  ensure brew or "Canceling until brew is installed"
  local _parameters="${*-}"
  local -i _err=0
  su - "${SUDO_USER}" -c "bash -c 'brew install --cask virtualbox'"
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    failed "$0:$LINENO  while running 'brew install --cask virtualbox' above _err:${_err}"
  }
  fi
} # end _darwin__64


_pause() {
  echo "Press any key to continue ${1}"
  while [ true ] ; do
    read -t 3 -n 1
    if [ $? = 0 ] ; then
      break ;
    else
      echo "waiting for the keypress ${1}"
    fi
  done
  return 0
}



 #--------/\/\/\/\-- 2tasks_templates_sudo/virtualbox …install_virtualbox.bash” -- Custom code-/\/\/\/\-------



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
