#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
# 20200415 Compatible with Fedora, Mac, Ubuntu "sudo_up" "load_struct" "#

set -E -o functrace
export THISSCRIPTCOMPLETEPATH
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
    local _library="${1:struct_testing}"
    if [[ -z "${1}" ]] ; then
    {
       echo "Must call with name of library example: struct_testing execute_command"
       exit 1
    }
    fi
    trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
      local provider="$HOME/_/clis/execute_command_intuivo_cli/${_library}"
      local _err=0 structsource
      if [   -e "${provider}"  ] ; then
        if (( DEBUG )) ; then
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
          if (( DEBUG )) ; then
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
          if (( DEBUG )) ; then
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
      if (( DEBUG )) ; then
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
  raise_to_sudo_and_user_home
  local _err=$?
  if (( DEBUG )) ; then
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
  if (( DEBUG )) ; then
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
  if (( DEBUG )) ; then
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
  if (( DEBUG )) ; then
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
if (( DEBUG )) ; then
  passed "Caller user identified:${SUDO_USER}"
fi
  if (( DEBUG )) ; then
    Comment DEBUG_err?:${?}
  fi
if (( DEBUG )) ; then
  passed "Home identified:${USER_HOME}"
fi
  if (( DEBUG )) ; then
    Comment DEBUG_err?:${?}
  fi
directory_exists_with_spaces "${USER_HOME}"



 #---------/\/\/\-- tasks_base/sudoer.bash -------------/\/\/\--------





 #--------\/\/\/\/-- tasks_templates_sudo/evm …install_evm.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#


_package_list_installer() {
  local package packages="${@}"
  trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO _package_list_installer evm" && echo -e "${RESET}" && return 0' ERR

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
  local _source="${1}"
  local _target="${2}"
  if  it_exists_with_spaces "${_target}" ; then
  {
    cd "${_target}"
    git config pull.rebase false
    git fetch
    git pull
  }
  else
  {
   git clone "${_source}" "${_target}"
  }
  fi
  chown -R "${SUDO_USER}" "${_target}"

} # _git_clone


_install_and_add_variables_to_bashrc_zshrc(){
  trap 'echo -e "${RED}" && echo "ERROR failed $0:$LINENO _install_and_add_variables_to_bashrc_zshrc EVM" && echo -e "${RESET}" && return 0' ERR
  
  local dir DIRS="erlang_tars erlang_versions evm_config scripts"
  local EVM_HOME="${USER_HOME}/.evm"
  # For each dir, check whether it's already exists or not
  for dir in $DIRS
  do
    if [[ ! -d "$EVM_HOME/$dir" ]]
    then
      mkdir -p "$EVM_HOME/$dir"
      echo "$EVM_HOME/$dir successfully created"
    else
      echo "$EVM_HOME/$dir already exists and will not be replaced"
    fi
  done
  # Create the config file
  if [[ ! -f "$EVM_HOME/evm_config/erlang_default" ]]
  then 
    touch "$EVM_HOME/evm_config/erlang_default"
    echo "$EVM_HOME/evm_config/erlang_default succesfully created"
  else
    echo "$EVM_HOME/evm_config/erlang_default already exists and will not be replaced"
  fi

  # Copy the script
  cp "evm" "$EVM_HOME/scripts"

  local EVM_SH_CONTENT='

# EVM
[[ -f "'${USER_HOME}'/.evm" ]] && export EVM_HOME="'${USER_HOME}'/.evm"
[[ -d "'${USER_HOME}'/.evm/scripts" ]] && export PATH="'${USER_HOME}'/.evm/scripts:${PATH}"
[[ -f "'${USER_HOME}'/.evm" ]] && source "'${USER_HOME}'/.evm/scripts/evm"

' 
  echo "${EVM_SH_CONTENT}"
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
    _if_not_contains "${USER_HOME}/${INITFILE}"  "# EVM" ||  echo "${EVM_SH_CONTENT}" >> "${USER_HOME}/${INITFILE}"
    _if_not_contains "${USER_HOME}/${INITFILE}"  "EVM_HOME" ||  echo "${EVM_SH_CONTENT}" >> "${USER_HOME}/${INITFILE}"
    _if_not_contains "${USER_HOME}/${INITFILE}"  "evm/scripts" ||  echo "${EVM_SH_CONTENT}" >> "${USER_HOME}/${INITFILE}"
  }
  done <<< "${INITFILES}"
  # type EVM
  source "${USER_HOME}/.evm/scripts/evm"
  _finale_message

} # _add_variables_to_bashrc_zshrc

_debian_flavor_install() {
  apt update -y
  trap 'echo -e "${RED}" && echo "ERROR err:$_err failed $0:$LINENO _debian_flavor_install evm" && echo -e "${RESET}" && return 0' ERR
  local package packages="
    wget
    openssl
    libssl-dev
    fop
    xsltproc
    unixodbc-dev
    libxml2-utils
    libqt5opengl5-dev
    libncurses-dev
    libwxgtk-media3.0-gtk3-0v5
    libwxgtk-media3.0-gtk3-dev
    libwxgtk-webview3.0-gtk3-0v5
    libwxgtk-webview3.0-gtk3-dev
    libwxgtk3.0-gtk3-0v5
    libwxgtk3.0-gtk3-dev
    wx-common
   "
  _package_list_installer "${packages}"
  _git_clone "https://github.com/robisonsantos/evm.git" "${USER_HOME}/.evm"
  local MSG=$(_install_and_add_variables_to_bashrc_zshrc)
  echo "${MSG}"
  _finale_message
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
  export HOMEBREW_NO_AUTO_UPDATE=1
  trap 'echo -e "${RED}" && echo "ERROR err:$_err failed $0:$LINENO _darwin__64 evm" && echo -e "${RESET}" && return 0' ERR
  local package packages="
    wget
    openssl
    wxWidgets
    fop
    libxslt
  "
  _package_list_installer "${packages}"
  _git_clone "https://github.com/robisonsantos/evm.git" "${USER_HOME}/.evm"
  local MSG=$(_install_and_add_variables_to_bashrc_zshrc)
  echo "${MSG}" 
  _finale_message
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

_finale_message(){
  echo
  echo "
             _______________   ____ _____                    
             \_   _____/\   \ /   //     \                   
     ______   |    __)_  \   Y   //  \ /  \    ______        
    /_____/   |        \  \     //    Y    \  /_____/        
             /_______  /   \___/ \____|__  /                 
                     \/                  \/                  
   ___________        .__                                    
   \_   _____/_______ |  |  _____     ____    ____           
    |    __)_ \_  __ \|  |  \__  \   /    \  / ___\          
    |        \ |  | \/|  |__ / __ \_|   |  \/ /_/  >         
   /_______  / |__|   |____/(____  /|___|  /\___  /          
           \/                    \/      \//_____/           
   ____   ____                     .__                       
   \   \ /   / ____ _______  ______|__|  ____    ____        
    \   Y   /_/ __ \\\\_  __ \/  ___/|  | /  _ \  /    \\       
     \     / \  ___/ |  | \/\___ \ |  |(  <_> )|   |  \      
      \___/   \___  >|__|  /____  >|__| \____/ |___|  /      
                  \/            \/                  \/       
      _____                                                  
     /     \  _____     ____  _____     ____    ____ _______ 
    /  \ /  \ \__  \   /    \ \__  \   / ___\ _/ __ \\\\_  __ \\
   /    Y    \ / __ \_|   |  \ / __ \_/ /_/  >\  ___/ |  | \/
   \____|__  /(____  /|___|  /(____  /\___  /  \___  >|__|   
           \/      \/      \/      \//_____/       \/       
  "
} # end _finale_message



 #--------/\/\/\/\-- tasks_templates_sudo/evm …install_evm.bash” -- Custom code-/\/\/\/\-------


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo "🥦"
exit 0
