#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
# 20200415 Compatible with Fedora, Mac, Ubuntu "sudo_up" "load_struct" "#
set -u
set -E -o functrace
export THISSCRIPTCOMPLETEPATH


echo "0. sudologic $0 Start Checking realpath  "
if ! ( command -v realpath >/dev/null 2>&1; )  ; then
  echo "... realpath not found. Downloading REF:https://github.com/swarmbox/realpath.git "
  cd $HOME
  git clone https://github.com/swarmbox/realpath.git
  cd realpath
  make
  sudo make install
  _err=$?
  [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Builing realpath. returned error did not download or is installed err:$_err  \n \n  " && exit 1
else
  echo "... realpath exists .. check!"
fi

typeset -r THISSCRIPTCOMPLETEPATH="$(realpath  "$0")"   # updated realpath macos 20210902
export BASH_VERSION_NUMBER
typeset BASH_VERSION_NUMBER=$(echo $BASH_VERSION | cut -f1 -d.)

export  THISSCRIPTNAME
typeset -r THISSCRIPTNAME="$(basename "$0")"

export _err
typeset -i _err=0

  function _trap_on_error(){
    #echo -e "\\n \033[01;7m*** ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m"
    local cero="$0"
    local file1="$(paeth ${BASH_SOURCE})"
    local file2="$(paeth ${cero})"
    echo -e "ERROR TRAP $THISSCRIPTNAME
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
ERR ..."
    exit 1
  }
  trap _trap_on_error ERR
  function _trap_on_int(){
    # echo -e "\\n \033[01;7m*** INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n  INT ...\033[0m"
    local cero="$0"
    local file1="$(paeth ${BASH_SOURCE})"
    local file2="$(paeth ${cero})"
    echo -e "INTERRUPT TRAP $THISSCRIPTNAME
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
INT ..."
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
    local _library="${1:-struct_testing}"
    local -i _DEBUG=${DEBUG:-0}
    if [[ -z "${1}" ]] ; then
    {
       echo "Must call with name of library example: struct_testing execute_command"
       exit 1
    }
    fi
    trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
      local provider="$HOME/_/clis/execute_command_intuivo_cli/${_library}"
      if [[ -n "${SUDO_USER:-}" ]] && [[ -n "${HOME:-}" ]] && [[ "${HOME:-}" == "/root" ]] && [[ !  -e "${provider}"  ]] ; then
      {
        provider="/home/${SUDO_USER}/_/clis/execute_command_intuivo_cli/${_library}"
      }
      elif [[ -z "${SUDO_USER:-}" ]] && [[ -n "${HOME:-}" ]] && [[ "${HOME:-}" == "/root" ]] && [[ !  -e "${provider}"  ]] ; then
      {
        provider="/home/${USER}/_/clis/execute_command_intuivo_cli/${_library}"
      }
      fi
      echo "$0: ${provider}" 
      echo "$0: SUDO_USER:${SUDO_USER:-nada SUDOUSER}: USER:${USER:-nada USER}: ${SUDO_HOME:-nada SUDO_HOME}: {${HOME:-nada HOME}}" 
      local _err=0 structsource
      if [[  -e "${provider}" ]] ; then
        if (( _DEBUG )) ; then
          echo "$0: tasks_base/sudoer.bash Loading locally"
        fi
        structsource="""$(<"${provider}")"""
        _err=$?
        if [ $_err -gt 0 ] ; then
        {
           echo -e "\n \n  ERROR! Loading ${_library}. running 'source locally' returned error did not download or is empty err:$_err  \n \n  " 
           exit 1
        }
        fi
      else
        if ( command -v curl >/dev/null 2>&1; )  ; then
          if (( _DEBUG )) ; then
            echo "$0: tasks_base/sudoer.bash Loading ${_library} from the net using curl "
          fi
          structsource="""$(curl https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/${_library}  -so -   2>/dev/null )"""  #  2>/dev/null suppress only curl download messages, but keep curl output for variable
          _err=$?
          if [ $_err -gt 0 ] ; then
          {
            echo -e "\n \n  ERROR! Loading ${_library}. running 'curl' returned error did not download or is empty err:$_err  \n \n  "
            exit 1
          }
          fi
        elif ( command -v wget >/dev/null 2>&1; ) ; then
          if (( _DEBUG )) ; then
            echo "$0: tasks_base/sudoer.bash Loading ${_library} from the net using wget "
          fi
          structsource="""$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/${_library} -O -   2>/dev/null )"""  #  2>/dev/null suppress only wget download messages, but keep wget output for variable
          _err=$?
          if [ $_err -gt 0 ] ; then
          {
            echo -e "\n \n  ERROR! Loading ${_library}. running 'wget' returned error did not download or is empty err:$_err  \n \n  "
            exit 1
          }
          fi
        else
          echo -e "\n \n  ERROR! Loading ${_library} could not find wget or curl to download  \n \n "
          exit 69
        fi
      fi
      if [[ -z "${structsource}" ]] ; then
      {
        echo -e "\n \n  ERROR! Loading ${_library} into ${_library}_source did not download or is empty " 
        exit 1
      }
      fi
      local _temp_dir="$(mktemp -d 2>/dev/null || mktemp -d -t "${_library}_source")"
      echo "${structsource}">"${_temp_dir}/${_library}"
      if (( _DEBUG )) ; then
        echo "$0: tasks_base/sudoer.bash Temp location ${_temp_dir}/${_library}"
      fi
      source "${_temp_dir}/${_library}"
      _err=$?
      if [ $_err -gt 0 ] ; then
      {
        echo -e "\n \n  ERROR! Loading ${_library}. Occured while running 'source' err:$_err  \n \n  "
        exit 1
      }
      fi
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
if [ $_err -ne 0 ] ; then
{
  echo -e "\n \n  ERROR FATAL! load_struct_testing_wget !!! returned:<$_err> \n \n  "
  exit 69;
}
fi

export sudo_it
function sudo_it() {
  local -i _DEBUG=${DEBUG:-}
	raise_to_sudo_and_user_home
  local _err=$?
  if (( _DEBUG )) ; then
    Comment _err:${_err}
  fi
  if [ $_err -gt 0 ] ; then
  {
    failed to sudo_it raise_to_sudo_and_user_home
    exit 1
  }
  fi
  # [ $_err -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
  _err=$?
  if (( _DEBUG )) ; then
    Comment _err:${_err}
  fi
  enforce_variable_with_value SUDO_USER "${SUDO_USER}"
  enforce_variable_with_value SUDO_UID "${SUDO_UID}"
  enforce_variable_with_value SUDO_COMMAND "${SUDO_COMMAND}"
  # Override bigger error trap  with local
  function _trap_on_err_int(){
    # echo -e "\033[01;7m*** ERROR OR INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR INT ...\033[0m"
    local cero="$0"
    local file1="$(paeth ${BASH_SOURCE})"
    local file2="$(paeth ${cero})"
    echo -e " ERROR OR INTERRUPT  TRAP $THISSCRIPTNAME
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
ERR INT ..."
    exit 1
  }
  trap _trap_on_err_int ERR INT
} # end sudo_it

# _linux_prepare(){
  sudo_it
  _err=$?
	typeset -i tomporalDEBUG=${DEBUG:-}
  if (( tomporalDEBUG )) ; then
    Comment _err:${_err}
  fi
  if [ $_err -gt 0 ] ; then
  {
    failed to sudo_it raise_to_sudo_and_user_home
    exit 1
  }
  fi
  # [ $_err -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
  _err=$?
  if (( tomporalDEBUG )) ; then
    Comment _err:${_err}
  fi
  # [ $? -gt 0 ] && (failed to sudo_it raise_to_sudo_and_user_home  || exit 1)
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
if (( tomporalDEBUG )) ; then
  passed "Caller user identified:${SUDO_USER}"
fi
  if (( tomporalDEBUG )) ; then
    Comment DEBUG_err?:${?}
  fi
if (( tomporalDEBUG )) ; then
  passed "Home identified:${USER_HOME}"
fi
  if (( tomporalDEBUG )) ; then
    Comment DEBUG_err?:${?}
  fi
directory_exists_with_spaces "${USER_HOME}"



 #---------/\/\/\-- tasks_base/sudoer.bash -------------/\/\/\--------





 #--------\/\/\/\/-- tasks_templates_sudo/masterpdf …install_masterpdf.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/env bash
#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
# SUDO_USER only exists during execution of sudo
# REF: https://stackoverflow.com/questions/7358611/get-users-home-directory-when-they-run-a-script-as-root
# Global:

echo enforce_variable_with_value SUDO_USER "${SUDO_USER}"
enforce_variable_with_value SUDO_USER "${SUDO_USER}"
passed Caller user identified:$SUDO_USER
echo enforce_variable_with_value USER_HOME "${USER_HOME}"
enforce_variable_with_value USER_HOME "${USER_HOME}"
passed Home identified:$USER_HOME
directory_exists_with_spaces "$USER_HOME"


# https://code.visualstudio.com/docs/?dv=linux64_rpm
get_lastest_studio_code_version() {
    local WEBPAGE_TO_READ_VERSION_NUMBER=$(curl -sSLo -  https://code.visualstudio.com/docs/?dv=linux32_deb&build=insiders  2>&1;) # suppress only wget download messages, but keep wget output for variable
    echo "${WEBPAGE_TO_READ_VERSION_NUMBER}" | grep 'facebook'  | head -3
    local VERSION_NUMBER=$(echo "${VERSION_NUMBER}" | grep 'direct download link ....' )
    wait
	    [[ -z "${VERSION_NUMBER}" ]] && failed "Master PDF Editor Version not found! :${VERSION_NUMBER}:"
    echo "${VERSION_NUMBER}"
    if [ -z "${VERSION_NUMBER}" ] ; then  # if empty
    {
      failed Could not find Code version
    }
    fi

} # end get_lastest_studio_code_version

_download_just_download() {
  #  url  https://code-industry.net/public/master-pdf-editor-3133_amd64.deb
  _trap_try_start
  local target_url="${1}"
  if [ -z "${target_url}" ] ; then  # if empty
  {
    failed Could not load target_url string or it was empty
  }
  fi
  _trap_catch_check
  # wget --directory-prefix="${USER_HOME}/Downloads/" --quiet --no-check-certificate "${target_url}" 2>/dev/null
  echo -e "\033[01;7m*** Downloading file to temp location...\033[0m"
  if ( command -v wget >/dev/null 2>&1; ) ; then
    # # REF: about :> http://unix.stackexchange.com/questions/37507/what-does-do-here
    _trap_try_start
    :> wgetrc   # here :> equals to Equivalent to the following: cat /dev/null > wgetrc which Nulls out the file called "wgetrc" in the current directory. As in creates an empty file "wgetrc" if one doesn't exist or overwrites one with nothing if it does.
    _trap_catch_check
    file_exists_with_spaces wgetrc
    _trap_try_start
    echo "noclobber=off" >> wgetrc
    _trap_catch_check
    echo "dir_prefix=." >> wgetrc
    echo "dirstruct=off" >> wgetrc
    echo "verbose=off" >> wgetrc    # NOTE Can't be verbose and quiet at the same time.--quiet
    echo "progress=bar:default" >> wgetrc
    echo "tries=3" >> wgetrc
    # _trap_try_start # _trap_catch_check
    # WGETRC=wgetrc wget --directory-prefix="${USER_HOME}/Downloads/" --quiet --no-check-certificate "${target_url}" 2>/dev/null
    #  _trap_catch_check
    # WGETRC=wgetrc wget --quiet --no-check-certificate "${target_url}" 2>/dev/null   # suppress only wget download messages, but keep wget output for variable
    _try "WGETRC=wgetrc wget --directory-prefix=\"${USER_HOME}/Downloads/\" --quiet --no-check-certificate \"${target_url}\"" # 2>/dev/null"
    echo -e "\033[7m*** Download Wget executed completed.\033[0m"
    rm -f wgetrc
    file_does_not_exist_with_spaces wgetrc
  elif ( command -v curl >/dev/null 2>&1; ); then
    curl -O "${target_url}" 2>/dev/null   # suppress only wget download messages, but keep wget output for variable
    _assure_success
  else
    failed "I cannot find wget or curl programs to perform a download action! ${target_url}"
  fi
}

_darwin__64() {
    local CODENAME="MasterPDFEditor.dmg"
    local URL="https://code-industry.net/public/"
    cd $USER_HOME/Downloads/
    _download "${URL}"
    sudo hdiutil attach ${CODENAME}
    sudo cp -R /Volumes/Master\ PDF\ Editor/Master\ PDF\ Editor.app /Applications/
    sudo hdiutil detach /Volumes/Master\ PDF\ Editor
} # end _darwin__64

_ubuntu__64() {
    local CODENAME="master-pdf-editor-${VERSION_NUMBER}-qt5.amd64.deb"
    local URL="https://code-industry.net/public/"
    cd $USER_HOME/Downloads/
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
} # end _ubuntu__64

_ubuntu__32() {
    local CODENAME="master-pdf-editor-${VERSION_NUMBER}.i386.deb"
    local URL="https://code-industry.net/public/"
    cd $USER_HOME/Downloads/
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
} # end _ubuntu__32

_centos__64() {
  _fedora__64
} # end _centos__64

_fedora__64() {
   # https://code-industry.net/public/master-pdf-editor-5.4.38-qt5.x86_64.rpm
  # get download link
  # https://code.visualstudio.com/docs/?dv=linux64_rpm
    local WEBPAGE_TO_READ_VERSION_NUMBER=$(curl -sSLo -  https://code-industry.net/get-masterpdfeditor/  2>&1;) # suppress only wget download messages, but keep wget output for variable
    local VERSION_NUMBER=$(echo $WEBPAGE_TO_READ_VERSION_NUMBER | sed s/\</\\n\</g | grep "now available for Linux" | sed s/\>/\>\\n/g | sed s/\ /\\n/g | head -3 | tail -1)
    local ARCHITECTURE=$(uname -m)
    echo enforce_variable_with_value ARCHITECTURE "${ARCHITECTURE}"
    enforce_variable_with_value ARCHITECTURE "${ARCHITECTURE}"
    wait
    [[ -z "${VERSION_NUMBER}" ]] && failed "Master PDF Version not found! :${VERSION_NUMBER}:"

    local WEBPAGE_TO_GET_DOWNLOAD_FILE=$(curl -sSLo -  https://code-industry.net/free-pdf-editor/\#get  2>&1;)
    local LASTEST_DOWNLOAD_FILE=$(echo $WEBPAGE_TO_GET_DOWNLOAD_FILE | sed s/\</\\n\</g | grep --color=none -E "${CODELASTESTBUILD}.*${ARCHITECTURE}.*.rpm" | cut -d'>' -f2 | tail -1)

    passed "Master PDF Version :${VERSION_NUMBER}:"
    [[ -z "${LASTEST_DOWNLOAD_FILE}" ]] && failed "Master PDF Version Dowload File NOT found! :${LASTEST_DOWNLOAD_FILE}:"
    passed "Master PDF Version Download File :${LASTEST_DOWNLOAD_FILE}:"
    local TARGET_URL=$(echo $WEBPAGE_TO_GET_DOWNLOAD_FILE | sed s/\</\\n\</g | grep --color=none -E "${CODELASTESTBUILD}.*${ARCHITECTURE}.*.rpm" | sed s/\ /\\n\</g | grep http | cut -d'"' -f2 | tail -1)
    [[ -z "${TARGET_URL}" ]] && failed "Master PDF Version Target URL NOT found! :${Target URL}:"
    passed "Master PDF Version Target URL :${TARGET_URL}:"

  # get download link
  local ID
  local VERSION
  local VERSION_ID
  file_exists_with_spaces "/etc/os-release"
  _assure_success

  source /etc/os-release
  # $ echo $ID
  # fedora
  # $ echo $VERSION_ID
  # 17
  # $ echo $VERSION
  # 17 (Beefy Miracle)
  echo  enforce_variable_with_value ID "${ID}"
  enforce_variable_with_value ID "${ID}"
  echo enforce_variable_with_value VERSION_ID "${VERSION_ID}"
  enforce_variable_with_value VERSION_ID "${VERSION_ID}"
  echo enforce_variable_with_value USER_HOME "${USER_HOME}"
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  echo enforce_variable_with_value VERSION_NUMBER "${VERSION_NUMBER}"
  enforce_variable_with_value VERSION_NUMBER "${VERSION_NUMBER}"
  local TARGET_DOWNLOAD_PATH="$USER_HOME/Downloads/${LASTEST_DOWNLOAD_FILE}"
  function download_part() {
    if  it_exists_with_spaces "${TARGET_DOWNLOAD_PATH}" ; then
    {
      file_exists_with_spaces "${TARGET_DOWNLOAD_PATH}"
    }
    else
    {
      file_exists_with_spaces $USER_HOME/Downloads
      cd $USER_HOME/Downloads
      _download "${TARGET_URL}" $USER_HOME/Downloads  ${LASTEST_DOWNLOAD_FILE}
      file_exists_with_spaces "${TARGET_DOWNLOAD_PATH}"
    }
    fi
    } # end download_part
  download_part

  function install_rpm_part() {
    if  it_exists_with_spaces "${TARGET_DOWNLOAD_PATH}" ; then
    {
      echo Attempting to install "${TARGET_DOWNLOAD_PATH}"
    } else {
      return
    }
    fi
    ensure rpm or "Canceling Install. Could not find rpm command to execute install"
    _trap_try_start # _trap_catch_check
    local msg=$(rpm -ivh "${TARGET_DOWNLOAD_PATH}")
    _trap_catch_check
    echo "${msg}"
    if [[ "${msg}" == *"not an rpm package"* ]] ; then
    {
      download_part
      install_rpm_part
    }
    elif [[ "${msg}" == *"Failed dependencies"* ]] && [[ "${msg}" == *"is needed"* ]] ; then
    {

      echo "Suggested Fix "
      echo "# when error error: Failed dependencies:
            #	     libQt5Svg.so.5()(64bit) is needed by master-pdf-editor-5.4.38-1.x86_64
            # then correct with
            # fix with
            # then fix with
            # sudo dnf -y install qt5-devel qt-creator qt5-qtbase qt5-qtbase-devel
            # rpm again"
      failed "ERROR MSG:\n ${msg}"
    }
    else
    {
      passed "Seems there were no errors"
    }
    fi

    rm -f "${TARGET_DOWNLOAD_PATH}"
  } # end install_rpm_part
  install_rpm_part

}

_mingw__64() {
    local CODENAME="MasterPDFEditor-setup.exe"
    cd $HOMEDIR
	    cd Downloads
    curl -O https://code-industry.net/public/${CODENAME}
    ${CODENAME}
} # end _mingw__64

_mingw__32() {
    local CODENAME="MasterPDFEditor-setup.exe"
    cd $HOMEDIR
    cd Downloads
	    curl -O https://code-industry.net/public/${CODENAME}
	    ${CODENAME}
} # end

_main() {
  determine_os_and_fire_action
} # end _main

_main

echo ":)"



 #--------/\/\/\/\-- tasks_templates_sudo/masterpdf …install_masterpdf.bash” -- Custom code-/\/\/\/\-------


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo "🥦"
exit 0
