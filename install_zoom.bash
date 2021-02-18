#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
  export THISSCRIPTCOMPLETEPATH 
  typeset -gr THISSCRIPTCOMPLETEPATH="$(basename "$0")"   # § This goes in the FATHER-MOTHER script 
  export _err 
  typeset -i _err=0 

function raise_to_sudo_and_user_home() {
  # export  THISSCRIPTCOMPLETEPATH
  # typeset -gr THISSCRIPTCOMPLETEPATH="$(basename "$0")"
  # export _err
  # typeset -i _err=0
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

  # Overwrite trap
  # function _trap_on_exit(){
    # echo -e "\033[01;7m*** TRAP $THISSCRIPTCOMPLETEPATH EXITS ...\033[0m"
  # }
  #trap kill ERR
  # trap _trap_on_exit EXIT
  #trap kill INT
} # end raise_to_sudo_and_user_home
load_struct_testing_wget(){
    local provider="$HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    [   -e "${provider}"  ] && source "${provider}" && echo "Loaded locally"
    [ ! -e "${provider}"  ] && eval """$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing -O -  2>/dev/null )"""   # suppress only wget download messages, but keep wget output for variable
    ( ( ! command -v passed >/dev/null 2>&1; ) && echo -e "\n \n  ERROR! Loading struct_testing \n \n " && exit 69; )
} # end load_struct_testing_wget
load_struct_testing_wget


_downloadfile_link(){
	_downloadfile_link "${PLATFORM}"  "${CODELASTESTBUILD}" "${URL}"
	local CODENAME=""
  case ${1} in
  mac)
    CODENAME="${3}-${2}.dmg"
    ;;

  windows)
    CODENAME="${3}-${2}.exe"
    CODENAME="${3}-${2}.win.zip"
    ;;

  linux)
    CODENAME="${3}-${2}.tar.gz"
    ;;

  *)
    CODENAME=""
    ;;
  esac
  echo "${CODENAME}" 
  return 0
} # end _downloadfile_link

_version() {
  local URL="${1}"      # https://www.website.com/product/
  #                    param order varname    varvalue    sampleregex
  enforce_parameter_with_value 1 URL "${URL}" "https://www.website.com/product/"
  local PLATFORM="${2}" # mac windows linux
  #                    param order varname    varvalue      validoptions
  enforce_parameter_with_options 2 PLATFORM "${PLATFORM}" "mac windows linux"
  local PATTERN="${3}"
  #                    param order varname    varvalue    sampleregex
  enforce_parameter_with_value 3 PATTERN "${PATTERN}" "BCompareOSX*.*.*.*.zip"
  DEBUG=1
  local CODEFILE="""$(wget --quiet --no-check-certificate  "${URL}" -O -  2>/dev/null )""" # suppress only wget download messages, but keep wget output for variable
  enforce_variable_with_value CODEFILE "${CODEFILE}"
  local CODELASTESTBUILD=$(_extract_version "${CODEFILE}")
  enforce_variable_with_value CODELASTESTBUILD "${CODELASTESTBUILD}"
  echo "${CODELASTESTBUILD}"
  return 0
} # end _version

function _install_rpm() {
	local TARGET_URL="${1}"
	enforce_parameter_with_value 1 TARGET_URL "${TARGET_URL}" "https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm"
	local DOWNLOADFOLDER="${2}"
	enforce_parameter_with_value 2 DOWNLOADFOLDER "${DOWNLOADFOLDER}" "$USER_HOME/Downloads"
	local CODENAME="${3}"
	enforce_parameter_with_value 3 CODENAME "${CODENAME}" "teamviewer.x86_64.rpm"
	local -i LOOP="${4}"
	enforce_parameter_with_value 4 LOOP "${LOOP}" "1 or 2 or 0"
	file_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
	local TARGET_DOWNLOAD_PATH="${DOWNLOADFOLDER}/${CODENAME}"
	enforce_parameter_with_value COMPOSITE TARGET_DOWNLOAD_PATH "${TARGET_DOWNLOAD_PATH}" "$USER_HOME/Downloads/teamviewer.x86_64.rpm"
	
    if  it_exists_with_spaces "${TARGET_DOWNLOAD_PATH}" ; then
    {
      echo Attempting to install "${TARGET_DOWNLOAD_PATH}"
    } 
    else 
    {
      return 1
    }
    fi
    ensure rpm or "Canceling Install. Could not find rpm command to execute install"
    ensure dnf or "Canceling Install. Could not find dnf command to execute install"
    _trap_try_start # _trap_catch_check
    local msg=$(dnf install -y "${TARGET_DOWNLOAD_PATH}")
    _trap_catch_check
    echo "${msg}"
    if [[ "${msg}" == *"not an rpm package"* ]] ; then
    {
    	Warning Package appearts broken, downloading again
      _download "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
      _install_rpm "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
    } 
    elif [[ "${msg}" == *"libQt5WebKit.so.5"* ]] && [[ "${msg}" == *"is needed"* ]] && (( ! LOOP )) ; then  
    {
		  echo "Suggested Fix "
      echo "# when error error: Failed dependencies:
            #	     libQt5Svg.so.5()(64bit) is needed by "${CODENAME}"
            # then correct with
            # fix with
            # then fix with
            # sudo dnf install -y qt5-devel qt-creator qt5-qtbase qt5-qtbase-devel
            # rpm again"
      Attempting to fix 
      dnf install -y qt5-devel qt-creator qt5-qtbase qt5-qtbase-devel
      _install_rpm "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}" 1
    }
    elif [[ "${msg}" == *"libQt5WebKit.so.5"* ]] && [[ "${msg}" == *"is needed"* ]] && (( LOOP )) ; then  
    {
		  echo "Suggested Fix "
      echo "# when error error: Failed dependencies:
            #	     libQt5Svg.so.5()(64bit) is needed by "${CODENAME}"
            # then correct with
            # fix with
            # then fix with
            # sudo dnf install -y qt5-devel qt-creator qt5-qtbase qt5-qtbase-devel
            # I could not install it automatically
            # rpm again"
      failed "ERROR MSG:\n ${msg}"
    }
    elif [[ "${msg}" == *"Failed dependencies"* ]] && [[ "${msg}" == *"is needed"* ]] ; then  
    {
      # echo "Suggested Fix "
      # echo "# when error error: 
      #       # fix with
      #       # then fix with
      #       # rpm again"
      failed "ERROR MSG:\n ${msg}"
    } 
    else 
    {
      passed "Seems there were no errors"
    }
    fi
    rm -f "${TARGET_DOWNLOAD_PATH}"
    return 0
} # end _install_rpm

_extract_version(){
	echo "${*}" | sed s/\</\\n\</g | sed s/\>/\>\\n/g | sed "s/&apos;/\'/g" | sed 's/&nbsp;/ /g' | grep  "New in WebStorm ${PATTERN}" | sed s/\ /\\n/g | tail -1  
	# | grep "What&apos;s New in&nbsp;WebStorm&nbsp;" | sed 's/\;/\;'\\n'/g' | sed s/\</\\n\</g  )
} # end _extract_version

_do_not_downloadtwice(){
	local TARGET_URL="${1}"
	enforce_parameter_with_value 1 TARGET_URL "${TARGET_URL}" "https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm"
	local DOWNLOADFOLDER="${2}"
	enforce_parameter_with_value 2 DOWNLOADFOLDER "${DOWNLOADFOLDER}" "$USER_HOME/Downloads"
	local CODENAME="${3}"
	enforce_parameter_with_value 3 CODENAME "${CODENAME}" "teamviewer.x86_64.rpm"
	
	if it_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}" ; then
  {
    file_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
  }
  else
  {
    cd "${DOWNLOADFOLDER}"
    _download "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
    file_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
  }
  fi
  return 0
} # end _do_not_downloadtwice

_fedora__64() {
	raise_to_sudo_and_user_home
	[ $? -gt 0 ] && failed to raise_to_sudo_and_user_home 
	# [ $? -gt 0 ] && exit 1
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  local TARGET_URL=https://zoom.us/client/latest/zoom_x86_64.rpm
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