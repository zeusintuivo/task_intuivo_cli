#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
# 20200415 Compatible with Fedora, Mac, Ubuntu "sudo_up" "load_struct" "#

set -E -o functrace
export THISSCRIPTCOMPLETEPATH
typeset -r THISSCRIPTCOMPLETEPATH="$(realpath  "$0")"  # updated realpath macos 20210902
export BASH_VERSION_NUMBER
typeset BASH_VERSION_NUMBER=$(echo $BASH_VERSION | cut -f1 -d.)

export  THISSCRIPTNAME
typeset -r THISSCRIPTNAME="$(basename "$0")"

export _err
typeset -i _err=0
  function _trap_on_error(){
    echo -e "\\n \033[01;7m*** ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m"
    exit 1
  }
  trap _trap_on_error ERR
  function _trap_on_int(){
    echo -e "\\n \033[01;7m*** INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n  INT ...\033[0m"
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
    [[ -z "${1}" ]] && echo "Must call with name of library example: struct_testing execute_command" && exit 1
    trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
      local provider="$HOME/_/clis/execute_command_intuivo_cli/${_library}"
      local _err=0 structsource
      if [   -e "${provider}"  ] ; then
        echo "Loading locally"
        structsource="""$(<"${provider}")"""
        _err=$?
        [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading ${_library}. running 'source locally' returned error did not download or is empty err:$_err  \n \n  " && exit 1
      else
        if ( command -v curl >/dev/null 2>&1; )  ; then
          echo "Loading ${_library} from the net using curl "
          structsource="""$(curl https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/${_library}  -so -   2>/dev/null )"""  #  2>/dev/null suppress only curl download messages, but keep curl output for variable
          _err=$?
          [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading ${_library}. running 'curl' returned error did not download or is empty err:$_err  \n \n  " && exit 1
        elif ( command -v wget >/dev/null 2>&1; ) ; then
          echo "Loading ${_library} from the net using wget "
          structsource="""$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/${_library} -O -   2>/dev/null )"""  #  2>/dev/null suppress only wget download messages, but keep wget output for variable
          _err=$?
          [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading ${_library}. running 'wget' returned error did not download or is empty err:$_err  \n \n  " && exit 1
        else
          echo -e "\n \n  ERROR! Loading ${_library} could not find wget or curl to download  \n \n "
          exit 69
        fi
      fi
      [[ -z "${structsource}" ]] && echo -e "\n \n  ERROR! Loading ${_library} into ${_library}_source did not download or is empty " && exit 1
      local _temp_dir="$(mktemp -d 2>/dev/null || mktemp -d -t "${_library}_source")"
      echo "${structsource}">"${_temp_dir}/${_library}"
      echo "Temp location ${_temp_dir}/${_library}"
      source "${_temp_dir}/${_library}"
      _err=$?
      [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading ${_library}. Occured while running 'source' err:$_err  \n \n  " && exit 1
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
[ $_err -ne 0 ]  && echo -e "\n \n  ERROR FATAL! load_struct_testing_wget !!! returned:<$_err> \n \n  " && exit 69;

export sudo_it
function sudo_it() {
  raise_to_sudo_and_user_home
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
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
  [ $? -gt 0 ] && (failed to sudo_it raise_to_sudo_and_user_home  || exit 1)
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
passed "Caller user identified:${SUDO_USER}"
passed "Home identified:${USER_HOME}"
directory_exists_with_spaces "${USER_HOME}"



 #--------\/\/\/\/-- install_webstorm.bash -- Custom code -\/\/\/\/-------


#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#

_version() {
  local PLATFORM="${1}" # mac windows linux
  local PATTERN="${2}"
  # THOUGHT:   https://download-cf.jetbrains.com/webstorm/WebStorm-2020.3.dmg
  local CODEFILE="""$(wget --quiet --no-check-certificate  https://www.jetbrains.com/webstorm/ -O -  2>/dev/null )""" # suppress only wget download messages, but keep wget output for variable
  # enforce_variable_with_value CODEFILE "${CODEFILE}"
  wait
  local CODELASTESTBUILD=$(echo "${CODEFILE}" | sed s/\</\\n\</g | sed s/\>/\>\\n/g | sed "s/&apos;/\'/g" | sed 's/&nbsp;/ /g' | grep  "New in WebStorm ${PATTERN}" | sed s/\ /\\n/g | tail -1 ) # | grep "What&apos;s New in&nbsp;WebStorm&nbsp;" | sed 's/\;/\;'\\n'/g' | sed s/\</\\n\</g  )
  enforce_variable_with_value CODELASTESTBUILD "${CODELASTESTBUILD}"

  local CODENAME=""
  case ${PLATFORM} in
  mac)
    CODENAME="https://download-cf.jetbrains.com/webstorm/WebStorm-${CODELASTESTBUILD}.dmg"
    ;;

  windows)
    CODENAME="https://download-cf.jetbrains.com/webstorm/WebStorm-${CODELASTESTBUILD}.exe"
    CODENAME="https://download-cf.jetbrains.com/webstorm/WebStorm-${CODELASTESTBUILD}.win.zip"
    ;;

  linux)
    CODENAME="https://download-cf.jetbrains.com/webstorm/WebStorm-${CODELASTESTBUILD}.tar.gz"
    ;;

  *)
    CODENAME=""
    ;;
  esac
  enforce_variable_with_value CODENAME "${CODENAME}"
  unset PATTERN
  unset PLATFORM
  unset CODEFILE
  unset CODELASTESTBUILD
  echo "${CODENAME}"
  return 0
} # end _version

_unzip(){
  # Sample use
  #
  #     _unzip "${DOWNLOADFOLDER}" "${UNZIPDIR}" "${CODENAME}"
  #
  local DOWNLOADFOLDER="${1}"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"

  local UNZIPDIR="${2}"
  enforce_variable_with_value UNZIPDIR "${UNZIPDIR}"

  local CODENAME="${3}"
  enforce_variable_with_value CODENAME "${CODENAME}"

  file_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
  if  it_exists_with_spaces "${DOWNLOADFOLDER}/${UNZIPDIR}" ; then
  {
    rm -rf "${DOWNLOADFOLDER}/${UNZIPDIR}"
    directory_does_not_exist_with_spaces "${DOWNLOADFOLDER}/${UNZIPDIR}"
  }
  fi

  ensure tar or "Canceling Install. Could not find tar command to execute unzip"
  ensure awk or "Canceling Install. Could not find awk command to execute unzip"
  ensure pv or "Canceling Install. Could not find pv command to execute unzip"
  ensure du or "Canceling Install. Could not find du command to execute unzip"
  ensure gzip or "Canceling Install. Could not find gzip command to execute unzip"
  ensure gio or "Canceling Install. Could not find gio command to execute unzip"
  ensure update-mime-database or "Canceling Install. Could not find update-mime-database command to execute unzip"
  ensure update-desktop-database or "Canceling Install. Could not find update-desktop-database command to execute unzip"
  ensure touch or "Canceling Install. Could not find touch command to execute unzip"

  # provide error handling , once learned goes here. LEarn under if, once learned here.
  # Start loop while ERROR flag in case needs to try again, based on error
  cd "${DOWNLOADFOLDER}"
  #_try "tar xvzf  \"${DOWNLOADFOLDER}/${CODENAME}.tar.gz\"--directory=${DOWNLOADFOLDER}"
  # GROw bar with tar Progress bar tar REF: https://superuser.com/questions/168749/is-there-a-way-to-see-any-tar-progress-per-file
  # Compress tar cvfj big-files.tar.bz2 folder-with-big-files
  # Compress tar cf - ${DOWNLOADFOLDER}/${CODENAME}.tar.gz --directory=${DOWNLOADFOLDER} -P | pv -s $(du -sb ${DOWNLOADFOLDER}/${CODENAME}.tar.gz | awk '{print $1}') | gzip > big-files.tar.gz
  # Extract tar Progress bar REF: https://coderwall.com/p/l_m2yg/tar-untar-on-osx-linux-with-progress-bars
  # Extract tar sample pv file.tgz | tar xzf - -C target_directory
  # Working simplme tar:  tar xvzf ${DOWNLOADFOLDER}/${CODENAME}.tar.gz --directory=${DOWNLOADFOLDER}
  pv "${DOWNLOADFOLDER}/${CODENAME}"  | tar xzf - -C "${DOWNLOADFOLDER}"
  #local msg=$(_try "tar xvzf  \"${DOWNLOADFOLDER}/${CODENAME}.tar.gz\" --directory=${DOWNLOADFOLDER} " )
  #  tar xvzf file.tar.gz
  # Where,
  # x: This option tells tar to extract the files.
  # v: The “v” stands for “verbose.” This option will list all of the files one by one in the archive.
  # z: The z option is very important and tells the tar command to uncompress the file (gzip).
  # f: This options tells tar that you are going to give it a file name to work with.
  local msg
  local folder_date
  local ret=$?
  if [ $ret -gt 0 ] ; then
  {
    failed "${ret}:${msg}"
    # add error handling knowledge while learning.
  }
  else
  {
    passed Install with Untar Unzip success!
  }
  fi

  local NEWDIRCODENAME=$(ls -1tr "${DOWNLOADFOLDER}/"  | tail  -1)
  local FROMUZIPPED="${DOWNLOADFOLDER}/${NEWDIRCODENAME}"
  directory_exists_with_spaces  "${FROMUZIPPED}"
  # directory_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"

} # end _unzip
_backup_current_target_and_remove_if_exists(){
  # Sample use
  #
  #     _backup_current_target_and_remove_if_exists "${TARGETFOLDER}"
  #     _backup_current_target_and_remove_if_exists "${TARGETFOLDER}"
  #
  local TARGETFOLDER="${1}"
  enforce_variable_with_value TARGETFOLDER "${TARGETFOLDER}"

  if  it_exists_with_spaces "${TARGETFOLDER}/webstorm" ; then
  {
     local folder_date=$(date +"%Y%m%d")
     if  it_exists_with_spaces "${TARGETFOLDER}/webstorm_${folder_date}" ; then
     {
       warning A backup already exists for today "${ret}:${msg} \n ... adding time"
       folder_date=$(date +"%Y%m%d%H%M")
     }
     fi
     local msg=$(mv "${TARGETFOLDER}/webstorm" "${TARGETFOLDER}/webstorm_${folder_date}")
     local ret=$?
     if [ $ret -gt 0 ] ; then
     {
       warning failed to move backup "${ret}:${msg} \n"
     }
     fi
     directory_exists_with_spaces "${TARGETFOLDER}/webstorm_${folder_date}"
     file_does_not_exist_with_spaces "${TARGETFOLDER}/webstorm"
  }
  fi
} # end _backup_current_target_and_remove_if_exists
_install_to_target(){
  # Sample use
  #
  #     _install_to_target "${TARGETFOLDER}" "${FROM_DOWNLOADEDFOLDER_UNZIPPED}"
  #
  local TARGETFOLDER="${1}"
  enforce_variable_with_value TARGETFOLDER "${TARGETFOLDER}"

  local FROM_DOWNLOADEDFOLDER_UNZIPPED="${2}"
  enforce_variable_with_value FROM_DOWNLOADEDFOLDER_UNZIPPED "${FROM_DOWNLOADEDFOLDER_UNZIPPED}"

  mkdir -p "${TARGETFOLDER}"
  directory_exists_with_spaces "${TARGETFOLDER}"
  directory_exists_with_spaces "${FROM_DOWNLOADEDFOLDER_UNZIPPED}"

  mv "${FROM_DOWNLOADEDFOLDER_UNZIPPED}" "${TARGETFOLDER}/webstorm"
  _err=$?
  if [ $ret -gt 0 ] ; then
   {
     failed to move "${FROM_DOWNLOADEDFOLDER_UNZIPPED}" to "${TARGETFOLDER}/webstorm"  "${ret}:${msg} \n"
   }
   fi
  directory_exists_with_spaces "${TARGETFOLDER}/webstorm"
  directory_exists_with_spaces "${TARGETFOLDER}/webstorm/bin"
} # end _install_to_target
_add_mine_associacions_and_browser_click_to_open (){
  # Sample use
  #
  #     _add_mine_associacions_and_browser_click_to_open "${TARGETFOLDER}" "${LOCALSHAREFOLDER}"  "${LOGGERFOLDER}"
  #     _add_mine_associacions_and_browser_click_to_open "${TARGETFOLDER}" "${USER_HOME}/.local/share" $USER_HOME/_/work"
  #
  local TARGETFOLDER="${1}"
  enforce_variable_with_value TARGETFOLDER "${TARGETFOLDER}"
  local LOCALSHAREFOLDER="${2}"
  enforce_variable_with_value LOCALSHAREFOLDER "${LOCALSHAREFOLDER}"
  local LOGGERFOLDER="${3}"
  enforce_variable_with_value LOGGERFOLDER "${LOGGERFOLDER}"

  mkdir -p "${LOCALSHAREFOLDER}/applications"
  directory_exists_with_spaces "${LOCALSHAREFOLDER}/applications"
  mkdir -p "${LOCALSHAREFOLDER}/mime/packages"
  directory_exists_with_spaces "${LOCALSHAREFOLDER}/mime/packages"
  file_exists_with_spaces "${TARGETFOLDER}/webstorm/bin/webstorm.sh"
  chown $SUDO_USER:$SUDO_USER -R "${TARGETFOLDER}/webstorm"
  # Now Proceed to register REF:  https://gist.github.com/c80609a/752e566093b1489bd3aef0e56ee0426c
  ensure cat or "Failed to use cat command does not exists"
  ensure xdg-mime or "Failed to install run xdg-mime"

   cat << EOF > ${TARGETFOLDER}/webstorm/bin/mine-open.rb
#!/usr/bin/env ruby

# ${TARGETFOLDER}/webstorm/bin/mine-open.rb
# script opens URL in format webstorm://open?file=%{file}:%{line} in WebStorm

require 'uri'

begin
    url = ARGV.first
    u = URI.parse(url)
    # puts u
    q = URI.decode_www_form(u.query)
    # puts q
    h = q.to_h
    # puts h
    file = h['file']
    line = h['line']
    # puts file
    # puts line
    if line
        arg = "#{file}:#{line}"
    else
        arg = "#{file}"
    end
rescue
    arg = ""
end
puts arg
EOF
  file_exists_with_spaces "${TARGETFOLDER}/webstorm/bin/mine-open.rb"
  chown $SUDO_USER:$SUDO_USER -R "${TARGETFOLDER}/webstorm/bin/mine-open.rb"
  chmod +x ${TARGETFOLDER}/webstorm/bin/mine-open.rb


    cat << EOF > ${TARGETFOLDER}/webstorm/bin/mine-open.sh
#!/usr/bin/env bash
#encoding: UTF-8
# ${TARGETFOLDER}/webstorm/bin/mine-open.sh
# script opens URL in format webstorm://open?file=%{file}:%{line} in WebStorm

echo "\${@}"
echo "\${@}" >>  ${LOGGERFOLDER}/requested.log
${TARGETFOLDER}/webstorm/bin/mine-open.rb \${@}
filetoopen=\$(${TARGETFOLDER}/webstorm/bin/mine-open.rb "\${@}")
echo filetoopen "\${filetoopen}"
echo "\${filetoopen}" >>  ${LOGGERFOLDER}/requestedfiletoopen.log
mine "\${filetoopen}"

EOF
  mkdir -p ${LOGGERFOLDER}/
  directory_exists_with_spaces ${LOGGERFOLDER}/
  chown $SUDO_USER:$SUDO_USER ${LOGGERFOLDER}/
  touch ${LOGGERFOLDER}/requestedfiletoopen.log
  file_exists_with_spaces ${LOGGERFOLDER}/requestedfiletoopen.log
  chown $SUDO_USER:$SUDO_USER -R ${LOGGERFOLDER}/requestedfiletoopen.log
  file_exists_with_spaces "${TARGETFOLDER}/webstorm/bin/mine-open.sh"
  chown $SUDO_USER:$SUDO_USER -R "${TARGETFOLDER}/webstorm/bin/mine-open.sh"
  chmod +x ${TARGETFOLDER}/webstorm/bin/mine-open.sh

 cat << EOF > ${LOCALSHAREFOLDER}/mime/packages/application-x-mine.xml
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-mine">
    <comment>new mime type</comment>
    <glob pattern="*.x-mine;*.rb;*.html;*.html.erb;*.js.erb;*.html.haml;*.js.haml;*.erb;*.haml;*.js"/>
  </mime-type>
</mime-info>
EOF
  file_exists_with_spaces "${LOCALSHAREFOLDER}/mime/packages/application-x-mine.xml"
  chown $SUDO_USER:$SUDO_USER -R "${LOCALSHAREFOLDER}/mime/packages/application-x-mine.xml"




  cat << EOF > ${LOCALSHAREFOLDER}/applications/jetbrains-webstorm.desktop
# ${LOCALSHAREFOLDER}/applications/jetbrains-webstorm.desktop
[Desktop Entry]
Encoding=UTF-8
Version=2019.3.2
Type=Application
Name=WebStorm
Icon=${TARGETFOLDER}/webstorm/bin/webstorm.svg
Exec="${TARGETFOLDER}/webstorm/bin/webstorm.sh" %f
MimeType=application/x-mine;text/x-mine;text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;x-directory/normal;inode/directory;
Comment=The Most Intelligent Ruby and Rails IDE
Categories=Development;IDE;
Terminal=true
StartupWMClass=jetbrains-webstorm
EOF
  file_exists_with_spaces "${LOCALSHAREFOLDER}/applications/jetbrains-webstorm.desktop"
  chown $SUDO_USER:$SUDO_USER -R "${LOCALSHAREFOLDER}/applications/jetbrains-webstorm.desktop"


  cat << EOF > ${LOCALSHAREFOLDER}/applications/mimeinfo.cache
# ${LOCALSHAREFOLDER}/applications/mimeinfo.cache

[MIME Cache]
x-scheme-handler/webstorm=mine-open.desktop;
EOF
  file_exists_with_spaces "${LOCALSHAREFOLDER}/applications/mimeinfo.cache"
  chown $SUDO_USER:$SUDO_USER -R "${LOCALSHAREFOLDER}/applications/mimeinfo.cache"

  cat << EOF > ${LOCALSHAREFOLDER}/applications/mine-open.desktop
# ${LOCALSHAREFOLDER}/applications/mine-open.desktop
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Terminal=true
Exec="${TARGETFOLDER}/webstorm/bin/mine-open.sh" %f
MimeType=application/webstorm;x-scheme-handler/webstorm;
Name=MineOpen
Comment=BetterErrors
EOF
  file_exists_with_spaces "${LOCALSHAREFOLDER}/applications/mine-open.desktop"
  chown $SUDO_USER:$SUDO_USER -R "${LOCALSHAREFOLDER}/applications/mine-open.desktop"

  # xdg-mime default jetbrains-webstorm.desktop text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;x-directory/normal;inode/directory;
  # xdg-mime default mine-open.desktop x-scheme-handler/webstorm
  # msg=$(_try "xdg-mime default mine-open.desktop x-scheme-handler/webstorm" )
  su - "${SUDO_USER}" -c "xdg-mime default mine-open.desktop x-scheme-handler/webstorm"
  su - "${SUDO_USER}" -c "xdg-mime default mine-open.desktop text/webstorm"
  su - "${SUDO_USER}" -c "xdg-mime default mine-open.desktop application/webstorm"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-webstorm.desktop x-scheme-handler/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-webstorm.desktop text/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-webstorm.desktop application/x-mine"

  #   cat << EOF > $USER_HOME/.config/mimeapps.list
  #   cat << EOF > ${LOCALSHAREFOLDER}/applications/mimeapps.list
  # [Default Applications]
  # x-scheme-handler/webstorm=mine-open.desktop
  # text/webstorm=mine-open.desktop
  # application/webstorm=mine-open.desktop
  # x-scheme-handler/x-mine=jetbrains-webstorm.desktop
  # text/x-mine=jetbrains-webstorm.desktop
  # application/x-mine=jetbrains-webstorm.desktop

  # [Added Associations]
  # x-scheme-handler/webstorm=mine-open.desktop;
  # text/webstorm=mine-open.desktop;
  # application/webstorm=mine-open.desktop;
  # x-scheme-handler/x-mine=jetbrains-webstorm.desktop;
  # text/x-mine=jetbrains-webstorm.desktop;
  # application/x-mine=jetbrains-webstorm.desktop;
  # EOF
  #   file_exists_with_spaces "${LOCALSHAREFOLDER}/applications/mimeapps.list"
  #   file_exists_with_spaces "$USER_HOME/.config/mimeapps.list"
  ln -fs "$USER_HOME/.config/mimeapps.list" "${LOCALSHAREFOLDER}/applications/mimeapps.list"
  softlink_exists_with_spaces "${LOCALSHAREFOLDER}/applications/mimeapps.list>$USER_HOME/.config/mimeapps.list"
  chown $SUDO_USER:$SUDO_USER -R  "${LOCALSHAREFOLDER}/applications/mimeapps.list"

  file_exists_with_spaces "${TARGETFOLDER}/webstorm/bin/mine-open.sh"

  su - "${SUDO_USER}" -c "xdg-mime query default x-scheme-handler/webstorm"
  su - "${SUDO_USER}" -c "xdg-mime query default x-scheme-handler/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime query default text/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime query default application/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime query default text/webstorm"
  su - "${SUDO_USER}" -c "xdg-mime query default application/webstorm"
  msg=$(_try "su - \"${SUDO_USER}\" -c \"xdg-mime query default x-scheme-handler/webstorm\"")
  ret=$?
  if [ $ret -gt 0 ] ; then
  {

    failed "${ret}:${msg} Install with xdg-mime scheme failed!"
  }
  else
  {
    passed Install with xdg-mime scheme success!
  }
  fi
  su - "${SUDO_USER}" -c "update-mime-database \"${LOCALSHAREFOLDER}/mime\""
  su - "${SUDO_USER}" -c "update-desktop-database \"${LOCALSHAREFOLDER}/applications\""
  su - "${SUDO_USER}" -c "touch test12345.rb "
  su - "${SUDO_USER}" -c "gio info test12345.rb  | grep \"standard::content-type\""
  su - "${SUDO_USER}" -c "touch test12345.erb "
  su - "${SUDO_USER}" -c "gio info test12345.erb  | grep \"standard::content-type\""
  su - "${SUDO_USER}" -c "touch test12345.js.erb "
  su - "${SUDO_USER}" -c "gio info test12345.js.erb  | grep \"standard::content-type\""
  su - "${SUDO_USER}" -c "touch test12345.html.erb "
  su - "${SUDO_USER}" -c "gio info test12345.html.erb  | grep \"standard::content-type\""
  su - "${SUDO_USER}" -c "touch test12345.haml "
  su - "${SUDO_USER}" -c "gio info test12345.haml  | grep \"standard::content-type\""
  su - "${SUDO_USER}" -c "touch test12345.html.haml "
  su - "${SUDO_USER}" -c "gio info test12345.html.haml  | grep \"standard::content-type\""
  su - "${SUDO_USER}" -c "touch test12345.js.haml "
  su - "${SUDO_USER}" -c "gio info test12345.js.haml  | grep \"standard::content-type\""

  su - "${SUDO_USER}" -c "gio mime x-scheme-handler/webstorm"
  su - "${SUDO_USER}" -c "gio mime x-scheme-handler/x-mine"
  su - "${SUDO_USER}" -c "gio mime text/x-mine"
  su - "${SUDO_USER}" -c "gio mime application/x-mine"
  su - "${SUDO_USER}" -c "gio mime text/webstorm"
  su - "${SUDO_USER}" -c "gio mime application/webstorm"
  su - "${SUDO_USER}" -c "rm test12345.rb"
  su - "${SUDO_USER}" -c "rm test12345.erb"
  su - "${SUDO_USER}" -c "rm test12345.js.erb"
  su - "${SUDO_USER}" -c "rm test12345.html.erb"
  su - "${SUDO_USER}" -c "rm test12345.haml"
  su - "${SUDO_USER}" -c "rm test12345.js.haml"
  su - "${SUDO_USER}" -c "rm test12345.html.haml"
  echo " "
  echo "HINT: Add this to your config/initializers/better_errors.rb file "
  echo "better_errors.rb
  # ... /path_to_ruby_project/ ... /config/initializers/better_errors.rb

  if defined?(BetterErrors)
    BetterErrors.editor = \"webstorm://open?file=%{file}:%{line}\"
    BetterErrors.editor = \"x-mine://open?file=%{file}:%{line}\"
  end
  "
} # end _add_mine_associacions_and_browser_click_to_open

_darwin__64() {
  verify_is_installed "
    wget
  "
  local _err=$?
  local CODENAME=$(_version "mac" "*.*")
  _err=$?
  echo "${CODENAME}";  # show either version or log with errors
  # exit on error
  [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! _version:$_err  \n \n  " && exit 1

  local TARGET_URL="$(echo -en "${CODENAME}" | tail -1)"
  CODENAME="$(basename "${TARGET_URL}" )"
  local VERSION="$(echo -en "${CODENAME}" | sed 's/WebStorm-//g' | sed 's/.dmg//g' )"
  enforce_variable_with_value VERSION "${VERSION}"
  local UNZIPDIR="$(echo -en "${CODENAME}" | sed 's/'"${VERSION}"'//g' | sed 's/.dmg//g'| sed 's/-//g')"
  local APPDIR="$(echo -en "${CODENAME}" | sed 's/'"${VERSION}"'//g' | sed 's/.dmg//g'| sed 's/-//g').app"
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
  # _do_not_downloadtwice
  if it_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}" ; then
  {
    file_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
  }
  else
  {
    cd "${DOWNLOADFOLDER}"
    _download "${TARGET_URL}" "${DOWNLOADFOLDER}"  ${CODENAME}
    file_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
  }
  fi
  if  it_exists_with_spaces "/Applications/${APPDIR}" ; then
  {
      echo Remove  unzipped "/Applications/${APPDIR}"
      sudo rm -rf  "/Applications/${APPDIR}"
      directory_does_not_exist_with_spaces  "/Applications/${APPDIR}"
  }
  fi
  echo Attaching dmg downloaded
  sudo hdiutil attach "${DOWNLOADFOLDER}/${CODENAME}"
  ls "/Volumes"
  directory_exists_with_spaces "/Volumes/${UNZIPDIR}"
  directory_exists_with_spaces "/Volumes/${UNZIPDIR}/${APPDIR}"
  echo "sudo  cp -R /Volumes/${UNZIPDIR}/${APPDIR} /Applications/"
  sudo  cp -R /Volumes/${UNZIPDIR}/${APPDIR} /Applications/
  ls -d "/Applications/${APPDIR}"
  directory_exists_with_spaces "/Applications/${APPDIR}"
  sudo hdiutil detach "/Volumes/${UNZIPDIR}"
} # end _darwin__64

_ubuntu__64() {
  _linux_prepare
  local CODENAME=$(_version "linux" "WebStorm-*.*.*.*amd64.deb")
  # THOUGHT          local CODENAME="WebStorm-4.3.3.24545_amd64.deb"
  local URL="https://download-cf.jetbrains.com/webstorm/${CODENAME}"
  cd $USER_HOME/Downloads/
  _download "${URL}"
  sudo dpkg -i ${CODENAME}
} # end _ubuntu__64

_ubuntu__32() {
  _linux_prepare
  local CODENAME=$(_version "linux" "WebStorm-*.*.*.*i386.deb")
  # THOUGHT local CODENAME="WebStorm-4.3.3.24545_i386.deb"
  local URL="https://download-cf.jetbrains.com/webstorm/${CODENAME}"
  cd $USER_HOME/Downloads/
  _download "${URL}"
  sudo dpkg -i ${CODENAME}
} # end _ubuntu__32

_fedora__32() {
  _linux_prepare
  local CODENAME=$(_version "linux" "WebStorm*.*.*.*.i386.rpm")
  # THOUGHT                          WebStorm-4.3.3.24545.i386.rpm
  local TARGET_URL="https://download-cf.jetbrains.com/webstorm/${CODENAME}"
  file_exists_with_spaces $USER_HOME/Downloads
  enforce_variable_with_value CODENAME "${CODENAME}"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  cd $USER_HOME/Downloads
  _download "${TARGET_URL}" $USER_HOME/Downloads  ${CODENAME}
  file_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}"
  ensure tar or "Canceling Install. Could not find tar command to execute unzip"

  # provide error handling , once learned goes here. LEarn under if, once learned here.
  # Start loop while ERROR flag in case needs to try again, based on error
  _try "rpm --import https://download-cf.jetbrains.com/webstorm/RPM-GPG-KEY-scootersoftware"
  local msg=$(_try "rpm -ivh \"$USER_HOME/Downloads/${CODENAME}\"" )
  local ret=$?
  if [ $ret -gt 0 ] ; then
  {
    failed "${ret}:${msg}"
    # add error handling knowledge while learning.
  }
  else
  {
    passed Install with RPM success!
  }
  fi
  ensure WebStorm or "Failed to install WebStorm"
  rm -f "$USER_HOME/Downloads/${CODENAME}"
  file_does_not_exist_with_spaces "$USER_HOME/Downloads/${CODENAME}"
} # end _fedora__32

_centos__64() {
  _fedora__64
} # end _centos__64

_fedora__64() {
  _linux_prepare
 local CODENAME=$(_version "linux" "*.*")
  echo "${CODENAME}";
  local TARGET_URL="$(echo "${CODENAME}" | tail -1)"
  CODENAME="$(basename "${TARGET_URL}" )"
  local UNZIPDIR="$(echo "${CODENAME}" | sed 's/.tar.gz//g' )"
  enforce_variable_with_value CODENAME "${CODENAME}"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  enforce_variable_with_value HOME "${HOME}"
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  enforce_variable_with_value UNZIPDIR "${UNZIPDIR}"
  local DOWNLOADFOLDER="$(_find_downloads_folder)"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  local TARGETFOLDER="${USER_HOME}/_/software"
  enforce_variable_with_value TARGETFOLDER "${TARGETFOLDER}"

  # _remove_if_corrypted_zipfile_folder?
  if it_exists_with_spaces /tmp/corrupted.tar.gzeraseit ; then
  {
    if it_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"; then
    {
      passed Removing Corrupted zip file
      rm "${DOWNLOADFOLDER}/${CODENAME}"
      file_does_not_exist_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
      rm  /tmp/corrupted.tar.gzeraseit
    }
    fi
  }
  fi
  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
  _unzip "${DOWNLOADFOLDER}" "${UNZIPDIR}" "${CODENAME}"
  _backup_current_target_and_remove_if_exists "${TARGETFOLDER}"
  _install_to_target "${TARGETFOLDER}" "${DOWNLOADFOLDER}/${UNZIPDIR}"

  # _remove_unzipped_folder?
  rm "${DOWNLOADFOLDER}/${UNZIPDIR}"
  directory_does_not_exist_with_spaces "${DOWNLOADFOLDER}/${UNZIPDIR}"

  # _remove_downloaded_file?
  rm "${DOWNLOADFOLDER}/${CODENAME}"
  file_does_not_exist_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"

   _add_mine_associacions_and_browser_click_to_open "${TARGETFOLDER}" "${USER_HOME}/.local/share" "${USER_HOME}/_/work"


} # end _fedora__64

_mingw__64() {
    local CODENAME=$(_version "win" "WebStorm*.*.*.*.exe")
    # THOUGHT        local CODENAME="WebStorm-4.3.3.24545.exe"
    local URL="https://download-cf.jetbrains.com/webstorm/${CODENAME}"
    cd $HOMEDIR
	  cd Downloads
    curl -O $URL
    ${CODENAME}
} # end _mingw__64

_mingw__32() {
    local CODENAME=$(_version "win" "WebStorm*.*.*.*.exe")
    # THOUGHT        local CODENAME="WebStorm-4.3.3.24545.exe"
    local URL="https://download-cf.jetbrains.com/webstorm/${CODENAME}"
    cd $HOMEDIR
    cd Downloads
	  curl -O $URL
	  ${CODENAME}
} # end



 #--------/\/\/\/\-- install_webstorm.bash -- Custom code-/\/\/\/\-------


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo "🥦"
exit 0
