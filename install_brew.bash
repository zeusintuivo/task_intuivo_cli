#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
# 20200415 Compatible with Fedora, Mac, Ubuntu "sudo_up" "load_struct"
set -E -o functrace
export THISSCRIPTCOMPLETEPATH
typeset -r THISSCRIPTCOMPLETEPATH="$(realpath  "$0")" # updated realpath macos 20210902
export BASH_VERSION_NUMBER
typeset BASH_VERSION_NUMBER=$(echo $BASH_VERSION | cut -f1 -d.)

export  THISSCRIPTNAME
typeset -r THISSCRIPTNAME="$(basename "$0")"

export _err
typeset -i _err=0
  function _trap_on_error(){
    echo -e "\\n \033[01;7m*** ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m"
    exit 1
  }
  trap _trap_on_error ERR
  function _trap_on_int(){
    echo -e "\\n \033[01;7m*** INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n  INT ...\033[0m"
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
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
    local provider="$HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    local _err=0 structsource
    if [   -e "${provider}"  ] ; then
      echo "Loading locally"
      structsource="""$(<"${provider}")"""
      _err=$?
      [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. running 'source locally' returned error did not download or is empty err:$_err  \n \n  " && exit 1
    else
      if ( command -v curl >/dev/null 2>&1; )  ; then
        echo "Loading struct_testing from the net using curl "
        structsource="""$(curl https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing  -so -   2>/dev/null )"""  #  2>/dev/null suppress only curl download messages, but keep curl output for variable
        _err=$?
        [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. running 'curl' returned error did not download or is empty err:$_err  \n \n  " && exit 1
      elif ( command -v wget >/dev/null 2>&1; ) ; then
        echo "Loading struct_testing from the net using wget "
        structsource="""$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing -O -   2>/dev/null )"""  #  2>/dev/null suppress only wget download messages, but keep wget output for variable
        _err=$?
        [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. running 'wget' returned error did not download or is empty err:$_err  \n \n  " && exit 1
      else
        echo -e "\n \n  ERROR! Loading struct_testing could not find wget or curl to download  \n \n "
        exit 69
      fi
    fi
    [[ -z "${structsource}" ]] && echo -e "\n \n  ERROR! Loading struct_testing. structsource did not download or is empty " && exit 1
    local _temp_dir="$(mktemp -d 2>/dev/null || mktemp -d -t 'struct_testing_source')"
    echo "${structsource}">"${_temp_dir}/struct_testing"
    echo "Temp location ${_temp_dir}/struct_testing"
    source "${_temp_dir}/struct_testing"
    _err=$?
    [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. Occured while running 'source' err:$_err  \n \n  " && exit 1
    if  ! typeset -f passed >/dev/null 2>&1; then
      echo -e "\n \n  ERROR! Loading struct_testing. Passed was not loaded !!!  \n \n "
      exit 69;
    fi
    return $_err
} # end load_struct_testing
load_struct_testing

 _err=$?
[ $_err -ne 0 ]  && echo -e "\n \n  ERROR FATAL! load_struct_testing_wget !!! returned:<$_err> \n \n  " && exit 69;

export sudo_it
function sudo_it() {
  raise_to_sudo_and_user_home
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
  enforce_variable_with_value SUDO_USER "${SUDO_USER}"
  enforce_variable_with_value SUDO_UID "${SUDO_UID}"
  enforce_variable_with_value SUDO_COMMAND "${SUDO_COMMAND}"
  # Override bigger error trap  with local
  function _trap_on_error(){
    echo -e "\033[01;7m*** TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR INT ...\033[0m"
  }
  trap _trap_on_error ERR INT
} # end sudo_it

# _linux_prepare(){
  sudo_it
  [ $? -gt 0 ] && (failed to sudo_it raise_to_sudo_and_user_home  || exit 1)
  export USER_HOME
  # shellcheck disable=SC2046
  # shellcheck disable=SC2031
  typeset -r USER_HOME="$(echo -n $(bash -c "cd ~${SUDO_USER} && pwd"))"  # Get the caller's of sudo home dir LINUX and MAC
  # USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)   # Get the caller's of sudo home dir LINUX
  enforce_variable_with_value USER_HOME "${USER_HOME}"
# }  # end _linux_prepare


# _linux_prepare

enforce_variable_with_value USER_HOME $USER_HOME
enforce_variable_with_value SUDO_USER $SUDO_USER
passed Caller user identified:$SUDO_USER
passed Home identified:$USER_HOME
directory_exists_with_spaces "$USER_HOME"



 #--------\/\/\/\/-- install_brew.bash -- Custom code -\/\/\/\/-------


#!/bin/bash

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
  [ -s  /home/linuxbrew/.linuxbrew/.linuxbrew ] && unlink /home/linuxbrew/.linuxbrew/.linuxbrew
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
  export USER_HOME="/home/${SUDO_USER}"
  enforce_variable_with_value USER_HOME "${USER_HOME}"
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
} # end _debian_flavor_install
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
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}
_redhat_flavor_install(){
  sudo_it
  export USER_HOME="/home/${SUDO_USER}"
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  install_requirements "linux" "
    # RedHat Flavor only
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
} # end _redhat_flavor_install
_centos__32() {
  echo "CURRENTLY NOT SUPPORTED BY LINUX BREW REF: https://docs.brew.sh/Homebrew-on-Linux#install"
}
_centos__64() {
  _redhat_flavor_install
}
_fedora__32() {
  echo "CURRENTLY NOT SUPPORTED BY LINUX BREW REF: https://docs.brew.sh/Homebrew-on-Linux#install"
}
_fedora__64() {
  _redhat_flavor_install
} # end _fedora__64



 #--------/\/\/\/\-- install_brew.bash -- Custom code-/\/\/\/\-------


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo "🥦"
exit 0
