#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
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
      (( DEBUG )) && echo "$0 0tasks_base/load_struct_testing Loading locally"
      structsource="""$(<"${provider}")"""
      _err=$?
      [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. running 'source locally' returned error did not download or is empty err:$_err  \n \n  " && exit 1
    else
      if ( command -v curl >/dev/null 2>&1; )  ; then
        (( DEBUG )) && echo "$0 0tasks_base/load_struct_testing curl Loading struct_testing from the net using curl "
        structsource="""$(curl https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing  -so -   2>/dev/null )"""  #  2>/dev/null suppress only curl download messages, but keep curl output for variable
        _err=$?
        [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. running 'curl' returned error did not download or is empty err:$_err  \n \n  " && exit 1
      elif ( command -v wget >/dev/null 2>&1; ) ; then
        (( DEBUG )) && echo "$0 0tasks_base/load_struct_testing wget Loading struct_testing from the net using wget "
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
    (( DEBUG )) && echo "$0 0tasks_base/load_struct_testing  Temp location ${_temp_dir}/struct_testing"
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



 #---------/\/\/\-- 0tasks_base/load_struct_testing -------------/\/\/\--------





 #--------\/\/\/\/-- 1tasks_templates/fedora37_preferences …install_fedora37_preferences.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/bash

_debian_flavor_install() {
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  if (
  install_requirements "linux" "
    base64
    unzip
    curl
    wget
    ufw
    nginx
		arandr
  "
  ); then
    {
      apt install base64 -y
      apt install unzip -y
      apt install nginx -y
    }
  fi
  verify_is_installed "
    unzip
    curl
    wget
    tar
    ufw
    nginx
  "
  local PB_VERSION=0.16.7
  local CODENAME="pocketbase_${PB_VERSION}_linux_amd64.zip"
  local TARGET_URL="https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/${CODENAME}"
  local DOWNLOADFOLDER="$(_find_downloads_folder)"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  directory_exists_with_spaces "${DOWNLOADFOLDER}"
  cd "${DOWNLOADFOLDER}"
  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
  # unzip "${DOWNLOADFOLDER}/${CODENAME}" -d $HOME/pb/
  local UNZIPDIR="${USER_HOME}/_/software"
  mkdir -p "${UNZIPDIR}"
  _unzip "${DOWNLOADFOLDER}" "${UNZIPDIR}" "${CODENAME}"
  local PATHTOPOCKETBASE="${UNZIPDIR}/pocketbase"
  local THISIP=$(myip)

} # end _debian_flavor_install

_redhat_flavor_install() {
  # enforce_variable_with_value USER_HOME "${USER_HOME}"
  local -i _err
  sudo updatedb &
  sudo dnf update -y
  sudo dnf build-dep zsh -y
  sudo dnf install zsh -y
  sudo dnf build-dep vim-enhanced -y
  sudo dnf install vim-enhanced -y
  ./install_basic_clis.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
    install_beyondcompare.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  ./install_powerlevel10k.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  ./install_brew.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  ./install_rbenv.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  ./install_nvm.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  ./install.clis.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  ./install_clis.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_1password.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_zoom.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_keybase.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_drogon.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_sublime_dev.sh.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_sublimemerge_dev.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_sublime4.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_taskwarrior.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  compile_nano.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_evm.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_pyenv.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_kiex.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_emacs.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_masterpdf.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_i3.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_vlc.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_go.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_discord.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_signal.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_skype.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_kerl.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_planner.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_telegram.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  install_valet.bash
  _err=$? && [[ ${_err} -gt 0 ]] && exit ${_err}
  # install_code.bash
  wget --max-redirect=10 --mirror --directory-prefix="/home/zeus/Downloads/20231122/" -O "code-1.84.2-20231122.el7.x86_64.rpm" --no-check-certificate https://update.code.visualstudio.com/1.84.2/linux-rpm-x64/stable
  sudo dnf install -vy code-1.84.2-20231122.el7.x86_64.rpm
  rm code-1.84.2-20231122.el7.x86_64.rpm
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
	dnf groupupdate core -y
	dnf group update core -y
	dnf install https://rpms.remirepo.net/fedora/remi-release-$(rpm -E %fedora).rpm -yv 

  if (
  install_requirements "linux" "
    arandr
    task
    gparted
    gpart
    thunderbird
    boxes
    firefox
    guake
    yakuake
    nginx
    gnome-tweaks
    breeze-cursor-theme
    oxygen-cursor-themes
    knock
    htop
    btop
  "
  ); then
    {
      echo "installed $0"
    }
  fi
  brew install libxscrnsaver libnotify bzip2 freetype2
  verify_is_installed "
    unzip
    curl
    wget
    tar
  "

  echo "Virtual box is multi step install ... "
	install_virtualbox.bash

} # end _redhat_flavor_install

_arch_flavor_install() {
  echo "_arch_flavor_install Procedure not yet implemented. I don't know what to do."
} # end _readhat_flavor_install

_arch__32() {
  _arch_flavor_install
} # end _arch__32

_arch__64() {
  _arch_flavor_install
} # end _arch__64

_centos__32() {
  _redhat_flavor_install
} # end _centos__32

_centos__64() {
  _redhat_flavor_install
} # end _centos__64

_debian__32() {
  _debian_flavor_install
} # end _debian__32

_debian__64() {
  _debian_flavor_install
} # end _debian__64

_fedora__32() {
  _redhat_flavor_install
} # end _fedora__32

_fedora__64() {
  _redhat_flavor_install
} # end _fedora__64

_gentoo__32() {
  _redhat_flavor_install
} # end _gentoo__32

_gentoo__64() {
  _redhat_flavor_install
} # end _gentoo__64

_madriva__32() {
  _redhat_flavor_install
} # end _madriva__32

_madriva__64() {
  _redhat_flavor_install
} # end _madriva__64

_suse__32() {
  _redhat_flavor_install
} # end _suse__32

_suse__64() {
  _redhat_flavor_install
} # end _suse__64

_ubuntu__32() {
  _debian_flavor_install
} # end _ubuntu__32

_ubuntu__64() {
  _debian_flavor_install
} # end _ubuntu__64

_darwin__64() {
  echo "_darwin__64 Procedure not yet implemented. I don't know what to do."
} # end _darwin__64

_darwin__arm64() {
  echo "_darwin__arm64 Procedure not yet implemented. I don't know what to do."
} # end _darwin__arm64

_tar() {
  echo "_tar Procedure not yet implemented. I don't know what to do."
} # end tar

_windows__64() {
  echo "_windows__64 Procedure not yet implemented. I don't know what to do."
} # end _windows__64

_windows__32() {
  echo "_windows__32 Procedure not yet implemented. I don't know what to do."
} # end _windows__32



 #--------/\/\/\/\-- 1tasks_templates/fedora37_preferences …install_fedora37_preferences.bash” -- Custom code-/\/\/\/\-------



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
