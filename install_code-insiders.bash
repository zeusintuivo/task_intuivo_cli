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

_remove_if_exists() {
  # Sample use 
  # _remove_if_exists "${APPDIR}" 
  local APPDIR="${1}" 
  if  it_exists_with_spaces "/Applications/${APPDIR}" ; then
  {
    echo Remove installed "/Applications/${APPDIR}"
    sudo rm -rf  "/Applications/${APPDIR}"
    directory_does_not_exist_with_spaces  "/Applications/${APPDIR}"
  }
  fi
  return 0
} # end _remove_if_exists

_install_dmg__64() {
  # Sample use 
  # local target_name="LittleSnitch-4.6.dmg"
  # local target_app="Little Snitch 4.6/Little Installer.app"
  # local target_url="https://www.obdev.at/ftp/pub/Products/littlesnitch/LittleSnitch-4.6.dmg"  
  #  _install_dmg__64 "${target_name}" "${target_app}" "${target_url}"
  #
  #  or zip
  #
  # local target_name="BetterTouchTool.zip"
  # local target_app="BetterTouchTool.app"
  # local target_url="https://raw.githubusercontent.com/danielng01/product-builds/master/iris/macos/Iris-1.2.0-OSX.zip"  
  # _install_dmg__64 "${target_name}" "${target_app}" "${target_url}"
  #
  local CODENAME="${1}"
  local extension="$(echo "${CODENAME}" | rev | cut -d'.' -f 1 | rev)"
  local APPDIR="${2}"
  local TARGET_URL="${3}"
  # CODENAME="$(basename "${TARGET_URL}" )"
  echo "${CODENAME}";
  echo "Extension:${extension}"
  # local VERSION="$(echo -en "${CODENAME}" | sed 's/RubyMine-//g' | sed 's/.dmg//g' )"
  # enforce_variable_with_value VERSION "${VERSION}"
  # local UNZIPDIR="$(echo -en "${CODENAME}" | sed 's/.dmg//g'| sed 's/-//g')"
  # local UNZIPDIR="$(echo -en "${APPDIR}" | sed 's/.app//g')"
  # echo "$(pwd)"
  local UNZIPDIR="$(dirname  "${APPDIR}")"
  local APPDIR="${APPDIR##*/}"    # same as  $(basename "${APPDIR}")
  # local APPDIR="$(echo -en "${CODENAME}" | sed 's/.dmg//g'| sed 's/-//g').app"
  # echo "${CODENAME}";
  # echo "${URL}";
  echo "CODENAME: ${CODENAME}"
  enforce_variable_with_value CODENAME "${CODENAME}"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  enforce_variable_with_value HOME "${HOME}"
  echo "UNZIPDIR: ${UNZIPDIR}"
  enforce_variable_with_value UNZIPDIR "${UNZIPDIR}"
  echo "APPDIR: ${APPDIR}"
  enforce_variable_with_value APPDIR "${APPDIR}"
  local DOWNLOADFOLDER="${HOME}/Downloads"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  directory_exists_with_spaces "${DOWNLOADFOLDER}"

  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
  _remove_if_exists "${APPDIR}" 

  _process_dmg_or_zip "${extension}" "${DOWNLOADFOLDER}" "${CODENAME}" "${APPDIR}" "${UNZIPDIR}"

  if [[ -n "${extension}" ]] && [[ "${extension}"  == "zip" ]] ; then
  {
    echo Unzipping downloaded
    unzip "${DOWNLOADFOLDER}/${CODENAME}"
    directory_exists_with_spaces "${DOWNLOADFOLDER}/${APPDIR}"
    echo "sudo  cp -R \"${DOWNLOADFOLDER}/${APPDIR}\" \"/Applications/\""
    cp -R "${DOWNLOADFOLDER}/${APPDIR}" "/Applications/"
  }
  else # elif [[ -n "${extension}" ]] && [[ "${extension}"  == "dmg" ]] ; then
  {
    echo Attaching dmg downloaded
    hdiutil attach "${DOWNLOADFOLDER}/${CODENAME}"
    ls "/Volumes"
    directory_exists_with_spaces "/Volumes/${UNZIPDIR}"
    directory_exists_with_spaces "/Volumes/${UNZIPDIR}/${APPDIR}"
    echo "sudo  cp -R \"/Volumes/${UNZIPDIR}/${APPDIR}\" \"/Applications/\""
    cp -R "/Volumes/${UNZIPDIR}/${APPDIR}" "/Applications/"
    hdiutil detach "/Volumes/${UNZIPDIR}"
  }
  fi
    directory_exists_with_spaces "/Applications/${APPDIR}"
    ls -d "/Applications/${APPDIR}"
    echo  Removing macOS gatekeeper quarantine attribute
    chown  -R $SUDO_USER "/Applications/${APPDIR}"
    chgrp  -R staff "/Applications/${APPDIR}"
    xattr -d com.apple.quarantine  "/Applications/${APPDIR}"
} # end _install_dmg__64

_install_dmgs_list(){
  # Sample use 
  #
  #     local TARGET_URL
  #     TARGET_URL="VSCode-darwin.zip|Visual Studio Code - Insiders.app|https://code.visualstudio.com/sha/download?build=insider&os=darwin"
  #     enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  #     _install_dmgs_list "${TARGET_URL}"
  # or
  #    local installlist 
  #    installlist="
  #      Caffeine.dmg|Caffeine/Caffeine.app|https://github.com/IntelliScape/caffeine/releases/download/1.1.3/Caffeine.dmg
  #      Keybase.dmg|Keybase App/Keybase.app|https://prerelease.keybase.io/Keybase.dmg
  #      Brave-Browser.dmg|Brave Browser/Brave Browser.app|https://referrals.brave.com/latest/Brave-Browser.dmg
  #      Firefox 84.0.2.dmg|Firefox/Firefox.app|https://download-installer.cdn.mozilla.net/pub/firefox/releases/84.0.2/mac/de/Firefox%2084.0.2.dmg
  #      MFF2_latest.dmg|MultiFirefox/MultiFirefox.app|http://mff.s3.amazonaws.com/MFF2_latest.dmg
  #      vlc-3.0.11.dmg|VLC media player/VLC.app|https://download.vlc.de/vlc/macosx/vlc-3.0.11.dmg
  #      mattermost-desktop-4.6.2-mac.dmg|Mattermost 4.6.2.app/Mattermost.app|https://releases.mattermost.com/desktop/4.6.2/mattermost-desktop-4.6.2-mac.dmg?src=dl
  #      gimp-2.10.22-x86_64-2.dmg|GIMP 2.10 Install/GIMP-2.10.app|https://ftp.lysator.liu.se/pub/gimp/v2.10/osx/gimp-2.10.22-x86_64-2.dmg
  #      sketch-70.3-109109.zip|Sketch.app|https://download.sketch.com/sketch-70.3-109109.zip
  #      Iris-1.2.0-OSX.zip|Iris.app|https://raw.githubusercontent.com/danielng01/product-builds/master/iris/macos/Iris-1.2.0-OSX.zip
  #      BetterTouchTool.zip|BetterTouchTool.app|https://folivora.ai/releases/BetterTouchTool.zip
  #      Options_8.36.76.zip|LogiMgr Installer 8.36.76.app|https://download01.logi.com/web/ftp/pub/techsupport/options/Options_8.36.76.zip
  #      tsetup.2.5.7.dmg|Telegram Desktop/Telegram.app|https://updates.tdesktop.com/tmac/tsetup.2.5.7.dmg
  #      VSCode-darwin.zip|Visual Studio Code.app|https://az764295.vo.msecnd.net/stable/ea3859d4ba2f3e577a159bc91e3074c5d85c0523/VSCode-darwin.zip
  #      VSCode-darwin.zip|Visual Studio Code.app|https://code.visualstudio.com/sha/download?build=stable&os=darwin
  #      VSCode-darwin.zip|Visual Studio Code - Insiders.app|https://az764295.vo.msecnd.net/insider/5a52bc29d5e9bc419077552d336ea26d904299fa/VSCode-darwin.zip
  #      VSCode-darwin.zip|Visual Studio Code - Insiders.app|https://code.visualstudio.com/sha/download?build=insider&os=darwin
  #      BCompareOSX-4.3.7.25118.zip|Beyond Compare.app|https://www.scootersoftware.com/BCompareOSX-4.3.7.25118.zip
  #      dbeaver-ce-7.3.4-macos.dmg|DBeaver Community/DBeaver.app|https://download.dbeaver.com/community/7.3.4/dbeaver-ce-7.3.4-macos.dmg
  #      Inkscape-1.0.2.dmg|Inkscape/Inkscape.app|https://media.inkscape.org/dl/resources/file/Inkscape-1.0.2.dmg
  #      LittleSnitch-4.6.dmg|Little Snitch 4.6/Little Installer.app|https://www.obdev.at/ftp/pub/Products/littlesnitch/LittleSnitch-4.6.dmg
  #    "  
  #     _install_dmg__64 "${installlist}"
  # Pending how to do pkg automatic?   # 1Password.pkg|https://c.1password.com/dist/1P/mac7/1Password-7.7.pkg
  local installlist one  target_name target_url target_app app_name # extension
  installlist="${*}"
  Checking dmgs apps
  while read -r one ; do
  {
    if [[ -n "${one}" ]] ; then
    {

      target_name="$(echo "${one}" | cut -d'|' -f1)"
      # extension="$(echo "${target_name}" | rev | cut -d'.' -f 1 | rev)"
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
            _install_dmg__64 "${target_name}" "${target_app}" "${target_url}"
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
  return 0
} # end _install_dmgs_list


export sudo_it
function sudo_it() {
  raise_to_sudo_and_user_home
} # end sudo_it

_darwin__64() {
  sudo_it
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  local TARGET_URL
  TARGET_URL="VSCode-darwin.zip|Visual Studio Code - Insiders.app|https://az764295.vo.msecnd.net/insider/5a52bc29d5e9bc419077552d336ea26d904299fa/VSCode-darwin.zip"
  TARGET_URL="VSCode-darwin.zip|Visual Studio Code - Insiders.app|https://code.visualstudio.com/sha/download?build=insider&os=darwin"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  _install_dmgs_list "${TARGET_URL}"
} # end _darwin__64

_fedora__64() {
	sudo_it
	[ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  local TARGET_URL=https://az764295.vo.msecnd.net/insider/04770364fdc1bebeca9d1a257df2cacce06b35d6/code-insiders-1.55.0-1614959504.el7.x86_64.rpm
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
	local CODENAME=$(basename "${TARGET_URL}")
	enforce_variable_with_value CODENAME "${CODENAME}"
	local DOWNLOADFOLDER="${USER_HOME}/Downloads"
	enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
 	_do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
  _install_rpm "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}" 0
} # end _fedora__64

_main() {
  determine_os_and_fire_action
} # end _main

_main

echo ":)"