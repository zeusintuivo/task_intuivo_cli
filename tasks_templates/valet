#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
# Compatible start with low version bash
export THISSCRIPTCOMPLETEPATH
typeset -r THISSCRIPTCOMPLETEPATH="$(realpath $(which $(basename "$0")))"   # § This goes in the FATHER-MOTHER script

export BASH_VERSION_NUMBER
typeset BASH_VERSION_NUMBER=$(echo $BASH_VERSION | cut -f1 -d.)

export  THISSCRIPTNAME
typeset -r THISSCRIPTNAME="$(realpath $(which $(basename "$0")))"

export _err
typeset -i _err=0

load_struct_testing_wget(){
    local provider="$HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    [   -e "${provider}"  ] && source "${provider}" && echo "Loaded locally"
    [ ! -e "${provider}"  ] && eval """$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing -O -  2>/dev/null )"""   # suppress only wget download messages, but keep wget output for variable
    ( ( ! command -v passed >/dev/null 2>&1; ) && echo -e "\n \n  ERROR! Loading struct_testing \n \n " && exit 69; )
} # end load_struct_testing_wget
load_struct_testing_wget

export sudo_it
function sudo_it() {
  raise_to_sudo_and_user_home
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  function _trap_on_error(){
    echo -e "\033[01;7m*** TRAP $THISSCRIPTNAME $BASHLINENO ERR INT ...\033[0m"

  }
  trap _trap_on_error ERR INT
} # end sudo_it



_debian_flavor_install(){
  sudo_it
  install_requirements "linux" "
    # Debian Ubuntu only
    network-manager
    libnss3-tools
    jq
    xsel
  "
  verify_is_installed "
    network-manager
    libnss3-tools
    jq
    xsel
    composer
    php
  "
    PHPS=$(which php)
  COMPOSERS=$(which composer)

  su - "$SUDO_USER" -c ''"$PHPS"''"$COMPOSERS"' global update'
  su - "$SUDO_USER" -c ''"$PHPS"''"$COMPOSERS"' global require cpriego/valet-linux'
  return 0
}
_debian__32() {
  echo "CURRENTLY NOT SUPPORTED BY LINUX BREW REF: https://docs.brew.sh/Homebrew-on-Linux#install"
}
_debian__64() {
  _debian_flavor_install
}
_ubuntu__32() {
  echo "CURRENTLY NOT SUPPORTED BY LINUX BREW REF: https://docs.brew.sh/Homebrew-on-Linux#install"
}
_ubuntu__64() {
  _debian_flavor_install
}
_darwin__32() {
  echo "CURRENTLY NOT SUPPORTED BY LINUX BREW REF: https://docs.brew.sh/Homebrew-on-Linux#install"
}
_darwin__64() {
  sudo_it
  echo "MORE TODO - Install not implemented"
}
_readhat_flavor_install(){
  sudo_it
  install_requirements "linux" "
    # ReadHat Flavor only
    nss-tools
    jq
    xsel
  "
  verify_is_installed "
    nss-tools
    jq
    xsel
    composer
    php
  "
  setenforce 0
  echo "Permanent:

    Open /etc/selinux/config
    Change SELINUX=enforcing to SELINUX=permissive"

  PHPS=$(which php)
  COMPOSERS=$(which composer)

  su - "$SUDO_USER" -c ''"$PHPS"''"$COMPOSERS"' global update'
  su - "$SUDO_USER" -c ''"$PHPS"''"$COMPOSERS"' global require cpriego/valet-linux'
  return 0
}
_centos__32() {
  echo "CURRENTLY NOT SUPPORTED BY LINUX BREW REF: https://docs.brew.sh/Homebrew-on-Linux#install"
}
_centos__64() {
  _readhat_flavor_install
}
_fedora__32() {
  echo "CURRENTLY NOT SUPPORTED BY LINUX BREW REF: https://docs.brew.sh/Homebrew-on-Linux#install"
}
_fedora__64() {
  _readhat_flavor_install
} # end _fedora__64
_main() {
  determine_os_and_fire_action
} # end _main

_main

echo ":)"
