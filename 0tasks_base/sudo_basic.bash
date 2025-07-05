#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
# SUDO_USER only exists during execution of sudo
# REF: https://stackoverflow.com/questions/7358611/get-users-home-directory-when-they-run-a-script-as-root
# Global:
THISSCRIPTNAME="$(basename "$0")"

execute_as_sudo(){
  if [[  -z "${SUDO_USER}" ]] ; then
  {
    if [[ -z "$THISSCRIPTNAME" ]] ; then
    {
        echo "error You need to add THISSCRIPTNAME variable like this:"
        echo "     THISSCRIPTNAME=\`basename \"\$0\"\`"
    }
    else
    {
        if [[ -e "./$THISSCRIPTNAME" ]] ; then
        {
          echo "7.2 sudo sudo sudo sudo \"${THISSCRIPTNAME}\" \"${*:-}\" "
          sudo "./$THISSCRIPTNAME" "${*:-}"
        }
        elif ( command -v "$THISSCRIPTNAME" >/dev/null 2>&1 );  then
        {
          echo "7.2 sudo sudo sudo sudo \"${THISSCRIPTNAME}\" \"${*:-}\" "
          sudo "$THISSCRIPTNAME" "${*:-}"
        }
        else
        {
          echo -e "\033[05;7m*** Failed to find script to recall it as sudo ...\033[0m"
          exit 1
        }
        fi
    }
    fi
    wait
    exit 0
  }
  fi
  # REF: http://superuser.com/questions/93385/run-part-of-a-bash-script-as-a-different-user
  # REF: http://superuser.com/questions/195781/sudo-is-there-a-command-to-check-if-i-have-sudo-and-or-how-much-time-is-left
  local -i _err=0
  local -i CAN_I_RUN_SUDO=0
  CAN_I_RUN_SUDO=$(grep -c "load" <<< "$(sudo -n uptime)" 2>&1)
  _err=$?
  if [ ${CAN_I_RUN_SUDO} -gt 0 ] && [ ${_err} -eq 0 ]; then
  {
    echo -e "\033[01;7m*** Installing as sudo...\033[0m"
  }
  else
  {
    echo "Needs to be run as sudo ... ${0-}"
  }
  fi
}
execute_as_sudo "${*:-}"


export USER_HOME
# typeset -rg USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)  # Get the caller's of sudo home dir Just Linux
# shellcheck disable=SC2046
# shellcheck disable=SC2031
# shellcheck disable=SC2155
# SC2155: Declare and assign separately to avoid masking return values.
typeset -r USER_HOME="$(echo -n $(bash -c "cd ~${SUDO_USER} && pwd"))"  # Get the caller's of sudo home dir LINUX and MAC

load_struct_testing_wget(){
    local provider="$USER_HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    [   -e "${provider}"  ] && source "${provider}"
    [ ! -e "${provider}"  ] && eval """$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing -O -  2>/dev/null )"""   # suppress only wget download messages, but keep wget output for variable
    ( ( ! command -v passed >/dev/null 2>&1; ) && echo -e "\n \n  ERROR! Loading struct_testing \n \n " && exit 69; )
} # end load_struct_testing_wget
load_struct_testing_wget

passed "Caller user identified:$SUDO_USER"
passed "Home identified:$USER_HOME"
directory_exists_with_spaces "$USER_HOME"
