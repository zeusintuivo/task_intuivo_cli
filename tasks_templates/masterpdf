#!/usr/bin/env bash
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

enforce_variable_with_value SUDO_USER "${SUDO_USER}"
passed Caller user identified:$SUDO_USER
enforce_variable_with_value USER_HOME "${USER_HOME}"
passed Home identified:$USER_HOME
directory_exists_with_spaces "$USER_HOME"


# https://code.visualstudio.com/docs/?dv=linux64_rpm
get_lastest_studio_code_version() {
    local WEBPAGE_TO_READ_VERSION_NUMBER=$(curl -sSLo -  https://code.visualstudio.com/docs/?dv=linux32_deb&build=insiders  2>&1;) # suppress only wget download messages, but keep wget output for variable
    echo "${WEBPAGE_TO_READ_VERSION_NUMBER}" | grep 'facebook'  | head -3
    local VERSION_NUMBER=$(echo "${VERSION_NUMBER}" | grep 'direct download link ....' )
    wait
	    [[ -z "${VERSION_NUMBER}" ]] && failed "Master PDF Editor Version not found! :${VERSION_NUMBER}:"
    echo "${VERSION_NUMBER}"
    if [ -z "${VERSION_NUMBER}" ] ; then  # if empty
    {
      failed Could not find Code version
    }
    fi

} # end get_lastest_studio_code_version

_download_just_download() {
  #  url  https://code-industry.net/public/master-pdf-editor-3133_amd64.deb
  _trap_try_start
  local target_url="${1}"
  if [ -z "${target_url}" ] ; then  # if empty
  {
    failed Could not load target_url string or it was empty
  }
  fi
  _trap_catch_check
  # wget --directory-prefix="${USER_HOME}/Downloads/" --quiet --no-check-certificate "${target_url}" 2>/dev/null
  echo -e "\033[01;7m*** Downloading file to temp location...\033[0m"
  if ( command -v wget >/dev/null 2>&1; ) ; then
    # # REF: about :> http://unix.stackexchange.com/questions/37507/what-does-do-here
    _trap_try_start
    :> wgetrc   # here :> equals to Equivalent to the following: cat /dev/null > wgetrc which Nulls out the file called "wgetrc" in the current directory. As in creates an empty file "wgetrc" if one doesn't exist or overwrites one with nothing if it does.
    _trap_catch_check
    file_exists_with_spaces wgetrc
    _trap_try_start
    echo "noclobber=off" >> wgetrc
    _trap_catch_check
    echo "dir_prefix=." >> wgetrc
    echo "dirstruct=off" >> wgetrc
    echo "verbose=off" >> wgetrc    # NOTE Can't be verbose and quiet at the same time.--quiet
    echo "progress=bar:default" >> wgetrc
    echo "tries=3" >> wgetrc
    # _trap_try_start # _trap_catch_check
    # WGETRC=wgetrc wget --directory-prefix="${USER_HOME}/Downloads/" --quiet --no-check-certificate "${target_url}" 2>/dev/null
    #  _trap_catch_check
    # WGETRC=wgetrc wget --quiet --no-check-certificate "${target_url}" 2>/dev/null   # suppress only wget download messages, but keep wget output for variable
    _try "WGETRC=wgetrc wget --directory-prefix=\"${USER_HOME}/Downloads/\" --quiet --no-check-certificate \"${target_url}\"" # 2>/dev/null"
    echo -e "\033[7m*** Download Wget executed completed.\033[0m"
    rm -f wgetrc
    file_does_not_exist_with_spaces wgetrc
  elif ( command -v curl >/dev/null 2>&1; ); then
    curl -O "${target_url}" 2>/dev/null   # suppress only wget download messages, but keep wget output for variable
    _assure_success
  else
    failed "I cannot find wget or curl programs to perform a download action! ${target_url}"
  fi
}

_darwin__64() {
    local CODENAME="MasterPDFEditor.dmg"
    local URL="https://code-industry.net/public/"
    cd $USER_HOME/Downloads/
    _download "${URL}"
    sudo hdiutil attach ${CODENAME}
    sudo cp -R /Volumes/Master\ PDF\ Editor/Master\ PDF\ Editor.app /Applications/
    sudo hdiutil detach /Volumes/Master\ PDF\ Editor
} # end _darwin__64

_ubuntu__64() {
    local CODENAME="master-pdf-editor-${VERSION_NUMBER}-qt5.amd64.deb"
    local URL="https://code-industry.net/public/"
    cd $USER_HOME/Downloads/
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
} # end _ubuntu__64

_ubuntu__32() {
    local CODENAME="master-pdf-editor-${VERSION_NUMBER}.i386.deb"
    local URL="https://code-industry.net/public/"
    cd $USER_HOME/Downloads/
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
} # end _ubuntu__32

_centos__64() {
  _fedora__64
} # end _centos__64

_fedora__64() {
   # https://code-industry.net/public/master-pdf-editor-5.4.38-qt5.x86_64.rpm
  # get download link
  # https://code.visualstudio.com/docs/?dv=linux64_rpm
    local WEBPAGE_TO_READ_VERSION_NUMBER=$(curl -sSLo -  https://code-industry.net/get-masterpdfeditor/  2>&1;) # suppress only wget download messages, but keep wget output for variable
    local VERSION_NUMBER=$(echo $WEBPAGE_TO_READ_VERSION_NUMBER | sed s/\</\\n\</g | grep "now available for Linux" | sed s/\>/\>\\n/g | sed s/\ /\\n/g | head -3 | tail -1)
    local ARCHITECTURE=$(uname -m)
    enforce_variable_with_value ARCHITECTURE "${ARCHITECTURE}"
    wait
    [[ -z "${VERSION_NUMBER}" ]] && failed "Master PDF Version not found! :${VERSION_NUMBER}:"

    local WEBPAGE_TO_GET_DOWNLOAD_FILE=$(curl -sSLo -  https://code-industry.net/free-pdf-editor/\#get  2>&1;)
    local LASTEST_DOWNLOAD_FILE=$(echo $WEBPAGE_TO_GET_DOWNLOAD_FILE | sed s/\</\\n\</g | grep --color=none -E "${CODELASTESTBUILD}.*${ARCHITECTURE}.*.rpm" | cut -d'>' -f2 | tail -1)

    passed "Master PDF Version :${VERSION_NUMBER}:"
    [[ -z "${LASTEST_DOWNLOAD_FILE}" ]] && failed "Master PDF Version Dowload File NOT found! :${LASTEST_DOWNLOAD_FILE}:"
    passed "Master PDF Version Download File :${LASTEST_DOWNLOAD_FILE}:"
    local TARGET_URL=$(echo $WEBPAGE_TO_GET_DOWNLOAD_FILE | sed s/\</\\n\</g | grep --color=none -E "${CODELASTESTBUILD}.*${ARCHITECTURE}.*.rpm" | sed s/\ /\\n\</g | grep http | cut -d'"' -f2 | tail -1)
    [[ -z "${TARGET_URL}" ]] && failed "Master PDF Version Target URL NOT found! :${Target URL}:"
    passed "Master PDF Version Target URL :${TARGET_URL}:"

  # get download link
  local ID
  local VERSION
  local VERSION_ID
  file_exists_with_spaces "/etc/os-release"
  _assure_success

  source /etc/os-release
  # $ echo $ID
  # fedora
  # $ echo $VERSION_ID
  # 17
  # $ echo $VERSION
  # 17 (Beefy Miracle)
  enforce_variable_with_value ID "${ID}"
  enforce_variable_with_value VERSION_ID "${VERSION_ID}"
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  enforce_variable_with_value VERSION_NUMBER "${VERSION_NUMBER}"
  local TARGET_DOWNLOAD_PATH="$USER_HOME/Downloads/${LASTEST_DOWNLOAD_FILE}"
  function download_part() {
    if  it_exists_with_spaces "${TARGET_DOWNLOAD_PATH}" ; then
    {
      file_exists_with_spaces "${TARGET_DOWNLOAD_PATH}"
    }
    else
    {
      file_exists_with_spaces $USER_HOME/Downloads
      cd $USER_HOME/Downloads
      _download "${TARGET_URL}" $USER_HOME/Downloads  ${LASTEST_DOWNLOAD_FILE}
      file_exists_with_spaces "${TARGET_DOWNLOAD_PATH}"
    }
    fi
    } # end download_part
  download_part

  function install_rpm_part() {
    if  it_exists_with_spaces "${TARGET_DOWNLOAD_PATH}" ; then
    {
      echo Attempting to install "${TARGET_DOWNLOAD_PATH}"
    } else {
      return
    }
    fi
    ensure rpm or "Canceling Install. Could not find rpm command to execute install"
    _trap_try_start # _trap_catch_check
    local msg=$(rpm -ivh "${TARGET_DOWNLOAD_PATH}")
    _trap_catch_check
    echo "${msg}"
    if [[ "${msg}" == *"not an rpm package"* ]] ; then
    {
      download_part
      install_rpm_part
    }
    elif [[ "${msg}" == *"Failed dependencies"* ]] && [[ "${msg}" == *"is needed"* ]] ; then
    {

      echo "Suggested Fix "
      echo "# when error error: Failed dependencies:
            #	     libQt5Svg.so.5()(64bit) is needed by master-pdf-editor-5.4.38-1.x86_64
            # then correct with
            # fix with
            # then fix with
            # sudo dnf -y install qt5-devel qt-creator qt5-qtbase qt5-qtbase-devel
            # rpm again"
      failed "ERROR MSG:\n ${msg}"
    }
    else
    {
      passed "Seems there were no errors"
    }
    fi

    rm -f "${TARGET_DOWNLOAD_PATH}"
  } # end install_rpm_part
  install_rpm_part

}

_mingw__64() {
    local CODENAME="MasterPDFEditor-setup.exe"
    cd $HOMEDIR
	    cd Downloads
    curl -O https://code-industry.net/public/${CODENAME}
    ${CODENAME}
} # end _mingw__64

_mingw__32() {
    local CODENAME="MasterPDFEditor-setup.exe"
    cd $HOMEDIR
    cd Downloads
	    curl -O https://code-industry.net/public/${CODENAME}
	    ${CODENAME}
} # end

_main() {
  determine_os_and_fire_action
} # end _main

_main

echo ":)"


