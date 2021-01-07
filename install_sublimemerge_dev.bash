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

export USER_HOME
# typeset -rg USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)  # Get the caller's of sudo home dir Just Linux
# shellcheck disable=SC2046
# shellcheck disable=SC2031
typeset -rg USER_HOME="$(echo -n $(bash -c "cd ~${SUDO_USER} && pwd"))"  # Get the caller's of sudo home dir LINUX and MAC

load_struct_testing_wget(){
    local provider="$USER_HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    [   -e "${provider}"  ] && source "${provider}"
    [ ! -e "${provider}"  ] && eval """$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing -O -  2>/dev/null )"""   # suppress only wget download messages, but keep wget output for variable
    ( ( ! command -v passed >/dev/null 2>&1; ) && echo -e "\n \n  ERROR! Loading struct_testing \n \n " && exit 69; )
} # end load_struct_testing_wget
load_struct_testing_wget
passed Caller user identified:$USER_HOME


_version() {
   # 0. Determine where is the latest vesion published
   #    + expected to respond: https://www.sublimemerge.com/
   # 1. Go to page and see current version
   # 2. Extract current version number
   # 3.
  local PLATFORM="${1}"
  local PATTERN="${2}"
   # normal local CODEFILE=$(curl -L https://www.sublimemerge.com/  2>/dev/null | sed -n "/<div\ class=\"current_version\">/,/<\/div>/p" | head -1)   # suppress only wget download messages, but keep wget output for variable
   #    + expected string:     <div class="current_version">Sublime Merge <i>(Build 1119)</i></div>
    local CODEFILE=$(curl -L https://www.sublimemerge.com/dev  2>/dev/null)
    local VERSION=$(echo "$CODEFILE" | sed -n "/<p\ class=\"latest\">/,/<\/div>/p" | head -1)   # suppress only wget download messages, but keep wget output for variable
   #    + expected string:      <p class="latest"><i>Version:</i> Build 1118</p>
    local _sublime_build_line=$(echo "${VERSION}" | grep 'Build ....')

    if [ -z "${_sublime_build_line}" ] ; then
    {
        echo "error when doing check of line string from website. Got nothing"
        echo "    VERSION: <${VERSION}>"
        echo "                      0123456789 123456789 123456789 123456789 123456789 123456789 1234567889 123456789 123456789 123456789 123456789 "
        echo "                                1         2         3         4         5         6          7         8         9        10        11"
        echo "_sublime_build_line: <${_sublime_build_line}>"
        failed "Error"
        exit 69;
    }
    fi
    local SUBLIMEDEVLASTESTBUILD=$(echo "${_sublime_build_line}" | cut -c42-45)
    wait
    [[ -z "${SUBLIMEDEVLASTESTBUILD}" ]] && failed "Sublime Merge Version not found!"
    # THOUGHT local TARGETURL=$(echo $CODEFILE | sed s/\</\\n\</g | grep "x86_64.rpm" | sed s/\"/\\n/g | head -2 | tail -1 | sed s@\/@\\n@g | tail -1)
    # echo SUBLIMEDEVLASTESTBUILD:"${SUBLIMEDEVLASTESTBUILD}"
    # echo PATTERN:"${PATTERN}"
    # echo $CODEFILE | sed s/\</\\n\</g | grep "${PATTERN}"
    local CODENAME=$(echo "$CODEFILE" | sed s/\</\\n\</g | grep "${PATTERN}" | sed s/\"/\\n/g | head -2 | tail -1 | sed s@\/@\\n@g | tail -1)
    wait
    # echo CODENAME:"${CODENAME}"
    [[ -z "${CODENAME}" ]] && failed "Sublime Merge Download Url not found!"
    echo "${CODENAME}"
    # exit 1

}
# https://download.sublimetext.com/${1}

_darwin__64() {
    # expected string: https://download.sublimetext.com/sublime_merge_build_1119_mac.zip
    local CODENAME=$(_version "mac" "mac.zip")
    local TARGET_URL="https://download.sublimetext.com/${CODENAME}"
    local SUBLIMENAME_4_HDUTIL="sublime_merge_build_{SUBLIMEDEVLASTESTBUILD}_mac.dmg"
    wait
    cd ~/Downloads/
    [ ! -e "${SUBLIMENAME_4_HDUTIL}" ] || _download "${SUBLIMENAME}"
    unzip "${SUBLIMENAME}"
    echo "${pwd}"
    echo "${SUBLIMENAME_4_HDUTIL}"
    ls -la "${SUBLIMENAME_4_HDUTIL}"
    wait
    sudo hdiutil attach "${SUBLIMENAME_4_HDUTIL}"
    wait
    sudo cp -R /Volumes/Sublime\ Merge/Sublime\ Merge.app /Applications/
    wait
    sudo hdiutil detach /Volumes/Sublime\ Merge
    wait
} # end _darwin__64

_ubuntu__64() {
   local CODENAME=$(_version "linux" "amd64.deb")
   local TARGET_URL="https://download.sublimetext.com/${CODENAME}"
   file_exists_with_spaces $USER_HOME/Downloads
   cd $USER_HOME/Downloads
   _download "${TARGET_URL}"
   file_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}"
    wait
    echo "installing "
    sudo dpkg -i ${SUBLIMENAME}
    wait
} # end _ubuntu__64

_ubuntu__32() {
   local CODENAME=$(_version "linux" "i386.deb")
   local TARGET_URL="https://download.sublimetext.com/${CODENAME}"
   file_exists_with_spaces $USER_HOME/Downloads
   cd $USER_HOME/Downloads
   _download "${TARGET_URL}"
   file_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}"

   sudo dpkg -i ${SUBLIMENAME}
   wait
} # end _ubuntu__32


_fedora__32() {
  # local CODENAME="sublime-merge_build-${VERSION}.i386.rpm"
  local CODENAME=$(_version "linux" "i386.rpm")
  local TARGET_URL="https://download.sublimetext.com/${CODENAME}"
  file_exists_with_spaces $USER_HOME/Downloads
  cd $USER_HOME/Downloads
  _download "${TARGET_URL}"
  file_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}"
  ensure rpm or "Canceling Install. Could not find rpm command to execute install"

  _try "rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg"

  # provide error handling , once learned goes here. LEarn under if, once learned here.
  # Start loop while ERROR flag in case needs to try again, based on error

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
  echo "fedora 64"
  # https://download.sublimetext.com/sublime-merge-1118-1.x86_64.rpm
  # sublime-merge-1118-1.x86_64.rpm
  local CODENAME=$(_version "linux" "x86_64.rpm")
  echo CODENAME: $CODENAME
  local TARGET_URL="https://download.sublimetext.com/${CODENAME}"
  echo TARGET_URL: $TARGET_URL
  file_exists_with_spaces $USER_HOME/Downloads
  cd $USER_HOME/Downloads
  _download "${TARGET_URL}" $USER_HOME/Downloads "${CODENAME}"
  file_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}"
  ensure rpm or "Canceling Install. Could not find rpm command to execute install"

  _try "rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg"

  # provide error handling , once learned goes here. LEarn under if, once learned here.
  # Start loop while ERROR flag in case needs to try again, based on error


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
    local CODENAME=$(_version "win" "exe")
    local TARGET_URL="https://download.sublimetext.com/${CODENAME}"
    wait
    cd $HOMEDIR
    cd Downloads
    curl -O https://download.sublimetext.com/${SUBLIMENAME}
    ${SUBLIMENAME}
    wait
} # end install_windows_lastest_sublime_64

_mingw__32() {
    local CODENAME=$(_version "win" "exe")
    local TARGET_URL="https://download.sublimetext.com/${CODENAME}"
    cd $HOMEDIR
    cd Downloads
	    curl -O https://download.sublimetext.com/${CODENAME}
	    ${CODENAME}
} # end


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo ":)"


