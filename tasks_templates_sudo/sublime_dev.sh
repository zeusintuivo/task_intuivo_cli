#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
  export THISSCRIPTCOMPLETEPATH
  typeset -r THISSCRIPTCOMPLETEPATH="$(realpath $(which $(basename "$0")))"  # updated realpath macos 20210902 # updated realpath macos 20210902 # § This goes in the FATHER-MOTHER script
  export _err
  typeset -i _err=0
load_struct_testing_wget(){
    local provider="$HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    [   -e "${provider}"  ] && source "${provider}"
    [ ! -e "${provider}"  ] && eval """$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing -O -  2>/dev/null )"""   # suppress only wget download messages, but keep wget output for variable
    ( ( ! command -v passed >/dev/null 2>&1; ) && echo -e "\n \n  ERROR! Loading struct_testing \n \n " && exit 69; )
} # end load_struct_testing_wget
load_struct_testing_wget

function _linux_prepare(){
  export  THISSCRIPTNAME
  typeset -gr THISSCRIPTNAME="$(pwd)/$(basename "$0")"
  export _err
  typeset -i _err=0
  load_execute_boot_basic_with_sudo(){
    # shellcheck disable=SC2030
    if ( typeset -p "SUDO_USER"  &>/dev/null ) ; then
    {
      export USER_HOME
      # typeset -rg USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)  # Get the caller's of sudo home dir Just Linux
      # shellcheck disable=SC2046
      # shellcheck disable=SC2031
      typeset -rg USER_HOME="$(echo -n $(bash -c "cd ~${SUDO_USER} && pwd"))"  # Get the caller's of sudo home dir LINUX and MAC
    }
    else
    {
      local USER_HOME=$HOME
    }
    fi
    local -r provider="$USER_HOME/_/clis/execute_command_intuivo_cli/execute_boot_basic.sh"
    echo source "${provider}"
    # shellcheck disable=SC1090
    [   -e "${provider}"  ] && source "${provider}"
    [ ! -e "${provider}"  ] && eval """$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/execute_boot_basic.sh -O -  2>/dev/null )"""   # suppress only wget download messages, but keep wget output for variable
    if ( command -v failed >/dev/null 2>&1; ) ; then
    {
      return 0
    }
    else
    {
      echo -e "\n \n  ERROR! Loading execute_boot_basic.sh \n \n "
      exit 1;
    }
    fi
    return 0
  } # end load_execute_boot_basic_with_sudo

  load_execute_boot_basic_with_sudo
  _err=$?
  if [ $_err -ne 0 ] ;  then
  {
    >&2 echo -e "ERROR There was an error loading load_execute_boot_basic_with_sudo Err:$_err "
    exit $_err
  }
  fi

  function _trap_on_exit(){
    echo -e "\033[01;7m*** TRAP $THISSCRIPTNAME EXITS ...\033[0m"
    ls -lad /opt/sublime_text/Packages
    tree /opt/sublime_text/Packages
    ls -lad $HOME/.config
    # ls -lad $HOME/.config/sublime-text-3/Installed\ Packages/Package\ Control.sublime-package
    tree $HOME/.config
    # tree $HOME/.config/sublime-text-3/Installed\ Packages/Package\ Control.sublime-package
  }
  #trap kill ERR
  trap _trap_on_exit EXIT
  #trap kill INT
} # end function _linux_prepare

_version() {
    local -i _err
    # local _sublime_version_page=$(curl -L https://www.sublimetext.com/3dev  2>/dev/null )  # suppress only wget download messages, but keep wget output for variable
    # set -x
    local _sublime_version_page=""
    _sublime_version_page=$(curl -L https://www.sublimetext.com/3dev  2>&1 )  # stout and stderr both get
    _err=$?
    if [ $_err -eq 6 ] ;  then # curl: (6) Could not resolve host:
    {
      >&2 echo -e "ERROR Failed to Connect to Internet. Check your connection or Site not found. "
      exit $_err
    }
    elif [ $_err -ne 0 ] ;  then
    {
      >&2 echo -e "ERROR There was an error doing command Curl to download  Err:$_err "
      exit $_err
    }
    fi
    local _sublime_string=$(echo "${_sublime_version_page}" | sed -n "/<p\ class=\"latest\">/,/<\/div>/p" | head -1)  # suppress only wget download messages, but keep wget output for variable
    _err=$?
    # echo -e "_sublime_string> ${_sublime_string} \n"
    # exit 0
    local _sublime_build_line=$(echo "${_sublime_string}" | grep "Build ....")
    _err=$?
    # echo -e "----------------err> ${_err} \n"
    # echo -e "_sublime_build_line> ${_sublime_build_line} \n"
    # exit 0
    if [ -z "${_sublime_build_line}" ] ; then
    {
        echo "ERROR when doing check of line string from website. Got nothing"
        echo "    _sublime_string: <${_sublime_string}>"
        echo "                      0123456789 123456789 123456789 123456789 123456789 123456789 1234567889 123456789 123456789 123456789 123456789 "
        echo "                                1         2         3         4         5         6          7         8         9        10        11"
        echo "_sublime_build_line: <${_sublime_build_line}>"
        failed "Error"
        exit 69;
    }
    else
    {
        local __online_version_from_page=$(echo "${_sublime_build_line}" | cut -c42-45)
        wait
        [[ -z "${__online_version_from_page}" ]] && failed "Sublime Version not found!"
        echo "${__online_version_from_page}"
    }
    fi
    # exit 0
    return 0
}

download_sublime(){
  # sample https://download.sublimetext.com/sublime-text_build-3133_amd64.deb
  # sample https://download.sublimetext.com/sublime_text_3_build_3211_x64.tar.bz2
  # https://download.sublimetext.com/sublime-text-3210-1.x86_64.rpm
  # https://download.sublimetext.com/sublime_text_3_build_3210_x32.tar.bz2
  # https://download.sublimetext.com/sublime_text_3_build_3211_x64.tar.bz2
  local target_url="https://download.sublimetext.com/${1}"

  _download "${target_url}" $USER_HOME/Downloads  ${1}

  # if ( command -v wget >/dev/null 2>&1; ) ; then
  #   wget --directory-prefix="${USER_HOME}/Downloads/" --quiet --no-check-certificate "${target_url}" 2>/dev/null
  #
  #   # echo -e "\e[7m*** Downloading file to temp location...\e[0m"
  #   # # REF: about :> http://unix.stackexchange.com/questions/37507/what-does-do-here
  #   # :> wgetrc   # here :> equals to Equivalent to the following: cat /dev/null > wgetrc which Nulls out the file called "wgetrc" in the current directory. As in creates an empty file "wgetrc" if one doesn't exist or overwrites one with nothing if it does.
  #   # echo "noclobber = off" >> wgetrc
  #   # echo "dir_prefix = ." >> wgetrc
  #   # echo "dirstruct = off" >> wgetrc
  #   # echo "verbose = on" >> wgetrc
  #   # echo "progress = bar:default" >> wgetrc
  #   # echo "tries = 3" >> wgetrc
  #
  #   # WGETRC=wgetrc wget --quiet --no-check-certificate "${target_url}" 2>/dev/null   # suppress only wget download messages, but keep wget output for variable
  #   # echo -e "\e[7m*** Download completed.\e[0m"
  #   # rm -f wgetrc
  # elif ( command -v curl >/dev/null 2>&1; ); then
  #   curl -O "${target_url}" 2>/dev/null   # suppress only wget download messages, but keep wget output for variable
  # else
  #   failed "I cannot find wget or curl to download! ${target_url}"
  # fi
}

download_install_package_control(){
  # Package Control - The Sublime Text Package Manager: https://sublime.wbond.net
  local __pc_dir_opt_s_p__=/opt/sublime_text/Packages/
  local __pc_dir_config_s_ip__=$USER_HOME/.config/sublime-text-3/Installed\ Packages/
  local __pc_download_filename__=Package\ Control.sublime-package
  local __pc_download_filepath__=$USER_HOME/$__pc_download_filename__
  local target_url="https://packagecontrol.io/Package%20Control.sublime-package"
  it_does_not_exist_with_spaces "${__pc_dir_opt_s_p__}" && mkdir  -p "${__pc_dir_opt_s_p__}"
  it_does_not_exist_with_spaces "${__pc_dir_opt_s_p__}" && mkdir -p "${__pc_dir_config_s_ip__}"
  directory_exists_with_spaces "${__pc_dir_opt_s_p__}"
  directory_exists_with_spaces "${__pc_dir_config_s_ip__}"

  if [ ! -e "${__pc_dir_opt_s_p__}" ] ; then
    failed "I cannot find target directory where sublime is installed or Packages folder! ${__pc_dir_opt_s_p__}"
  fi
  if ( command -v wget >/dev/null 2>&1; ) ; then
    wget --directory-prefix="${__pc_download_filepath__}" --quiet --no-check-certificate "${target_url}" 2>/dev/null   # suppress only wget download messages, but keep wget output for variable
  elif ( command -v curl >/dev/null 2>&1; ); then
    curl -o "${__pc_download_filepath__}" "${target_url}" 2>/dev/null   # suppress only wget download messages, but keep wget output for variable
  else
    failed "I cannot find wget or curl to download! ${target_url}"
  fi
  directory_does_not_exist_with_spaces "${__pc_download_filepath__}"
  if [ ! -e "${__pc_download_filepath__}" ] ; then
    failed "I cannot find target downloaded where the Packages was supposed to be! ${__pc_download_filepath__}"
  fi
  file_exists_with_spaces "${__pc_download_filepath__}"

exit 0
  if it_exists_with_spaces "${__pc_dir_config_s_ip__}/${__pc_download_filename__}" ; then
    rm -rf "${__pc_dir_config_s_ip__}/${__pc_download_filename__}"
  fi
  sudo cp -R "${__pc_download_filepath__}"  "${__pc_dir_config_s_ip__}"

  if it_exists_with_spaces "${__pc_dir_opt_s_p__}/${__pc_download_filename__}" ; then
    rm -rf "${__pc_dir_opt_s_p__}/${__pc_download_filename__}"
  fi
  sudo cp -R "${__pc_download_filepath__}"  "${__pc_dir_opt_s_p__}"
  rm -rf "${__pc_download_filepath__}"
  if it_exists_with_spaces "${__pc_dir_config_s_ip__}/${__pc_download_filename__}/${__pc_download_filename__}" ; then
    sudo mv "${__pc_dir_config_s_ip__}/${__pc_download_filename__}/${__pc_download_filename__}" "${__pc_dir_config_s_ip__}/${__pc_download_filename__}/${__pc_download_filename__}m"
    sudo mv "${__pc_dir_config_s_ip__}/${__pc_download_filename__}/${__pc_download_filename__}m" "${__pc_dir_config_s_ip__}/"
    sudo rm -rf "${__pc_dir_config_s_ip__}/${__pc_download_filename__}m"
    sudo mv "${__pc_dir_config_s_ip__}/${__pc_download_filename__}m" "${__pc_dir_config_s_ip__}/${__pc_download_filename__}"

  fi
  sudo chown -R "${SUDO_USER}" "${__pc_dir_config_s_ip__}"
}

add_to_applications_list(){
  # Add to applications list
  directory_exists "
  ${USER_HOME}/.local/share/applications/
  /opt/sublime_text/Icon/128x128/
  /usr/share/applications/
  "


  #Creando archivo .desktop
  echo -e "\e[7m*** Creating .desktop file (for easy launch and associate to Sublime Text 3)...\e[0m"
  echo "[Desktop Entry]
  Version=1.0
  Type=Application
  Name=Sublime Text 3 DEV
  GenericName=Text Editor
  Comment=Sophisticated text editor for code, markup and prose
  #Exec=/opt/sublime_text/sublime_text %F
  Exec=sublime-text-3 %F
  Terminal=false
  MimeType=text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;x-directory/normal;inode/directory;
  Icon=sublime-text-3
  Categories=TextEditor;Development;
  StartupNotify=true
  Actions=Window;Document;
  [Desktop Action Window]
  Name=New Window
  Exec=/opt/sublime_text/sublime_text -n
  OnlyShowIn=Unity;
  [Desktop Action Document]
  Name=New File
  Exec=/opt/sublime_text/sublime_text --command new_file
  OnlyShowIn=Unity;" > /usr/share/applications/"Sublime Text 3.desktop"

  cat << EOF > $USER_HOME/.local/share/applications/sublime.desktop
  [Desktop Entry]
  Name=Sublime Text Dev
  Exec=subl %F
  MimeType=text/plain;
  Terminal=false
  Type=Application
  Icon=/opt/sublime_text/Icon/128x128/sublime-text.png
  Categories=Utility;TextEditor;Development;
EOF
}

_darwin__64() {
    local __online_version_from_page=$(_version)
    local SUBLIMENAME="Sublime%20Text%20Build%20${__online_version_from_page}.dmg"
    local SUBLIMENAME_4_HDUTIL="Sublime Text Build ${__online_version_from_page}.dmg"
    wait
    cd ~/Downloads/
    [ ! -e "${SUBLIMENAME_4_HDUTIL}" ] || download_sublime "${SUBLIMENAME}"
    echo "${pwd}"
    echo "${SUBLIMENAME_4_HDUTIL}"
    ls -la "${SUBLIMENAME_4_HDUTIL}"
    wait
    sudo hdiutil attach "${SUBLIMENAME_4_HDUTIL}"
    wait
    sudo cp -R /Volumes/Sublime\ Text/Sublime\ Text.app /Applications/
    wait
    sudo hdiutil detach /Volumes/Sublime\ Text
    wait
} # end _darwin__64

add_rpm_gpg_key_and_add_install_repository() {
    if  is_not_included "sublime-text" "$(dnf repolist)" ; then
    {
      sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
      # Stable
      # sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
      # Dev
      sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/dev/x86_64/sublime-text.repo
    }
    fi
} # add_rpm_gpg_key_and_add_install_repository

_centos__64() {
  _fedora__64
} # end _centos__64

_fedora__64() {
  _linux_prepare
  local -i __online_version_from_page=$(_version)
  passed $__online_version_from_page
  if command -v "subl" >/dev/null 2>&1 ; then
  {
    local -i __current_version=$(subl --version | cüt "Sublime Text Build")
    passed $__current_version
    if [ $__current_version -gt $__online_version_from_page ] ; then
    {
      failed installed version is higher than online version
      exit 69
    }
    fi
  }
  fi
  local SUBLIMENAME="sublime-text-${__online_version_from_page}-1.x86_64.rpm"
  passed $SUBLIMENAME
  local CODENAME=$SUBLIMENAME
  # Sample https://download.sublimetext.com/sublime-text-3210-1.x86_64.rpm
  local TARGET_URL="https://download.sublimetext.com/${CODENAME}"
  passed $TARGET_URL
  if  it_exists_with_spaces "$USER_HOME/${CODENAME}" ; then
  {
    file_exists_with_spaces "$USER_HOME/${CODENAME}"
  }
  else
  {
    file_exists_with_spaces $USER_HOME/Downloads
    cd $USER_HOME
    _download "${TARGET_URL}" "$USER_HOME/"  "${CODENAME}"
    file_exists_with_spaces "$USER_HOME/${CODENAME}"
  }
  fi


  add_rpm_gpg_key_and_add_install_repository
  sudo dnf -y install "$USER_HOME/${CODENAME}"
  if  it_exists_with_spaces "$USER_HOME/${CODENAME}" ; then
  {
    rm -rf "$USER_HOME/${CODENAME}"
    directory_does_not_exist_with_spaces "$USER_HOME/${CODENAME}"
  }
  fi
  download_install_package_control
  add_to_applications_list
exit 0
  file_exists "
    /opt/sublime_text/sublime_text
  "

  wait
  if it_exists "${SUBLIMENAME}"; then
      rm -f "${SUBLIMENAME}"
  fi

    verify_is_installed "subl"

    passed ""
    passed "Sublime Text 3 installed successfully!"
    passed "Run with: subl"
    passed "\e[7m*** That's all. Have fun Sublime Texting ;)\e[0m"

} # end _fedora__64

_fedora__32() {
    execute_as_sudo
    local __online_version_from_page=$(_version)
    local SUBLIMENAME="sublime_text_3_build_${__online_version_from_page}_x32.tar.bz2"
    wait
    cd $USER_HOME/Downloads/
    download_sublime "${SUBLIMENAME}"
    wait

    if tar -xf "${SUBLIMENAME}" --directory=$USER_HOME; then
      sudo mv $USER_HOME/sublime_text/ /opt/
      sudo ln -s /opt/sublime_text/sublime_text /usr/bin/subl
    fi
    rm "${SUBLIMENAME}"

    download_install_package_control
    add_to_applications_list

    file_exists "
    /opt/sublime_text/sublime_text
    "

    softlink_exists "
    subl>/opt/sublime_text/sublime_text
    "
    wait
    passed ""
    passed "Sublime Text 3 installed successfully!"
    passed "Run with: subl"

} # end _fedora__32

_ubuntu__64() {
    execute_as_sudo
    local __online_version_from_page=$(_version)
    echo " version ${__online_version_from_page}"
    local SUBLIMENAME="sublime-text_build-${__online_version_from_page}_amd64.deb"
    echo " looking for file ${SUBLIMENAME} online"
    wait
    echo "changing to Downloads folder  ~/Downloads/"
    cd ~/Downloads/
    echo "downloading ${SUBLIMENAME}"
    download_sublime "${SUBLIMENAME}"
    wait
    echo "installing "
    sudo dpkg -i ${SUBLIMENAME}
    wait
} # end _ubuntu__64

_linux__32() {
    execute_as_sudo
    local __online_version_from_page=$(_version)
    local SUBLIMENAME="sublime-text_build-${__online_version_from_page}_i386.deb"
    wait
    cd ~/Downloads/
    download_sublime "${SUBLIMENAME}"
    wait
    sudo dpkg -i ${SUBLIMENAME}
    wait
} # end _linux__32

_windows__64() {
    local __online_version_from_page=$(curl -L https://www.sublimetext.com/3dev | sed -n "/<p\ class=\"latest\">/,/<\/div>/p" | head -1 | grep 'Build ....' | cut -c42-45)
    wait
    local SUBLIMENAME="Sublime%20Text%20Build%20${__online_version_from_page}%20x64%20Setup.exe"
    wait
    cd $USER_HOMEDIR
    cd Downloads
    curl -O https://download.sublimetext.com/${SUBLIMENAME}
    ${SUBLIMENAME}
    wait
} # end _windows__64

_windows__32() {
    local __online_version_from_page=$(curl -L https://www.sublimetext.com/3dev | sed -n "/<p\ class=\"latest\">/,/<\/div>/p" | head -1 | grep 'Build ....' | cut -c42-45)
    wait
    local SUBLIMENAME="Sublime%20Text%20Build%20${__online_version_from_page}%20Setup.exe"
    wait
    cd $USER_HOMEDIR
    cd Downloads
    curl -O https://download.sublimetext.com/${SUBLIMENAME}
    ${SUBLIMENAME}
    wait
} # end _windows__32

determine_os_and_fire_action


