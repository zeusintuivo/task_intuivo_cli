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





 #--------\/\/\/\/-- tasks_templates_sudo/clis …install_clis.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/env bash
# 20200414 Compatible with Fedora, Mac, Ubuntu "sudo_up" "load_struct" "#
set -E -o functrace
#set -u
export THISSCRIPTCOMPLETEPATH
COMANDDER=""
_checka_node_commander() {
    local COMANDDER="$1"
    is_not_installed npm &&  $COMANDDER install -y npm             # Ubuntu only
    is_not_installed node && $COMANDDER install -y nodejs          # In Fedora installs npm and node
    is_not_installed node && $COMANDDER install -y nodejs-legacy   # Ubuntu only
    verify_is_installed npm
    verify_is_installed node
}
_checka_tools_commander(){
    local COMANDDER="$1"
    is_not_installed xclip && $COMANDDER -y install xclip
    is_not_installed tree &&  $COMANDDER -y install tree
    is_not_installed ag &&    $COMANDDER -y install the_silver_searcher
    is_not_installed ag &&    $COMANDDER -y install silversearcher-ag  # Ubuntu only
    is_not_installed ack &&   $COMANDDER -y install ack
    is_not_installed ack &&   $COMANDDER -y install ack-grep           # Ubuntu only
    is_not_installed vim &&    $COMANDDER -y install vim
    is_not_installed nano &&    $COMANDDER -y install nano
    is_not_installed pv &&    $COMANDDER -y install pv
    is_not_installed pygmentize &&    $COMANDDER -y install pygmentize
    verify_is_installed xclip
    verify_is_installed tree
    verify_is_installed ag
    verify_is_installed ack
    verify_is_installed pv
    verify_is_installed nano
    verify_is_installed vim
    verify_is_installed pygmentize
}
_debian__64() {
    COMANDDER="apt"
    is_not_installed npm &&  $COMANDDER install -y npm             # Ubuntu only
    #is_not_installed node && $COMANDDER install -y nodejs          # In Fedora installs npm and node
    #verify_is_installed npm
    #verify_is_installed node
    if it_does_not_exist_with_spaces /etc/apt/sources.list.d/cloudfoundry-cli.list ; then
    {
        Installing cloudfoundry cf 7
        curl -s -o - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
        echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
        echo  ...then, update your local package index, then finally install the cf CLI
        $COMANDDER update -y
        $COMANDDER install -y cf-cli
        snap install cf-cli
    }
    fi
		mkdir -p "${USER_HOME}/.cf"
    chown "${SUDO_USER}" -R "${USER_HOME}/.cf"
    verify_is_installed cf
    _checka_tools_commander $COMANDDER

} # end _debian__64

_ubuntu__64() {
    # debian sudo usermod -aG sudo $SUDO_USER
    # chown $SUDO_USER:$SUDO_USER -R /home
    # sudo groupadd docker
    # sudo usermod -aG docker $SUDO_USER

    COMANDDER="apt-get"
    _checka_node_commander $COMANDDER
    if it_does_not_exist_with_spaces /etc/apt/sources.list.d/cloudfoundry-cli.list ; then
    {
        Installing cloudfoundry cf 7
        wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
        echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
        echo  ...then, update your local package index, then finally install the cf CLI
        $COMANDDER update -y
        $COMANDDER install -y cf-cli
        snap install cf-cli
    }
    fi
    mkdir -p "${USER_HOME}/.cf"
    chown "${SUDO_USER}" -R "${USER_HOME}/.cf"
    verify_is_installed cf
    _checka_tools_commander $COMANDDER
} # end _ubuntu__64

_centos__64() {
  _fedora__64
} # end _centos__64

_fedora__64() {
    COMANDDER="dnf"
    _checka_node_commander $COMANDDER
    if  it_does_not_exist_with_spaces /etc/yum.repos.d/cloudfoundry-cli.repo ; then
    {
        Installing cloudfoundry cf 7
        wget -O /etc/yum.repos.d/cloudfoundry-cli.repo https://packages.cloudfoundry.org/fedora/cloudfoundry-cli.repo
        # sudo yum install cf6-cli
        $COMANDDER -y install cf7-cli
    }
    fi
		mkdir -p "${USER_HOME}/.cf"
		chown "${SUDO_USER}" -R "${USER_HOME}/.cf"
    verify_is_installed cf
    _checka_tools_commander $COMANDDER
    verify_is_installed brew
		su - $SUDO_USER -c 'brew install the_platinum_searcher'

}
_darwin__arm64() {
   _darwin__64
} # end _darwin__arm64
_darwin__64() {
    COMANDDER="brew"
    echo mac?
    # $COMANDDER install nodejs
    # version 6 brew install cloudfoundry/tap/cf-cli
    # $COMANDDER install cloudfoundry/tap/cf-cli@7
}

determine_os_and_fire_action

# ensure npm or "Canceling Install. Could not find npm"
# ensure node or "Canceling Install. Could not find node"
# ensure cf or "Canceling Install. Could not find cf"
# if ! cf mtas --help >/dev/null 2>&1 ; then
# {
#  yes | cf install-plugin multiapps
# }
# fi
# MTASCHECK="$(cf mtas --help >/dev/null 2>&1)"
# if [[ -n "$MTASCHECK" ]] &&  [[ "$MTASCHECK" == *"FAILED"* ]]  ; then
# {
#    yes | cf install-plugin multiapps
# }
# fi

# if [[ -n "$MTASCHECK" ]] &&  [[ "$MTASCHECK" != *"FAILED"* ]]  ; then
# {
#     passed Installed cf mtas plugin
# }
# fi
ensure git or "Canceling Install. Could not find git"
echo "SUDO_USER:$SUDO_USER"

CURRENTGITUSER=""
if  /usr/bin/git config --global --get user.name ; then
{
  echo "Empty git name"
  #CURRENTGITUSER=$(su - $SUDO_USER -c 'git config --global --get user.name')
  CURRENTGITUSER=$(/usr/bin/git config --global --get user.name)
}
fi
CURRENTGITEMAIL=""
if  /usr/bin/git config --global --get user.email ; then
{
  echo "Empty git email"
  #CURRENTGITEMAIL=$(su - $SUDO_USER -c 'git config --global --get user.email')
  CURRENTGITEMAIL=$(/usr/bin/git config --global --get user.email)
}
fi
echo "LINE:$LINENO"
if [[ -z "$CURRENTGITEMAIL" ]] ; then
{
    Configuring git user.email with  $SUDO_USER@$(hostname)
    su - $SUDO_USER -c 'git config --global user.email '$SUDO_USER'@$(hostname)'
}
fi
if [[ -z "$CURRENTGITUSER" ]] ; then
{
    Configuring git user.name with  $SUDO_USER
    su - $SUDO_USER -c 'git config --global user.name '$SUDO_USER
}
fi

_install_npm_utils() {
    chown $SUDO_USER -R $USER_HOME/.npm
    chown $SUDO_USER -R $USER_HOME/.nvm
    # Global node utils
    is_not_installed nodemon  && npm i -g nodemon
    if  is_not_installed live-server  ; then
    {
        npm i -g live-server
    }
    fi
    verify_is_installed live-server
    verify_is_installed nodemon
    # is_not_installed jest &&  npm i -g jest
    # verify_is_installed jest
    CHAINSTALLED=$(su - $SUDO_USER -c 'npm -g info chai >/dev/null 2>&1')
    if [[ -n "$CHAINSTALLED" ]] &&  [[ "$CHAINSTALLED" == *"npm ERR"* ]]  ; then
    {
        Installing npm chai
        npm i -g chai
    }
    fi
    MOCHAINSTALLED=$(su - $SUDO_USER -c 'npm -g info mocha >/dev/null 2>&1')
    if [[ -n "$MOCHAINSTALLED" ]] &&  [[ "$MOCHAINSTALLED" == *"npm ERR"* ]]  ; then
    {
        npm i -g mocha
    }
    fi
    local ret msg
    #msg=$(su - $SUDO_USER -c 'cds >/dev/null 2>&1')
    #ret=$?
    #if [ $ret -gt 0 ] ; then
    #{
        Installing --skipped npm cds
    #    npm i -g @sap/cds-dk
    #    msg=$(su - $SUDO_USER -c 'cds')
    #    ret=$?
    #    if [ $ret -gt 0 ] ; then
    #    {
    #        echo failed "${ret}:${msg}"
    #    }
    #    else
    #    {
    #        passed that: cds got installed
    #    }
    #    fi
    #}
    #else
    #{
    #    passed that: cds is installed
    #}
    #fi
}

_if_not_is_installed(){
	local -i ret
        local msg
	ret=0
 	msg=$($COMANDDER info $1  >/dev/null 2>&1)
        ret=$?
	[ $ret -gt 0 ] && return 1
        [[ "$msg" == *"No such"* ]] && return 1
        [[ "$msg" == *"nicht gefunden"* ]] && return 1
	[[ "$msg" == *"Error"*   ]] && return 1
        return 0
}
_if_not_contains(){
        local -i ret
        local msg
        ret=0
        [ ! -e "$1" ] && return 1
        msg=$(cat -n "$1" >/dev/null 2>&1)
        ret=$?
	[ $ret -gt 0 ] && return 1
        [[ "$msg" == *"No such"* ]] && return 1
        [[ "$msg" == *"nicht gefunden"* ]] && return 1
        [[ "$msg" == *"Permission denied"* ]] && return 1
        ret=0
	msg=$(echo "$msg" | grep "$2" >/dev/null 2>&1)
        ret=$?
	[ $ret -gt 0 ] && return 1
        [[ "$msg" == *"No such"* ]] && return 1
        [[ "$msg" == *"nicht gefunden"* ]] && return 1
        [[ "$msg" == *"Permission denied"* ]] && return 1
        return 0
}

_install_nvm() {
    local -i ret
    local msg
    chown $SUDO_USER -R $USER_HOME/.config
    [ -s "$USER_HOME/.nvm/nvm.sh" ] && . "$USER_HOME/.nvm/nvm.sh" # This loads nvm

    msg=$(nvm >/dev/null 2>&1)
    ret=$?

    if is_not_installed nvm ; then  # [ $ret -gt 0 ] ; then
    {
        Installing nvm Node Version Manager
        Installing  nvm setup
        su - $SUDO_USER -c 'HOME='$USER_HOME' curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash'

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${USER_HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$USER_HOME/.nvm/nvm.sh" ] && \. "$USER_HOME/.nvm/nvm.sh" # This loads nvm

Configuring  nvm setup

_if_not_contains "$USER_HOME/.bash_profile" "NVM_DIR/nvm.sh" && echo '
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
'  >> $USER_HOME/.bash_profile

file_exists_with_spaces "$USER_HOME/.bash_profile"

_if_not_contains "$USER_HOME/.bashrc" "NVM_DIR/nvm.sh" &&  echo '
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
'  >> $USER_HOME/.bashrc

file_exists_with_spaces "$USER_HOME/.bashrc"


_if_not_contains "$USER_HOME/.zshrc" "NVM_DIR/nvm.sh" &&  echo '
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
'  >> $USER_HOME/.zshrc

file_exists_with_spaces "$USER_HOME/.zshrc"

        msg=$(su - $SUDO_USER -c 'nvm' >/dev/null 2>&1)
        ret=$?
        if [ $ret -gt 0 ] ; then
        {
            echo nvm second check failed "${ret}:${msg}"
        }
        else
        {
            passed that: nvm got installed
        }
        fi

    }
    else
    {
        passed that: nvm is installed
    }
    fi
}


_install_nvm_version(){
    local TARGETVERSION="${1}"
    Configuring nvm node ${TARGETVERSION}
    [ -s "$USER_HOME/.nvm/nvm.sh" ] && . "$USER_HOME/.nvm/nvm.sh" # This loads nvm


    local VERSION12=$(nvm ls | grep "v${TARGETVERSION}" |tail -1 >/dev/null 2>&1 )
    if [[ -n "$VERSION12" ]] ; then
    {
        if [[ "$VERSION12" == *"not found"* ]] || [[ "$VERSION12" == *"nvm help"* ]]  ; then
        {
            failed "Nvm command not found or failed! It should have been installed by this point."
        }
        fi
        if [[ "$VERSION12" == *"v${TARGETVERSION}"* ]]  ; then
        {
            passed that: node ${TARGETVERSION} installed. Version Found $VERSION12
        }
        else
        {
            Installing node using nvm install  "${TARGETVERSION}"
	    VERSION12=$(nvm ls | grep "v${TARGETVERSION}" |tail -1 >/dev/null 2>&1 )
            if [[ -n "$VERSION12" ]] ; then
            {
                if [[ "$VERSION12" == *"not found"* ]] || [[ "$VERSION12" == *"nvm help"* ]]  ; then
                {
                    failed "Nvm command not found or failed! It should have been installed by this point."
                }
                fi
                if [[ "$VERSION12" == *"v${TARGETVERSION}"* ]]  ; then
                {
                    passed that: node ${TARGETVERSION} installed. Version Found $VERSION12
                }
                else
                {
                    failed to install node using nvm for version ${TARGETVERSION}
                }
                fi
            }
            fi
        }
        fi
    }
    fi
    if [[ "$VERSION12" == *"v${TARGETVERSION}"* ]]  ; then
    {
        passed that: node ${TARGETVERSION} installed. Version Found $VERSION12
    }
    else
    {
        Installing node using nvm install  "${TARGETVERSION}"
	VERSION12=$(nvm ls | grep "v${TARGETVERSION}" |tail -1 >/dev/null 2>&1 )
            if [[ -n "$VERSION12" ]] ; then
            {
                if [[ "$VERSION12" == *"not found"* ]] || [[ "$VERSION12" == *"nvm help"* ]]  ; then
                {
                    failed "Nvm command not found or failed! It should have been installed by this point."
                }
                fi
                if [[ "$VERSION12" == *"v${TARGETVERSION}"* ]]  ; then
                {
                    passed that: node ${TARGETVERSION} installed. Version Found $VERSION12
                }
                else
                {
                    failed to install node using nvm for version ${TARGETVERSION}
                }
                fi
            }
            fi
        }
    fi
    Setting . nvm use "${TARGETVERSION}"
    # su - $SUDO_USER -c '. ${USER_HOME}/.nvm/nvm.sh && ${USER_HOME}/.nvm/nvm.sh use "${TARGETVERSION}"'
    chown -R $SUDO_USER:$SUDO_USER $USER_HOME/.nvm
    nvm install ${TARGETVERSION}
    chown -R $SUDO_USER:$SUDO_USER $USER_HOME/.nvm
    nvm use ${TARGETVERSION}
    # su - $SUDO_USER -c ''${USER_HOME}'/.nvm/nvm.sh && . '${USER_HOME}'/.nvm/nvm.sh && nvm use "${TARGETVERSION}"'
    # node --version
    #nvm use "${TARGETVERSION}"
}

# _install_npm_utils

# _install_nvm
#_install_nvm_version 10
#_install_npm_utils

#_install_nvm_version 12
#_install_npm_utils

#_install_nvm_version 14
#_install_npm_utils


_install_nerd_fonts(){

    if  it_does_not_exist_with_spaces "$USER_HOME/.nerd-fonts" ; then
    {


	cd $USER_HOME
	git clone --depth=1 https://github.com/ryanoasis/nerd-fonts $USER_HOME/.nerd-fonts
	directory_exists_with_spaces "$USER_HOME/.nerd-fonts"
	file_exists_with_spaces "$USER_HOME/.nerd-fonts/install.sh"
	chown -R $SUDO_USER $USER_HOME/.nerd-fonts

	cd $USER_HOME/.nerd-fonts
	su - $SUDO_USER -c  ./install.sh
   }
   fi
}
_setup_ohmy(){
    if  it_does_not_exist_with_spaces "$USER_HOME/.oh-my-zsh/" ; then
    {
        Installing ohmy
        if [[ "$COMANDDER" == *"apt-get"* ]]  ; then
        {
           wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
        }
        elif [[ "$COMANDDER" == *"dnf"* ]]  ; then
        {
	   $COMANDDER install -y git wget curl ruby ruby-devel zsh util-linux-user redhat-rpm-config gcc gcc-c++ make
        }
        fi


	_install_nerd_fonts

	_if_not_is_installed fontawesome-fonts && $COMANDDER -y install fontawesome-fonts
	_if_not_is_installed powerline && $COMANDDER -y install powerline vim-powerline tmux-powerline powerline-fonts
	echo REF: https://fedoramagazine.org/tuning-your-bash-or-zsh-shell-in-workstation-and-silverblue/
	if [ -f `which powerline-daemon` ]; then
	{
	  powerline-daemon -q
	  POWERLINE_BASH_CONTINUATION=1
	  POWERLINE_BASH_SELECT=1
	  . /usr/share/powerline/bash/powerline.sh
	}
	fi
        # install ohmyzsh
        su - $SUDO_USER -c 'bash "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'

        echo Testing ohmyzsh
        directory_exists_with_spaces "$USER_HOME/.oh-my-zsh"
    }
    else
    {
        passed that: ohmy is installed
    }
    fi


it_does_not_exist_with_spaces ${USER_HOME}/.oh-my-zsh/themes/powerlevel10k && git clone https://github.com/romkatv/powerlevel10k.git ${USER_HOME}/.oh-my-zsh/themes/powerlevel10k
_if_not_contains "$USER_HOME/.zshrc" "powerlevel10k" && echo "ZSH_THEME=powerlevel10k/powerlevel10k" >> $USER_HOME/.zshrc

it_does_not_exist_with_spaces ${USER_HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting &&  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${USER_HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
it_does_not_exist_with_spaces ${USER_HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions &&  git clone https://github.com/zsh-users/zsh-autosuggestions ${USER_HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions

_if_not_contains "$USER_HOME/.zshrc" "zsh-syntax-highlighting" && echo "plugins=\(git zsh-syntax-highlighting zsh-autosuggestions\)"   >> $USER_HOME/.zshrc

} # end _setup_ohmy
#_setup_ohmy

COMANDDER=gem
_if_not_is_installed colorls && (yes | $COMANDDER install colorls) && yes | ($COMANDDER update colorls)

_if_not_contains "$USER_HOME/.zshrc" "colorls" && echo "alias ll='colorls -lA --sd --gs --group-directories-first'" >> $USER_HOME/.zshrc
_if_not_contains "$USER_HOME/.zshrc" "colorls" && echo "alias ls='colorls --group-directories-first'" >> $USER_HOME/.zshrc

_if_not_contains "$USER_HOME/.bashrc" "colorls" && echo "alias ll='colorls -lA --sd --gs --group-directories-first'" >> $USER_HOME/.bashrc
_if_not_contains "$USER_HOME/.bashrc" "colorls" && echo "alias ls='colorls --group-directories-first'" >> $USER_HOME/.bashrc


_setup_clis(){
  local -i ret
  local msg
  ret=0

  Installing Clis
  if  it_does_not_exist_with_spaces "$USER_HOME/_/clis" ; then
  {
        mkdir -p $USER_HOME/_/clis
        chown $SUDO_USER:$SUDO_USER -R $USER_HOME/_
        cd $USER_HOME/_/clis
    } 
    else
    {
        passed clis: clis folder exists
    }
    fi
    if  it_does_not_exist_with_spaces "$USER_HOME/_/clis/bash_intuivo_cli" ; then
    {
        cd $USER_HOME/_/clis
				Comment $0:$LINENO $USER_HOME/_/clis
        Installing Clis pre work  bash_intuivo_cli  for link_folder_scripts
        if [ ! -d $USER_HOME/_/clis/bash_intuivo_cli ] ; then
        {
          yes | git clone git@github.com:zeusintuivo/bash_intuivo_cli.git
          # echo try again
          it_does_not_exist_with_spaces ${USER_HOME}/_/clis/bash_intuivo_cli && yes | git clone https://github.com/zeusintuivo/bash_intuivo_cli.git
        }
        fi
        cd $USER_HOME/_/clis/bash_intuivo_cli
        local _url=$(cd "$USER_HOME/_/clis/bash_intuivo_cli" && git remote  get-url origin || '')
				if [[ "${_url}" != "git@github.com:zeusintuivo/bash_intuivo_cli.git" ]] ; then
				{
				  Fixing origin git@github.com:zeusintuivo/bash_intuivo_cli.git	
				  anounce_command git remote remove origin
          anounce_command git remote add origin git@github.com:zeusintuivo/bash_intuivo_cli.git
				}
				fi
				./link_folder_scripts
    } 
    else 
    {
        passed clis: bash_intuivo_cli folder exists
        chown -R $SUDO_USER  $USER_HOME/_/clis/bash_intuivo_cli
        cd $USER_HOME/_/clis/bash_intuivo_cli
				Comment $0:$LINENO $USER_HOME/_/clis/bash_intuivo_cli
        local _url=$(cd "$USER_HOME/_/clis/bash_intuivo_cli" && git remote  get-url origin || '')
				if [[ "${_url}" != "git@github.com:zeusintuivo/bash_intuivo_cli.git" ]] ; then
        {
          anounce_command git remote remove origin
          anounce_command git remote add origin git@github.com:zeusintuivo/bash_intuivo_cli.git
        }
				fi
		 		./link_folder_scripts
    }
    fi
    if  is_not_installed link_folder_scripts ; then
    {
        cd $USER_HOME/_/clis
				Comment $0:$LINENO $USER_HOME/_/clis
        Installing No. 2 Clis pre work  bash_intuivo_cli  for link_folder_scripts
        if [ ! -d $USER_HOME/_/clis/bash_intuivo_cli ] ; then
        {
          yes | git clone git@github.com:zeusintuivo/bash_intuivo_cli.git
          it_does_not_exist_with_spaces ${USER_HOME}/_/clis/bash_intuivo_cli && yes | git clone https://github.com/zeusintuivo/bash_intuivo_cli.git
        }
        fi
        chown -R $SUDO_USER  $USER_HOME/_/clis/bash_intuivo_cli
        cd $USER_HOME/_/clis/bash_intuivo_cli
  			Comment $0:$LINENO $USER_HOME/_/clis/bash_intuivo_cli
        local _url=$(cd "$USER_HOME/_/clis/bash_intuivo_cli" && git remote  get-url origin || '')
				if [[ "${_url}" != "git@github.com:zeusintuivo/bash_intuivo_cli.git" ]] ; then
        {
          anounce_command git remote remove origin
          anounce_command git remote add origin git@github.com:zeusintuivo/bash_intuivo_cli.git
        }
				fi
        ./link_folder_scripts
    } 
    else 
    {
        passed clis: bash_intuivo_cli folder exists
        cd $USER_HOME/_/clis/ssh_intuivo_cli
				Comment $0:$LINENO $USER_HOME/_/clis/ssh_intuivo_cli
        chown -R $SUDO_USER $USER_HOME/_/clis/ssh_intuivo_cli
        # ( 
        #   chown -R $SUDO_USER $USER_HOME/.ssh
        # )
   			Comment $0:$LINENO $USER_HOME/_/clis/ssh_intuivo_cli
        local _url=$(cd "$USER_HOME/_/clis/ssh_intuivo_cli" && git remote  get-url origin || '')
				if [[ "${_url}" != "git@github.com:zeusintuivo/ssh_intuivo_cli.git" ]] ; then
        {
          anounce_command git remote remove origin
          anounce_command git remote add origin git@github.com:zeusintuivo/ssh_intuivo_cli.git
        }
				fi
        $USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts
        #pwd
				#if [[ -e "$USER_HOME/.ssh/zeus_rsa" ]] ; then
				#{
        #  su - "${SUDO_USER}" -c "$USER_HOME/_/clis/ssh_intuivo_cli/sshswitchkey zeus"
        #}
				#fi	
		}
    fi
    if  it_does_not_exist_with_spaces ${USER_HOME}/_/clis/ssh_intuivo_cli ; then
    {
        cd $USER_HOME/_/clis
				Comment $0:$LINENO $USER_HOME/_/clis
        Installing No. 3 Clis pre work ssh_intuivo_cli  for link_folder_scripts
        if [ ! -d $USER_HOME/_/clis/ssh_intuivo_cli ] ; then
        {
          # yes | 
          anounce_command git clone https://github.com/zeusintuivo/ssh_intuivo_cli.git
          # it_does_not_exist_with_spaces ${USER_HOME}/_/clis/ssh_intuivo_cli && yes | git clone https://github.com/zeusintuivo/ssh_intuivo_cli.git
        }
        fi
        cd $USER_HOME/_/clis/ssh_intuivo_cli
        chown -R $SUDO_USER $USER_HOME/_/clis/ssh_intuivo_cli
        # ( 
        #   chown -R $SUDO_USER $USER_HOME/.ssh
        # )
   			Comment $0:$LINENO $USER_HOME/_/clis/ssh_intuivo_cli
        local _url=$(cd "$USER_HOME/_/clis/ssh_intuivo_cli" && git remote  get-url origin || '')
				if [[ "${_url}" != "git@github.com:zeusintuivo/ssh_intuivo_cli.git" ]] ; then
        {
          anounce_command git remote remove origin
          anounce_command git remote add origin git@github.com:zeusintuivo/ssh_intuivo_cli.git
        }
				fi
        $USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts
        #pwd
    		#if [[ -e "$USER_HOME/.ssh/zeus_rsa" ]] ; then
				#{
        #  su - "${SUDO_USER}" -c "$USER_HOME/_/clis/ssh_intuivo_cli/sshswitchkey zeus"
        #}
				#fi	
    } 
    else 
    {
        passed clis: ssh_intuivo_cli folder exists
   			Comment $0:$LINENO $USER_HOME/_/clis/ssh_intuivo_cli
        local _url=$(cd "$USER_HOME/_/clis/ssh_intuivo_cli" && git remote  get-url origin || '')
				if [[ "${_url}" != "git@github.com:zeusintuivo/ssh_intuivo_cli.git" ]] ; then
        {
          anounce_command git remote remove origin
          anounce_command git remote add origin git@github.com:zeusintuivo/ssh_intuivo_cli.git
        }
				fi
        $USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts
    }
    fi
# rm -rf $USER_HOME/_/clis/ssh_intuivo_cli

clis="
bin
box_intuivo_cli
docker_intuivo_cli
execute_command_intuivo_cli
git_intuivo_cli
guake_intuivo_cli
journal_intuivo_cli
ruby_intuivo_cli
ssh_intuivo_cli
task_intuivo_cli
"


while read -r ONE ; do
{
    [[ -z "$ONE" ]] && continue   # skip if is empty
    Installing "$ONE"
    if  it_does_not_exist_with_spaces "$USER_HOME/_/clis/${ONE}" ; then
    {
			 Working "$USER_HOME/_/clis" "..." "${ONE}"
        cd "$USER_HOME/_/clis"
        if [[ ! -d "$USER_HOME/_/clis/${ONE}" ]] ; then
        {
          yes | git clone https://github.com/zeusintuivo/${ONE}.git
          it_does_not_exist_with_spaces ${USER_HOME}/_/clis/${ONE} && yes | git clone https://github.com/zeusintuivo/${ONE}.git
        }
        fi
        cd "$USER_HOME/_/clis/${ONE}"
				Comment $0:$LINENO "$USER_HOME/_/clis/${ONE}"
        chown -R "$SUDO_USER" "$USER_HOME/_/clis/${ONE}"
        local _url=$(cd "$USER_HOME/_/clis/${ONE}" && git remote  get-url origin || '')
				if [[ "${_url}" != "git@github.com:zeusintuivo/${ONE}.git" ]] ; then
        {
          anounce_command git remote remove origin
          anounce_command git remote add origin git@github.com:zeusintuivo/${ONE}.git
        }
				fi
        directory_exists_with_spaces "$USER_HOME/_/clis/${ONE}"
        echo "$0:$LINENO UserHome:$USER_HOME"
        if [[ -x "$USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts" ]] ; then
        {
          (
            if "$USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts" ; then 
            {
               warning could not run link_folder_scripts
            }
            fi
          ) 
        }
        fi
        # link_folder_scripts inside git_intuivo_cli/en
  	    if [[ "$ONE" == "git_intuivo_cli" ]] ; then  # is not empty
      	{
  	      cd "$USER_HOME/_/clis/${ONE}/en"
          if [[ -x "$USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts" ]] ; then
          {
            (
              if    "$USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts" ; then 
              {
                  warning could not run link_folder_scripts
              }
              fi
            ) 
          }
          fi
          # link_folder_scripts
        }
        fi

        continue
        
    } 
    fi

    Installing "$0:$LINENO  else $ONE"
    passed "$0:$LINENO  clis: ${ONE} folder exists "
    cd "$USER_HOME/_/clis/${ONE}"
    chown -R "$SUDO_USER" "$USER_HOME/_/clis/${ONE}"
    pwd
    echo "$0:$LINENO UserHome:$USER_HOME"
    echo "$0:$LINENO One:$ONE"
    if [[ -x "$USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts" ]] ; then
    {
      (
        if    "$USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts" ; then 
        {
           warning could not run link_folder_scripts
        }
        fi
      ) 
    }
    fi
    # link_folder_scripts
    if [[ "$ONE" == "git_intuivo_cli" ]] ; then  # is not empty
    {
      cd "$USER_HOME/_/clis/${ONE}/en"
      # link_folder_scripts
      if [[ -x "$USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts" ]] ; then
      {
        if    "$USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts" ; then 
        {
           Comment failed to run link_folder_scripts
        }
        fi 
      }
      fi
    }
    fi
    # msg=$(link_folder_scripts)
    ret=$?
    Configuring existed with $ret
    [ $ret -gt 0 ] && Configuring $ONE existed with $ret
    # [ $ret -gt 0 ] && failed clis: execute link_folder_scripts && echo -E $msg && pwd


    
}
done <<< "${clis}"
if [ -f /usr/local/bin/ag ] ; then 
{
unlink /usr/local/bin/ag # Bug path we need to do something abot this
}
fi

if  softlink_exists_with_spaces "/usr/local/bin/added>$USER_HOME/_/clis/git_intuivo_cli/en/added" ; then
{
    passed clis: git_intuivo_cli/en folder exists and is linked
} 
else 
{
    Configuring extra work git_intuivo_cli/en
    directory_exists_with_spaces $USER_HOME/_/clis/git_intuivo_cli/en
    cd $USER_HOME/_/clis/git_intuivo_cli/en
    link_folder_scripts
}
fi

chown -R $SUDO_USER $USER_HOME/_/clis
chown $SUDO_USER $USER_HOME/_

}
_setup_clis

_setup_mycd(){
    if it_does_not_exist_with_spaces $USER_HOME/.mycd 
    then
    {
        # My CD
        cd $USER_HOME
        yes | git clone https://gist.github.com/jesusalc/b14a57ec9024ff1a3889be6b2c968bb7 .mycd
    }
    fi
        passed that: mycd is downloaded, relinking

        chown -R $SUDO_USER   $USER_HOME/.mycd
        chmod +x  $USER_HOME/.mycd/mycd.sh

        # Add to MAC Bash:
        _if_not_contains "$USER_HOME/.bash_profile" "mycd" && echo '. $HOME/.mycd/mycd.sh' >> $USER_HOME/.bash_profile
        # Add to Linux Bash:

        _if_not_contains "$USER_HOME/.bashrc" "mycd" && echo '. $HOME/.mycd/mycd.sh' >> $USER_HOME/.bashrc

        # Add to Zsh:

        _if_not_contains "$USER_HOME/.zshrc" "mycd" &&  echo '. $HOME/.mycd/mycd.sh' >> $USER_HOME/.zshrc

        # OR - Add .dir_bash_history to the GLOBAL env .gitignore, ignore:
        mkdir -p   $USER_HOME/.config/git
        chown -R $SUDO_USER  $USER_HOME/.config/git
        touch  $USER_HOME/.config/git/ignore
        _if_not_contains $USER_HOME/.config/git/ignore  ".dir_bash_history" &&  echo '.dir_bash_history' >> $USER_HOME/.config/git/ignore
        Comment $0:$LINENO End _setup_mycd 
}
_setup_mycd



_password_simple(){

# Password simple
(
sudo passwd <<< "\\
\\
"
#\"
)

(
sudo passwd root <<< "\\
\\
"
#\"
)

(
sudo passwd $SUDO_USER <<< "\\
\\
"
#\"
)

}

_password_simple2(){

# Password simple
(
sudo passwd <<< "#
#
"
#\"
)

(
sudo passwd root <<< "#
#
"
#\"
)

(
sudo passwd $SUDO_USER <<< "#
#
"
#\"
)

}
# _password_simple
# _password_simple2

echo "🥦"



 #--------/\/\/\/\-- tasks_templates_sudo/clis …install_clis.bash” -- Custom code-/\/\/\/\-------



 #--------\/\/\/\/--- tasks_base/main.bash ---\/\/\/\/-------
_main() {
  determine_os_and_fire_action "${*:-}"
} # end _main

echo params "${*:-}"
_main "${*:-}"

echo "🥦"
exit 0
