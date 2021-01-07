#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
# SUDO_USER only exists during execution of sudo
# REF: https://stackoverflow.com/questions/7358611/get-users-home-directory-when-they-run-a-script-as-root
# Global:
THISSCRIPTNAME=`basename "$0"`

execute_as_sudo(){
  if [ -z $SUDO_USER ] ; then
    if [[ -z "$THISSCRIPTNAME" ]] ; then
    {
        echo "error You need to add THISSCRIPTNAME variable like this:"
        echo "     THISSCRIPTNAME=\`basename \"\$0\"\`"
    }
    else
    {
        if [ -e "./$THISSCRIPTNAME" ] ; then
        {
          sudo "./$THISSCRIPTNAME"
        }
        elif ( command -v "$THISSCRIPTNAME" >/dev/null 2>&1 );  then
        {
          echo "sudo sudo sudo "
          sudo "$THISSCRIPTNAME"
        }
        else
        {
          echo -e "\033[05;7m*** Failed to find script to recall it as sudo ...\033[0m"
          exit 1
        }
        fi
    }
    fi
    wait
    exit 0
  fi
  # REF: http://superuser.com/questions/93385/run-part-of-a-bash-script-as-a-different-user
  # REF: http://superuser.com/questions/195781/sudo-is-there-a-command-to-check-if-i-have-sudo-and-or-how-much-time-is-left
  local CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
  if [ ${CAN_I_RUN_SUDO} -gt 0 ]; then
    echo -e "\033[01;7m*** Installing as sudo...\033[0m"
  else
    echo "Needs to run as sudo ... ${0}"
  fi
}
execute_as_sudo

USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)

load_struct_testing_wget(){
    local provider="$USER_HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    [   -e "${provider}"  ] && source "${provider}"
    [ ! -e "${provider}"  ] && eval """$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing -O -  2>/dev/null )"""   # suppress only wget download messages, but keep wget output for variable
    ( ( ! command -v passed >/dev/null 2>&1; ) && echo -e "\n \n  ERROR! Loading struct_testing \n \n " && exit 69; )
} # end load_struct_testing_wget
load_struct_testing_wget

passed Caller user identified:$SUDO_USER
passed Home identified:$USER_HOME
file_exists_with_spaces "$USER_HOME"


_version() {
  # fedora_32 https://www.scootersoftware.com/bcompare-4.3.3.24545.i386.rpm
  # https://www.scootersoftware.com/bcompare-4.3.3.24545.x86_64.rpm
  # zz=dl4&platform=mac, zz=dl4&platform=linux, zz=dl4&platform=win

  local PLATFORM="${1}"
  local PATTERN="${2}"
  # THOUGHT: local CODEFILE=$(curl -d "zz=dl4&platform=linux" -H "Content-Type: application/x-www-form-urlencoded" -X POST  -sSLo -  https://www.scootersoftware.com/download.php  2>&1;) # suppress only wget download messages, but keep wget output for variable
  local CODEFILE=$(curl -d "zz=dl4&platform=${PLATFORM}" -H "Content-Type: application/x-www-form-urlencoded" -X POST  -sSLo -  https://www.scootersoftware.com/download.php  2>&1;) # suppress only wget download messages, but keep wget output for variable
  # THOUGHT: local CODELASTESTBUILD=$(echo $CODEFILE | sed s/\</\\n\</g | grep "bcompare*.*.*.*.x86_64.rpm" | sed s/\"/\\n/g | grep "/" | cuet "/")
  local CODELASTESTBUILD=$(echo $CODEFILE | sed s/\</\\n\</g | grep "${PATTERN}" | sed s/\"/\\n/g | grep "/" | cuet "/")
  # fedora 32 local CODELASTESTBUILD=$(echo $CODEFILE | sed s/\</\\n\</g | grep "bcompare*.*.*.*.i386.rpm" | sed s/\"/\\n/g | grep "/" | cuet "/")
  wait
  [[ -z "${CODELASTESTBUILD}" ]] && failed "Beyond Compare Version not found! :${CODELASTESTBUILD}:"


  # assert not empty "${USER_HOME}"
  # assert not empty "${CODELASTESTBUILD}"

  local CODENAME="${CODELASTESTBUILD}"
  echo "${CODELASTESTBUILD}"
  unset PATTERN
  unset PLATFORM
  unset CODEFILE
  unset CODELASTESTBUILD
} # end _version

_darwin__64() {
    local CODENAME=$(_version "mac" "BCompareOSX*.*.*.*.zip")
    # THOUGHT        local CODENAME="BCompareOSX-4.3.3.24545.zip"
    local URL="https://www.scootersoftware.com/${CODENAME}"
    cd $USER_HOME/Downloads/
    _download "${URL}"
    unzip ${CODENAME}
    sudo hdiutil attach ${CODENAME}
    sudo cp -R /Volumes/Beyond\ Compare/Beyond\ Compare.app /Applications/
    sudo hdiutil detach /Volumes/Beyond \ Compare
} # end _darwin__64

_ubuntu__64() {
    local CODENAME=$(_version "linux" "bcompare-*.*.*.*amd64.deb")
    # THOUGHT          local CODENAME="bcompare-4.3.3.24545_amd64.deb"
    local URL="https://www.scootersoftware.com/${CODENAME}"
    cd $USER_HOME/Downloads/
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
} # end _ubuntu__64

_ubuntu__32() {
    local CODENAME=$(_version "linux" "bcompare-*.*.*.*i386.deb")
    # THOUGHT local CODENAME="bcompare-4.3.3.24545_i386.deb"
    local URL="https://www.scootersoftware.com/${CODENAME}"
    cd $USER_HOME/Downloads/
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
} # end _ubuntu__32

_fedora__32() {
  local CODENAME=$(_version "linux" "bcompare*.*.*.*.i386.rpm")
  # THOUGHT                          bcompare-4.3.3.24545.i386.rpm
  local TARGET_URL="https://www.scootersoftware.com/${CODENAME}"
  file_exists_with_spaces $USER_HOME/Downloads
  cd $USER_HOME/Downloads
  _download "${TARGET_URL}" "${USER_HOME}/Downloads" "${CODENAME}"
  file_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}"
  ensure rpm or "Canceling Install. Could not find rpm command to execute install"

  # provide error handling , once learned goes here. LEarn under if, once learned here.
  # Start loop while ERROR flag in case needs to try again, based on error
  _try "rpm --import https://www.scootersoftware.com/RPM-GPG-KEY-scootersoftware"
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
  ensure bcompare or "Failed to install Beyond Compare"
  rm -f "$USER_HOME/Downloads/${CODENAME}"
  file_does_not_exist_with_spaces "$USER_HOME/Downloads/${CODENAME}"
} # end _fedora__32

_centos__64() {
  _fedora__64 
} # end _centos__64

_fedora__64() {
  local CODENAME=$(_version "linux" "bcompare*.*.*.*.x86_64.rpm")
  # THOUGHT  https://www.scootersoftware.com/bcompare-4.3.3.24545.x86_64.rpm
  local TARGET_URL="https://www.scootersoftware.com/${CODENAME}"
  if  it_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}" ; then
  {
    file_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}"
  }
  else
  {
    file_exists_with_spaces $USER_HOME/Downloads
    cd $USER_HOME/Downloads
    echo _download "${TARGET_URL}" "${USER_HOME}/Downloads" "${CODENAME}"
    _download "${TARGET_URL}" "${USER_HOME}/Downloads" "${CODENAME}"
    file_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}"
    echo  _download "${TARGET_URL}" "${USER_HOME}/Downloads" "${CODENAME}"
  }
  fi

  ensure tar or "Canceling Install. Could not find tar command to execute unzip"
  ensure awk or "Canceling Install. Could not find awk command to execute unzip"
  ensure pv or "Canceling Install. Could not find pv command to execute unzip"
  ensure du or "Canceling Install. Could not find du command to execute unzip"
  ensure gzip or "Canceling Install. Could not find gzip command to execute unzip"
  ensure gio or "Canceling Install. Could not find gio command to execute gio"
  ensure update-mime-database or "Canceling Install. Could not find update-mime-database command to execute update-mime-database"
  ensure update-desktop-database or "Canceling Install. Could not find update-desktop-database command to execute update"
  ensure touch or "Canceling Install. Could not find touch command to execute touch"

  # provide error handling , once learned goes here. LEarn under if, once learned here.
  # Start loop while ERROR flag in case needs to try again, based on error
  cd $USER_HOME/Downloads
  _try "rpm --import https://www.scootersoftware.com/RPM-GPG-KEY-scootersoftware"
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
  ensure bcompare or "Failed to install Beyond Compare"
  rm -f "$USER_HOME/Downloads/${CODENAME}"
  file_does_not_exist_with_spaces "$USER_HOME/Downloads/${CODENAME}"
} # end _fedora__64

_mingw__64() {
    local CODENAME=$(_version "win" "BCompare*.*.*.*.exe")
    # THOUGHT        local CODENAME="BCompare-4.3.3.24545.exe"
    local URL="https://www.scootersoftware.com/${CODENAME}"
    cd $HOMEDIR
	  cd Downloads
    curl -O $URL
    ${CODENAME}
} # end _mingw__64

_mingw__32() {
    local CODENAME=$(_version "win" "BCompare*.*.*.*.exe")
    # THOUGHT        local CODENAME="BCompare-4.3.3.24545.exe"
    local URL="https://www.scootersoftware.com/${CODENAME}"
    cd $HOMEDIR
    cd Downloads
	  curl -O $URL
	  ${CODENAME}
} # end


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo ":)"


