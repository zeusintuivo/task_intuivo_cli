#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
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


set -E -o functrace

load_struct_testing_wget(){
    local provider="$HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    [   -e "${provider}"  ] && source "${provider}"
    [ ! -e "${provider}"  ] && eval """$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing -O -  2>/dev/null )"""   # suppress only wget download messages, but keep wget output for variable
    ( ( ! command -v passed >/dev/null 2>&1; ) && echo -e "\n \n  ERROR! Loading struct_testing \n \n " && exit 69; )
} # end load_struct_testing_wget
load_struct_testing_wget

get_lastest_sublime_version() {
    local SUBLIMELASTESTBUILD=$(curl -L https://www.sublimetext.com/3  2>/dev/null | sed -n "/<p\ class=\"latest\">/,/<\/div>/p" | head -1 | grep 'Build ....' | cut -c42-45)  # suppress only wget download messages, but keep wget output for variable
    wait
    [[ -z "${SUBLIMELASTESTBUILD}" ]] && failed "Sublime Version not found!"
    echo "${SUBLIMELASTESTBUILD}"
}
download_sublime() {
  # sample https://download.sublimetext.com/sublime-text_build-3133_amd64.deb
  if ( command -v wget >/dev/null 2>&1; ) ; then
    wget --quiet --no-check-certificate "https://download.sublimetext.com/${1}" 2>/dev/null   # suppress only wget download messages, but keep wget output for variable
  elif ( command -v curl >/dev/null 2>&1; ); then
    curl -O "https://download.sublimetext.com/${1}" 2>/dev/null   # suppress only wget download messages, but keep wget output for variable
  else
    failed "I cannot find wget or curl to download! https://download.sublimetext.com/${1}"
  fi
}
install_darwin_lastest_sublime_64() {
    local SUBLIMELASTESTBUILD=$(get_lastest_sublime_version)
    local SUBLIMENAME="Sublime%20Text%20Build%20${SUBLIMELASTESTBUILD}.dmg"

    wait
    cd ~/Downloads/
    download_sublime "${SUBLIMENAME}"
    wait
    sudo hdiutil attach ${SUBLIMENAME}
    wait
    sudo cp -R /Volumes/Sublime\ Text/Sublime\ Text.app /Applications/
    wait
    sudo hdiutil detach /Volumes/Sublime\ Text
    wait
} # end install_darwin_lastest_sublime_64

install_linux_lastest_sublime_64() {
    local SUBLIMELASTESTBUILD=$(get_lastest_sublime_version)
    local SUBLIMENAME="sublime-text_build-${SUBLIMELASTESTBUILD}_amd64.deb"
    wait
    cd ~/Downloads/
    download_sublime "${SUBLIMENAME}"
    wait
    sudo dpkg -i ${SUBLIMENAME}
    wait
} # end install_linux_lastest_sublime_64

install_linux_lastest_sublime_32() {
    local SUBLIMELASTESTBUILD=$(get_lastest_sublime_version)
    local SUBLIMENAME="sublime-text_build-${SUBLIMELASTESTBUILD}_i386.deb"
    wait
    cd ~/Downloads/
    download_sublime "${SUBLIMENAME}"
    wait
    sudo dpkg -i ${SUBLIMENAME}
    wait
} # end install_linux_lastest_sublime_32

install_windows_lastest_sublime_64() {
    local SUBLIMELASTESTBUILD=$(curl -L https://www.sublimetext.com/3 | sed -n "/<p\ class=\"latest\">/,/<\/div>/p" | head -1 | grep 'Build ....' | cut -c42-45)
    wait
    local SUBLIMENAME="Sublime%20Text%20Build%20${SUBLIMELASTESTBUILD}%20x64%20Setup.exe"
    wait
    cd $HOMEDIR
    cd Downloads
    curl -O https://download.sublimetext.com/${SUBLIMENAME}
    ${SUBLIMENAME}
    wait
} # end install_windows_lastest_sublime_64

install_windows_lastest_sublime_32() {
    local SUBLIMELASTESTBUILD=$(curl -L https://www.sublimetext.com/3 | sed -n "/<p\ class=\"latest\">/,/<\/div>/p" | head -1 | grep 'Build ....' | cut -c42-45)
    wait
    local SUBLIMENAME="Sublime%20Text%20Build%20${SUBLIMELASTESTBUILD}%20Setup.exe"
    wait
    cd $HOMEDIR
    cd Downloads
    curl -O https://download.sublimetext.com/${SUBLIMENAME}
    ${SUBLIMENAME}
    wait
} # end install_windows_lastest_sublime_32

# check operation systems
if [[ "$(uname)" == "Darwin" ]] ; then
  # Do something under Mac OS X platform
    [[ "$(uname -m)" == "x86_64" ]] && install_darwin_lastest_sublime_64 "$@"
    [[ "$(uname -m)" == "i686"   ]] && install_darwin_lastest_sublime_64 "$@"
elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]] ; then
  # Do something under GNU/Linux platform
  # ubuntu lsb_release -i | sed 's/Distributor\ ID://g' = \tUbuntu\n
    [[ "$(uname -i)" == "x86_64" ]] && install_linux_lastest_sublime_64 "$@"
    [[ "$(uname -i)" == "i686"   ]] && install_linux_lastest_sublime_32 "$@"
elif [[ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]] ; then
  # Do something under Windows NT platform
    [[ "$(uname -i)" == "x86_64" ]] && install_windows_lastest_sublime_64 "$*"
    [[ "$(uname -i)" == "i686"   ]] && install_windows_lastest_sublime_32 "$*"
  install_windows_lastest_sublime_64 "$*"
  # nothing here
fi



