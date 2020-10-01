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

_get_user_home() {
  # check operation systems
  if [[ "$(uname)" == "Darwin" ]] ; then
    # Do something under Mac OS X platform
    CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
    if [ ${CAN_I_RUN_SUDO} -gt 0 ]; then
      echo -e "\033[01;7m*** Installing as sudo...\033[0m"
    else
      echo "Needs to run as sudo ... ${0}"
      exit 1
    fi
    USER_HOME=$(echo "/Users/$SUDO_USER")
  elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]] ; then
    # Do something under GNU/Linux platform
    execute_as_sudo
    USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
  elif [[ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]] ; then
    # Do something under Windows NT platform
    USER_HOME=$(echo "/Users/$SUDO_USER")
    # nothing here
  fi

} # end _get_user_home

_get_user_home



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


# function _assure_success() {
#   if [ $? != 0 ] ; then
#     echo -e "\033[38;5;1m Something went wrong \033[0m"
#     exit 1
#   fi
#   wait
# }

# function _trap_try_start() {
#   trap _term SIGTERM
# }

# function _trap_catch_check() {
#   declare -i ret=$?
#   local child
#   if [ $ret -gt 0 ] ; then
#   {
#     child=$!
#     wait $child
#     warning "${YELLOW}Error SIGNAL_RETURN(${RED}${ret}${YELLOW}) executing: \n${action}"
#     return 1 # non zero is error
#   }
#   fi
#   return 0
# }

# function _action_runner() {
#   local action
#   while read -r action ; do
#   {
#     if [[ ! -z "${action}" ]] ; then # if not empty
#     {
#       _trap_try_start
#       echo "${action}"
#       "${action}"
#       _trap_catch_check
#     }
#     fi
#   }
#   done <<< "${@}"
# } # end _action_runner

# function _try_runner() {
#   local body=$(_function_body "#{1}")
#   function_exists "${1}"
#   while read -r action ; do
#   {
#     if [[ ! -z "${action}" ]] ; then # if not empty
#     {
#       _trap_try_start
#       echo "${action}"
#       "${action}"
#       _trap_catch_check
#     }
#     fi
#   }
#   done <<< "${body}"
# } # end _try_runner

# function _function_body() {
#   local functionname="${1}"
#   # function_exists "${functionname}"
#   # ensure head or Cancel. Missing head command
#   # ensure tail or Cancel. Missing tail command
#   # ensure declare or Cancel. Missing declare command
#   # ensure wc or Cancel. Missing declare command
#   local functioncomplete=$(declare -f "${functionname}")
#   # echo complete:"${functioncomplete}"
#   local functionbody=$(echo "${functioncomplete}" | cüt "${functionname} ()")
#   # echo body:"${functionbody}"
#   local functionlength=$(echo "${functionbody}" | wc -l)
#   # echo length:${functionlength}
#   # echo less:${functionlengthless}
#   (( functionlength-- ))
#   # echo lenght:${functionlength}
#   functionbody=$(echo "${functionbody}" | head -${functionlength} )
#   # echo body:"${functionbody}"
#   (( functionlength-- ))
#   # echo length:${functionlength}
#   functionbody=$(echo "${functionbody}" | tail -${functionlength} )
#   # echo body:"${functionbody}"
#   echo "${functionbody}"
# }

# function _try() {
#   local body=$(_function_body "#{1}")
#   _trap_try_start
#   "${body}"
#   _trap_catch_check
# }

_darwin__64() {
    local CODENAME="Visual Studio Code%20Text%20Build%20${CODELASTESTBUILD}.dmg"
    cd $USER_HOME/Downloads/
    local URL=""
    _download "${URL}"
    sudo hdiutil attach ${CODENAME}
    sudo cp -R /Volumes/Visual Studio Code\ Text/Visual Studio Code\ Text.app /Applications/
    sudo hdiutil detach /Volumes/Visual Studio Code\ Text
} # end _darwin__64

_ubuntu__64() {
    local CODENAME="studio_code-text_build-${CODELASTESTBUILD}_amd64.deb"
    cd $USER_HOME/Downloads/
    local URL=""
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
} # end _ubuntu__64

_ubuntu__32() {
    local CODENAME="studio_code-text_build-${CODELASTESTBUILD}_i386.deb"
    cd $USER_HOME/Downloads/
    local URL=""
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
} # end _ubuntu__32

_fedora__64() {
  # sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  # sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
  # sudo dnf -y check-update
  # sudo dnf -y install code

  # rpm: https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-31.noarch.rpm
  # get download link
  # https://code.visualstudio.com/docs/?dv=linux64_rpm
  # local DOWNLOAD_DISPLAY_PAGE=$(curl -sSLo -  https://code.visualstudio.com/docs/?dv=linux64_rpm&build=insiders  2>&1;) # suppress only wget download messages, but keep wget output for variable
  # https://vscode-update.azurewebsites.net/latest/linux-rpm-x64/insider
  # https://vscode-update.azurewebsites.net/latest/linux-rpm-x64/stable
  # local DOWNLOAD_DISPLAY_PAGE=$(curl -sSLo -  https://vscode-update.azurewebsites.net/latest/linux-rpm-x64/insider  2>&1;) # suppress only wget download messages, but keep wget output for variable
  local DOWNLOAD_DISPLAY_PAGE=$(curl -sSLo -  https://code.visualstudio.com/updates/  2>&1;) # suppress only wget download messages, but keep wget output for variable


  local LASTEST_VERSION=$(echo "${DOWNLOAD_DISPLAY_PAGE}" | sed s/\</\\n\</g | grep ".strong.Update." | cüt "<strong>Update " | sort -n | tail -n -1)
  local TARGET_URL=$(echo  "${DOWNLOAD_DISPLAY_PAGE}" | sed s/\</\\n\</g | grep "${LASTEST_VERSION}" | grep 'rpm' | cut -d'"' -f2 )
  # local TARGET_URL="https://vscode-update.azurewebsites.net/latest/linux-rpm-x64/insider"
  local ARCHITECTURE=$(uname -m)
  wait
  [[ -z "${LASTEST_VERSION}" ]] && failed "Visual Studio Code Version not found! :${LASTEST_VERSION}:"

  Message "Visual Studio Code Version found LASTEST_VERSION:" "<${LASTEST_VERSION}>"
  Message "Visual Studio Code Version found TARGET_URL:" "<${TARGET_URL}>"

  if [ -z "${LASTEST_VERSION}" ] ; then  # if empty
  {
    failed Could not find Code version
  }
  fi


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
  assert not empty "${ID}"
  assert not empty "${VERSION_ID}"
  assert not empty "${USER_HOME}"
  assert not empty "${LASTEST_VERSION}"
  assert not empty "${ARCHITECTURE}"


  file_exists_with_spaces "${USER_HOME}/Downloads"

  local folder_date=$(date +"%Y%m%d")
  _assure_success
  assert not empty "${folder_date}"
  local download_folder=$(echo  "${USER_HOME}/Downloads/${folder_date}")

  mkdir -p "${download_folder}"
  file_exists_with_spaces "${download_folder}"
  cd "${download_folder}"
  # TODO: Fragile providing name manually
  local NEW_FILENAME="code-${LASTEST_VERSION}-${folder_date}.el7.${ARCHITECTURE}.rpm"
  Message NEW_FILENAME: "${NEW_FILENAME}"

  # Hash compare
  # REF: https://askubuntu.com/questions/685775/bash-get-md5-of-online-file
  ensure curl or "Canceling Install. Could not find curl command to execute install"
  ensure md5sum or "Canceling Install. Could not find md5sum command to execute install"
  ensure cut or "Canceling Install. Could not find cut command to execute install"

  # wget -q -O- http://example.com/your_file | md5sum | sed 's:-$:local_file:' | md5sum -c
  local HASHLOCAL HASHREMOTE="$(curl -sL "${TARGET_URL}" | md5sum | cut -d ' ' -f 1)"
  if it_exists_with_spaces "${download_folder}/${NEW_FILENAME}" ; then
  {
    HASHLOCAL="$(md5sum "${download_folder}/${NEW_FILENAME}" | cut -d ' ' -f 1)"
    if [ "$HASHREMOTE" == "$HASHLOCAL" ]; then
        Message "Already" "downloaded using cached file ${download_folder}/${NEW_FILENAME}"
    fi
  } else {
    Message Downloading
    rm -rf "${download_folder}/${NEW_FILENAME}"
    file_does_not_exist_with_spaces "${download_folder}/${NEW_FILENAME}"
    _download "${TARGET_URL}" "${download_folder}/" "${NEW_FILENAME}"

  }
  fi



  _trap_try_start
  local CODENAME=$(ls -1 "${download_folder}" | tail -1)
  _trap_catch_check
  assert not empty "${CODENAME}"

  Message Downloaded filename: "${CODENAME}"
  Showing ls -1 "${download_folder}"
  file_exists_with_spaces "${download_folder}/${CODENAME}"
  local MAJOR MINOR MICRO BUILD ONE_VERSION_BEFORE NEW_FILENAME

  ensure dnf or "Canceling Install. Could not find dnf command to execute install"
    IFS=. read MAJOR MINOR MICRO <<EOF
${LASTEST_VERSION##*-}
EOF
  if (( MICRO > 0 )) ; then
  {
    (( MICRO-- ))
  }
  else
  {
    MICRO=9
    (( MINOR-- ))
  }
  fi
  ONE_VERSION_BEFORE=${MAJOR}.${MINOR}.${MICRO}
  OLD_FILENAME=$(echo "${NEW_FILENAME}" | sed s/$LASTEST_VERSION/$ONE_VERSION_BEFORE/g)
  Message OLD_FILENAME: "${OLD_FILENAME}"
  ensure cüt or "Canceling Install. Could not find cüt command to execute install"
  local OLD_PACKAGE=$(echo $OLD_FILENAME | cüt '.rpm')
  Message dnf -y remove "${OLD_PACKAGE}"
  _trap_try_start # _trap_catch_check
  local msg=$(dnf -y remove "${OLD_PACKAGE}")
  _trap_catch_check
  Message "${msg}"


  ensure rpm or "Canceling Install. Could not find rpm command to execute install"
  Message rpm -ivh "${download_folder}/${CODENAME}"
  _trap_try_start # _trap_catch_check
  msg=$(rpm -ivh "${download_folder}/${CODENAME}")
  _trap_catch_check
  Message "${msg}"
}

_mingw__64() {
    local CODENAME="Visual Studio Code%20Text%20Build%20${CODELASTESTBUILD}%20x64%20Setup.exe"
    cd $HOMEDIR
    cd Downloads
    curl -O https://download.studio_codetext.com/${CODENAME}
    ${CODENAME}
} # end _mingw__64

_mingw__32() {
    local CODENAME="Visual Studio Code%20Text%20Build%20${CODELASTESTBUILD}%20Setup.exe"
    cd $HOMEDIR
    cd Downloads
    curl -O https://download.studio_codetext.com/${CODENAME}
    ${CODENAME}
} # end


# function_exists _fedora__64

# ensure ls or "Cancel Export" ensure tests for command line executables, not "functions" in especific, but true if the funtion is available in command line

            if ! command -v _fedora__64 >/dev/null 2>&1;  then # Command Does not-exist
                echo "Command Does not-exist "
            else
                echo "Command exists"
            fi
# function_exists ls

# build_table_from_installed_components $USER
# build_table_from_installed_components $SUDO_USER

_main() {
  determine_os_and_fire_action
} # end _main

_main

echo ":)"


