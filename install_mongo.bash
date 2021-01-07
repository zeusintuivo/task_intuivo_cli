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



_version() {
  # echo "3.4"
  echo "mongodb-osx-ssl-x86_64-3.4.23"
}

_darwin__64() {
  # REF: https://docs.mongodb.com/v3.4/tutorial/install-mongodb-on-os-x/
  # ensure brew or "Canceling until brew is installed"
  # local VERSION="3.4"
  # _try "brew tap mongodb/brew"
  # _try "brew install mongodb-community@${VERSION}"

  # file_does_not_exist_with_spaces "/usr/local/etc/mongod.conf"
  # file_does_not_exist_with_spaces "/usr/local/var/log/mongodb"
  # file_does_not_exist_with_spaces "/usr/local/var/mongodb"

  # _try "brew services start mongodb-community@${VERSION}"

  # Final make it a permant service
  # mongod --config /usr/local/etc/mongod.conf --fork

  # ps aux | grep -v grep | grep mongod
  # ensure mongod or "Failed to install mongo"

  local CODENAME=$(_version "mac" "x86_64")
  local VERSION="3.4"

  echo CODENAME: $CODENAME
  # https://fastdl.mongodb.org/osx/mongodb-osx-ssl-x86_64-3.4.23.tgz
  local TARGET_URL="https://fastdl.mongodb.org/osx/${CODENAME}.tgz"
  echo TARGET_URL: $TARGET_URL
  cd $USER_HOME/Downloads
  _download $TARGET_URL
  wait
  file_exists_with_spaces "${CODENAME}.tgz"
  tar -zxvf "${CODENAME}.tgz"
  local FOLDERNAME=$(echo "${CODENAME}" | cüt '-ssl')
  file_exists_with_spaces "${FOLDERNAME}"
  mkdir -p mongodb${VERSION}
  sudo cp -R "${FOLDERNAME}/" mongodb${VERSION}
  file_exists_with_spaces "mongodb${VERSION}"
  file_exists_with_spaces "mongodb${VERSION}/bin"
  file_exists_with_spaces "mongodb${VERSION}/bin/mongod"
  rm -rf "${FOLDERNAME}"
  file_does_not_exist_with_spaces "${FOLDERNAME}"
  cd "mongodb${VERSION}"
  local INSTALLDIR=$(pwd)
  echo "# Mongo ${VERSION}" >> $USER_HOME/.bashrc
  echo "# Mongo ${VERSION}" >> $USER_HOME/.zshrc
  echo "export PATH=${INSTALLDIR}/bin:\$PATH" >> $USER_HOME/.bashrc
  echo "export PATH=${INSTALLDIR}/bin:\$PATH" >> $USER_HOME/.zshrc

  # NOTE Starting with macOS 10.15 Catalina, Apple restricts
  # access to the MongoDB default data directory of /data/db.
  # On macOS 10.15 Catalina, you must use a different data directory,
  # such as /usr/local/var/mongodb.
  sudo mkdir -p /usr/local/var/mongodb
  file_exists_with_spaces /usr/local/var/mongodb
  sudo mkdir -p /usr/local/var/log/mongodb
  file_exists_with_spaces /usr/local/var/log/mongodb
  sudo chown $SUDO_USER /usr/local/var/mongodb
  sudo chown $SUDO_USER /usr/local/var/log/mongodb
  echo "alias mongo_run=mongod --dbpath /usr/local/var/mongodb --logpath /usr/local/var/log/mongodb/mongo.log --fork"  >> $USER_HOME/.bashrc
  echo "alias mongo_check=ps aux | grep -v grep | grep mongod" >> $USER_HOME/.bashrc
  echo "alias mongo_run=mongod --dbpath /usr/local/var/mongodb --logpath /usr/local/var/log/mongodb/mongo.log --fork"  >> $USER_HOME/.zshrc
  echo "alias mongo_check=ps aux | grep -v grep | grep mongod" >> $USER_HOME/.zshrc
  cd ..
  rm -f "${CODENAME}.tgz"
  file_does_not_exist_with_spaces "${CODENAME}.tgz"
} # end _darwin__64

_ubuntu__64() {
  echo "Need to implement"
} # end _ubuntu__64

_ubuntu__32() {
  echo "Need to implement"

} # end _ubuntu__32


_fedora__32() {
  echo "Need to implement"

} # end _fedora__32


_centos__64() {
  _fedora__64
} # end _centos__64

_fedora__64() {
  echo "Need to implement"

} # end _fedora__64

_mingw__64() {
  echo "Need to implement"

} # end install_windows_lastest_sublime_64

_mingw__32() {
  echo "Need to implement"

} # end


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo ":)"


