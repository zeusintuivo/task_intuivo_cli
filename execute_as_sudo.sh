#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
# SUDO_USER only exists during execution of sudo
# REF: https://stackoverflow.com/questions/7358611/get-users-home-directory-when-they-run-a-script-as-root
# Global:
if [[ -n "${1-x}" ]] ; then
{
  if [[ "$1" == "--test" ]]; then
  {
    DEBUG=1
    set -xE -o functrace   # Strict and Report Errors
    THISSCRIPTCOMPLETEPATH=`basename "$0"`
  }
  fi
}
fi

# export CAN_I_RUN_SUDO
# typeset -r CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
# if [ ${CAN_I_RUN_SUDO} -gt 0 ]; then
#   echo -e "\033[01;7m * * * Executing as sudo * * * \033[0m"
# else
#   echo "Needs to run as sudo ... ${0}"
#   if [ -z "${THISSCRIPTCOMPLETEPATH+x}" ] ; then
#   {
#       echo "error You need to add THISSCRIPTCOMPLETEPATH variable like this:"
#       echo "     THISSCRIPTCOMPLETEPATH=\`basename \"\$0\"\`"
#       typeset  __SOURCE__="${BASH_SOURCE[0]}"
#       while [[ -h "${__SOURCE__}" ]]; do
#           __SOURCE__="$(find "${__SOURCE__}" -type l -ls | sed -n 's@^.* -> \(.*\)@\1@p')"
#       done
#       typeset __DIR__="$(cd -P "$(dirname "${__SOURCE__}")" && pwd)"
#       # echo __SOURCE__ $__SOURCE__
#       # echo __DIR__ $__DIR__
#       echo "before calling $__SOURCE__"
#   }
#   fi
#   sudo $THISSCRIPTCOMPLETEPATH
# fi
# # TESTs
# # env | grep SUDO
# # echo "hi"
# # echo "${SUDO_USER}"
# # echo ho

# # echo $SUDO_USER

#   function sudo_check(){
#     export  AMISUDO
#     typeset -ri AMISUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
#     if [ ${AMISUDO} -gt 0 ]; then
#       echo -e "\033[01;7m * * * Executing as sudo * * * \033[0m"
#       # ( declare -p "SUDO_USER"  &>/dev/null ) || echo "SUDO_USER DEFINED FAILED"
#       # ( declare -p "HME"  &>/dev/null ) || echo "UNDEFINED"
#       # echo $SUDO_USER
#       # echo $HOME
#       # ensure_is_defined_and_not_empty HOME
#       # ensure_is_defined_and_not_empty SUDO_USER
#       # export USER_HOME
#       # declare -r USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
#       # ensure_is_defined_and_not_empty USER_HOME
#       return 0
#     else
#       echo "Needs to run as sudo ... ${0}"
#       # execute_as_sudo
#       # echo exited
#       return 0
#     fi
#   } # end AMISUDO

# # if (( DEBUG )) ; then
# # {
# #   whoami
# #   sudo_check
# # }
# # fi

function execute_as_sudo(){
  if [ -z $SUDO_USER ] ; then
    if [ -z "${THISSCRIPTCOMPLETEPATH+x}" ] ; then
    {
        echo "error You need to add THISSCRIPTCOMPLETEPATH variable like this:"
        echo "  export THISSCRIPTCOMPLETEPATH "
        echo "  typeset -r THISSCRIPTCOMPLETEPATH=\"\$(pwd)/\$(basename \"\$0\")\"   # § This goes in the FATHER-MOTHER script "
        echo "  export _err "
        echo "  typeset -i _err=0 "
        typeset  __SOURCE__="${BASH_SOURCE[0]}"
        while [[ -h "${__SOURCE__}" ]]; do
        {
            __SOURCE__="$(find "${__SOURCE__}" -type l -ls | sed -n 's@^.* -> \(.*\)@\1@p')"
        }
        done
        typeset __DIR__="$(cd -P "$(dirname "${__SOURCE__}")" && pwd)"
        # echo __SOURCE__ $__SOURCE__
        # echo __DIR__ $__DIR__
        echo "before calling $__SOURCE__"
        echo "or call direclty as sudo $__SOURCE__ then you dont need THISSCRIPTCOMPLETEPATH to be defined from your script "
    }
    else
    {
        if [ -e "./$THISSCRIPTCOMPLETEPATH" ] ; then
        {
          sudo "./$THISSCRIPTCOMPLETEPATH"
        }
        elif ( command -v "$THISSCRIPTCOMPLETEPATH" >/dev/null 2>&1 );  then
        {
          # echo "sudo sudo sudo "
          sudo "$THISSCRIPTCOMPLETEPATH"
        }
        else
        {
          echo -e "\033[05;7m*** Failed to find script to recall it as sudo ...\033[0m $THISSCRIPTCOMPLETEPATH"
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
  local -i CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
  if [ ${CAN_I_RUN_SUDO} -gt 0 ]; then
    echo -e "\033[01;7m*** Running as sudo ...\033[0m"
  else
    echo "Needs to run as sudo ... ${0}"
  fi
  return 0
}

function enforce_variable_with_value(){
  # repeated in struct_testing
  # Sample use
  # enforce_variable_with_value HOME $HOME
  # enforce_variable_with_value USER_HOME $USER_HOME
  # enforce_variable_with_value SUDO_USER $SUDO_USER
  # enforce_variable_with_value HOME $HOME && echo "HOME ensure_is_defined_and_not_empty 1"
  # Tests for the function
  # declare -rg USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
  #  ( typeset -p "HOME"  &>/dev/null )    @ Is HOME declared listed in declarations ?
  #  ( declare -p "HOME"  &>/dev/null )    @ Is HOME declared listed in declarations ?
  #  [ -n "${HOME+x}" ] && echo "HOME 1"   @ Is HOME declared and not empty?
  #  [ -z "${HOME+x}" ] && echo "HOME 1"   @ Is HOME declared and empty?
  # [ -n "${HOME+x}" ] && echo "HOME 1"
  # [ -n "${HOME+x}" ] && echo "HOME 12"
  # [ -n "${CAN_I_RUN_SUDO2+x}" ] && echo "CAN_I_RUN_SUDO2 null"
  # [ -n "${CAN_I_RUN_SUDO+x}" ] && echo "CAN_I_RUN_SUDO 12"
  # [ -n "${SUDO_USER+x}" ] && echo "SUDO_USER 111"
  # ( declare -p "HOME" ) && echo "HOME 2"
  typeset -r TESTING="that variable is listed and: ${CYAN}${1}${LIGHTYELLOW} and has value: ${RESET}<${YELLOW_OVER_DARKBLUE}${2}${RESET}>"
  (( DEBUG )) && echo -e "${FUNCNAME[0]}"
  (( DEBUG )) && echo ${@} -assume existing variable for this part
  (( DEBUG )) && ( typeset -p "${1}"  &>/dev/null  ) && echo "1 defined 1"
  (( DEBUG )) && [ -n "${2+x}" ]  && echo "1 defined 2"
  (( DEBUG )) && ( typeset -p "${1}"  &>/dev/null ) &&  [ -n "${2+x}" ]  && echo "1 declared,defined and with value not empty 3"
  (( DEBUG )) && ( ( typeset -p "${1}"  &>/dev/null  ) || echo "1 not defined 1")
  (( DEBUG )) && ( ! typeset -p "${1}"  &>/dev/null  ) && echo "1 not defined 2"
  # echo QWER - assume non existant variable for this part
  # ( typeset -p "QWER"  &>/dev/null  ) && echo "QWER defined 1"
  # [ -n "${QWER+x}" ]  && echo "QWER defined 2"
  # ( typeset -p "QWER"  &>/dev/null ) &&  [ -n "${QWER+x}" ]  && echo "QWER defined 3"
  # ( typeset -p "QWER"  &>/dev/null  ) || echo "QWER not defined 1"
  # ( ! typeset -p "QWER"  &>/dev/null  ) && echo "QWER not defined 2"
  # echo bye
  # exit 0
  if ( typeset -p "${1}"  &>/dev/null ) &&  [ -n "${2+x}" ] ; then
  {
      (( DEBUG )) && echo -e "${LIGHTGREEN} ✔ ${LIGHTYELLOW} ${TESTING} has passed "
      return 0
  } else {
      echo -e "${RED} 𝞦 ${LIGHTYELLOW} ${TESTING} has failed "
      exit 1
  }
  fi
  exit 1  # Stop the scripts execution
} # end enforce_variable_with_value
