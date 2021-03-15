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
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home
  enforce_variable_with_value USER_HOME "${USER_HOME}"
} # end sudo_it

_make_linuxbrewfolder(){
  mkdir /home/linuxbrew
  directory_exists_with_spaces /home/linuxbrew
  mkdir /home/linuxbrew/.linuxbrew/
  directory_exists_with_spaces /home/linuxbrew/.linuxbrew/
  chmod -R "${SUDO_USER}" /home/linuxbrew
  chgrp -R "${SUDO_USER}" /home/linuxbrew
}

_eval_linuxbrew(){
  # test -d "${USER_HOME}/.linuxbrew" && eval $("${USER_HOME}/.linuxbrew/bin/brew shellenv")
  test -d "/home/linuxbrew/.linuxbrew" && eval $("/home/linuxbrew/.linuxbrew/bin/brew shellenv")  
}

_add_to_file(){
  if test -r "${USER_HOME}/${1}" ; then
  {
    #                   filename            value      || do this .............
    (_if_not_contains  "${USER_HOME}/${1}" "# RBENV" ) || echo "# RBENV " >>"${USER_HOME}/${1}"
    (_if_not_contains  "${USER_HOME}/${1}" "/bin/brew shellenv" ) || echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>"${USER_HOME}/${1}"
  }
  fi
}
_clone_linuxbrew(){
  git clone https://github.com/Homebrew/brew "/home/linuxbrew/.linuxbrew/Homebrew"
  cd "${USER_HOME}" 
  ln -s /home/linuxbrew/.linuxbrew .linuxbrew 
  softlink_exists "${USER_HOME}/.linuxbrew>/home/linuxbrew/.linuxbrew"  
  mkdir "${USER_HOME}/.linuxbrew/bin"
  directory_exists_with_spaces "${USER_HOME}/.linuxbrew/bin"
  ln -s "${USER_HOME}/.linuxbrew/Homebrew/bin/brew" "${USER_HOME}/.linuxbrew/bin"
  file_exists_with_spaces "${USER_HOME}/.linuxbrew/bin/brew"
  eval $("${USER_HOME}/.linuxbrew/bin/brew" shellenv)
}
_debian_flavor_install(){
  sudo_it
  install_requirements "linux" "
    # Debian Ubuntu only
    build-essential 
    curl 
    file 
    git
  "
  verify_is_installed "
    curl 
    file 
    git
  "
  
  _make_linuxbrewfolder
  _clone_linuxbrew
  _eval_linuxbrew
  _add_to_file .profile 

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
    curl 
    file 
    git
    # needed by Fedora 30 and up
    libxcrypt-compat 
  "
  verify_is_installed "
    curl 
    file 
    git
  "
  dnf groupinstall 'Development Tools'
  dnf install libxcrypt-compat # needed by Fedora 30 and up

  _make_linuxbrewfolder
  _clone_linuxbrew
  _eval_linuxbrew
  _add_to_file .bash_profile 
  
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
