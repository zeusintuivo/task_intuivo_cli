#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
if ! ( command -v realpath >/dev/null 2>&1; ) ; then # MAC  # updated realpath macos 20210902
{
  # updated realpath macos 20210902
  export realpath    # updated realpath macos 20210902
  function realpath() ( # Macos after BigSur is missing realpath  # updated realpath macos 20210902
    local OURPWD=$PWD
    cd "$(dirname "$1")"
    local LINK=$(readlink "$(basename "$1")")
    while [ "$LINK" ]; do
      cd "$(dirname "$LINK")"
      LINK=$(readlink "$(basename "$1")")
    done
    local REALPATH="$PWD/$(basename "$1")"
    cd "$OURPWD"
    echo "$REALPATH"
  )
}
fi

# 20200415 Compatible with Fedora, Mac, Ubuntu "sudo_up" "load_struct" "#


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
  function load_library(){
    local _library="${1:struct_testing}"
    [[ -z "${1}" ]] && echo "Must call with name of library example: struct_testing execute_command" && exit 1
    trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
      local provider="$HOME/_/clis/execute_command_intuivo_cli/${_library}"
      local _err=0 structsource
      if [   -e "${provider}"  ] ; then
        echo "Loading locally"
        structsource="""$(<"${provider}")"""
        _err=$?
        [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading ${_library}. running 'source locally' returned error did not download or is empty err:$_err  \n \n  " && exit 1
      else
        if ( command -v curl >/dev/null 2>&1; )  ; then
          echo "Loading ${_library} from the net using curl "
          structsource="""$(curl https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/${_library}  -so -   2>/dev/null )"""  #  2>/dev/null suppress only curl download messages, but keep curl output for variable
          _err=$?
          [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading ${_library}. running 'curl' returned error did not download or is empty err:$_err  \n \n  " && exit 1
        elif ( command -v wget >/dev/null 2>&1; ) ; then
          echo "Loading ${_library} from the net using wget "
          structsource="""$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/${_library} -O -   2>/dev/null )"""  #  2>/dev/null suppress only wget download messages, but keep wget output for variable
          _err=$?
          [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading ${_library}. running 'wget' returned error did not download or is empty err:$_err  \n \n  " && exit 1
        else
          echo -e "\n \n  ERROR! Loading ${_library} could not find wget or curl to download  \n \n "
          exit 69
        fi
      fi
      [[ -z "${structsource}" ]] && echo -e "\n \n  ERROR! Loading ${_library} into ${_library}_source did not download or is empty " && exit 1
      local _temp_dir="$(mktemp -d 2>/dev/null || mktemp -d -t "${_library}_source")"
      echo "${structsource}">"${_temp_dir}/${_library}"
      echo "Temp location ${_temp_dir}/${_library}"
      source "${_temp_dir}/${_library}"
      _err=$?
      [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading ${_library}. Occured while running 'source' err:$_err  \n \n  " && exit 1
      if  ! typeset -f passed >/dev/null 2>&1; then
        echo -e "\n \n  ERROR! Loading ${_library}. Passed was not loaded !!!  \n \n "
        exit 69;
      fi
      return $_err
  } # end load_library
  load_library "struct_testing"
  load_library "execute_command"
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
  # USER_HOME=$(getent passwd "${SUDO_USER}" | cut -d: -f6)   # Get the caller's of sudo home dir LINUX
  enforce_variable_with_value USER_HOME "${USER_HOME}"
# }  # end _linux_prepare


# _linux_prepare
export SUDO_GRP='staff'
enforce_variable_with_value USER_HOME "${USER_HOME}"
enforce_variable_with_value SUDO_USER "${SUDO_USER}"
passed "Caller user identified:${SUDO_USER}"
passed "Home identified:${USER_HOME}"
directory_exists_with_spaces "${USER_HOME}"



 #--------\/\/\/\/-- install_sublime4.bash -- Custom code -\/\/\/\/-------




function _version() {
    local -i _err
    # local _sublime_version_page=$(curl -L https://www.sublimetext.com/3dev  2>/dev/null )  # suppress only wget download messages, but keep wget output for variable
    # set -x
    local _sublime_version_page=""
    _sublime_version_page=$(curl -L https://www.sublimetext.com/ | grep Build 2>&1 )  # stout and stderr both get sublime
    # _sublime_version_page=$(curl -L https://www.sublimetext.com/dev  2>&1 )  # stout and stderr both get sublime dev
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
    # local _sublime_string=$(echo "${_sublime_version_page}" | sed -n "/<p\ class=\"latest\">/,/<\/div>/p" | head -1)  # suppress only wget download messages, but keep wget output for variable
    local _sublime_string=$(echo "${_sublime_version_page}" | cut -d'(' -f2 | cut -d')' -f1 | cut -d' ' -f2  | head -1)  # suppress only wget download messages, but keep wget output for variable
    _err=$?
    # echo -e "_sublime_string> ${_sublime_string} \n"
    # exit 0
    local _sublime_build_line="${_sublime_string}"
    # local _sublime_build_line=$(echo "${_sublime_version_page}" | grep "Build ....")
    _err=$?
    >&2 echo -e "----------------err> ${_err} \n"
    >&2 echo -e "_sublime_build_line> ${_sublime_build_line} \n"
    >&2 echo -e "    _sublime_string> ${_sublime_string} \n"
    # exit 0
    if [ -z "${_sublime_build_line}" ] ; then
    {
        >&2 echo "ERROR when doing check of line string from website. Got nothing"
        >&2 echo "    _sublime_string: <${_sublime_string}>"
        >&2 echo "                      0123456789 123456789 123456789 123456789 123456789 123456789 1234567889 123456789 123456789 123456789 123456789 "
        >&2 echo "                                1         2         3         4         5         6          7         8         9        10        11"
        >&2 echo "_sublime_build_line: <${_sublime_build_line}>"
        >&2 failed "Error"
        exit 69;
    }
    else
    {
        echo "${_sublime_string}"
        # local __online_version_from_page=$(echo "${_sublime_build_line}" | cut -c42-45)
        # wait
        # [[ -z "${__online_version_from_page}" ]] && failed "Sublime Version not found!"
        [[ -z "${_sublime_string}" ]] && >&2 failed "Sublime Version not found!"
        # echo "${__online_version_from_page}"
    }
    fi
    # exit 0
    return 0
} # end _version

function download_install_package_control(){
  # Package Control - The Sublime Text Package Manager: https://sublime.wbond.net
  local __pc_dir_opt_s_p__=/opt/sublime_text/Packages/
  local __pc_dir_config_s_ip__="${USER_HOME}"/.config/sublime-text-3/Installed\ Packages
  local __pc_download_filename__=Package\ Control.sublime-package
  local TARGET_URL="https://packagecontrol.io/Package%20Control.sublime-package"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  it_does_not_exist_with_spaces "${__pc_dir_opt_s_p__}" && mkdir  -p "${__pc_dir_opt_s_p__}"
  it_does_not_exist_with_spaces "${__pc_dir_opt_s_p__}" && mkdir -p "${__pc_dir_config_s_ip__}"
  directory_exists_with_spaces "${__pc_dir_opt_s_p__}"
  directory_exists_with_spaces "${__pc_dir_config_s_ip__}"

  enforce_variable_with_value __pc_dir_config_s_ip__ "${__pc_dir_config_s_ip__}"
  enforce_variable_with_value __pc_download_filename__ "${__pc_download_filename__}"
  Downloading Package Control
  local __pc_download_filepath__="${__pc_dir_config_s_ip__}/${__pc_download_filename__}"
  enforce_variable_with_value __pc_download_filepath__ "${__pc_download_filepath__}"
  _do_not_downloadtwice "${TARGET_URL}" "${__pc_dir_config_s_ip__}"  "${__pc_download_filename__}"
  file_exists_with_spaces "${__pc_download_filepath__}"
  # cp -R "${__pc_download_filepath__}"  "${__pc_dir_config_s_ip__}"
  # _remove_downloaded_codename_or_err  $_err "${__pc_dir_opt_s_p__}/${__pc_download_filename__}"
  # if it_exists_with_spaces "${__pc_dir_opt_s_p__}/${__pc_download_filename__}" ; then
  #   rm -rf "${__pc_dir_opt_s_p__}/${__pc_download_filename__}"
  # fi
  # cp -R "${__pc_download_filepath__}"  "${__pc_dir_opt_s_p__}"
  # _remove_downloaded_codename_or_err  $_err "${__pc_download_filepath__}"
  # rm -rf "${__pc_download_filepath__}"
  # if it_exists_with_spaces "${__pc_download_filepath__}/${__pc_download_filename__}" ; then
  #   mv "${__pc_download_filepath__}/${__pc_download_filename__}" "${__pc_download_filepath__}/${__pc_download_filename__}m"
  #   mv "${__pc_download_filepath__}/${__pc_download_filename__}m" "${__pc_dir_config_s_ip__}/"
  #   rm -rf "${__pc_download_filepath__}m"
  #   mv "${__pc_download_filepath__}m" "${__pc_download_filepath__}"
  # fi
  chown -R "${SUDO_USER}" "${__pc_dir_opt_s_p__}"
  chown -R "${SUDO_USER}" "${__pc_dir_config_s_ip__}"
} # end download_install_package_control

function add_to_applications_list(){
  # Add to applications list
  directory_exists "
  ${USER_HOME}/.local/share/applications/
  /opt/sublime_text/Icon/128x128/
  /usr/share/applications/
  "

  # Creando archivo .desktop
  echo -e "\e[7m*** Creating .desktop file (for easy launch and associate to Sublime Text 4)...\e[0m"
  echo "[Desktop Entry]
  Version=1.0
  Type=Application
  Name=Sublime Text 4
  GenericName=Text Editor
  Comment=Sophisticated text editor for code, markup and prose
  Exec=/opt/sublime_text/sublime_text %F
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
  OnlyShowIn=Unity;" > /usr/share/applications/"Sublime Text 4.desktop"

  cat << EOF > ${USER_HOME}/.local/share/applications/sublime.desktop
  [Desktop Entry]
  Name=Sublime Text
  Exec=subl %F
  MimeType=text/plain;
  Terminal=false
  Type=Application
  Icon=/opt/sublime_text/Icon/128x128/sublime-text.png
  Categories=Utility;TextEditor;Development;
EOF
} # end add_to_applications_list

function add_rpm_gpg_key_and_add_install_repository() {
    if  is_not_included "sublime-text" "$(dnf repolist)" ; then
    {
      rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
      # Stable
      # sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
      # Dev
      dnf config-manager --add-repo https://download.sublimetext.com/rpm/dev/x86_64/sublime-text.repo
    }
    fi
} # add_rpm_gpg_key_and_add_install_repository


function new_version_is_higher(){
  local __online_version_from_page="${1}"
  if is_not_installed subl ; then
  {
    local -i __current_version=$(subl --version | cüt "Sublime Text Build")
    passed $__current_version
    if [ $__current_version -gt $__online_version_from_page ] ; then
    {
      echo failed installed version is higher than online version
      return 0
    }
    fi
  }
  fi
  return 1
} # end ensure_new_version_is_higher


function _do_install() {
  local SUBLIMENAME="sublime-text-${__online_version_from_page}-1.x86_64.rpm"
  enforce_variable_with_value SUBLIMENAME "${SUBLIMENAME}"
  passed ${SUBLIMENAME}
  local CODENAME=${SUBLIMENAME}
  enforce_variable_with_value CODENAME "${CODENAME}"
  # Expected sample: https://download.sublimetext.com/sublime-text-4213-1.x86_64.rpm
  local TARGET_URL="https://download.sublimetext.com/${CODENAME}"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  local DOWNLOADFOLDER="$(_find_downloads_folder)"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
  add_rpm_gpg_key_and_add_install_repository
  _install_rpm "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}" 0
  _remove_downloaded_codename_or_err  $_err "${DOWNLOADFOLDER}/${CODENAME}"
} # end _do_install

_redhat_flavor_install() {
  local -i __online_version_from_page=$(_version)
  enforce_variable_with_value __online_version_from_page "${__online_version_from_page}"
  passed "${__online_version_from_page}"
  if new_version_is_higher "${__online_version_from_page}" ; then
  {
    Installing sublimetext  "${__online_version_from_page}"
    exit 0
    _do_install "${__online_version_from_page}"
  }
  else
  {
    if [[ "${*}" == "--force" ]] && [[ "${*}" == "--reinstall" ]] ; then
    {
      Installing --force --reinstall sublimetext  "${__online_version_from_page}"
      dnf remove sublime-text
      _do_install "${__online_version_from_page}"
    }
    else
    {
      Skipping sublimetext version is higher or same as installed . Use force use --force or --reinstall  to force reinstall
    }
    fi
  }
  fi
  download_install_package_control
  add_to_applications_list
  file_exists "/opt/sublime_text/sublime_text"
  chown -R "${SUDO_USER}" /opt/sublime_text/
  wait
  verify_is_installed "subl"
  passed ""
  passed "Sublime Text 4 installed successfully!"
  passed "Run with: subl"
  passed "\e[7m*** That's all. Have fun Sublime Texting ;)\e[0m"
  return  $_err
} # end _redhat_flavor_install

_arch_flavor_install() {
  echo "Procedure not yet implemented. I don't know what to do."
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
  execute_as_sudo
    local __online_version_from_page=$(_version)
    local SUBLIMENAME="sublime_text_3_build_${__online_version_from_page}_x32.tar.bz2"
    wait
    cd ${USER_HOME}/Downloads/
    download_sublime "${SUBLIMENAME}"
    wait

    if tar -xf "${SUBLIMENAME}" --directory=${USER_HOME}; then
      sudo mv ${USER_HOME}/sublime_text/ /opt/
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
    passed "Sublime Text 4 installed successfully!"
    passed "Run with: subl"
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
 local __online_version_from_page=$(_version) # expected numnber 4113
 # https://download.sublimetext.com/sublime_text_build_4113_mac.zip
 local SUBLIMENAME="sublime_text_build_${__online_version_from_page}_mac.zip"
 local installlist one  target_name target_url target_app app_name extension
 installlist="
  sublime_text_build_${SUBLIMENAME}_mac.zip|Sublime Text.app|https://download.sublimetext.com/sublime_text_build_${SUBLIMENAME}_mac.zip
 "
 Checking dmgs apps
  while read -r one ; do
  {
    if [[ -n "${one}" ]] ; then
    {

      target_name="$(echo "${one}" | cut -d'|' -f1)"
      extension="$(echo "${target_name}" | rev | cut -d'.' -f 1 | rev)"
      target_app="$(echo "${one}" | cut -d'|' -f2)"
      app_name="$(echo "$(basename "${target_app}")")"
      target_url="$(echo "${one}" | cut -d'|' -f3-)"
      if [[ -n "${target_name}" ]] ; then
      {
        if [[ -n "${target_url}" ]] ; then
        {
          if [[ ! -d "/Applications/${app_name}" ]] ; then
          {
            Installing "${app_name}"
            _install_dmgs_dmg__64 "${target_name}" "${target_app}" "${target_url}"
          }
          else
          {
            passed  "/Applications/${app_name}"  --skipping already installed
          }
          fi
        }
        fi
      }
      fi
    }
    fi
  }
  done <<< "${installlist}"
  Creating softlinks for subl, sublime
  anounce_command ln -s "/Applications/${app_name}/Contents/SharedSupport/bin/subl" /usr/local/bin/sublime
  anounce_command ln -s "/Applications/${app_name}/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
  return 0
} # end _darwin__64

_tar() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end tar


_windows__64() {
    local __online_version_from_page=$(curl -L https://www.sublimetext.com/3dev | sed -n "/<p\ class=\"latest\">/,/<\/div>/p" | head -1 | grep 'Build ....' | cut -c42-45)
    wait
    local SUBLIMENAME="Sublime%20Text%20Build%20${__online_version_from_page}%20x64%20Setup.exe"
    wait
    cd ${USER_HOMEDIR}
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
    cd ${USER_HOMEDIR}
    cd Downloads
    curl -O https://download.sublimetext.com/${SUBLIMENAME}
    ${SUBLIMENAME}
    wait
} # end _windows__32



 #--------/\/\/\/\-- install_sublime4.bash -- Custom code-/\/\/\/\-------


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo "🥦"
exit 0
