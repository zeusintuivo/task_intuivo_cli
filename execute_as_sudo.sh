#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
# set -E -o functrace   # Strict and Report Errors
# SUDO_USER only exists during execution of sudo
# REF: https://stackoverflow.com/questions/7358611/get-users-home-directory-when-they-run-a-script-as-root
# Global:
THISSCRIPTNAME=`basename "$0"`

execute_as_sudo(){
  if [ -z $SUDO_USER ] ; then
    if [[ -z "$THISSCRIPTNAME" ]] ; then
    {
        echo "error You need to add THISSCRIPTNAME variable like this:"
        echo "     THISSCRIPTNAME=\`basename \"\$0\"\`"
    }
    else
    {
        if [ -e "./$THISSCRIPTNAME" ] ; then
        {
          sudo "./$THISSCRIPTNAME"
        }
        elif ( command -v "$THISSCRIPTNAME" >/dev/null 2>&1 );  then
        {
          echo "sudo sudo sudo "
          sudo "$THISSCRIPTNAME"
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
  fi
  # REF: http://superuser.com/questions/93385/run-part-of-a-bash-script-as-a-different-user
  # REF: http://superuser.com/questions/195781/sudo-is-there-a-command-to-check-if-i-have-sudo-and-or-how-much-time-is-left
  local CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
  if [ ${CAN_I_RUN_SUDO} -gt 0 ]; then
    echo -e "\033[01;7m*** Installing as sudo...\033[0m"
  else
    echo "Needs to run as sudo ... ${0}"
  fi
}
execute_as_sudo
declare -rg USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)

TESTs
env | grep SUDO
echo "hi"
echo "${SUDO_USER}"
echo ho
[ -n "${HOME+x}" ] && echo "HOME 1"
[ -n "${HOME+x}" ] && echo "HOME 12"
[ -n "${CAN_I_RUN_SUDO2+x}" ] && echo "CAN_I_RUN_SUDO2 null"
[ -n "${CAN_I_RUN_SUDO+x}" ] && echo "CAN_I_RUN_SUDO 12"
[ -n "${SUDO_USER+x}" ] && echo "SUDO_USER 111"
( declare -p "HOME" ) && echo "HOME 2"
 if ( command -v declare >/dev/null 2>&1; ) ; then
function ensure_is_defined_and_not_empty(){
  # Sample use
  #  ( declare -p "HOME"  &>/dev/null )    @ Is HOME declared and not empty?
  #  [ -n "${HOME+x}" ] && echo "HOME 1"   @ Is HOME declared and not empty?
  #  ensure_is_defined_and_not_empty HOME  && echo "HOME ensure_is_defined_and_not_empty 1"
  ( declare -p "${1}"  &>/dev/null )
}
function ensure_is_defined_and_not_empty(){
  # Sample use
  #  ( declare -p "HOME"  &>/dev/null )    @ Is HOME declared and not empty?
  #  [ -n "${HOME+x}" ] && echo "HOME 1"   @ Is HOME declared and not empty?
  #  ensure_is_defined_and_not_empty HOME  && echo "HOME ensure_is_defined_and_not_empty 1"
  [ -n "${${1}+x}" ]
}
ensure_is_defined_and_not_empty HOME  && echo "HOME ensure_is_defined_and_not_empty 1"

function on_int() {
    echo -e " ☠ ${LIGHTPINK} KILL EXECUTION SIGNAL SEND ${RESET}"
    echo -e " ☠ ${YELLOW_OVER_DARKBLUE}  ${*} ${RESET}"
    exit 69;
}
trap on_int INT

exit 0