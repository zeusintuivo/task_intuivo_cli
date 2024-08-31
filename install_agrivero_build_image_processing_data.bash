#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
# 20200415 Compatible with Fedora, Mac, Ubuntu "sudo_up" "load_struct" "#
#set -u
set -E -o functrace
export THISSCRIPTCOMPLETEPATH

echo "0. sudologic $0:$LINENO           SUDO_COMMAND:${SUDO_COMMAND:-}"
echo "0. sudologic $0:$LINENO               SUDO_GRP:${SUDO_GRP:-}"
echo "0. sudologic $0:$LINENO               SUDO_UID:${SUDO_UID:-}"
echo "0. sudologic $0:$LINENO               SUDO_GID:${SUDO_GID:-}"
echo "0. sudologic $0:$LINENO              SUDO_USER:${SUDO_USER:-}"
echo "0. sudologic $0:$LINENO                   USER:${USER:-}"
echo "0. sudologic $0:$LINENO              USER_HOME:${USER_HOME:-}"
echo "0. sudologic $0:$LINENO THISSCRIPTCOMPLETEPATH:${THISSCRIPTCOMPLETEPATH:-}"
echo "0. sudologic $0:$LINENO         THISSCRIPTNAME:${THISSCRIPTNAME:-}"
echo "0. sudologic $0:$LINENO       THISSCRIPTPARAMS:${THISSCRIPTPARAMS:-}"

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
# typeset -r THISSCRIPTCOMPLETEPATH="$(realpath "$(basename "$0")")"  # updated realpath macos 20210902  # § This goe$
export BASH_VERSION_NUMBER
typeset BASH_VERSION_NUMBER=$(echo $BASH_VERSION | cut -f1 -d.)

export  THISSCRIPTNAME
typeset -r THISSCRIPTNAME="$(basename "$0")"

export THISSCRIPTPARAMS
typeset -r THISSCRIPTPARAMS="${*:-}"
echo "0. sudologic $0:$LINENO       THISSCRIPTPARAMS:${THISSCRIPTPARAMS:-}"

export _err
typeset -i _err=0

  function _trap_on_error(){
    #echo -e "\\n \033[01;7m*** 1 ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m"
    local cero="$0"
    local file1="$(paeth ${BASH_SOURCE})"
    local file2="$(paeth ${cero})"
    echo -e "ERROR TRAP $THISSCRIPTNAME $THISSCRIPTPARAMS
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
ERR ..."
    exit 1
  }
  trap _trap_on_error ERR
  function _trap_on_int(){
    # echo -e "\\n \033[01;7m*** 1 INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n  INT ...\033[0m"
    local cero="$0"
    local file1="$(paeth ${BASH_SOURCE})"
    local file2="$(paeth ${cero})"
    echo -e "INTERRUPT TRAP $THISSCRIPTNAME $THISSCRIPTPARAMS
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
INT ..."
    exit 0
  }

  trap _trap_on_int INT

load_struct_testing(){
  function _trap_on_error(){
    local -ir __trapped_error_exit_num="${2:-0}"
		echo -e "\\n \033[01;7m*** tasks_base/sudoer.bash:$LINENO load_struct_testing() ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[1]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[2]}()  \\n$0:${BASH_LINENO[2]} ${FUNCNAME[3]}() \\n ERR ...\033[0m  \n \n "

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
          echo -e "\n \n 2  ERROR! Loading ${_library} could not find wget or curl to download  \n \n "
          exit 69
        fi
      fi
      if [[ -z "${structsource}" ]] ; then
      {
        echo -e "\n \n 3 ERROR! Loading ${_library} into ${_library}_source did not download or is empty "
        exit 1
      }
      fi
      local _temp_dir="$(mktemp -d 2>/dev/null || mktemp -d -t "${_library}_source")"
      echo "${structsource}">"${_temp_dir}/${_library}"
      if (( _DEBUG )) ; then
        echo "1. sudologic $0: tasks_base/sudoer.bash Temp location ${_temp_dir}/${_library}"
      fi
      source "${_temp_dir}/${_library}"
      _err=$?
      if [ $_err -gt 0 ] ; then
      {
        echo -e "\n \n 4 ERROR! Loading ${_library}. Occured while running 'source' err:$_err  \n \n  "
        exit 1
      }
      fi
      if  ! typeset -f passed >/dev/null 2>&1; then
        echo -e "\n \n 5 ERROR! Loading ${_library}. Passed was not loaded !!!  \n \n "
        exit 69;
      fi
      return $_err
  } # end load_library
  if  ! typeset -f passed >/dev/null 2>&1; then
    load_library "struct_testing"
  fi
  if  ! typeset -f load_colors >/dev/null 2>&1; then
    load_library "execute_command"
  fi
} # end load_struct_testing
load_struct_testing

 _err=$?
if [ $_err -ne 0 ] ; then
{
  echo -e "\n \n 6 ERROR FATAL! load_struct_testing_wget !!! returned:<$_err> \n \n  "
  exit 69;
}
fi

if [[ -z "${SUDO_COMMAND:-}" ]] && \
   [[ -z "${SUDO_GRP:-}" ]] && \
   [[ -z "${SUDO_UID:-}" ]] && \
   [[ -z "${SUDO_GID:-}" ]] && \
   [[ -z "${SUDO_USER:-}" ]] && \
   [[ -n "${USER:-}" ]] && \
   [[ -z "${USER_HOME:-}" ]] && \
   [[ -n "${THISSCRIPTCOMPLETEPATH:-}" ]] && \
   [[ -n "${THISSCRIPTNAME:-}" ]] \
  ; then
{
  passed Called from user
}
fi


if [[ -n "${SUDO_COMMAND:-}"  ]] && \
   [[ -z "${SUDO_GRP:-}"  ]] && \
   [[ -n "${SUDO_UID:-}"  ]] && \
   [[ -n "${SUDO_GID:-}"  ]] && \
   [[ -n "${SUDO_USER:-}"  ]] && \
   [[ -n "${USER:-}"  ]] && \
   [[ -z "${USER_HOME:-}"  ]] && \
   [[ -n "${THISSCRIPTCOMPLETEPATH:-}"  ]] && \
   [[ -n "${THISSCRIPTNAME:-}"  ]] \
  ; then
{
  passed Called from user as sudo
}
else
{

if [[ "${SUDO_USER:-}" == 'root'  ]] && \
   [[ "${USER:-}" == 'root' ]] \
  ; then
{
  failed This script is has to be called from normal user. Not Root. Abort
  exit 69
}
fi

export sudo_it
function sudo_it() {
  local -i _DEBUG=${DEBUG:-}
  local _err=$?
  # check operation systems
  if [[ "$(uname)" == "Darwin" ]] ; then
  {
    passed "sudo_it() # Do something under Mac OS X platform "
      # nothing here
      raise_to_sudo_and_user_home "${*-}"
      [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
    SUDO_USER="${USER}"
    SUDO_COMMAND="$0"
    SUDO_UID=502
    SUDO_GID=20
  }
  elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]] ; then
  {
      # Do something under GNU/Linux platform
      raise_to_sudo_and_user_home "${*-}"
      [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
      enforce_variable_with_value SUDO_USER "${SUDO_USER}"
      enforce_variable_with_value SUDO_UID "${SUDO_UID}"
      enforce_variable_with_value SUDO_COMMAND "${SUDO_COMMAND}"
      # Override bigger error trap  with local
      function _trap_on_error(){
        echo -e "\033[01;7m*** 3 ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR INT ...\033[0m"

      }
      trap _trap_on_error ERR INT
  }
  elif [[ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]] || [[ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]] ; then
  {
      # Do something under Windows NT platform
      # nothing here
    SUDO_USER="${USER}"
    SUDO_COMMAND="$0"
    SUDO_UID=502
    SUDO_GID=20
  }
  fi

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
    # echo -e "\033[01;7m*** 7 ERROR OR INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR INT ...\033[0m"
    local cero="$0"
    local file1="$(paeth ${BASH_SOURCE})"
    local file2="$(paeth ${cero})"
    echo -e " ERROR OR INTERRUPT  TRAP $THISSCRIPTNAME $THISSCRIPTPARAMS
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
ERR INT ..."
    exit 1
  }
  trap _trap_on_err_int ERR INT
} # end sudo_it

# _linux_prepare(){
  sudo_it "${*}"
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



  exit
}
fi




typeset -i tomporalDEBUG=${DEBUG:-}
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


  function _trap_on_error(){
    local -ir __trapped_error_exit_num="${2:-0}"
    echo -e "\\n \033[01;7m*** 2 ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[1]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[2]}()  \\n$0:${BASH_LINENO[2]} ${FUNCNAME[3]}() \\n ERR ...\033[0m  \n \n "
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
    exit ${__trapped_error_exit_num}
  }
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR

  function _trap_on_exit(){
    local -ir __trapped_exit_num="${2:-0}"
    echo -e "\\n \033[01;7m*** 5 EXIT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[1]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[2]}()  \\n$0:${BASH_LINENO[2]} ${FUNCNAME[3]}() \\n EXIT ...\033[0m  \n \n "
    echo ". ${1}"
    echo ". exit  ${__trapped_exit_num}  "
    echo ". caller $(caller) "
    echo ". ${BASH_COMMAND}"
    local -r __caller=$(caller)
    local -ir __caller_line=$(echo "${__caller}" | cut -d' ' -f1)
    local -r __caller_script_name=$(echo "${__caller}" | cut -d' ' -f2)
    awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}"

    # $(eval ${BASH_COMMAND}  2>&1; )
    # echo -e " ☠ ${LIGHTPINK} Offending message:  ${__bash_error} ${RESET}"  >&2
    exit ${__trapped_INT_num}
  }
  # trap  '_trap_on_exit $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  EXIT

  function _trap_on_INT(){
    local -ir __trapped_INT_num="${2:-0}"
    echo -e "\\n \033[01;7m*** 7 INT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[1]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[2]}()  \\n$0:${BASH_LINENO[2]} ${FUNCNAME[3]}() \\n INT ...\033[0m  \n \n "
    echo ". ${1}"
    echo ". INT  ${__trapped_INT_num}  "
    echo ". caller $(caller) "
    echo ". ${BASH_COMMAND}"
    local -r __caller=$(caller)
    local -ir __caller_line=$(echo "${__caller}" | cut -d' ' -f1)
    local -r __caller_script_name=$(echo "${__caller}" | cut -d' ' -f2)
    awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}"

    # $(eval ${BASH_COMMAND}  2>&1; )
    # echo -e " ☠ ${LIGHTPINK} Offending message:  ${__bash_error} ${RESET}"  >&2
    exit ${__trapped_INT_num}
  }
  trap  '_trap_on_INT $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  INT



 #---------/\/\/\-- tasks_base/sudoer.bash -------------/\/\/\--------





 #--------\/\/\/\/-- tasks_templates_sudo/agrivero_build_image_processing_data …install_agrivero_build_image_processing_data.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#


PROJECT_DIR_F=""  # GLOBAL
set -E -o functrace

_find_project_location_PROJECT_DIR_F() {
  local _target_project=""
  Checking "location of project "
  local _list_posssibles="
    ${USER_HOME}/_/work/agrivero/projects
    ${USER_HOME}/_/work/agriveo
    /repo/work/agrivero/projects
  "
  local one=""
  while read -r one ; do
  {
    [[ -z "${one}" ]] && continue
    if it_exists_with_spaces "${one}" ; then
    {
     _target_project="${one}"
     break
    }
    fi
  }
  done <<< "${_list_posssibles}"
  [[ -z "${one}" ]] && warning "Could not find/determine location of project" && return 1
  passed "found of project dir ${_target_project}"
  PROJECT_DIR_F="${_target_project}"
  return 0
} # end _find_project_location_PROJECT_DIR_F

_step1_apt_installs() {

  trap 'echo -e "${RED}" && echo "ERROR err:$_err failed $0:$LINENO _debian_flavor_install agri_pd" && echo -e "${RESET}" && return 0' ERR
  # Batch 1 18.04
  apt update -y
  local package packages="
    autoconf
    bison
    build-essential
    libssl-dev
    libyaml-dev
    # libreadline6-dev
    zlib1g-dev
    libncurses5-dev
    libffi-dev
    make
    libbz2-dev
    libreadline-dev
    libsqlite3-dev
    wget
    curl
    llvm
    libncursesw5-dev
    xz-utils
    tk-dev
    libxml2-dev
    libxmlsec1-dev
		libffi-dev
    liblzma-dev
  "
  _package_list_installer "${packages}"
  # Batch 2 20.04
  local package packages="
    gcc
    libssl-dev
    libsensors-dev
    clang
    autoconf
    bison
    build-essential
    libssl-dev
    libyaml-dev
    # libreadline6-dev
    zlib1g-dev
    libncurses5-dev
    libffi-dev
  "
  if _package_list_installer "${packages}"; then
  {
    echo "Installer returned $?"
  }
  fi


} # end _step1_apt_installs

_step2_vimba_kernel_drivers() {
  local _topic="Vimba camera drivers"
  Installing "${_topic}"
  if _msg="$(__download_file_check_checksum .camera_driver_vimba "https://developer.files.com/VimbaX_Setup-2023-4-Linux64.tar.gz" "daa552b0b116c19c8d4d784a740bd630033e6eedc334f6361d114a9ce05e2bde" 2>&1)" ; then  # capture all sdout stdout input and output  sderr stderr
  {
    _err=0
	}
  else
	{
		_err=2
	}
	fi
  if [ ${_err} -gt 0 ] ; then
  {
    failed "\n +----     while running ${_topic}  __download_file_check_checksum() above _msg: ''' \n${_msg} \n '''\n  _err:${_err} ------+ \n "
  }
  fi
  if ( command -v nvidia-smi >/dev/null 2>&1; )  ; then
  {
    nvidia-smi
  }
  fi

  echo "ref: https://docs.alliedvision.com/Vimba_X/Vimba_X_DeveloperGuide/settings.html#linux-and-arm"
  Installing "Increasing the USBFS buffer size:"
  mkdir -p /sys/module/usbcore/parameters/
  touch /sys/module/usbcore/parameters/usbfs_memory_mb
  cat /sys/module/usbcore/parameters/usbfs_memory_mb
  sudo sh -c 'echo 1000 > /sys/module/usbcore/parameters/usbfs_memory_mb'
  cat /sys/module/usbcore/parameters/usbfs_memory_mb

  Installing "Increasing the OS receive buffer size:"
  sysctl -w net.core.rmem_max=33554432
  sysctl -w net.core.wmem_max=33554432
  sysctl -w net.core.rmem_default=33554432
  sysctl -w net.core.wmem_default=33554432

  Installing "Kernel update for nvdia jetson Vimba X ref: https://github.com/alliedvision/linux_nvidia_jetson/releases"
  file_exists_with_spaces   "${USER_HOME}/Downloads/AlliedVision_NVidia_L4T_35.4.1_5.1.2.gcf4fa7ea0.tar.gz"
  mkdir -p "${USER_HOME}/Downloads/AlliedVisionDriver"
  cd "${USER_HOME}/Downloads/AlliedVisionDriver"
  cp "${USER_HOME}/Downloads/AlliedVision_NVidia_L4T_35.4.1_5.1.2.gcf4fa7ea0.tar.gz"  "${USER_HOME}/Downloads/AlliedVisionDriver"
  tar -xvf  AlliedVision_NVidia_L4T_35.4.1_5.1.2.gcf4fa7ea0.tar.gz "${USER_HOME}/Downloads/AlliedVisionDriver"
  # tar -czf folder . # perform backup
  # mkdir -p folder && cd folder && tar -xzf VimbaX_Setup-2023-4-Linux_ARM64.tar.gz # perform restore
  cd "${USER_HOME}/Downloads/AlliedVisionDriver"
	if cd "${USER_HOME}/Downloads/AlliedVisionDriver/Alli*" ; then
	{
		warning "Could  not find ${USER_HOME}/Downloads/AlliedVisionDriver/Alli*" 
	}
	fi
	Checking "from hacked install script"
	Installing "
#!/bin/bash
#==============================================================================
# Copyright (C) 2022 Allied Vision Technologies.  All Rights Reserved.
#
# Redistribution of this file, in original or modified form, without
# prior written consent of Allied Vision Technologies is prohibited.
#
#------------------------------------------------------------------------------
#
# File:         -install.sh
#
# Description:  -bash script for installing avt debian packages from tarball
#
#------------------------------------------------------------------------------
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF TITLE,
# NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR  PURPOSE ARE
# DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
# AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#==============================================================================
"
  local NC='\033[0m'
  local RED='\033[0;31m'
  local GREEN='\033[0;32m'
  local REQ_MACHINE="NVidia Jetson"
  local REQ_KERNEL="5.10.120"
  local DEST="/boot"


echo -e ${RED}"Allied Vision"${NC}" MIPI CSI-2 camera driver for "${GREEN}${REQ_MACHINE}${NC}" (kernel "${REQ_KERNEL}")"


# ========================================================= usage function
usage() {
  echo -e "Options:"
  echo -e "-h:\t Display help"
  echo -e "-y:\t Automatic install and reboot"
  exit 0
}

inst() {
  modprobe mtd_blkdevs
  modprobe mtdblock

  set -e

  echo "Extracting repository:"

  mkdir -p "/opt/avt/packages"

  tar -C /opt/avt/packages -xvf avt_l4t_repository.tar.xz

  echo "Importing Repository:"

  local AVT_NV_PACKAGES=$(apt-cache search avt-nvidia-)

  if [[ ! -z "$AVT_NV_PACKAGES" ]]; then
    apt-get --yes remove avt-nvidia-*
  fi

  if [[ -f /opt/avt/packages/KEY.gpg ]]; then
    apt-key add /opt/avt/packages/KEY.gpg

    echo "deb file:/opt/avt/packages ./" | sudo tee /etc/apt/sources.list.d/avt-l4t-sources.list
  else
    echo "deb [allow-insecure=yes] file:/opt/avt/packages ./" | sudo tee /etc/apt/sources.list.d/avt-l4t-sources.list

    local INSTALL_ARGS="--allow-unauthenticated"
  fi

#  sudo apt-get update

  echo "Installing packages:"
	
  Installing "Execute install script inside   ./install.sh -- This is a HACK ref: https://forums.balena.io/t/getting-linux-for-tegra-into-a-container-on-balena-os/179421/20 because Jetson Orin Nano has newer things tht Vimba has written for "
	echo "deb https://repo.download.nvidia.com/jetson/common r32.4 main" >> /etc/apt/sources.list
  echo "deb https://repo.download.nvidia.com/jetson/t194 r32.4 main" >> /etc/apt/sources.list
  yes |  apt-key adv --fetch-key http://repo.download.nvidia.com/jetson/jetson-ota-public.asc
  mkdir -p /opt/nvidia/l4t-packages/
  touch /opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall
  apt-get update -y
  apt-get install -y --no-install-recommends nvidia-l4t-core
  apt-get install --no-install-recommends -y \
    nvidia-l4t-firmware \
    nvidia-l4t-multimedia-utils \
    nvidia-l4t-multimedia \
    nvidia-l4t-cuda \
    nvidia-l4t-x11 \
    nvidia-l4t-camera \
    nvidia-l4t-tools \
    nvidia-l4t-graphics-demos \
    nvidia-l4t-gstreamer \
    nvidia-l4t-jetson-io \
    nvidia-l4t-configs \
    nvidia-l4t-3d-core \
    nvidia-l4t-oem-config


 # sudo apt-get $INSTALL_ARGS --reinstall install --yes avt-nvidia-l4t-bootloader avt-nvidia-l4t-kernel avt-nvidia-l4t-kernel-dtbs avt-nvidia-l4t-kernel-headers
}


# if [[ ( $1 == "-help") || ( $1 == "-h") ]]; then
#   usage
# fi

# if [[ ( $1 == "-y" ) ]]; then
  inst
#  init 6
#  exit 0
# fi


# read -p "Install kernel driver (y/n)? " answer
# case $answer in
#   [Yy]* )
#    echo -e "\nInstalling..."
#    inst
#  ;;
#  [Nn]* )
#    echo -e
#  ;;
# esac

read -p "Reboot now (y/n)? " answer
case $answer in
  [Yy]* )
    echo -e "Reboot..."
    init 6
  ;;
  [Nn]* )
    echo -e
#    exit 0
  ;;
esac

} # end _step2_vimba_kernel_drivers

_step3_processing_data() {

  Checking "needs .ssh setup before using git@git  have added .ssh keys  yet ?  sshgenerate key ?? "
  if ! it_exists_with_spaces "${USER_HOME}/.ssh/id_rsa.pub" ; then
  {
    read -p "Warning - I don't see ssh keys can you create first sshgenerate keys and acitvate sshswithkeys nd place in website github.com access before continuing . Have you done it (y/n)? " answer
    case $answer in
      [Yy]* )
				echo -e "Good boy/girl !... : ) "
      ;;
      [Nn]* )
        echo -e "Bad boy / girl ... :< "
      ;;
    esac
	}
	fi
  file_exists_with_spaces "${USER_HOME}/.ssh/id_rsa.pub"

  cd "${PROJECTSBASEDIR}"
  _git_clone "${PROJECTGITREPO}" "${PROJECTREPO}" "${PROJECTGITREPOBRANCH}"
  directory_exists_with_spaces "${PROJECTREPO}"

  cd "${PROJECTREPO}"
	mkdir -p cam_capture/images
	mkdir -p test_company/images
	chown -R "${SUDO_USER}"  "${PROJECTREPO}"

	_execute_project_command "${PROJECTREPO}" "pip install pipenv"
  # brew install pipenv  # <- takes very long but it could be an alternative
  _execute_project_command "${PROJECTREPO}" "pip install mvtec-halcon==23110"
	_execute_project_command "${PROJECTREPO}" "pipenv install"

  Installing "Torch Package from Jetpack 6 / PyTorch v2.1"
  Checking "curl https://forums.developer.nvidia.com/t/pytorch-for-jetson/72048"

	_execute_project_command "${PROJECTREPO}" "pipenv run python main.py --folder --skip_undistort --company=test_company"

} # end _step3_processing_data


_execute_project_command() {
  # Sample usage:
  #   _execute_project_command "${PROJECTREPO}" "bundle exec rake db:migrate db:migrate:emails db:migrate:credit_check "
  #   _execute_project_command "${PWD}" sdkmanager --cli
  #
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local PROJECTREPO=${1}
  enforce_parameter_with_value           1        PROJECTREPO      "${PROJECTREPO}"     "path folder where Gemfile or project is located "
  local _command=${2}
  enforce_parameter_with_value           2        _command         "${_command}"        "bash command to run"
  local _parameters="${*:3}"  # grab all parameters after second
  # _command="$(sed 's/["]/\\\"/g' <<< "${_command}")"
  echo "_command:${_command}"
  su - "${SUDO_USER}" -c  "bash -c 'cd "${PROJECTREPO}" && ${_command} ${_parameters} '"
} # end _execute_project_command

check_run_command_as_root() {
  # Sample usage:
  #  check_run_command_as_root
  #
  [[ "${EUID:-${UID}}" == "0" ]] || return

  # Allow Azure Pipelines/GitHub Actions/Docker/Concourse/Kubernetes to do everything as root (as it's normal there)
  [[ -f /.dockerenv ]] && return
  [[ -f /proc/1/cgroup ]] && grep -E "azpl_job|actions_job|docker|garden|kubepods" -q /proc/1/cgroup && return

  failed "Don't run this as root!"
}

__download_file_check_checksum() {
  # Sample usage:
  #    __download_file_check_checksum .torch_22_jetson_6_python_3_10 "https://developer.download.nvidia.cn/compute/redist/jp/v60dp/pytorch/torch-2.2.0a0+6a974be.nv23.11-cp310-cp310-linux_aarch64.whl" 94e70c4f45211737174a3c0f0b791b479c5fd9a2955ba77f573d31c0273e485e
  local -i _err=0
  local file_url_configuration="${1}"
        enforce_parameter_with_value           1        file_url_configuration      "${file_url_configuration}"     ".trained_model .torch_22_jetson_6_python_3_10 full path filename "
        if [[ ! -e "${file_url_configuration}" ]] ; then
        {
          failed "file_url_configuration=file:${file_url_configuration}  does not exists"
        }
        fi
  local sample_url_download="${2}"
        enforce_parameter_with_value           2       sample_url_download         "${sample_url_download}"     "https://developer.download.nvidia.cn/compute/redist/jp/v60dp/pytorch/torch-2.2.0a0+6a974be.nv23.11-cp310-cp310-linux_aarch64.whl"
  local hash_check_sum_to_check_against="${3}"
        enforce_parameter_with_value           3       hash_check_sum_to_check_against "${hash_check_sum_to_check_against}"    "94e70c4f45211737174a3c0f0b791b479c5fd9a2955ba77f573d31c0273e48"

  local service_url="$(<"${file_url_configuration}")"
        enforce_parameter_with_value           1        service_url      "${service_url}"    "${sample_url_download}"
        enforce_variable_with_value service_url  "${service_url}"
  local filename=$(basename "${service_url}")
        if [[ -e  "${filename}" ]] ; then
        {
          passed "Already downloaded: ${filename}"
        }
        else
        {
          ensure curl or "curl is needed to connect to download stuff - Cannot continue"
          local passwords="$(<.env)"
                enforce_parameter_with_value           2        passwords      "${passwords}"     "--proxy-user user:password --user user:password"
                enforce_variable_with_value service_url  "${passwords}"

          Intalling "Calling curl to sevice url: curl $passwords -k $service_url"
          curl $passwords -k $service_url
          _err=$?
          if [ ${_err} -gt 0 ] ; then
          {
            failed "while running curl above: curl  $passwords -k $service_url > \"${filename}\""
          }
          fi
        }
        fi

  Checking "checksum for ${filename}"
  file_exists_with_spaces "${filename}"
  local checksum=""
  checksum=$(sha256sum "${filename}" | cut -d' ' -f1)
  _err=$?
  if [ ${_err} -gt 0 ] ; then
  {
    failed "while running checksum above: sha256sum \"${filename}\""
  }
  fi
  if [[ "${checksum}" == "${hash_check_sum_to_check_against}" ]] ; then
  {
    passed "Checksum checks ${checksum}"
  }
  else
  {
    rm -rf ${filename}
    failed "removed file ${filename} Checksum DOES NOT check
		     GOT:${checksum}
		EXPECTED:${hash_check_sum_to_check_against}
	 	Try again to download again"
  }
  fi
} # end __download_file_check_checksum

_package_list_installer() {
  # trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local package packages="${@}"
  trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO _package_list_installer agri_pd" && echo -e "${RESET}" && return 0' ERR

  if ! install_requirements "linux" "${packages}" ; then
  {
    warning "installing requirements. ${CYAN} attempting to install one by one"
    while read package; do
    {
      [ -z ${package} ] && continue
      if ! install_requirements "linux" "${package}" ; then
      {
        _err=$?
        if [ ${_err} -gt 0 ] ; then
        {
          echo -e "${RED}"
          echo failed to install requirements "${package}"
          echo -e "${RESET}"
        }
        fi
      }
      fi
    }
    done <<< "${packages}"
  }
  fi
} # end _package_list_installer

_git_clone() {
  # Sample usage
  # _git_clone git@github.com:some-ai/processing_data.git  "$HOME"
  # _git_clone git@github.com:another-ai/processing_data.git  "$HOME" "i_experiment_branch"
  #
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO  _git_clone I3STATUS" && echo -e "${RESET}" && return 0' ERR
  local _source="${1-}"
  local _target="${2-}"
  local _branch="${3-}"
  Checking "${SUDO_USER} git clone ${_source}  ${_target}  --branch ${_branch} "
  pwd
  if  it_exists_with_spaces "${_target}" ; then # && it_exists_with_spaces "${_target}/.git" ; then
  {
    if it_exists_with_spaces "${_target}/.git" ; then
    {
      if ! cd "${_target}" ; then
      {
        warning Could not CD into "${_target}. There seems to be a problem"
        return 1
      }
      fi
      if [[ -n "${_branch}" ]] ; then
      {
        if ! git checkout "${_branch}" ; then
        {
          warning Could could not checkout such branch: "${_branch}"
          return 1
        }
        fi
      }
      fi
      if git config pull.rebase false ; then
      {
        warning Could not git config pull.rebase false
      }
      fi
      if git fetch  ; then
      {
        warning Could not git fetch
      }
      fi
      if git pull  ; then
      {
        warning Could not git pull
      }
      fi
    }
    fi
  }
  else
  {
    if git clone "${_source}" "${_target}"  ; then
    {
      warning Could not git clone "${_source}" "${_target}"
    }
    fi
      if ! cd "${_target}" ; then
      {
        warning Could not CD into "${_target}. There seems to be a problem. Clone failed!!!"
        return 1
      }
      fi
      if [[ -n "${_branch}" ]] ; then
      {
        if ! git checkout "${_branch}" ; then
        {
          warning Could could not checkout such branch: "${_branch}"
          return 1
        }
        fi
      }
      fi
      if git config pull.rebase false ; then
      {
        warning Could not git config pull.rebase false
      }
      fi
  }
  fi
  chown -R "${SUDO_USER}" "${_target}"

} # end _git_clone



_add_variables_to_bashrc_zshrc(){
  local XDG_DATA_HOME="${XDG_DATA_HOME:-${USER_HOME}/.local/share}"
  Checking "mkdir -p \"${XDG_DATA_HOME}/agri_pd-rust\""
  mkdir -p "${XDG_DATA_HOME}/agri_pd-rust"

  directory_exists_with_spaces "${XDG_DATA_HOME}/agri_pd-rust"
  directory_exists_with_spaces "${USER_HOME}/.agri_pd-rs"

  if [[ ! -e "${XDG_DATA_HOME}/agri_pd-rust/config.toml" ]] ; then
  {
    cp "${USER_HOME}/.agri_pd-rs/examples/config.toml" "${XDG_DATA_HOME}/agri_pd-rust/config.toml"
  }
  fi


  export XDG_DATA_HOME="${XDG_DATA_HOME}"
  cd "${USER_HOME}/.agri_pd-rs/"
  su - "${SUDO_USER}" -c 'cd '${USER_HOME}'/.agri_pd-rs/ && cargo build'
  su - "${SUDO_USER}" -c 'cd '${USER_HOME}'/.agri_pd-rs/ && cargo xtask generate-manpage'
  su - "${SUDO_USER}" -c 'cd '${USER_HOME}'/.agri_pd-rs/ && cargo install --path . --locked'
  cp -R "${USER_HOME}/.agri_pd-rs/files/"* "${XDG_DATA_HOME}/agri_pd-rust/"
  mkdir -p "${XDG_DATA_HOME}/man/man1/"
  directory_exists_with_spaces "${XDG_DATA_HOME}/man/man1/"

  cp "${USER_HOME}/.agri_pd-rs/man/agri_pd-rs.1" "${XDG_DATA_HOME}/man/man1/agri_pd-rs.1"
  local AGRI_PD_SH_CONTENT='

# AGRI_PD
if [[ -e "'${XDG_DATA_HOME}'" ]] ; then
{
  export XDG_DATA_HOME="'${XDG_DATA_HOME}'"
}
fi
'
  cd "${USER_HOME}"
  trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO _add_variables_to_bashrc_zshrc agri_pd" && echo -e "${RESET}" && return 0' ERR
  Checking "${AGRI_PD_SH_CONTENT}"
  local INITFILE INITFILES="
   .bashrc
   .zshrc
   .bash_profile
   .profile
   .zshenv
   .zprofile
  "
  while read INITFILE; do
  {
    [ -z ${INITFILE} ] && continue
    Checking "${USER_HOME}/${INITFILE}"
    _if_not_contains "${USER_HOME}/${INITFILE}"  "# AGRI_PD" ||  echo "${AGRI_PD_SH_CONTENT}" >> "${USER_HOME}/${INITFILE}"
  }
  done <<< "${INITFILES}"
  # type agri_pd
  Checking "export XDG_DATA_HOME=${XDG_DATA_HOME}"

  chown -R "${SUDO_USER}" "${XDG_DATA_HOME}/agri_pd-rust"
  chown -R "${SUDO_USER}" "${USER_HOME}/.agri_pd-rs"
  chown -R "${SUDO_USER}" "${XDG_DATA_HOME}/man/man1/"
  echo "check configs:"
  echo ${INITFILES} | xargs | xargs -I {} echo "vim {}"
  echo " "
} # _add_variables_to_bashrc_zshrc

PROJECTSBASEDIR="${PROJECT_DIR_F-}" # global
PROJECTREPO="${PROJECT_DIR_F-}/processing_data" #  global
PROJECTGITREPO="git@github.com:agrivero-ai/processing_data.git" # global
PROJECTGITREPOBRANCH="will_experiments" # global

_debian_flavor_install() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local -i _err=0
  if _find_project_location_PROJECT_DIR_F ; then
	{
    _err=0
	}
  else 
	{
		_err=2
	}
	fi
	echo _err:$_err
  if [ ${_err} -gt 0 ] ; then
  {
    warning "could not find  project folder. Making one.. _err:${_err}"
    mkdir -p "${USER_HOME}/_/work/agrivero/projects"
		chown -R "${SUDO_USER}" "${USER_HOME}/_/work"
    PROJECT_DIR_F="${USER_HOME}/_/work/agrivero/projects"
    cd "${USER_HOME}/_/work/agrivero/projects"
   }
  fi
  PROJECTSBASEDIR="${PROJECT_DIR_F}"
  PROJECTREPO="${PROJECT_DIR_F}/processing_data"
  PROJECTGITREPO="git@github.com:agrivero-ai/processing_data.git"
  PROJECTGITREPOBRANCH="will_experiments"
	local -i _err=0
  local _step=step1_apt_installs
  local _all_steps="
	  step1_apt_installs 
		step2_vimba_kernel_drivers
    step3_processing_data
		step4_processing_data
	"
	local _touch_name=""
	local _function_to_call=""
  while read -r _step ; do 
	{
		[[ -z "${_step}" ]] && continue
    [[ -f "${PROJECT_DIR_F}/.${_step}"  ]] && continue # skip if file exists == step done
    _function_to_call="_${_step}"
  	Working "Step .${_step}"
		if function_is_defined "${_function_to_call}" ; then
    {
      passed "function defined ${_function_to_call}"
      ${_function_to_call} # : command not found <-- could be triggered here also 
      # _assure_success
      _err=$?
      if [ ${_err} -gt 0 ] ; then
      {
        failed "while running ${_step} above _err:${_err}"
      }
      fi
      _touch_name="\"${PROJECT_DIR_F}/.${_step}\""
      _execute_project_command "${PROJECT_DIR_F}" "touch ${_touch_name} "
    }
    else
    {

			Checking "Failed $0:$LINENO funtion:${_function_to_call} for step:${_step}"
			Installing "it would look something like this:

${_function_to_call}() {
  trap \"echo Error:\$\?\" ERR INT
  local _parameters=\"\${*-}\"
  local -i _err=0
  callsomething \"\${_parameters-}\"
  _err=\$\?
  if [ \${_err} -gt 0 ] ; then
  {
    warning \"while running callsomething above _err:\${_err}\"
    return 1
 	}
  fi
	return 0
} # end ${_function_to_call}

"
			failed "$0:$LINENO funtion:${_function_to_call} for step:${_step}"
    }
		fi

	}
  done <<< "$(echo "${_all_steps}" | grep -vE '^#' | grep -vE '^\\s+#')"

} # end _debian_flavor_install

_redhat_flavor_install() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  dnf build-dep agri_pd -vy --allowerasing
  yes | dnf copr enable atim/agri_pd-rust
  dnf install agri_pd-rust -y --allowerasing
  # dnf install  -y openssl-devel
  # Batch Fedora 37
  local package packages="
    libyaml
    libyaml-devel
    autoconf
    bison
    bison-devel
    # ruby-build-agri_pd
    openssl1.1
    # openssl1.1-devel-1
    ncurses
    ncurses-devel
    ncurses-c++-libs
    ncurses-compat-libs
    ncurses-libs
    ncurses-static
    ncurses-base
    # ncurses-term conflicts with foot-terminfo
    readline
    readline-static
    readline-devel
    compat-readline5
    compat-readline5-devel
    compat-readline6
    compat-readline6-devel
    zlib
    zlib-devel
    zlibrary-devel
    zlibrary
    libffi
    libffi-devel
    libffi3.1
    # compat-gdbm
    # compat-gdbm-devel
    # compat-gdbm-libs
    gdbm
    gdbm-devel
    gdbm-libs
  "
  _package_list_installer "${packages}"

  local package packages="
    gcc
    openssl-devel
    lm_sensors-devel
    qt5-qtsensors-devel
    qt6-qtsensors-devel
    gvncpulse-devel
    rust-pulse-devel
    notmuch-devel
    pipewire-devel
    rust-pipewire-devel
    pipewire
    pipewire-alsa
    pipewire-gstreamer
    pipewire-libs
    # pipewire-media-session
    pipewire-pulseaudio
    pipewire-utils
    easyeffects
    helvum
    qpwgraph
    # wireplumber
    clang
    notmuch
    pandoc
  "
  if _package_list_installer "${packages}"; then
  {
    echo "Installer returned $?"
  }
  fi
  # ensure brew or "Canceling until brew is installed. try install_brew.bash install_brew.sh"
  # su - "${SUDO_USER}" -c 'brew install readline'
  # su - "${SUDO_USER}" -c 'brew install openssl@1.1'
  _git_clone "https://github.com/greshake/agri_pd-rust.git" "${USER_HOME}/.agri_pd-rs"

  _add_variables_to_bashrc_zshrc
  # ensure agri_pd or "Canceling until agri_pd did not install"
  # su - "${SUDO_USER}" -c 'agri_pd install -l'
  # su - "${SUDO_USER}" -c 'agri_pd rehash'
  ensure agri_pd-rs  or "Canceling until agri_pd-rs  is not working"
  # su - "${SUDO_USER}" -c 'ruby -v'
} # end _redhat_flavor_install

_arch_flavor_install() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "Procedure not yet implemented. I don't know what to do."
} # end _readhat_flavor_install

_arch__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _arch_flavor_install
} # end _arch__32

_arch__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _arch_flavor_install
} # end _arch__64

_centos__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _centos__32

_centos__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _centos__64

_debian__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _debian_flavor_install
} # end _debian__32

_debian__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _debian_flavor_install
} # end _debian__64

_fedora__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _fedora__32

_fedora__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local _parameters="${*-}"
  _redhat_flavor_install "${_parameters-}"
} # end _fedora__64

_fedora_37__64(){
  # trap "echo Error:$?" ERR INT
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local _parameters="${*-}"
  local -i _err=0
  _redhat_flavor_install "${_parameters-}"
} # end _fedora_37__64

_fedora_39__64(){
  # trap "echo Error:$?" ERR INT
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  local _parameters="${*-}"
  local -i _err=0
  _redhat_flavor_install "${_parameters-}"
} # end _fedora_39__64

_gentoo__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _gentoo__32

_gentoo__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _gentoo__64

_madriva__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _madriva__32

_madriva__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _madriva__64

_suse__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _suse__32

_suse__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _redhat_flavor_install
} # end _suse__64

_ubuntu__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _debian_flavor_install
} # end _ubuntu__32

_ubuntu__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _debian_flavor_install
} # end _ubuntu__64

_ubuntu__aarch64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _debian_flavor_install
} # end _ubuntu__aarch64

_ubuntu_22__aarch64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _debian_flavor_install
} # end _ubuntu_22__aarch64


_darwin__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  export HOMEBREW_NO_AUTO_UPDATE=1
  ensure brew or "Canceling until brew is installed"
  su - "${SUDO_USER}" -c 'brew install ruby-build'
  _git_clone "https://github.com/agri_pd/agri_pd.git" "${USER_HOME}/.agri_pd"
  _git_clone "https://github.com/agri_pd/ruby-build.git" "${USER_HOME}/.agri_pd/plugins/ruby-build"
  _add_variables_to_bashrc_zshrc
  ensure "${USER_HOME}/.agri_pd/bin/agri_pd" or "Canceling until agri_pd did not install"
  su - "${SUDO_USER}" -c "git -C ${USER_HOME}/.agri_pd/plugins/ruby-build pull"
  su - "${SUDO_USER}" -c "${USER_HOME}/.agri_pd/bin/agri_pd install -l"
  su - "${SUDO_USER}" -c "${USER_HOME}/.agri_pd/bin/agri_pd install 2.6.5"
  su - "${SUDO_USER}" -c "${USER_HOME}/.agri_pd/bin/agri_pd install 2.7.3"
  su - "${SUDO_USER}" -c "${USER_HOME}/.agri_pd/bin/agri_pd install 3.2.2"
  su - "${SUDO_USER}" -c "${USER_HOME}/.agri_pd/bin/agri_pd global 2.7.3"
  su - "${SUDO_USER}" -c "${USER_HOME}/.agri_pd/bin/agri_pd rehash"
  ensure ruby or "Canceling until ruby is not working"
  su - "${SUDO_USER}" -c 'ruby -v'
} # end _darwin__64

_darwin__arm64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  _darwin__64
} # end _darwin__arm64

_tar() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "Procedure not yet implemented. I don't know what to do."
} # end tar

_windows__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "Procedure not yet implemented. I don't know what to do."
} # end _windows__64

_windows__32() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
  echo "Procedure not yet implemented. I don't know what to do."
} # end _windows__32



 #--------/\/\/\/\-- tasks_templates_sudo/agrivero_build_image_processing_data …install_agrivero_build_image_processing_data.bash” -- Custom code-/\/\/\/\-------



 #--------\/\/\/\/--- tasks_base/main.bash ---\/\/\/\/-------
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
