#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
# Compatible start with low version bash
export USER_HOME
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
  enforce_variable_with_value SUDO_USER "${SUDO_USER}"
  enforce_variable_with_value SUDO_UID "${SUDO_UID}"
  enforce_variable_with_value SUDO_COMMAND "${SUDO_COMMAND}"
  # Override bigger error trap  with local
  function _trap_on_error(){
    echo -e "\033[01;7m*** TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}\(\) \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}\(\) \\n ERR INT ...\033[0m"

  }
  trap _trap_on_error ERR INT
} # end sudo_it

_make_linuxbrewfolder(){
  if it_exists /home/linuxbrew ; then
  {
    rm -rf /home/linuxbrew
  }
  fi
  directory_does_not_exist /home/linuxbrew
  mkdir /home/linuxbrew
  directory_exists_with_spaces /home/linuxbrew
  mkdir /home/linuxbrew/.linuxbrew/
  directory_exists_with_spaces /home/linuxbrew/.linuxbrew/
  chown -R "${SUDO_USER}" /home/linuxbrew
  chgrp -R "${SUDO_USER}" /home/linuxbrew
}
_eval_linuxbrew(){
  # test -d "${USER_HOME}/.linuxbrew" && eval $("${USER_HOME}/.linuxbrew/bin/brew" shellenv)
  test -d "/home/linuxbrew/.linuxbrew" && eval $("/home/linuxbrew/.linuxbrew/bin/brew" shellenv)
}
_add_to_file(){
  if test -r "${USER_HOME}/${1}" ; then
  {
    #                   filename            value      || do this .............
    (_if_not_contains  "${USER_HOME}/${1}" "# BREW - HOMEBREW" ) || echo "# BREW - HOMEBREW " >>"${USER_HOME}/${1}"
    (_if_not_contains  "${USER_HOME}/${1}" "/bin/brew shellenv" ) || echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>"${USER_HOME}/${1}"
  }
  fi
}
_clone_linuxbrew(){
  git clone https://github.com/Homebrew/brew "/home/linuxbrew/.linuxbrew/Homebrew"
  chown -R "${SUDO_USER}" /home/linuxbrew
  chgrp -R "${SUDO_USER}" /home/linuxbrew
}
_softlink_it(){
  file_does_not_exist_with_spaces "/home/linuxbrew/.linuxbrew/.linuxbrew"
  mkdir "/home/linuxbrew/.linuxbrew/bin"
  ln -s "/home/linuxbrew/.linuxbrew/Homebrew/bin/brew" "/home/linuxbrew/.linuxbrew/bin"
  softlink_exists "/home/linuxbrew/.linuxbrew/bin/brew>/home/linuxbrew/.linuxbrew/Homebrew/bin/brew"
  chown -R "${SUDO_USER}" "/home/linuxbrew/.linuxbrew"
  chgrp -R "${SUDO_USER}" "/home/linuxbrew/.linuxbrew"
}
_softlink_user_it(){
  cd "${USER_HOME}"
  if it_exists "${USER_HOME}/.linuxbrew" ; then
    if softlink_exists "${USER_HOME}/.linuxbrew>/home/linuxbrew/.linuxbrew" ; then
      unlink  "${USER_HOME}/.linuxbrew"
    else
      rm -rf .linuxbrew
    fi
  fi
  Message Make sure we did not delete the install
  directory_exists_with_spaces "/home/linuxbrew/.linuxbrew"
  ln -s "/home/linuxbrew/.linuxbrew" "${USER_HOME}/.linuxbrew"
  Message Make sure we did overlap current folders
  softlink_exists "${USER_HOME}/.linuxbrew>/home/linuxbrew/.linuxbrew"
  file_does_not_exist_with_spaces "/home/linuxbrew/.linuxbrew/.linuxbrew"
  directory_does_not_exist_with_spaces "/home/linuxbrew/.linuxbrew/.linuxbrew"
  file_does_not_exist_with_spaces "${USER_HOME}/.linuxbrew/.linuxbrew"
  directory_does_not_exist_with_spaces "${USER_HOME}/.linuxbrew/.linuxbrew"
  chown -R "${SUDO_USER}" "${USER_HOME}/.linuxbrew"
  chgrp -R "${SUDO_USER}" "${USER_HOME}/.linuxbrew"
}

  # directory_exists_with_spaces "/home/linuxbrew/.linuxbrew"
  # file_does_not_exists_with_spaces "${USER_HOME}/.linuxbrew"
  # ln -s /home/linuxbrew/.linuxbrew .linuxbrew
  # softlink_exists "${USER_HOME}/.linuxbrew>/home/linuxbrew/.linuxbrew"
  # [ $? -gt 0 ] && failed install $BASHLINENO brew  && exit 1
  # file_does_not_exist_with_spaces "/home/linuxbrew/.linuxbrew/.linuxbrew"
  # [ $? -gt 0 ] && failed install $BASHLINENO brew  && exit 1

  # mkdir "${USER_HOME}/.linuxbrew/bin"
  # [ $? -gt 0 ] && failed install $BASHLINENO brew  && exit 1
  # directory_exists_with_spaces "${USER_HOME}/.linuxbrew/bin"
  # [ $? -gt 0 ] && failed install $BASHLINENO brew  && exit 1
  # ln -s "${USER_HOME}/.linuxbrew/Homebrew/bin/brew" "${USER_HOME}/.linuxbrew/bin"
  # [ $? -gt 0 ] && failed install $BASHLINENO brew  && exit 1
  # file_exists_with_spaces "${USER_HOME}/.linuxbrew/bin/brew"
  # [ $? -gt 0 ] && failed install $BASHLINENO brew  && exit 1
  # eval $("${USER_HOME}/.linuxbrew/bin/brew" shellenv)
  # [ $? -gt 0 ] && failed install $BASHLINENO brew  && exit 1


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
  _softlink_it
  _softlink_user_it
  _eval_linuxbrew
  _add_to_file .profile
  _add_to_file .zshrc
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
  export USER_HOME="/home/${SUDO_USER}"
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  install_requirements "linux" "
    # ReadHat Flavor only
    curl
    file
    git
    # needed by Fedora 30 and up
    libxcrypt-compat
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
  }
  fi
  # dnf install libxcrypt-compat -y # needed by Fedora 30 and up
  verify_is_installed "
    curl
    file
    git
    pip3
    pygmentize
    xclip
    tree
    ag
    ack
    pv
    nano
    vim
  "

  _make_linuxbrewfolder
  _clone_linuxbrew
  _softlink_it
  _softlink_user_it
  _eval_linuxbrew
  _add_to_file .bash_profile
  _add_to_file .zshrc
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
