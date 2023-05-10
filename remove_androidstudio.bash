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
      (( DEBUG )) && echo "$0 tasks_base/load_struct_testing Loading locally"
      structsource="""$(<"${provider}")"""
      _err=$?
      [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. running 'source locally' returned error did not download or is empty err:$_err  \n \n  " && exit 1
    else
      if ( command -v curl >/dev/null 2>&1; )  ; then
        (( DEBUG )) && echo "$0 tasks_base/load_struct_testing curl Loading struct_testing from the net using curl "
        structsource="""$(curl https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing  -so -   2>/dev/null )"""  #  2>/dev/null suppress only curl download messages, but keep curl output for variable
        _err=$?
        [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. running 'curl' returned error did not download or is empty err:$_err  \n \n  " && exit 1
      elif ( command -v wget >/dev/null 2>&1; ) ; then
        (( DEBUG )) && echo "$0 tasks_base/load_struct_testing wget Loading struct_testing from the net using wget "
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
    (( DEBUG )) && echo "$0 tasks_base/load_struct_testing  Temp location ${_temp_dir}/struct_testing"
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



 #---------/\/\/\-- tasks_base/load_struct_testing -------------/\/\/\--------





 #--------\/\/\/\/-- tasks_templates_sudo/androidstudio …install_androidstudio.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/bash

_debian_flavor_install() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _debian_flavor_install

_redhat_flavor_install() {
  echo "Procedure not yet implemented. I don't know what to do."
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

say ";;"
say  "Removing all AndroidStudio Following instructions form "
say  "REF: https://stackoverflow.com/questions/17625622/how-to-completely-uninstall-android-studio-on-mac"
say ";;" 
  # Over write say with text version since Struct Testing say will speak on mac 
  HOW_TO_LOAD_JUST_ONE_SCRIPT_LOCAL_AND_ONLINE_EXECUTE_COMMAND
say  "Deletes the Android Studio application"
say  "Note that this may be different depending on what you named the application as, or whether you downloaded the preview version"
anounce_command rm -Rf /Applications/Android\ Studio.app
say  "Delete All Android Studio related preferences"
say  "The asterisk here should target all folders/files beginning with the string before it"
anounce_command rm -Rf ~/Library/Preferences/AndroidStudio*
anounce_command rm -Rf ~/Library/Preferences/Google/AndroidStudio*
say  "Deletes the Android Studio's plist file"
anounce_command rm -Rf ~/Library/Preferences/com.google.android.*
say  "Deletes the Android Emulator's plist file"
anounce_command rm -Rf ~/Library/Preferences/com.android.*
say  "Deletes mainly plugins (or at least according to what mine (Edric) contains)"
anounce_command rm -Rf ~/Library/Application\ Support/AndroidStudio*
anounce_command rm -Rf ~/Library/Application\ Support/Google/AndroidStudio*
say  "Deletes all logs that Android Studio outputs"
anounce_command rm -Rf ~/Library/Logs/AndroidStudio*
anounce_command rm -Rf ~/Library/Logs/Google/AndroidStudio*
say  "Deletes Android Studio's caches"
anounce_command rm -Rf ~/Library/Caches/AndroidStudio*
anounce_command rm -Rf ~/Library/Caches/Google/AndroidStudio*
say  "Deletes older versions of Android Studio"
anounce_command rm -Rf ~/.AndroidStudio*
say ";;"
say "If you would like to delete all projects:"
say ";;"
anounce_command rm -Rf ~/AndroidStudioProjects
say ";;"
say "To remove gradle related files (caches & wrapper)"
say ";;"
anounce_command rm -Rf ~/.gradle
say ";;"
say "Use the below command to delete all Android Virtual Devices(AVDs) and keystores."
say ";;"
say "Note: This folder is used by other Android IDEs as well, so if you still using other IDE you may not want to delete this folder)"
say ";;"
anounce_command rm -Rf ~/.android
say ";;"
say "To delete Android SDK tools"
say ";;"
anounce_command rm -Rf ~/Library/Android*
say ";;"
say "Emulator Console Auth Token"
say ";;"
anounce_command rm -Rf ~/.emulator_console_auth_token

} # end _darwin__64

_tar() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end tar

_windows__64() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _windows__64

_windows__32() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _windows__32



 #--------/\/\/\/\-- tasks_templates_sudo/androidstudio …install_androidstudio.bash” -- Custom code-/\/\/\/\-------


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo "🥦"
exit 0
