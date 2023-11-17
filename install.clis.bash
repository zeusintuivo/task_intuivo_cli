#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
# 20200415 Compatible with Fedora, Mac, Ubuntu "sudo_up" "load_struct" "#
#set -u
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


#function pip () {
#  echo "pip was called to install: $*"
#}
export _err
typeset -i _err=0
  # function _trap_on_error(){
  #   echo -e "\\n \033[01;7m*** ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m"
  #   exit 1
  # }
  # trap _trap_on_error ERR
  # function _trap_on_int(){
  #   echo -e "\\n \033[01;7m*** INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n  INT ...\033[0m"
  #   exit 0
  # }
  # trap _trap_on_int INT

load_struct_testing(){
  # function _trap_on_error(){
  #   local -ir __trapped_error_exit_num="${2:-0}"
  #   warning "${@}"
  #   echo -e "\\n \033[01;7m*** ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m  \n \n "
  #   echo ". ${1}"
  #   echo ". exit  ${__trapped_error_exit_num}  "
  #   echo ". caller $(caller) "
  #   echo ". ${BASH_COMMAND}"
  #   local -r __caller=$(caller)
  #   local -ir __caller_line=$(echo "${__caller}" | cut -d' ' -f1)
  #   local -r __caller_script_name=$(echo "${__caller}" | cut -d' ' -f2)
  #   awk 'NR>L-10 && NR<L+10 { printf "%-10d%10s%s\n",NR,(NR==L?"☠ » » » > ":""),$0 }' L="${__caller_line}" "${__caller_script_name}"

  #   # $(eval ${BASH_COMMAND}  2>&1; )
  #   # echo -e " ☠ ${LIGHTPINK} Offending message:  ${__bash_error} ${RESET}"  >&2
  #   warning "${@}"
  #   # exit 1
  # }
  # trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
 
  
  # if [[ -d "${HOME}/_/clis" ]] && [[ ! -f "${HOME}/_/clis/task_intuivo_cli/add_error_trap.sh" ]] ; then
  # {
  #   sudo rm -rf "${HOME}/_"
  # }
  # fi
    local provider="$HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    local _err=0 structsource
    if [   -e "${provider}"  ] ; then
      echo "Loading locally"
      structsource="""$(<"${provider}")"""
      _err=$?
      [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. running 'source locally' returned error did not download or is empty err:$_err  \n \n  " && exit 1
    else
      if ( command -v curl >/dev/null 2>&1; )  ; then
        echo "Loading struct_testing from the net using curl "
        structsource="""$(curl https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing  -so -   2>/dev/null )"""  #  2>/dev/null suppress only curl download messages, but keep curl output for variable
        _err=$?
        [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. running 'curl' returned error did not download or is empty err:$_err  \n \n  " && exit 1
      elif ( command -v wget >/dev/null 2>&1; ) ; then
        echo "Loading struct_testing from the net using wget "
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
    echo "1. sudologic struct_testing Temp location ${_temp_dir}/struct_testing"
    source "${_temp_dir}/struct_testing"
    _err=$?
    [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. Occured while running 'source' err:$_err  \n \n  " && exit 1
    if  ! typeset -f passed >/dev/null 2>&1; then
      echo -e "\n \n  ERROR! Loading struct_testing. Passed was not loaded !!!  \n \n "
      exit 69;
    fi
    return $_err
} # end load_struct_testing
#
# Since the script is relaoded this IF takes care of not reloading struct_testing again
# When switched to sudo it loosed its context we might need to reload
#
if  ! typeset -f passed >/dev/null 2>&1; then
  echo "0.1 sudologic load_struct_testing"
  load_struct_testing
   _err=$?
  [ $_err -ne 0 ]  && echo -e "\n \n  ERROR FATAL! load_struct_testing_wget !!! returned:<$_err> \n \n  " && exit 69;
else 
  echo "4.1 sudologic not run load_struct_testing again"
fi


export sudo_it
function sudo_it() {
  # Call struct_testing.raise_to_sudo_and_user_home 
  # \... which loads 
  # _    \.... execute_command_intuivo_cli/execute_boot_basic.sh
  # _    \.... task_intuivo_cli/add_error_trap.sh
  # Will fail with ERROR Local File does not exists  or cannot be accessed if not found
  raise_to_sudo_and_user_home
  if [ $? -gt 0 ] ; then
  {
    failed to sudo_it raise_to_sudo_and_user_home
    exit 1
  }
  fi
  enforce_variable_with_value SUDO_USER "${SUDO_USER}"
  enforce_variable_with_value SUDO_UID "${SUDO_UID}"
  enforce_variable_with_value SUDO_COMMAND "${SUDO_COMMAND}"
  # Override bigger error trap  with local
  function _trap_on_error(){
    echo -e "\033[01;7m*** TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR INT ...\033[0m"
  }
  trap _trap_on_error ERR INT
} # end sudo_it

# _linux_prepare(){
  sudo_it
  if [ $? -gt 0 ] ; then
  {
    failed to sudo_it raise_to_sudo_and_user_home
    exit 1
  }
  fi
  export USER_HOME
  # shellcheck disable=SC2046
  # shellcheck disable=SC2031
  typeset -r USER_HOME="$(echo -n $(bash -c "cd ~${SUDO_USER} && pwd"))"  # Get the caller's of sudo home dir LINUX and MAC
  # USER_HOME=$(getent passwd "${SUDO_USER}" | cut -d: -f6)   # Get the caller's of sudo home dir LINUX
  enforce_variable_with_value USER_HOME "${USER_HOME}"
# }  # end _linux_prepare


# _linux_prepare
export SUDO_GRP='wheel'
enforce_variable_with_value USER_HOME "${USER_HOME}"
enforce_variable_with_value SUDO_USER "${SUDO_USER}"
passed "Caller user identified:${SUDO_USER}"
passed "Home identified:${USER_HOME}"
directory_exists_with_spaces "${USER_HOME}"

if [[ -e "${HOME}/_" ]] && [[ ! -e "${HOME}/_/clis/task_intuivo_cli" ]] && [[ ! -e "${HOME}/_/clis/execute_command_intuivo_cli" ]] ; then
{
  rm -rf "${HOME}/_"
}
fi

# exit 0
COMANDDER=""
_checka_node_commander() {
    local _commander="$1"
    is_not_installed npm &&  $_commander install -y npm             # Ubuntu only
    is_not_installed node && $_commander install -y nodejs          # In Fedora installs npm and node
    is_not_installed node && $_commander install -y nodejs-legacy   # Ubuntu only
    #verify_is_installed npm
    #verify_is_installed node
} # end _checka_node_commander

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


_checka_tools_commander(){
    # install_requirements "linux" "
    # xclip
    # tree
    # ag@the_silver_searcher
    # # Ubuntu only
    # ag@silversearcher-ag
    # ack
    # # Ubuntu only
    # ack@ack-grep
    # vim
    # nano
    # pv
    # # Ubuntu only
    # python-pip
    # "
    #verify_is_installed "
    #xclip
    #tree
    #ag
    #ack
    #pv
    #nano
    #vim
    #pip
    #sed
    #"
  if ( ! command -v pygmentize >/dev/null 2>&1; ) ;  then
    if ( command -v pip >/dev/null 2>&1; ) ; then # MAC
    {
       su - "${SUDO_USER}" -c 'pip install pygments'
       #pip install pygments
    }
    fi
    if ( command -v pip3 >/dev/null 2>&1; ) ; then # MAC
    {
       su - "${SUDO_USER}" -c 'pip3 install pygments'
       #pip3 install pygments
    }
    fi
  fi

   # is_not_installed pygmentize &&    pip install pygments
   # verify_is_installed pygmentize
  ensure pygmentize or "Canceling Install. Could not find pygmentize.  pip install pygments"
  # ensure npm or "Canceling Install. Could not find npm"
  # ensure node or "Canceling Install. Could not find node"
  # ensure cf or "Canceling Install. Could not find cf"
  #MTASCHECK=$(su - "${SUDO_USER}" -c 'cf mtas --help' >/dev/null 2>&1)
  #if [[ -n "$MTASCHECK" ]] &&  [[ "$MTASCHECK" == *"FAILED"* ]]  ; then
  #{
  #    su - "${SUDO_USER}" -c 'yes | cf install-plugin multiapps'
  #}
  #fi
  #
  #if [[ -n "$MTASCHECK" ]] &&  [[ "$MTASCHECK" != *"FAILED"* ]]  ; then
  #{
  #    passed Installed cf mtas plugin
  #}
  #fi
} # end _checka_tools_commander

_add_self_cron_update() {
  # Make a cron REF: https://www.golinuxcloud.com/create-schedule-cron-job-shell-script-linux/
  local -i DEBUG=0
  local -i _err=0
  local cronallowdir
  local cronallowfile
  if is_not_installed crontab ; then
  {
    echo -e "\033[05;7m*** Failed there is no crontab installed ...\033[0m"
    return 1
  }
  fi
  if [[ -n "${1}" ]] && [[ -n "${2}" ]] ; then {
    cronallowdir="${1}"
    cronallowfile="${2}"
  } else {
    cronallowfile=$(man crontab | grep cron.allow | sed 's/^[[:space:]]*//g'  2>&1 )
    cronallowdir=$(dirname "${cronallowfile}") # up to last slash
  }
  fi
  _ensure_touch_dir_and_file "${cronallowdir}" "${cronallowfile}"
  Installing cron  "${cronallowdir}" "${cronallowfile}"
  (( DEBUG )) &&  cat  "${cronallowfile}"
  su - "${SUDO_USER}" -c "touch ${cronallowfile}"
  _err=$?
  [ ${_err} -eq 0 ] || failed touching file ${cronallowfile}
  (_if_not_contains  "${cronallowfile}" "root") || echo 'root' >> "${cronallowfile}"
  (_if_not_contains  "${cronallowfile}" "${SUDO_USER}") ||  echo "${SUDO_USER}" >> "${cronallowfile}"
  (( DEBUG )) &&  cat  "${cronallowfile}"
  Installing crontab to pull clis automatically
  local _tmp_directory="$(_find_downloads_folder)"
   enforce_variable_with_value _tmp_directory "${_tmp_directory}"
   cd "${_tmp_directory}"
  local _tmp_cronfile="${_tmp_directory}/cronfile"
   enforce_variable_with_value _tmp_cronfile "${_tmp_cronfile}"
  Checking crontab is not empty
  if (su - "${SUDO_USER}" -c "crontab  \"${SUDO_USER}\" -l" /dev/null 2>&1 ) ; then
  {
    Loading crontab into _tmp_cronfile:"${_tmp_cronfile}"
    (crontab -u  "${SUDO_USER}" -l   2>&1) >"${_tmp_cronfile}"
  }
  else
  {
    Comment crontab is empty
    Creating _tmp_cronfile:"${_tmp_cronfile}" with new cron
    /bin/echo "* * * * * \$(cd \"${USER_HOME}/_/clis\" && pull_all_subdirectories  && echo \"updated \$(date +%Y%m%d%H%M)\" \$? >> \"${USER_HOME}/_/clis/uploaded.log\") > /dev/null 2>&1 || true" >> "${_tmp_cronfile}"
    # note about this cron this line will email locally, check with mail or mailx commands  REF: https://www.cyberciti.biz/faq/disable-the-mail-alert-by-crontab-command/bash
    # adding > /dev/null 2>&1 || true will block email sending
  }
  fi
  # exit 0
  if (_if_not_contains  "${_tmp_cronfile}" "/_/clis && pull_all_subdirectories") ; then
  {
    Updating _tmp_cronfile:"${_tmp_cronfile}" into crontab
    /bin/echo "* * * * * \$(cd \"${USER_HOME}/_/clis\" && pull_all_subdirectories  && echo \"updated \$(date +%Y%m%d%H%M)\" \$? >> \"${USER_HOME}/_/clis/uploaded.log\") > /dev/null 2>&1 || true" >> "${_tmp_cronfile}"
    # note about this cron this line will email locally, check with mail or mailx commands  REF: https://www.cyberciti.biz/faq/disable-the-mail-alert-by-crontab-command/bash
    # adding > /dev/null 2>&1 || true will block email sending
    su - "${SUDO_USER}" -c "crontab  \"${SUDO_USER}\" \"${_tmp_cronfile}\""
    Checking crontab exists
    if (su - "${SUDO_USER}" -c "crontab  \"${SUDO_USER}\" -l" /dev/null 2>&1 ) ; then
    {
      Loading crontab exists
      Checking crontab updated
      # crontab -u "${SUDO_USER}" "${_tmp_cronfile}"
      (crontab -u  "${SUDO_USER}" -l   2>&1) >"${_tmp_cronfile}"
      _err=$?
      [ ${_err} -eq 0 ] || failed checking to read crontab or write to file "${_tmp_cronfile}"
      (_if_not_contains  "${_tmp_cronfile}" "/_/clis && pull_all_subdirectories") || failed installing crontab
      (_if_not_contains  "${_tmp_cronfile}" "/_/clis && pull_all_subdirectories") || failed installing crontab
    }
    else
    {
      Comment crontab is still empty
      failed updated crontab
      # _err=$?
      # [ ${_err} -eq 0 ] || failed installing to read crontab or write to file "${_tmp_cronfile}"
      # this line will email locally, check with mail or mailx commands  REF: https://www.cyberciti.biz/faq/disable-the-mail-alert-by-crontab-command/bash
      # adding > /dev/null 2>&1 || true will block email sending
    }
    fi
  }
  fi
  # how to install crontab automatically REF: https://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash-automatically-without-the-interactive-editor/878647#878647
  passed passed - installed cron with clis_autoupdate
} # end _add  _self_cron_update

_add_launchd(){
  # Make a launchd REF: https://alvinalexander.com/mac-os-x/mac-osx-startup-crontab-launchd-jobs/
  local -i DEBUG=0
  local -i _err=0
  local launchdir
  local launchfile
  local launchname
  local launchservice
  if is_not_installed launchd ; then
  {
    echo -e "\033[05;7m*** Failed there is no launchd installed ...\033[0m"
    return 1
  }
  fi
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  if [[ -n "${1}" ]] && [[ -n "${2}" ]] ; then
  {
    launchdir="${1}"
    launchfile="${2}"
    launchservice="$(basename "${2}")"
  }
  else
  {
    launchfile="${USER_HOME}/Library/LaunchAgents/com.intuivo.clis_pull_all.plist"
    launchdir=$(dirname "${launchfile}")
    launchservice="$(basename "${launchfile}")"

  }
  fi
  _ensure_touch_dir_and_file "${launchdir}" "${launchfile}"
  _ensure_touch_dir_and_file "${USER_HOME}/_/clis" "${USER_HOME}/_/clis/updateall.bash"
  launchname="${launchfile##*/}"
  enforce_variable_with_value launchname "${launchname}"
  Installing  $0:$LINENO launchd "${launchdir}" "${launchfile}"
  Installing  $0:$LINENO /Library/LaunchDaemons - run when no users are logged in. run as 'administrator'
  Installing  $0:$LINENO /Library/LaunchAgents - when users are logged in. run as 'administrator'
  Installing  $0:$LINENO"${USER_HOME}/Library/LaunchAgents -  when as user when user is logged."
  su - "${SUDO_USER}" -c "echo '#!/usr/bin/env bash
  THISDIR=\"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )\" && pwd )\" # Getting the source directory of a Bash script from within REF: https://stackoverflow.com/questions/59895/how-can-i-get-the-source-directory-of-a-bash-script-from-within-the-script-itsel/246128#246128
  cd \"\${THISDIR}\"
  su - \"${SUDO_USER}\" -c \"${USER_HOME}/_/clis/git_intuivo_cli/pull_all_subdirectories\"
  _err=\$?
  if [ \${_err} -eq 0 ] ; then
  {
    su - \"${SUDO_USER}\" -c \"echo \"\$(date +%Y%m%d%H%M) failed \" > \"${USER_HOME}/_/clis/git_intuivo_cli/pull_all_subdirectories\"\"
  } else {
    su - \"${SUDO_USER}\" -c \"echo \"\$(date +%Y%m%d%H%M) passed \" > \"${USER_HOME}/_/clis/git_intuivo_cli/pull_all_subdirectories\"\"
  }
  fi
  su - \"${SUDO_USER}\" -c \"touch \"${USER_HOME}/_/clis/pulled.log\"\"
  _err=\$?
  if [ \${_err} -eq 0 ] ; then
  {
    su - \"${SUDO_USER}\" -c \"echo \"\$(date +%Y%m%d%H%M) failed \" > \"${USER_HOME}/_/clis/pulled.log\"\"
  } else {
    su - \"${SUDO_USER}\" -c \"echo \"\$(date +%Y%m%d%H%M) passed \" > \"${USER_HOME}/_/clis/pulled.log\"\"
  }
  fi
' > \"${USER_HOME}/_/clis/updateall.bash\" "
  (_if_not_contains  "${USER_HOME}/_/clis/updateall.bash" "pull_all_subdirectories") || failed writting to "${USER_HOME}/_/clis/updateall.bash"
  (( DEBUG )) && cat "${USER_HOME}/_/clis/updateall.bash"
  chmod +x "${USER_HOME}/_/clis/updateall.bash"


  echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>'"${launchname}"'</string>

  <key>ProgramArguments</key>
  <array>
    <string>'"${USER_HOME}/_/clis/update-repos.sh of clis"'</string>
  </array>

  <key>Nice</key>
  <integer>1</integer>

  <key>StartInterval</key>
  <integer>60</integer>

  <key>RunAtLoad</key>
  <true/>

  <key>StandardErrorPath</key>
  <string>'"${USER_HOME}/_/clis/pulled_err.log"'</string>

  <key>StandardOutPath</key>
  <string>'"${USER_HOME}/_/clis/pulled_out.log"'</string>
</dict>
</plist>
' > "${launchfile}"
   #(( DEBUG )) && cat "${launchfile}"

   Checking $0:$LINENO "${launchfile}"
   # Set correct permissions REF: https://stackoverflow.com/questions/28063598/error-while-executing-plist-file-path-had-bad-ownership-permissions
   # sudo chown root "${launchfile}"
   chown "${SUDO_USER}"  "${launchfile}"
   chgrp wheel "${launchfile}"
   chmod o-w  "${launchfile}"
   if [[ -n "$( su - "${SUDO_USER}" -c "launchctl list | grep \"${launchservice}\"" )" ]] ; then
   # if ( launchctl list "${launchservice}" | grep "${launchservice}" ) ; then
   {
     wait
     Comment $0:$LINENO exists "${launchfile}"
     su - "${SUDO_USER}" -c "launchctl unload \"${launchfile}\" "
     wait
     # launchctl unload "${launchservice}"
     # _err=$?
     # [ ${_err} -ne 0 ] || failed "${_err} -err launchctl unload \"${launchfile}\" "
   }
   else
   {
     Comment $0:$LINENO exists not "${launchfile}"
   }
   fi

   wait
   Installing "$0:$LINENO ${launchfile}"
   if [[ "$(uname -m)" == "arm64" ]] ; then
   {
     Installing  $0:$LINENO launchctl bootstrap gui/501 "${launchfile}"
     echo "LEGACY launchctl load "${launchfile}" "
     echo " now we need to make it owned by root"
     chown root "${launchfile}"
     if /bin/launchctl bootout gui/501 "${launchfile}" ; then 
     {
        warning it did not exists, no worries installing again
     }
     fi
     if /bin/launchctl bootstrap gui/501 "${launchfile}" ; then 
     {
        warning  bootstrap gui/501 has failed
     }
     else
     {
        passed to load "${launchfile}"
     }
     fi

      passed "done using bootstrap attempting to install launchctl for ${launchfile}"

   }
   else 
   {
     Installing before mac 10.15 we need LEGACY launchctl 
     if su - "${SUDO_USER}" -c "launchctl load  -w  \"${launchfile}\"" ; then 
     {
        warning it did not exists, no worries installing again
     }
     fi
     if launchctl load  -w "${launchfile}" ; then 
     {
        warning it did not exists, no worries installing again
     }
     fi
     if su - "${SUDO_USER}" -c "launchctl load  \"${launchfile}\"" ; then 
     {
        warning su -  launchctl load failed
     }
     fi
     if launchctl load  "${launchfile}" ; then 
     {
        warninglaunchctl load failed
     }
     fi
     
     passed "done  LEGACY attempting to install launchctl for ${launchfile}"
     
   }
   fi
   echo "end $0:$LINENO _add_launchd "
} # end _add_launchd

_configure_git(){
  ensure git or "Canceling Install. Could not find git"
  local CURRENTGITUSER=$(su - "${SUDO_USER}" -c 'git config --global --get user.name')
  local CURRENTGITEMAIL=$(su - "${SUDO_USER}" -c 'git config --global --get user.email')
  # exit 0

  if [[ -z "$CURRENTGITEMAIL" ]] ; then
  {
    Configuring git user.email with  "${SUDO_USER}"@$(hostname)
    su - "${SUDO_USER}" -c 'git config --global user.email '${SUDO_USER}'@$(hostname)'
  }
  fi
  # exit 0
  if [[ -z "$CURRENTGITUSER" ]] ; then
  {
    Configuring git user.name with  "${SUDO_USER}"
    su - "${SUDO_USER}" -c 'git config --global user.name '${SUDO_USER}
  }
  fi
} # end _configure_git

_install_npm_utils() {
    mkdir -p "${USER_HOME}/.npm"
    mkdir -p "${USER_HOME}/.nvm"
    chown -R "${SUDO_USER}" "${USER_HOME}/.npm"
    chown -R "${SUDO_USER}" "${USER_HOME}/.nvm"
    # Global node utils
    is_not_installed nodemon  && npm i -g nodemon
    if  is_not_installed live-server  ; then
    {
        npm i -g live-server
    }
    fi
   # verify_is_installed live-server
   # verify_is_installed nodemon
    # is_not_installed jest &&  npm i -g jest
    # verify_is_installed jest
    #CHAINSTALLED=$(su - "${SUDO_USER}" -c 'npm -g info chai >/dev/null 2>&1')
    CHAINSTALLED=$(npm -g info chai >/dev/null 2>&1)
    if [[ -n "$CHAINSTALLED" ]] &&  [[ "$CHAINSTALLED" == *"npm ERR"* ]]  ; then
    {
        Installing npm chai
        npm i -g chai
    }
    fi
    #MOCHAINSTALLED=$(su - "${SUDO_USER}" -c 'npm -g info mocha >/dev/null 2>&1')
    MOCHAINSTALLED=$(npm -g info mocha >/dev/null 2>&1)
    if [[ -n "$MOCHAINSTALLED" ]] &&  [[ "$MOCHAINSTALLED" == *"npm ERR"* ]]  ; then
    {
        npm i -g mocha
    }
    fi
    local ret msg
    #msg=$(su - "${SUDO_USER}" -c 'cds >/dev/null 2>&1')
    #ret=$?
    #if [ $ret -gt 0 ] ; then
    #{
        Installing --skipped npm cds
    #    npm i -g @sap/cds-dk
    #    msg=$(su - "${SUDO_USER}" -c 'cds')
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
} # end _install_npm_utils

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
} # end _if_not_is_installed

_install_nvm() {
    local -i ret
    local msg
    [[  ! -e "${USER_HOME}/.config" ]] && mkdir -p "${USER_HOME}/.config"
    chown  -R "${SUDO_USER}" "${USER_HOME}/.config"
    [ -s "${USER_HOME}/.nvm/nvm.sh" ] && . "${USER_HOME}/.nvm/nvm.sh" # This loads nvm

    msg=$(nvm >/dev/null 2>&1)
    ret=$?

    if is_not_installed nvm ; then  # [ $ret -gt 0 ] ; then
    {
        Installing nvm Node Version Manager
        Installing  nvm setup
        su - "${SUDO_USER}" -c 'HOME='${USER_HOME}' curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash'

        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${USER_HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
        [ -s "${USER_HOME}/.nvm/nvm.sh" ] && \. "${USER_HOME}/.nvm/nvm.sh" # This loads nvm

        Configuring  nvm setup

        _if_not_contains "${USER_HOME}/.bash_profile" "NVM_DIR/nvm.sh" || echo '
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
'  >> "${USER_HOME}/.bash_profile"

        file_exists_with_spaces "${USER_HOME}/.bash_profile"

        _if_not_contains "${USER_HOME}/.bashrc" "NVM_DIR/nvm.sh" ||  echo '
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
'  >> "${USER_HOME}/.bashrc"

        file_exists_with_spaces "${USER_HOME}/.bashrc"

        _if_not_contains "${USER_HOME}/.zshrc" "NVM_DIR/nvm.sh" ||  echo '
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
'  >> "${USER_HOME}/.zshrc"

        file_exists_with_spaces "${USER_HOME}/.zshrc"

        msg=$(su - "${SUDO_USER}" -c 'nvm' >/dev/null 2>&1)
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
} # end _install_nvm

_install_nvm_version(){
    local TARGETVERSION="${1}"
    # chown -R $SUDO_USER:$(id -gn $SUDO_USER) "${USER_HOME}/.config"
    Configuring nvm node "${TARGETVERSION}"
    [ -s "${USER_HOME}/.nvm/nvm.sh" ] && . "${USER_HOME}/.nvm/nvm.sh" # This loads nvm


    local VERSION12=$(nvm ls | grep "v${TARGETVERSION}" |tail -1 >/dev/null 2>&1 )
    if [[ -n "${VERSION12}" ]] ; then
    {
        if [[ "${VERSION12}" == *"not found"* ]] || [[ "${VERSION12}" == *"nvm help"* ]]  ; then
        {
            failed "Nvm command not found or failed! It should have been installed by this point."
        }
        fi
        if [[ "${VERSION12}" == *"v${TARGETVERSION}"* ]]  ; then
        {
            passed that: node "${TARGETVERSION}" installed. Version Found "${VERSION12}"
        }
        else
        {
            Installing node using nvm install  "${TARGETVERSION}"
          VERSION12=$(nvm ls | grep "v${TARGETVERSION}" |tail -1 >/dev/null 2>&1 )
            if [[ -n "${VERSION12}" ]] ; then
            {
                if [[ "${VERSION12}" == *"not found"* ]] || [[ "${VERSION12}" == *"nvm help"* ]]  ; then
                {
                    failed "Nvm command not found or failed! It should have been installed by this point."
                }
                fi
                if [[ "${VERSION12}" == *"v${TARGETVERSION}"* ]]  ; then
                {
                    passed that: node "${TARGETVERSION}" installed. Version Found "${VERSION12}"
                }
                else
                {
                    failed to install node using nvm for version "${TARGETVERSION}"
                }
                fi
            }
            fi
        }
        fi
    }
    fi
    if [[ "${VERSION12}" == *"v${TARGETVERSION}"* ]]  ; then
    {
        passed that: node "${TARGETVERSION}" installed. Version Found "${VERSION12}"
    }
    else
    {
        Installing node using nvm install  "${TARGETVERSION}"
          VERSION12=$(nvm ls | grep "v${TARGETVERSION}" |tail -1 >/dev/null 2>&1 )
            if [[ -n "${VERSION12}" ]] ; then
            {
                if [[ "${VERSION12}" == *"not found"* ]] || [[ "${VERSION12}" == *"nvm help"* ]]  ; then
                {
                    failed "Nvm command not found or failed! It should have been installed by this point."
                }
                fi
                if [[ "${VERSION12}" == *"v${TARGETVERSION}"* ]]  ; then
                {
                    passed that: node "${TARGETVERSION}" installed. Version Found "${VERSION12}"
                }
                else
                {
                    failed to install node using nvm for version "${TARGETVERSION}"
                }
                fi
            }
            fi
        }
    fi
    Setting . nvm use "${TARGETVERSION}"
    # su - "${SUDO_USER}" -c '. "${USER_HOME}/.nvm/nvm.sh && "${USER_HOME}/.nvm/nvm.sh use "${TARGETVERSION}"'
    chown -R "${SUDO_USER}"  "${USER_HOME}/.nvm"
    chgrp -R "${SUDO_GRP}" "${USER_HOME}/.nvm"
    nvm install "${TARGETVERSION}"
    chown -R "${SUDO_USER}"  "${USER_HOME}/.nvm"
    chgrp -R "${SUDO_GRP}" "${USER_HOME}/.nvm"
    nvm use "${TARGETVERSION}"
    # su - "${SUDO_USER}" -c ''${USER_HOME}'/.nvm/nvm.sh && . '${USER_HOME}'/.nvm/nvm.sh && nvm use "${TARGETVERSION}"'
    # node --version
    #nvm use "${TARGETVERSION}"
} # end _install_nvm_version

_install_nerd_fonts(){

  if  it_does_not_exist_with_spaces "${USER_HOME}/.nerd-fonts" ; then
  {
    cd "${USER_HOME}"
    su - "${SUDO_USER}" -c  "git clone --depth=1 https://github.com/ryanoasis/nerd-fonts \"${USER_HOME}/.nerd-fonts\""
    directory_exists_with_spaces "${USER_HOME}/.nerd-fonts"
    file_exists_with_spaces "${USER_HOME}/.nerd-fonts/install.sh"
    chown -R "${SUDO_USER}" "${USER_HOME}/.nerd-fonts"

    cd "${USER_HOME}/.nerd-fonts"
    su - "${SUDO_USER}" -c  "bash -c \"${USER_HOME}/.nerd-fonts/install.sh\""
  }
  fi
} # end _install_nerd_fonts



        function _find_executable_for() {
          trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR

          local _executable_test="${1:-}" 
          enforce_parameter_with_value           1:-        _executable_test     "${_executable_test:-}"     "nothing|brew"
          if [[ "${_executable_test:-}" == "nothing" ]] ; then
          {
            _executable_test=""
          }
          fi
          local _argumentexecutable_test="${2:-}" 
          if [[ "${_argumentexecutable_test:-}" == "nothing" ]] ; then
          {
            _argumentexecutable_test=""
          }
          fi
          if [[ -z "${_executable_test}" ]] ; then
          {
            _argumentexecutable_test=""
          }
          fi
          enforce_parameter_with_value           2:-        _argumentexecutable_test     "${_argumentexecutable_test:-}"     "nothing|--prefix"
          local _possibles="${*:3}"
          enforce_parameter_with_value           *:3++        _possibles     "${_possibles:-}"     "
                  bin/brew
                  brew
          "
          local -i _err=0
          local _try_returned_echo=""
          _try_returned_echo="$(_try_more_times_find "${_possibles}")"
          _err=$?
          if [ $_err -gt 0 ] ; then # failed
          {
            echo "${_try_returned_echo}"
            failed "to find any ${_executable_test} of ${_possibles}"
          }
          fi
          local _target_found=""
          _target_found="$(echo -n "${_try_returned_echo:-}" | tail -1)"
          passed "found ${_executable_test} of ${_possibles} one = ${_target_found:-}"
          if [[ -n "${_target_found:-}" ]] ; then 
          {
            Checking "if ${_executable_test} is responds to command -v ${_executable_test} since \$_target_found  var is empty"
            if ( su - "${SUDO_USER}" -c "command -v ${_executable_test}" >/dev/null 2>&1; )  ; then
            {
              if [[ -z "${_argumentexecutable_test:-}" ]] ; then
              {
                _target_found="$(su - "${SUDO_USER}" -c "${_executable_test}")"
              }
              else 
              {
                _target_found="$(su - "${SUDO_USER}" -c "${_executable_test} ${_argumentexecutable_test}")"
              }
              fi
            }
            fi
          }
          fi
          enforce_variable_with_value _target_found "${_target_found}"
  
          if [[ -n "${_target_found:-}" ]] ; then 
          {
            echo "${_target_found}"
            return 0
          }
          fi
          failed "Not found ${_executable_test} ${_argumentexecutable_test} or of ${_possibles} "
          return 1
          # if ( command -v ${_target_found} >/dev/null 2>&1; ) ; then
          # {
          # }
          # fi
        } # end _find_executable_for 


_setup_ohmy(){
    if  it_does_not_exist_with_spaces "${USER_HOME}/.oh-my-zsh/" ; then
    {
        Installing ohmy
        if [[ "$COMANDDER" == *"apt-get"* ]]  ; then
        {
           wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
            _if_not_is_installed fontawesome-fonts && $COMANDDER fontawesome-fonts
            _if_not_is_installed powerline && $COMANDDER powerline vim-powerline tmux-powerline powerline-fonts
            echo REF: https://fedoramagazine.org/tuning-your-bash-or-zsh-shell-in-workstation-and-silverblue/
            if [ -f `which powerline-daemon` ]; then
            {
              powerline-daemon -q
              POWERLINE_BASH_CONTINUATION=1
              POWERLINE_BASH_SELECT=1
              . /usr/share/powerline/bash/powerline.sh

            }
            fi
        }
        elif [[ "$COMANDDER" == *"dnf"* ]]  ; then
        {
         $COMANDDER git wget curl ruby ruby-devel zsh util-linux-user redhat-rpm-config gcc gcc-c++ make
            _if_not_is_installed fontawesome-fonts && $COMANDDER fontawesome-fonts
            _if_not_is_installed powerline && $COMANDDER powerline vim-powerline tmux-powerline powerline-fonts
            if [ -f `which powerline-daemon` ]; then
            {
              powerline-daemon -q
              POWERLINE_BASH_CONTINUATION=1
              POWERLINE_BASH_SELECT=1
              . /usr/share/powerline/bash/powerline.sh
            }
            fi

        }
        fi


    _install_nerd_fonts
    if [[ "$COMANDDER" == *"brew"* ]]  ; then # MAC and linux 
    {
                  local -i _err=0
                  ensure_brew_in_linux_mac
                        # su - "${SUDO_USER}" -c "brew install --cask font-fontawesome" # This was fontawesome 4, new 6 is gone
      $COMANDDER tap homebrew/cask-fonts         # You only need to do this once!
      $COMANDDER install font-inconsolata
      $COMANDDER install font-awesome-terminal-fonts 
      $COMANDDER install font-fontawesome 
      $COMANDDER install python3


      local missing="powerline-status"
      local -i err_buff=0
      local _powerline_sh=""

                  local _target_pip3=""
                  _target_pip3="$(_find_executable_for "which" "pip3"  "pip3
                     bin/pip3")"
                  _err=$?
                  if [ $_err -gt 0 ] ; then # failed
                  {
                    echo "${_target_pip3}"
                    failed "to find pip3"
                  }
                  fi
                  _target_pip3="$(echo -n "${_target_pip3}" | tail -1)"
                  enforce_variable_with_value _target_pip3 "${_target_pip3}"
                 
                  if ( command -v "${_target_pip3}" >/dev/null 2>&1; ) ; then
                  {
                    # _run_command pip3 install ${missing}
                    if (( DEBUG )) ; then
                      echo "pip3 install"
                      echo "${_target_pip3} install ....${missing}"
                    fi
                    # install=$($HOME/.pyenv/shims/pip3 install "${missing}")
                    su - "${SUDO_USER}" -c "${_target_pip3} install ${missing} "
                    err_buff=$?
                    _powerline_sh=$(su - "${SUDO_USER}" -c "${_target_pip3} show ${missing} " | grep "Location:" |  cut -d: -f2- | xargs)
                   
                    err_buff=$?
                    # su - "${SUDO_USER}" -c "pip3 install ${missing} "
                  }
                  else 
                  {
                    failed "to find get command -v ${_target_pip3} to respond"
                  }
                  fi


      $COMANDDER install powerline vim-powerline tmux-powerline powerline-fonts
          if [[ -n "${_powerline_sh}" ]] ; then
          {
            powerline-daemon -q
            POWERLINE_BASH_CONTINUATION=1
            POWERLINE_BASH_SELECT=1
            \. "${_powerline_sh}"
          }
          fi

      }
      fi
    }
    fi

                  Testing zsh
                  # install ohmyzsh
                  su - "${SUDO_USER}" -c 'sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
                  chown -R "${SUDO_USER}" "${USER_HOME}/.oh-my-zsh"

                  local -i _err=0
                  local _target_zsh=""
                  _target_zsh="$(_find_executable_for "which" "zsh"  "bin/zsh")"
                  _err=$?
                  if [ $_err -gt 0 ] ; then # failed
                  {
                    echo "${_target_zsh}"
                    failed "to find zsh"
                  }
                  fi
                  _target_zsh="$(echo -n "${_target_zsh}" | tail -1)"
                  enforce_variable_with_value _target_zsh "${_target_zsh}"
                 
                  if ( command -v "${_target_zsh}" >/dev/null 2>&1; ) ; then
                  {
                    # _run_command zsh install ${missing}
                    if (( DEBUG )) ; then
                      echo "zsh chsh"
                      echo "${_target_zsh} install ....${missing}"
                    fi
                    chsh -s "${_target_zsh}" "${SUDO_USER}"
                    su - "${SUDO_USER}" -c "chsh -s \"${_target_zsh}\" \"${SUDO_USER}\""                  
                    err_buff=$?
                  }
                  else 
                  {
                    failed "to find get command -v ${_target_zsh} to respond so chsh -s zsh ${SUDO_USER} ...was not run and not changed "
                  }
                  fi


        Testing ohmyzsh
        directory_exists_with_spaces "${USER_HOME}/.oh-my-zsh"
        passed that: ohmy is installed


  if it_does_not_exist_with_spaces "${USER_HOME}/.oh-my-zsh/themes/powerlevel10k" ; then
  {
    su - "${SUDO_USER}" -c "git clone https://github.com/romkatv/powerlevel10k.git \"${USER_HOME}/.oh-my-zsh/themes/powerlevel10k\""
    _if_not_contains "${USER_HOME}/.zshrc" "powerlevel10k" || echo "ZSH_THEME=powerlevel10k/powerlevel10k" >> "${USER_HOME}/.zshrc"
  }
  else
  {
    passed powerlevel10k already there
  }
  fi
  if it_does_not_exist_with_spaces "${USER_HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ; then
  {
    su - "${SUDO_USER}" -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \"${USER_HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting\""
    _if_not_contains "${USER_HOME}/.zshrc" "zsh-highlighting" || echo "plugins=(git zsh-syntax-highlighting)"   >> "${USER_HOME}/.zshrc"
  }
  else
  {
    passed zsh-syntax-highlighting already there
  }
  fi
  if it_does_not_exist_with_spaces "${USER_HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ; then
  {
    su - "${SUDO_USER}" -c "git clone https://github.com/zsh-users/zsh-autosuggestions \"${USER_HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions\""
    _if_not_contains "${USER_HOME}/.zshrc" "zsh-autosuggestions" || echo "plugins=(git zsh-syntax-highlighting zsh-autosuggestions)"   >> "${USER_HOME}/.zshrc"
  }
  else
  {
    passed zsh-autosuggestions  already there
  }
  fi
  if it_does_not_exist_with_spaces "${USER_HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ; then
  {
    su - "${SUDO_USER}" -c "git clone clone --depth 1 https://github.com/unixorn/fzf-zsh-plugin.git  \"${USER_HOME}/.oh-my-zsh/custom/plugins/fzf-zsh-plugin\""
    _if_not_contains "${USER_HOME}/.zshrc" "fzf-zsh-plugin" || echo "plugins=(git zsh-syntax-highlighting zsh-autosuggestions fzf-zsh-plugin)"   >> "${USER_HOME}/.zshrc"
  }
  else
  {
    passed zsh-autosuggestions  already there
  }
  fi
  return 0
} # end _setup_ohmy

_install_colorls(){
if ( gem list colorls | grep -q "^colorls" ) ; then
{
  passed colorls is already installed as gem
  return 0
}
else
{
  if [[ "$(uname)" == "Darwin" ]] ; then
  {
   # verify_is_installed xcodebuild
    # Do something under Mac OS X platform
    local xcodeversion=$(xcodebuild -version | head -1)
    if  ! version_installed_is "${xcodeversion}"  "11.3.1" ;   then # is like version installed is  11.3.1 ?
    {
      Comment xcodebuild \-version Xcode 11.3.1 is ruby broken fix here \-\> REF: https://stackoverflow.com/questions/20559255/error-while-installing-json-gem-mkmf-rb-cant-find-header-files-for-ruby
      local non_existent_path=$(ruby -rrbconfig -e 'puts RbConfig::CONFIG["rubyhdrdir"]')
      if  ! it_exists_with_spaces  "${non_existent_path}"  ; then 
      {
        if  it_exists_with_spaces /Applications/Xcode.app  ; then 
        {
        
          Comment "see ! filepath \"${non_existent_path}\" does not exists !!!  "
          Comment "changing to  xcode-select --switch /Library/Developer/CommandLineTools"
          xcode-select --switch /Library/Developer/CommandLineTools
          touch "${USER_HOME}/.install.clis.step_xcode_ruby_change.lock" 
          Comment "checking again .."
          non_existent_path=$(ruby -rrbconfig -e 'puts RbConfig::CONFIG["rubyhdrdir"]')
          if  ! it_exists_with_spaces  "${non_existent_path}"  ; then 
          {
              Comment "ok even afer doing patch from REF: https://stackoverflow.com/questions/20559255/error-while-installing-json-gem-mkmf-rb-cant-find-header-files-for-ruby "
              Comment "it still does not work "
              Comment  "${non_existent_path}"
              rm "${USER_HOME}/.install.clis.step_xcode_ruby_change.lock"
              warning nah "cannot install colorls To add ruby path to compile colorls install it manually and try again"
          }
          else 
          {
  Installing colorls
  yes | DEVELOPER_DIR=/Library/Developer/CommandLineTools/  gem install colorls
  yes | DEVELOPER_DIR=/Library/Developer/CommandLineTools/  gem update colorls
  chown -R "${SUDO_USER}" /Library/Ruby
  _if_not_contains "${USER_HOME}/.zshrc" "colorls" || echo "alias ll='colorls -lA --sd --gs --group-directories-first'" >> "${USER_HOME}/.zshrc"
  _if_not_contains "${USER_HOME}/.zshrc" "colorls" || echo "alias ls='colorls --group-directories-first'" >> "${USER_HOME}/.zshrc"
  _if_not_contains "${USER_HOME}/.bashrc" "colorls" || echo "alias ll='colorls -lA --sd --gs --group-directories-first'" >> "${USER_HOME}/.bashrc"
  _if_not_contains "${USER_HOME}/.bashrc" "colorls" || echo "alias ls='colorls --group-directories-first'" >> "${USER_HOME}/.bashrc"
               passed "Found new rubyfilepath !!!  \<${non_existent_path}\> " 
          }
          fi        
        }
        fi
      } 
      else 
      {
        Comment "Never mind filepath does exists  \<${non_existent_path}\> " 
      }
      fi
    }
    fi
  }
  fi

  if ( it_exists_with_spaces   "${USER_HOME}/.install.clis.step_xcode_ruby_change.lock"  ) ; then
  {
    Comment "Removing patch for ruby build "
    xcode-select --switch /Applications/Xcode.app
    rm "${USER_HOME}/.install.clis.step_xcode_ruby_change.lock"
  }
  fi

}
fi
return 0
} # end _install_colorls

_setup_clis(){
  local -i ret
  local msg
  Comment start _setup_clis
  Comment USER_HOME:${USER_HOME}
  Comment SUDO_GRP:${SUDO_GRP}
  ret=0
  if  it_exists_with_spaces "${USER_HOME}/_/clis" ; then
  {
    directory_exists_with_spaces "${USER_HOME}/_/clis"
  }
  fi
  if  it_does_not_exist_with_spaces "${USER_HOME}/_/clis" ; then
  {
    su - "${SUDO_USER}" -c "mkdir -p \"${USER_HOME}/_/clis\""
    chown  -R  "${SUDO_USER}" "${USER_HOME}/_"
    chgrp -R "${SUDO_GRP}" "${USER_HOME}/_"
    cd "${USER_HOME}/_/clis"
  }
  else
  {
    passed clis: clis folder exists
  }
  fi
  if  it_does_not_exist_with_spaces "${USER_HOME}/_/clis/bash_intuivo_cli" ; then
  {
    cd "${USER_HOME}/_/clis"
    Installing Clis pre work  bash_intuivo_cli  for link_folder_scripts
    su - "${SUDO_USER}" -c "yes | git clone https://github.com/zeusintuivo/bash_intuivo_cli.git \"${USER_HOME}/_/clis/bash_intuivo_cli\""
    if it_does_not_exist_with_spaces "${USER_HOME}/_/clis/bash_intuivo_cli" ; then
    {
      su - "${SUDO_USER}" -c "yes | git clone https://github.com/zeusintuivo/bash_intuivo_cli.git \"${USER_HOME}/_/clis/bash_intuivo_cli\""
    }
    fi
    cd "${USER_HOME}/_/clis/bash_intuivo_cli"
    git remote remove origin
    git remote add origin https://github.com/zeusintuivo/bash_intuivo_cli.git
    bash -c "${USER_HOME}/_/clis/bash_intuivo_cli/link_folder_scripts"
  }
  else
  {
    passed clis: bash_intuivo_cli folder exists
  }
  fi
  if  is_not_installed link_folder_scripts ; then
  {
    cd "${USER_HOME}/_/clis"
    Installing No. 2 Clis pre work  bash_intuivo_cli  for link_folder_scripts
    # su - "${SUDO_USER}" -c "yes | git clone https://github.com/zeusintuivo/bash_intuivo_cli.git  \"${USER_HOME}/_/clis/bash_intuivo_cli\""
    if it_does_not_exist_with_spaces "${USER_HOME}/_/clis/bash_intuivo_cli" ; then
    {
      su - "${SUDO_USER}" -c "yes | git clone https://github.com/zeusintuivo/bash_intuivo_cli.git \"${USER_HOME}/_/clis/bash_intuivo_cli\""
    }
    fi
    chown -R "${SUDO_USER}"  "${USER_HOME}/_/clis/bash_intuivo_cli"
    chgrp -R "${SUDO_GRP}" "${USER_HOME}/_/clis/bash_intuivo_cli"
    cd "${USER_HOME}/_/clis/bash_intuivo_cli"
    git remote remove origin
    git remote add origin https://github.com/zeusintuivo/bash_intuivo_cli.git
    bash -c "${USER_HOME}/_/clis/bash_intuivo_cli/link_folder_scripts"
  }
  else
  {
    passed clis: bash_intuivo_cli folder exists
  }
  fi
  # if  it_does_not_exist_with_spaces "${USER_HOME}/_/clis/ssh_intuivo_cli" ; then
  # {
  #   cd "${USER_HOME}/_/clis"
  #   Installing No. 3 Clis pre work ssh_intuivo_cli  for link_folder_scripts
  #   yes | git clone https://github.com/zeusintuivo/ssh_intuivo_cli.git
  #   if it_does_not_exist_with_spaces "${USER_HOME}/_/clis/ssh_intuivo_cli" ; then
  #   {
  #     su - "${SUDO_USER}" -c "yes | git clone https://github.com/zeusintuivo/ssh_intuivo_cli.git  \"${USER_HOME}/_/clis/ssh_intuivo_cli\""
  #   }
  #   fi
  #   cd "${USER_HOME}/_/clis/ssh_intuivo_cli"
  #   chown -R "${SUDO_USER}" "${USER_HOME}/_/clis/ssh_intuivo_cli"
  #   chgrp -R "${SUDO_GRP}" "${USER_HOME}/_/clis/ssh_intuivo_cli"
  #   chown -R "${SUDO_USER}"  "${USER_HOME}/.ssh"
  #   chgrp -R "${SUDO_GRP}" "${USER_HOME}/.ssh"
  #   git remote remove origin
  #   git remote add origin https://github.com/zeusintuivo/ssh_intuivo_cli.git
  #   bash -c "${USER_HOME}/_/clis/bash_intuivo_cli/link_folder_scripts"
  #   ./sshswitchkey zeus
  # }
  # else {
  #   passed clis: ssh_intuivo_cli folder exists
  # }
  # fi
#   TODO: Consider installing like here with no Sudo support.
#   TODO: Adding it as plugin to ohmyzsh
#   https://www.scootersoftware.com/support.php?zz=kb_OSXInstallCLT
# INSTALL COMMAND LINE TOOLS WITHOUT SUDO/ROOT ACCESS
# Go to the Terminal and run:
# mkdir ~/bin
# nano ~/.zshrc (macOS Catalina) or nano ~/.bash_profile (macOS Mohave or older)
# Add the line export PATH=$HOME/bin:$PATH
# ln -s /Applications/Beyond\ Compare.app/Contents/MacOS/bcomp ~/bin/bcompare
# ln -s /Applications/Beyond\ Compare.app/Contents/MacOS/bcomp ~/bin/bcomp
# rm -rf "${USER_HOME}/_/clis/ssh_intuivo_cli

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
  if [ -n "$ONE" ] ; then  # is not empty
  {
    Installing "$ONE"
    if  it_does_not_exist_with_spaces "${USER_HOME}/_/clis/${ONE}" ; then
    {
      cd "${USER_HOME}/_/clis"
      su - "${SUDO_USER}" -c "yes | git clone https://github.com/zeusintuivo/${ONE}.git  \"${USER_HOME}/_/clis/${ONE}\""
      if it_does_not_exist_with_spaces "${USER_HOME}/_/clis/${ONE}" ; then
      {
        su - "${SUDO_USER}" -c "yes | git clone https://github.com/zeusintuivo/${ONE}.git  \"${USER_HOME}/_/clis/${ONE}\""
      }
      fi
      cd "${USER_HOME}/_/clis/${ONE}"
      chown -R "${SUDO_USER}" "${USER_HOME}/_/clis/${ONE}"
      git remote remove origin
      git remote add origin https://github.com/zeusintuivo/${ONE}.git
      directory_exists_with_spaces "${USER_HOME}/_/clis/${ONE}"
      if bash -c "${USER_HOME}/_/clis/bash_intuivo_cli/link_folder_scripts" ; then
      {
        echo "linked \"${USER_HOME}/_/clis/${ONE}\""
      }
      fi
      if [[ "$ONE" == "git_intuivo_cli" ]] ; then  # is not empty
      {
        cd "${USER_HOME}/_/clis/${ONE}/en"
        if bash -c "${USER_HOME}/_/clis/bash_intuivo_cli/link_folder_scripts" ; then
        {
          echo "linked \"${USER_HOME}/_/clis/${ONE}/en\""
        }
        fi
      }
      fi
    }
    else
    {
      Installing else $ONE
      passed clis: ${ONE} folder exists
      cd "${USER_HOME}/_/clis/${ONE}"
      chown -R "${SUDO_USER}" "${USER_HOME}/_/clis/${ONE}"
      pwd
      if bash -c "${USER_HOME}/_/clis/bash_intuivo_cli/link_folder_scripts" ; then
      {
        echo "linked \"${USER_HOME}/_/clis/${ONE}\""
      }
      fi
      if [[ "$ONE" == "git_intuivo_cli" ]] ; then  # is not empty
      {
        cd "${USER_HOME}/_/clis/${ONE}/en"
        if bash -c "${USER_HOME}/_/clis/bash_intuivo_cli/link_folder_scripts" ; then
        {
          echo "linked \"${USER_HOME}/_/clis/${ONE}/en\""
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
    fi
  }
  fi
}
done <<< "${clis}"
# unlink /usr/local/bin/ag # Bug path we need to do something abot this

if  softlink_exists_with_spaces "/usr/local/bin/added>${USER_HOME}/_/clis/git_intuivo_cli/en/added" ; then
{
    passed clis: git_intuivo_cli/en folder exists and is linked
}
else
{
  Configuring extra work git_intuivo_cli/en
  directory_exists_with_spaces "${USER_HOME}/_/clis/git_intuivo_cli/en"
  cd "${USER_HOME}/_/clis/git_intuivo_cli/en"
  if bash -c "${USER_HOME}/_/clis/bash_intuivo_cli/link_folder_scripts" ; then
  {
    echo "linked \"${USER_HOME}/_/clis/git_intuivo_cli/en\""
  }
  fi

}
fi

chown -R "${SUDO_USER}" "${USER_HOME}/_/clis"
Comment ended _setup_clis
return 0
} # end _setup_clis

_setup_mycd(){
  Comment start ${0:-} ${1:-} _setup_mycd
  if it_does_not_exist_with_spaces "${USER_HOME}/.mycd"  ; then
  {
    # My CD
    cd "${USER_HOME}"
    su - "${SUDO_USER}" -c "yes | git clone https://gist.github.com/jesusalc/b14a57ec9024ff1a3889be6b2c968bb7 \"${USER_HOME}/.mycd\""
  }
  else
  {
    passed that: mycd is in home folder
    chmod 0755 "${USER_HOME}/.mycd"
    if ( chown -R "${SUDO_USER}"  "${USER_HOME}/.mycd" ) ; then
    {
      Comment failed  chown -R "${SUDO_USER}"  "${USER_HOME}/.mycd"
    }
    fi
    chmod +x "${USER_HOME}/.mycd/mycd.sh"

    # Add to MAC Bash:
    # DEBUG=1
    _if_not_contains "${USER_HOME}/.bash_profile" ".mycd/mycd.sh" || echo -e "\n# MYCD\n[[ -d \"${USER_HOME}/.mycd\" ]] && . \"${USER_HOME}/.mycd/mycd.sh\"\n" >> "${USER_HOME}/.bash_profile"
    # DEBUG=0
    # Add to Linux Bash:

    # _if_not_contains "${USER_HOME}/.bashrc" ".mycd/mycd.sh" || echo -e "\n# MYCD\n[[ -d \"${USER_HOME}/.mycd\" ]] && . \"${USER_HOME}/.mycd/mycd.sh\"\n" >> "${USER_HOME}/.bashrc"

    # Add to Zsh:
    # _if_not_contains "${USER_HOME}/.zshrc" ".mycd/mycd.sh" ||  echo -e "\n# MYCD\n[[ -d \"${USER_HOME}/.mycd\" ]] && . \"${USER_HOME}/.mycd/mycd.sh\"\n" >> "${USER_HOME}/.zshrc"

    # OR - Add .dir_bash_history to the GLOBAL env .gitignore, ignore:
    if it_exists_with_spaces "${USER_HOME}/.config"  ; then
    {
      [[ -f "${USER_HOME}/.config"  ]] && rm "${USER_HOME}/.config"
    }
    fi
    if it_does_not_exist_with_spaces "${USER_HOME}/.config"  ; then
    {
      mkdir -p   "${USER_HOME}/.config"
    }
    fi
    directory_exists_with_spaces  "${USER_HOME}/.config"
    chown -R "${SUDO_USER}" "${USER_HOME}/.config"
    if it_does_not_exist_with_spaces "${USER_HOME}/.config/git"  ; then
    {
      mkdir -p   "${USER_HOME}/.config/git"
    }
    fi
    directory_exists_with_spaces  "${USER_HOME}/.config/git"
    chown -R "${SUDO_USER}" "${USER_HOME}/.config/git"
    touch  "${USER_HOME}/.config/git/ignore"
    file_exists_with_spaces "${USER_HOME}/.config/git/ignore"
    # DEBUG=1
    (_if_not_contains "${USER_HOME}/.config/git/ignore"  ".dir_bash_history") ||  (echo -e "\n.dir_bash_history" >> "${USER_HOME}/.config/git/ignore")
    # DEBUG=0

    if local otherignore="$(git config --global core.excludesfile)" ; then
    {
      echo "More ignore choices for excludesfile <..<${otherignore}>..>"
      if [[ -n "${otherignore}" ]] ; then
      {
        local realdir=$(su - "${SUDO_USER}" -c "realpath  ${otherignore}") # updated realpath macos 20210924
        local dirother=$(dirname  "${realdir}")
        mkdir -p   "${dirother}"
        directory_exists_with_spaces "${dirother}"
        chown -R "${SUDO_USER}" "${dirother}"
        touch "${realdir}"
        file_exists_with_spaces "${realdir}"
        (_if_not_contains "${realdir}"  ".dir_bash_history") ||  (echo -e "\n.dir_bash_history" >> "${realdir}")
      }
      else
      {
        echo "More ignore choices for excludesfile Empty. .Not Found."
      }
      fi

    }
    fi
  }
  fi
  Comment end ${0:-} ${1:-}  _setup_mycd 
  # return 0
} # end _setup_mycd

_install_dmg__64() {
  local CODENAME="${1}"
  local extension="$(echo "${CODENAME}" | rev | cut -d'.' -f 1 | rev)"
  local APPDIR="${2}"
  local TARGET_URL="${3}"
  Comment start $0$1 _install_dmg__64
  # CODENAME="$(basename "${TARGET_URL}" )"
  echo "${CODENAME}";
  echo "Extension:${extension}"
  # local VERSION="$(echo -en "${CODENAME}" | sed 's/RubyMine-//g' | sed 's/.dmg//g' )"
  # enforce_variable_with_value VERSION "${VERSION}"
  # local UNZIPDIR="$(echo -en "${CODENAME}" | sed 's/.dmg//g'| sed 's/-//g')"
  # local UNZIPDIR="$(echo -en "${APPDIR}" | sed 's/.app//g')"
  # echo "$(pwd)"
  local UNZIPDIR="$(dirname  "${APPDIR}")"
  local APPDIR="${APPDIR##*/}"    # same as  $(basename "${APPDIR}")
  # local APPDIR="$(echo -en "${CODENAME}" | sed 's/.dmg//g'| sed 's/-//g').app"
  # echo "${CODENAME}";
  # echo "${URL}";
  echo "CODENAME: ${CODENAME}"
  enforce_variable_with_value CODENAME "${CODENAME}"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  enforce_variable_with_value HOME "${HOME}"
  echo "UNZIPDIR: ${UNZIPDIR}"
  enforce_variable_with_value UNZIPDIR "${UNZIPDIR}"
  echo "APPDIR: ${APPDIR}"
  enforce_variable_with_value APPDIR "${APPDIR}"
  local DOWNLOADFOLDER="${HOME}/Downloads"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  directory_exists_with_spaces "${DOWNLOADFOLDER}"

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
  if  it_exists_with_spaces "/Applications/${APPDIR}" ; then
  {
    echo Remove installed "/Applications/${APPDIR}"
    sudo rm -rf  "/Applications/${APPDIR}"
    directory_does_not_exist_with_spaces  "/Applications/${APPDIR}"
  }
  fi
  if [[ -n "${extension}" ]] && [[ "${extension}"  == "zip" ]] ; then
  {
    echo Unzipping downloaded
    unzip "${DOWNLOADFOLDER}/${CODENAME}"
    directory_exists_with_spaces "${DOWNLOADFOLDER}/${APPDIR}"
    echo "sudo  cp -R \"${DOWNLOADFOLDER}/${APPDIR}\" \"/Applications/\""
    cp -R "${DOWNLOADFOLDER}/${APPDIR}" "/Applications/"
  }
  else # elif [[ -n "${extension}" ]] && [[ "${extension}"  == "dmg" ]] ; then
  {
    echo Attaching dmg downloaded
    hdiutil attach "${DOWNLOADFOLDER}/${CODENAME}"
    ls "/Volumes"
    directory_exists_with_spaces "/Volumes/${UNZIPDIR}"
    directory_exists_with_spaces "/Volumes/${UNZIPDIR}/${APPDIR}"
    echo "sudo  cp -R \"/Volumes/${UNZIPDIR}/${APPDIR}\" \"/Applications/\""
    cp -R "/Volumes/${UNZIPDIR}/${APPDIR}" "/Applications/"
    hdiutil detach "/Volumes/${UNZIPDIR}"
  }
  fi
    directory_exists_with_spaces "/Applications/${APPDIR}"
    ls -d "/Applications/${APPDIR}"
    echo  Removing macOS gatekeeper quarantine attribute
    chown  -R "${SUDO_USER}" "/Applications/${APPDIR}"
    chgrp  -R staff "/Applications/${APPDIR}"
    #echo xattr "/Applications/${APPDIR}"
   # if xattr "/Applications/${APPDIR}" ; then
   # {
   #   if [[ "$(xattr "/Applications/${APPDIR}")" == *"com.apple.quarantine"* ]] ; then
   #   {
   #     if xattr -d com.apple.quarantine  "/Applications/${APPDIR}" ; then
   #     {
   #     Comment ${ORANGE} WARNING! ${YELLOW_OVER_DARKBLUE} failed xattr -d com.apple.quarantine  "/Applications/${APPDIR}" ${YELLOW_OVER_GRAY241}"${APPDIR}"${RESET}
   #     }
   #     fi
   #   }
   #   fi
   # }
   # fi
  Comment end ${0:-} ${1:-} _install_dmg__64
} # end _install_dmg__64

_install_dmgs_list() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR

  Comment start ${0:-} ${1:-}  _install_dmgs_list
  # Iris.dmg|
  # 1Password.pkg|https://c.1password.com/dist/1P/mac7/1Password-7.7.pkg
  # Keka-1.2.16.dmg|Keka/Keka.app|https://github-releases.githubusercontent.com/73220421/eec2e3d8-ba82-4d01-ac25-b266ad0bcf64?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20210809%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20210809T155416Z&X-Amz-Expires=300&X-Amz-Signature=9f60b0ef230cff82eaebd6673579693211968bc6451c539af92d8b5cccec03f7&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=73220421&response-content-disposition=attachment%3B%20filename%3DKeka-1.2.16.dmg&response-content-type=application%2Foctet-stream
  # KekaExternalHelper-v1.1.1.zip|KekaExternalHelper.app|https://github-releases.githubusercontent.com/73220421/dfb73d80-582e-11eb-80f7-180c8f11844b?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20210809%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20210809T155831Z&X-Amz-Expires=300&X-Amz-Signature=4360cc8d4b2cce8843548c0fcd52a188acd74ce764df82a24f3de7807a6cfa37&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=73220421&response-content-disposition=attachment%3B%20filename%3DKekaExternalHelper-v1.1.1.zip&response-content-type=application%2Foctet-stream
  local installlist one  target_name target_url target_app app_name extension
  installlist="
  iTerm2-3_4_8.zip|iTerm.app|https://iterm2.com/downloads/stable/iTerm2-3_4_22.zip
  sublime_text_build_4113_mac.zip|Sublime Text.app|https://download.sublimetext.com/sublime_text_build_4152_mac.zip
  Caffeine.dmg|Caffeine/Caffeine.app|https://github.com/IntelliScape/caffeine/releases/download/1.1.3/Caffeine.dmg
  Docker.dmg|Docker.app|https://desktop.docker.com/mac/main/$(uname -m)/Docker.dmg
  Keybase.dmg|Keybase App/Keybase.app|https://prerelease.keybase.io/Keybase.dmg
  Brave-Browser.dmg|Brave Browser/Brave Browser.app|https://referrals.brave.com/latest/Brave-Browser.dmg
  Firefox%20118.0.2.dmg|Firefox/Firefox.app|https://download-installer.cdn.mozilla.net/pub/firefox/releases/118.0.2/mac/en-US/Firefox%20119.0.1.dmg
  # Firefox%20118.0.2.dmg|Firefox/Firefox.app|https://download-installer.cdn.mozilla.net/pub/firefox/releases/118.0.2/mac/en-US/Firefox%20118.0.2.dmg
  # Firefox%2098.0.1.dmg|Firefox/Firefox.app|https://download-installer.cdn.mozilla.net/pub/firefox/releases/98.0.1/mac/en-US/Firefox%2098.0.1.dmg
  MFF2_latest.dmg|MultiFirefox/MultiFirefox.app|http://mff.s3.amazonaws.com/MFF2_latest.dmg
  vlc-3.0.11.dmg|VLC media player/VLC.app|https://download.vlc.de/vlc/macosx/vlc-3.0.11.dmg
  Slack.dmg|Slack.app|https://downloads.slack-edge.com/releases/macos/4.35.121/prod/universal/Slack-4.35.121-macOS.dmg
  mattermost-desktop-4.6.2-mac.dmg|Mattermost 4.6.2/Mattermost.app|https://releases.mattermost.com/desktop/4.6.2/mattermost-desktop-4.6.2-mac.dmg
  gimp-2.10.22-x86_64-2.dmg|GIMP 2.10 Install/GIMP-2.10.app|https://ftp.lysator.liu.se/pub/gimp/v2.10/osx/gimp-2.10.22-x86_64-2.dmg
  sketch-70.3-109109.zip|Sketch.app|https://download.sketch.com/sketch-70.3-109109.zip
  Iris-1.2.0-OSX.zip|Iris.app|https://raw.githubusercontent.com/danielng01/product-builds/master/iris/macos/Iris-1.2.0-OSX.zip
  BetterTouchTool.zip|BetterTouchTool.app|https://folivora.ai/releases/BetterTouchTool.zip
  Options_8.36.76.zip|LogiMgr Installer 8.36.76.app|https://download01.logi.com/web/ftp/pub/techsupport/options/Options_8.36.76.zip
  tsetup.3.5.1.dmg|Telegram Desktop/Telegram.app|https://updates.tdesktop.com/tmac/tsetup.3.5.1.dmg
  VSCode-darwin.zip|Visual Studio Code.app|https://az764295.vo.msecnd.net/stable/ea3859d4ba2f3e577a159bc91e3074c5d85c0523/VSCode-darwin.zip
  # VSCode-darwin.zip|Visual Studio Code.app|https://code.visualstudio.com/sha/download?build=stable&os=darwin
  # VSCode-darwin.zip|Visual Studio Code.app|https://az764295.vo.msecnd.net/insider/5a52bc29d5e9bc419077552d336ea26d904299fa/VSCode-darwin.zip
  # VSCode-darwin.zip|Visual Studio Code.app|https://code.visualstudio.com/sha/download?build=insider&os=darwin
  # BCompareOSX-4.3.7.25118.zip|Beyond Compare.app|https://www.scootersoftware.com/BCompareOSX-4.3.7.25118.zip
  dbeaver-ce-latest-macos-x86_64.dmg|DBeaver Community/DBeaver.app|https://dbeaver.io/files/dbeaver-ce-latest-macos-x86_64.dmg
  Inkscape-1.0.2.dmg|Inkscape/Inkscape.app|https://media.inkscape.org/dl/resources/file/Inkscape-1.0.2.dmg
  LittleSnitch-5.3.2.dmg|Little Snitch 5.3.2/Little Snitch.app|https://www.obdev.at/ftp/pub/Products/littlesnitch/LittleSnitch-5.3.2.dmg
  Postgres-2.5.6-10-11-12-13-14.dmg|Postgres-2.5.6-10-11-12-13-14/Postgres.app|https://objects.githubusercontent.com/github-production-release-asset-2e65be/3946572/fca30b05-f1f0-47e7-ab2b-a53feb55c76e?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20220216%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220216T162004Z&X-Amz-Expires=300&X-Amz-Signature=5e36ddb945a897c7d34367c1f63668442f668bc97a3a4dff4771f9e78ee4fe4c&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=3946572&response-content-disposition=attachment%3B%20filename%3DPostgres-2.5.6-10-11-12-13-14.dmg&response-content-type=application%2Foctet-stream
  mysql-workbench-community-8.0.28-macos-x86_64.dmg|MySQL Workbench community-8.0.28/MySQLWorkbench.app|https://cdn.mysql.com//Downloads/MySQLGUITools/mysql-workbench-community-8.0.28-macos-x86_64.dmg
  Red+1.7.8.zip|Red.app|https://s3.amazonaws.com/echodot/red/Red+1.7.8.zip
  Unlox.zip|https://unlox.it/download/
  mysql-8.0.28-macos11-x86_64.dmg|mysql-8.0.28-macos11-x86_64/mysql-8.0.28-macos11-x86_64.pkg|https://cdn.mysql.com//Downloads/MySQL-8.0/mysql-8.0.28-macos11-x86_64.dmg"
  Checking dmgs apps
  local -i _err=0
  while read -r one ; do
  {
    [[ -z "${one}" ]] && continue
    target_name="$(echo "${one}" | cut -d'|' -f1)"
    extension="$(echo "${target_name}" | rev | cut -d'.' -f 1 | rev)"
    target_app="$(echo "${one}" | cut -d'|' -f2)"
    app_name="$(echo "$(basename "${target_app}")")"
    target_url="$(echo "${one}" | cut -d'|' -f3-)"
    [[ -z "${target_name}" ]] && continue
    [[ -z "${target_url}" ]] && continue
    if [[  -d "/Applications/${app_name}" ]] ; then
    {
      passed  "/Applications/${app_name}" ${ORANGE} --skipping ${YELLOW_OVER_DARKBLUE} already installed ${RESET}
      continue
    }
    fi
    if  it_exists "${SUDO_USER}/.___${app_name}" ; then
    {
      passed skipping ${app_name} ${ORANGE} --skipping ${YELLOW_OVER_DARKBLUE} because ${RESET}"${SUDO_USER}/.___${app_name}" ${ORANGE} lock exists${RESET}
      continue
    }
    fi
    
    echo -e " ${BRIGHT_BLUE87} === ${ORANGE}Install "${app_name}" ❓${RESET} [y/n] ? " 
      if yes_or_no ; then
      {
        _err=0
      }
      else
      {
        _err=1
      }
      fi

    # [ $_err -eq 0 ] &&  # yes
    # [ $_err -gt 0 ] &&  # no
    if [ $_err -gt 0 ] ; then # no
    {
      passed you said no 
      touch "${SUDO_USER}/.___${app_name}" 
      continue
    }
    fi
    # yes
    passed you said yes 
    Installing "${app_name}" 
    if  _install_dmgs_dmg__64 "${target_name}" "${target_app}" "${target_url}" ; then
    {
      _err=$?
      warning "could not install ${app_name}"
      touch "${SUDO_USER}/.___${app_name}" 
    }
    else 
    {
      passed installed ${app_name}
      touch "${SUDO_USER}/.___${app_name}" 
    }
    fi
   
  }
  done <<< "$(echo "${installlist}" | grep -vE '^#' | grep -vE '^\s+#')"
  _sublime_softlink_command_line "/Applications/Sublime\\ Text.app"
  _bcompare_softlink_command_line "/Applications/Beyond\\ Compare.app"

  Comment end ${0:-} ${1:-} _install_dmgs_list
  return 0
} # end _install_dmgs_list

_bcompare_softlink_command_line() {
  local _target="${1}"
  if it_exists_with_spaces /Applications/Beyond\ Compare.app && is_not_installed bcomp  ; then
  {
    Creating softlinks for bcomp, bcompare, pdftotext
    [ ! -d /usr/local/bin/ ] && anounce_command mkdir -p  /usr/local/bin/
    anounce_command ln -s /Applications/Beyond\\ Compare.app/Contents/MacOS/BCompare /usr/local/bin/bcompare
    anounce_command ln -s /Applications/Beyond\\ Compare.app/Contents/MacOS/bcomp /usr/local/bin/bcomp
    anounce_command ln -s /Applications/Beyond\\ Compare.app/Contents/MacOS/pdftotext /usr/local/bin/pdftotext
    anounce_command sudo chown -R root  /usr/local/bin/bcomp
    anounce_command sudo chown -R root  /usr/local/bin/bcompare
    anounce_command sudo chown -R root  /usr/local/bin/pdftotext
  }
  fi
} # end _bcompare_link_command_line

_sublime_softlink_command_line() {
  local _target="${1}"
  if it_exists_with_spaces /Applications/Sublime\ Text.app && is_not_installed subl  ; then
  {
    Creating softlinks for subl, sublime
    [ ! -d /usr/local/bin/ ] && anounce_command mkdir -p  /usr/local/bin/
    anounce_command sudo chown -R "${SUDO_USER}"  /usr/local/&
    anounce_command rm -rf  /usr/local/bin/sublime
    anounce_command rm -rf  /usr/local/bin/subl
    anounce_command ln -s  /Applications/Sublime\\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/sublime
    anounce_command ln -s  /Applications/Sublime\\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl
    anounce_command sudo chown -R "${SUDO_USER}"  /usr/local/bin/sublime&
    anounce_command sudo chown -R "${SUDO_USER}"  /usr/local/bin/subl&
  }
  fi
} # end _sublime_link_command_line

_password_simple() {
  Installing password change
  local Answer
  read -p 'Change Passwords? [Y/n] (Enter Defaults - No/N/n )' Answer
  case ${Answer:-N} in
    '' | [Nn]* )
      passed you said no "Skip Password change"
      return 0
      ;;
    [Yy]* )
      passed you said Yes
      ;;
    * )
      echo Please click lettes Y,y or N,n only or CTRL +C to cancel all script.
  esac

  local policies
  if is_installed pwpolicy ; then
  {
    policies=$(pwpolicy getaccountpolicies  2>&1; )
    ret=$?
    if [ $ret -gt 0 ] ; then
    {
      echo reading policies failed  "ERR:${ret} \n MSG:${policies}"
      return 1
    }
    else
    {
      echo "${policies}" > temp.xml
      if _if_contains temp.xml "{1,}" ; then
      {
        passed "passwords policy already set to {1,}"
      }
      else
      {
        passed Reading policies for passwords pwpolicy
        echo ":dd to delete --> Getting global account policies"
        echo "press i  to edit  --> {4,} to {1,}.  press esc to exit edit mode"
        policies="$(echo "${policies}" |  grep -v "^Getting" | sed -E 's/\{4\,\}/\{1\,\}/')"
        echo "${policies}" > temp.xml
        pwpolicy setaccountpolicies temp.xml
        rm temp.xml
      }
      fi
    }
    fi
  }
  fi

Updating passwd root
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

Updating passwd "${SUDO_USER}"
(
sudo passwd "${SUDO_USER}" <<< "\\
\\
"
#\"
)
if [[ "$(uname)" == "Darwin" ]] ; then
{
  # Do something under Mac OS X platform
  Updating security set-keychain-password default
  security set-keychain-password
}
fi
return 0
} # end _password_simple

_password_simple2(){
# Password simple2
Updating passwd default user
(
sudo passwd <<< "#
#
"
#\"
)

Updating passwd root
(
sudo passwd root <<< "#
#
"
#\"
)
Updating passwd "${SUDO_USER}"
(
sudo passwd "${SUDO_USER}" <<< "#
#
"
#\"
)
if [[ "$(uname)" == "Darwin" ]] ; then
{
  # Do something under Mac OS X platform
  Updating security set-keychain-password default
  security set-keychain-password
}
fi
return 0
} # end password_simple2


_debian__32() {
  COMANDDER="apt install -y"
  is_not_installed ag && $COMANDDER silversearcher-ag         # In Ubuntu
  is_not_installed ack && $COMANDDER ack-grep        # In Ubuntu
   install_requirements "linux" "
    # Ubuntu only
    xclip
    tree
    vim
    nano
    pv
    python-pip
    zsh
    "
    if ( command -v pip >/dev/null 2>&1; ) ; then # MAC
    {
       pip install pygments
    }
    fi
    if ( command -v pip3 >/dev/null 2>&1; ) ; then # MAC
    {
       pip3 install pygments
    }
    fi
  _checka_tools_commander
  _configure_git
  _install_nvm
  _install_nvm_version 14.16.1
  _install_npm_utils

  _setup_ohmy
  _install_colorls
  _setup_clis
  # _setup_mycd



  _password_simple
  # _password_simple2

  if it_does_not_exist_with_spaces /etc/apt/sources.list.d/cloudfoundry-cli.list ; then
  {
    Installing cloudfoundry cf 7
    wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
    echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
    echo  ...then, update your local package index, then finally install the cf CLI
    apt update -y
    $COMANDDER cf-cli
    snap install cf-cli
    chown -R "${SUDO_USER}" "${USER_HOME}/.cf"
  }
  fi
 # verify_is_installed cf
  _setup_mycd
} # end _debian__32
_debian__64() {
  COMANDDER="apt install -y"
  is_not_installed ag && $COMANDDER silversearcher-ag         # In Ubuntu
  is_not_installed ack && $COMANDDER ack-grep        # In Ubuntu
   install_requirements "linux" "
    # Ubuntu only
    xclip
    tree
    vim
    nano
    pv
    python-pip
    zsh
    "
    if ( command -v pip >/dev/null 2>&1; ) ; then # MAC
    {
       pip install pygments
    }
    fi
    if ( command -v pip3 >/dev/null 2>&1; ) ; then # MAC
    {
       pip3 install pygments
    }
    fi

  _checka_tools_commander
  _configure_git
  _install_nvm
  _install_nvm_version 14.16.1
  _install_npm_utils

  _setup_ohmy
  _install_colorls
  _setup_clis
  # _setup_mycd



  _password_simple
  # _password_simple2

  if it_does_not_exist_with_spaces /etc/apt/sources.list.d/cloudfoundry-cli.list ; then
  {
    Installing cloudfoundry cf 7
    wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
    echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
    echo  ...then, update your local package index, then finally install the cf CLI
    apt update -y
    $COMANDDER cf-cli
    snap install cf-cli
    chown -R "${SUDO_USER}" "${USER_HOME}/.cf"
  }
  fi
 # verify_is_installed cf
  _setup_mycd
} # end _debian__64
_ubuntu__64() {
  Comment start $0$1 _ubuntu__64
  # debian sudo usermod -aG sudo "${SUDO_USER}"
  # chown "${SUDO_USER}" /home
  # chgrp -R "${SUDO_GRP}" /home
  # sudo groupadd docker
  # sudo usermod -aG docker "${SUDO_USER}"
  COMANDDER="apt install -y"
  is_not_installed ag && $COMANDDER silversearcher-ag         # In Ubuntu
  is_not_installed ack && $COMANDDER ack-grep        # In Ubuntu
  install_requirements "linux" "
    # Ubuntu only
    xclip
    tree
    vim
    nano
    pv
    python3-pip
    zsh
    "
    if ( command -v pip >/dev/null 2>&1; ) ; then # MAC
    {
       pip install pygments
    }
    fi
    if ( command -v pip3 >/dev/null 2>&1; ) ; then # MAC
    {
       pip3 install pygments
    }
    fi
  _checka_tools_commander
  _configure_git
  _install_nvm
  _install_nvm_version 14.16.1
  _install_npm_utils

  _setup_ohmy
  _install_colorls
  _setup_clis
  # _setup_mycd



  _password_simple
  # _password_simple2

  if it_does_not_exist_with_spaces /etc/apt/sources.list.d/cloudfoundry-cli.list ; then
  {
    Installing cloudfoundry cf 7
    wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
    echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
    echo  ...then, update your local package index, then finally install the cf CLI
    apt update -y
    $COMANDDER cf-cli
    snap install cf-cli
    chown -R "${SUDO_USER}" "${USER_HOME}/.cf"
  }
  fi
  # verify_is_installed cf
  _setup_mycd
  Comment end ${0:-} ${1:-} _ubuntu__64
} # end _ubuntu__64

_centos__64() {
  _fedora__64
} # end _centos__64

_fedora__64() {
  SUDO_GRP='wheel'
  COMANDDER="dnf install -y"
  is_not_installed ag && $COMANDDER the_silver_searcher          # In Fedora
  dnf groupinstall 'development tools' -y

  install_requirements "linux" "xclip"
  # epel-release
  # python3-paramiko

  install_requirements "linux" 
  # epel-release
  install_requirements "linux"  snap
    # xclip
    # tree
  install_requirements "linux"  ack
  install_requirements "linux"  vim
  install_requirements  "linux"  nano
  install_requirements  "linux"  pv
  install_requirements  "linux"  python2
    # python2-devel
  install_requirements  "linux"   python3
  install_requirements  "linux"  python3-devel
    # twisted
  install_requirements  "linux"   zsh
  install_requirements  "linux"  xclip
  install_requirements  "linux"  autoconf
  install_requirements  "linux"  automake
  install_requirements  "linux"  libtool
  install_requirements  "linux"  libXmu-devel
  # autoreconf ubuntu

   cd
   git clone https://github.com/astrand/xclip.git
   cd xclip
    ./bootstrap
    ./configure
    make
    make install

   #systemctl enable --now snapd.socket
   sudo snap install tree
  _checka_tools_commander
  _configure_git
  _install_nvm
  _install_nvm_version 14.16.1
  _install_npm_utils

  _setup_ohmy
  _install_colorls
  _setup_clis
  # _setup_mycd



  _password_simple
  # _password_simple2
  if  it_does_not_exist_with_spaces /etc/yum.repos.d/cloudfoundry-cli.repo ; then
  {
    Installing cloudfoundry cf 7
    wget -O /etc/yum.repos.d/cloudfoundry-cli.repo https://packages.cloudfoundry.org/fedora/cloudfoundry-cli.repo
    # sudo yum install cf6-cli
    $COMANDDER cf7-cli
  }
  fi
 # verify_is_installed cf
  _setup_mycd
  if ( su - "${SUDO_USER}" -c 'command -v brew' >/dev/null 2>&1; ) ; then # MAC
  {
    su - "${SUDO_USER}" -c 'brew install the_silver_searcher'
    su - "${SUDO_USER}" -c 'brew install ag@the_silver_searcher'
    su - "${SUDO_USER}" -c 'brew install the_platinum_searcher'
    su - "${SUDO_USER}" -c 'brew install pt@the_platinum_searcher'
  }
  else 
  {
    warning "${RED}Brew${ORANGE} is not installed. Or  bashtv and zshrc files are missing" 
  }
  fi

} # end _fedora__64

_darwin__arm64() {
  _darwin__64
} # end _darwin__arm64
_darwin__64() {
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR

  Installing "## macOS Preferences"

  Comment "# Set a blazingly fast keyboard repeat rate ms"
  defaults write NSGlobalDomain KeyRepeat -int 1

  Comment "# Set a shorter Delay until key repeat ms"
  defaults write NSGlobalDomain InitialKeyRepeat -int 10

  Comment "# Add a context menu item for showing the Web Inspector in web views"
  defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

  Comment "# Show the ~/Library folder"
  chflags nohidden ~/Library

  Comment "# Store screenshots in subfolder on desktop"
  mkdir -p ~/Desktop/Screenshots
  defaults write com.apple.screencapture location ~/Desktop/Screenshots
  SUDO_GRP='staff'
  [[  -e "${USER_HOME}/.bash_profile" ]] && chown -R "${SUDO_USER}" "${USER_HOME}/.bash_profile"
  [[  -e "${USER_HOME}/.bashrc" ]] && chown -R "${SUDO_USER}" "${USER_HOME}/.bashrc"
  [[  -e "${USER_HOME}/.bash_profile" ]] && chown -R "${SUDO_USER}" "${USER_HOME}/.bash_profile"
  [[  -e "${USER_HOME}/.profile" ]] && chown -R "${SUDO_USER}" "${USER_HOME}/.profile"
  [[  -e "${USER_HOME}/.zprofile" ]] && chown -R "${SUDO_USER}" "${USER_HOME}/.zprofile"
  [[  -e "${USER_HOME}/.zshrc" ]] && chown -R "${SUDO_USER}" "${USER_HOME}/.zshrc"
  [[  -e "${USER_HOME}/.zshenv" ]] && chown -R "${SUDO_USER}" "${USER_HOME}/.zshenv"
  [[  -e "${USER_HOME}/.composer" ]] && chown -R "${SUDO_USER}" "${USER_HOME}/.composer"




  local Answer
  read -p 'Continue with more brew installs.clis....etc ? [Y/n] (Enter Defaults to - No/N/n - No exits )' Answer
  case $Answer in
    '' | [Nn]* )
      passed you said no "Skip more installs"
      exit 0
      ;;
    [Yy]* )
      passed you said Yes
      ;;
    * )
      echo Please click lettes Y,y or N,n only or CTRL +C to cancel all script.
  esac

                  local -i _err=0
                  ensure_brew_in_linux_mac
                  local _target_bin_brew=""
                  _target_bin_brew="$(_find_executable_for "brew" "--prefix"  "bin/brew")"
                  _err=$?
                  if [ $_err -gt 0 ] ; then # failed
                  {
                    echo "${_target_bin_brew}"
                    failed "to find brew"
                  }
                  fi
                  _target_bin_brew="$(echo -n "${_target_bin_brew}" | tail -1)"
                  enforce_variable_with_value _target_bin_brew "${_target_bin_brew}"
                 
                  if ( command -v "${_target_bin_brew}" >/dev/null 2>&1; ) ; then
                  {
                    # _run_command brew install ${missing}
                    if (( DEBUG )) ; then
                      echo "brew install"
                      echo "${_target_bin_brew} install"
                    fi
                    # install=$(/opt/homebrew/bin/brew install "${missing}")
                    # su - "${SUDO_USER}" -c "${_target_bin_brew} install ${missing} "
                    err_buff=$?
                    # su - "${SUDO_USER}" -c "brew install ${missing} "
                  }
                  else 
                  {
                    failed "to find get command -v ${_target_bin_brew} to respond"
                  }
                  fi

  # COMANDDER="_run_command /usr/local/bin/brew install "
  # COMANDDER="_run_command /opt/homebrew/bin/brew install "
  # COMANDDER="_run_command ${_target_bin_brew} install "
  COMANDDER="su - \"${SUDO_USER}\" -c \" \"${_target_bin_brew}\"  install "
  # LINKER="_run_command /opt/homebrew/bin/brew link "
  # LINKER="_run_command ${_target_bin_brew} link "
  LINKER="su - \"${SUDO_USER}\" -c \" \"${_target_bin_brew}\"  link "
  $COMANDDER  node

  _add_launchd "${USER_HOME}/Library/LaunchAgents" "${USER_HOME}/Library/LaunchAgents/com.intuivo.clis_pull_all.plist"
  _install_dmgs_list

  # Start a subprocress
  (
    if anounce_command sudo chown -R "${SUDO_USER}" "${USER_HOME}/Library/Caches/" ; then
    {
      mkdir -p "${USER_HOME}/Library/Caches/"
      Comment ${ORANGE} WARNING! ${YELLOW_OVER_DARKBLUE} failed chown -R "${SUDO_USER}" "${USER_HOME}/Library/Caches/" ${YELLOW_OVER_GRAY241}"${APPDIR}"${RESET}
    }
    fi
  )

  # su - "${SUDO_USER}" -c 'brew install the_silver_searcher'
  install_requirements "darwin" "
    tree
    the_silver_searcher
    ag@the_silver_searcher
    pt@the_platinum_searcher
    wget
    node@nodejs
    cf
    ack
    gawk
    pyenv
    vim
    nano
    pv
    gsed@gnu-sed
    zsh
    powerlevel10k@romkatv/powerlevel10k/powerlevel10k
    powerline-go
    powerlevel10k
    zsh-completions
    bash-completion
    zsh-syntax-highlighting 
    zsh-autosuggestions

  "
  #su - "${SUDO_USER}" -c 'pip install --upgrade pip'
  #su - "${SUDO_USER}" -c 'pip3 install --upgrade pip'
  #verify_is_installed pip3
  if ( ! su - "${SUDO_USER}" -c 'command -v pygmentize' >/dev/null 2>&1; ) ;  then
    if ( su - "${SUDO_USER}" -c 'command -v pip' >/dev/null 2>&1; ) ; then # MAC
    {
       su - "${SUDO_USER}" -c 'pip install pygments'
       #pip install pygments
    }
    fi
    if ( su - "${SUDO_USER}" -c 'command -v pip3' >/dev/null 2>&1; ) ; then # MAC
    {
       su - "${SUDO_USER}" -c 'pip3 install pygments'
       #pip3 install pygments
    }
    fi
  fi
  #is_not_installed pygmentize &&   pip3 install pygments
  #is_not_installed pygmentize &&   pip install pygments
  #su - "${SUDO_USER}" -c 'pip3 install pygments'
  #su - "${SUDO_USER}" -c 'pip install pygments'
  Comment "relink ag"
  if ( su - "${SUDO_USER}" -c 'command -v brew' >/dev/null 2>&1; ) ; then # MAC
  {
    su - "${SUDO_USER}" -c 'brew unlink the_silver_searcher' && $LINKER the_silver_searcher
  }
  else 
  {
    warning "${RED}Brew${ORANGE} is not installed. Or  bashtv and zshrc files are missing" 
  }
  fi
  

  # verify_is_installed "
  #  wget
  #  tree
  #  ag
  #  pt
  #  cf
  #  node
  #  ack
  #  pv
  #  nano
  #  vim
  #  gawk
  #  pygmentize
  #  "
  if  ! su - "${SUDO_USER}" -c 'command -v pygmentize' >/dev/null 2>&1;   then
    if  su - "${SUDO_USER}" -c 'command -v pip' >/dev/null 2>&1;   then # MAC
    {
       #su - "${SUDO_USER}" -c 'pip install pygments'
       su - "${SUDO_USER}" -c 'pip install pygments'
    }
    fi
    if  su - "${SUDO_USER}" -c 'command -v pip3' >/dev/null 2>&1;  then # MAC
    {
       #su - "${SUDO_USER}" -c 'pip3 install pygments'
       su - "${SUDO_USER}" -c 'pip3 install pygments'
    }
    fi
  fi

  _configure_git
  # _install_nvm
  # _install_nvm_version 14.16.1
  # _install_nvm_version 16.6.1
  _install_npm_utils
  if ( ! su - "${SUDO_USER}" -c 'command -v cf' >/dev/null 2>&1; ) ;  then
    su - "${SUDO_USER}" -c 'npm i -g cloudfoundry/tap/cf-cli@7'
  fi
  # _install_npm_utils

  # _install_nvm
  #_install_nvm_version 10
  #_install_npm_utils

  #_install_nvm_version 12
  #_install_npm_utils

  #_install_nvm_version 14
  #_install_npm_utils

  _setup_ohmy
  chown -R "${SUDO_USER}" "/Library/Ruby"
  _install_colorls
  _setup_clis
  # _setup_mycd
  [[  -e "${USER_HOME}/.bash_profile" ]] && chown -R "${SUDO_USER}" "${USER_HOME}/.bash_profile"
  [[  -e "${USER_HOME}/.bashrc" ]] && chown -R "${SUDO_USER}" "${USER_HOME}/.bashrc"
  [[  -e "${USER_HOME}/.zshrc" ]] && chown -R "${SUDO_USER}" "${USER_HOME}/.zshrc"
  [[  -e "${USER_HOME}/.zshenv" ]] && chown -R "${SUDO_USER}" "${USER_HOME}/.zshenv"
  [[  -e "${USER_HOME}/.zprofile" ]] && chown -R "${SUDO_USER}" "${USER_HOME}/.zprofile"
  [[  -e "${USER_HOME}/.profile" ]] && chown -R "${SUDO_USER}" "${USER_HOME}/.profile"
  [[  -e "${USER_HOME}/.composer" ]] && chown -R "${SUDO_USER}" "${USER_HOME}/.composer"

  _add_self_cron_update /usr/lib/cron/  /usr/lib/cron/cron.allow
  # _add_launchd "${USER_HOME}/Library/LaunchAgents" "${USER_HOME}/Library/LaunchAgents/com.intuivo.clis_pull_all.plist"
   
  if  su - "${SUDO_USER}" -c 'command -v php' >/dev/null 2>&1;  then # MAC
  {
    Installing composer global require laravel/valet 
    local php_version="$(major_minor_version "$(php --version  |  head -1 | extract_version )")"
    if version_lt "$php_version" "7.2.5"; then 
    {
      Warning PHP Vesion is too old 
      Comment trying to install version 7.4 
      if [[ "$(uname)" == "Darwin" ]] ; then
      {
        #brew install php@7.4
        su - "${SUDO_USER}" -c 'brew install  php@7.4'
        su - "${SUDO_USER}" -c 'brew link  php@7.4'
         (_if_not_contains   "${USER_HOME}/.bashrc" "php@7.4") ||  echo "$(cat <<EOINSERT
export PATH="/usr/local/opt/php@7.4/bin:$PATH"
export PATH="/usr/local/opt/php@7.4/sbin:$PATH"
EOINSERT
)" >> "${USER_HOME}/.bashrc"
          (_if_not_contains   "${USER_HOME}/.zshrc" "php@7.4") ||  echo "$(cat <<EOINSERT
export PATH="/usr/local/opt/php@7.4/bin:$PATH"
export PATH="/usr/local/opt/php@7.4/sbin:$PATH"
EOINSERT
)" >> "${USER_HOME}/.zshrc"
          export PATH="/usr/local/opt/php@7.4/bin:$PATH"
          export PATH="/usr/local/opt/php@7.4/sbin:$PATH"
      }
      fi
    }
    fi
    su - "${SUDO_USER}" -c 'composer global require laravel/valet'

  }
  fi
  Updating _password_simple
  _password_simple
  Installing disable spotlight using significant power REF: https://discussions.apple.com/thread/5610674
  syslog -k Sender mdworker -o -k Sender mds | grep -v 'boxd\|Norm' | tail | open -ef
  mdutil -as | open -ef
  echo " Disable gamed "
  echo "
    
    REF: https://discussions.apple.com/thread/5521495

    You can prevent gamed from running by logging in as an administrative user, running the Terminal application, and typing (or copying and pasting) at the prompt:

      sudo defaults write /System/Library/LaunchAgents/com.apple.gamed Disabled -bool true

    After restarting your computer, gamed will not be running and the Little Snitch network monitor won't be flashing.


    To reverse the change, you can type:

      sudo defaults delete /System/Library/LaunchAgents/com.apple.gamed Disabled

  "
  Message disable "Integrity protection" reboot mac . Commnd R Terminal csrutil disable
  Message then reboot
  Message REF: https://cleanmymac.com/faq/how-to-turn-off-spotlight-search-on-mac
  echo "# Message disable "Integrity protection" reboot mac . Commnd R Terminal csrutil disable"  > disable.spotlight.bash
  echo "# Message REF: https://cleanmymac.com/faq/how-to-turn-off-spotlight-search-on-mac " > disable.spotlight.bash
  echo "sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist"  > disable.spotlight.bash
  Message then run this file  disable.spotlight.bash
  chmod +x  disable.spotlight.bash
  chown -R "${SUDO_USER}"   disable.spotlight.bash
  _setup_mycd
  return 0
  # _password_simple2
} # end _darwin__64

determine_os_and_fire_action
# exit 0


echo "🥦"
exit 0

