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
        (( DEBUG )) && echo "$0: tasks_base/sudoer.bash Loading locally"
        structsource="""$(<"${provider}")"""
        _err=$?
        [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading ${_library}. running 'source locally' returned error did not download or is empty err:$_err  \n \n  " && exit 1
      else
        if ( command -v curl >/dev/null 2>&1; )  ; then
          (( DEBUG )) && echo "$0: tasks_base/sudoer.bash Loading ${_library} from the net using curl "
          structsource="""$(curl https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/${_library}  -so -   2>/dev/null )"""  #  2>/dev/null suppress only curl download messages, but keep curl output for variable
          _err=$?
          [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading ${_library}. running 'curl' returned error did not download or is empty err:$_err  \n \n  " && exit 1
        elif ( command -v wget >/dev/null 2>&1; ) ; then
          (( DEBUG )) && echo "$0: tasks_base/sudoer.bash Loading ${_library} from the net using wget "
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
      (( DEBUG )) && echo "$0: tasks_base/sudoer.bash Temp location ${_temp_dir}/${_library}"
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
(( DEBUG )) && passed "Caller user identified:${SUDO_USER}"
(( DEBUG )) && passed "Home identified:${USER_HOME}"
directory_exists_with_spaces "${USER_HOME}"



 #---------/\/\/\-- tasks_base/sudoer.bash -------------/\/\/\--------





 #--------\/\/\/\/-- tasks_templates_sudo/phpstorm …install_phpstorm.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#

_version() {
  # https://download.jetbrains.com/webide/PhpStorm-2019.3.4.tar.gz
  # https://download-cf.jetbrains.com/webide/PhpStorm-2019.3.4.tar.gz
  # https://download.jetbrains.com/webide/PhpStorm-2020.2.0.tar.gz
  # https://download.jetbrains.com/webide/PhpStorm-2021.3.2.tar.gz
  local PLATFORM="${1}" # mac windows linux
  local PATTERN="${2}"
  # https://www.jetbrains.com/phpstorm/download/#section=linux
  # local CODEFILE="""$(wget --quiet --no-check-certificate https://www.jetbrains.com/phpstorm/download/#section=linux -O -  2>/dev/null )""" # suppress only wget download messages, but keep wget output for variable
  # local CODEFILE="""$(wget --quiet --no-check-certificate https://www.jetbrains.com/phpstorm/download/other.html -O -  2>/dev/null )""" # suppress only wget download messages, but keep wget output for variable
  local CODEFILE="""$(wget --quiet --no-check-certificate https://www.jetbrains.com/phpstorm/whatsnew/ -O -  2>/dev/null )""" # suppress only wget download messages, but keep wget output for variable
  # echo "PATTERN:${PATTERN}"
  # local CODEFILE=$(curl -d "zz=dl4&platform=${PLATFORM}" -H "Content-Type: application/x-www-form-urlencoded" -X POST  -sSLo -  https://www.jetbrains.com/phpstorm/download/\#section=linux  2>&1;) # suppress only wget download messages, but keep wget output for variable
  # echo "$CODEFILE" | sed s/\</\\n\</g | sed s/\>/\>\\n/g| sed 's/:/\n/g' | grep "PhpStorm"
  # echo "$CODEFILE" | sed s/\</\\n\</g | sed s/\>/\>\\n/g  | grep "New in PhpStorm" | grep "New" | grep "2021"


  # echo "$CODEFILE" | sed s/\</\\n\</g | sed s/\>/\>\\n/g | sed 's/,/\n/g'  | grep '"version"'  | cut -d'"' -f4
  # echo "$CODEFILE"  | phantomjs  --- crashes

  # local CODELASTESTBUILD=$(echo $CODEFILE | sed s/\</\\n\</g | grep "${PATTERN}" | sed s/\"/\\n/g | grep "/" | cüt "/")
  local CODELASTESTBUILD=$(echo "$CODEFILE" | sed s/\</\\n\</g | sed s/\>/\>\\n/g | sed 's/,/\n/g'  | grep '"version"'  | cut -d'"' -f4)
  # fedora 32 local CODELASTESTBUILD=$(echo $CODEFILE | sed s/\</\\n\</g | grep "PhpStorm*.*.*.*.i386.rpm" | sed s/\"/\\n/g | grep "/" | cüt "/")
  wait
  # [[ -z "${CODELASTESTBUILD}" ]] && failed "PhpStorm Version not found! :${CODELASTESTBUILD}:"


  enforce_variable_with_value USER_HOME "${USER_HOME}"
  enforce_variable_with_value CODELASTESTBUILD "${CODELASTESTBUILD}"

  local CODENAME="${CODELASTESTBUILD}"
  echo "${CODELASTESTBUILD}"
  unset PATTERN
  unset PLATFORM
  unset CODEFILE
  unset CODELASTESTBUILD
} # end _version

_darwin__64() {
    local CODENAME=$(_version "mac" "PhpStormOSX*.*.*.*.zip")
    # THOUGHT        local CODENAME="PhpStormOSX-4.3.3.24545.zip"
    local URL="https://download-cf.jetbrains.com/webide/${CODENAME}"
    local DOWNLOADFOLDER="$(_find_downloads_folder)"
    enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
    cd ${DOWNLOADFOLDER}/
    _download "${URL}"
    unzip ${CODENAME}
    sudo hdiutil attach ${CODENAME}
    sudo cp -R /Volumes/Beyond\ Compare/Beyond\ Compare.app /Applications/
    sudo hdiutil detach /Volumes/Beyond \ Compare
} # end _darwin__64

_ubuntu__64() {
    local CODENAME=$(_version "linux" "PhpStorm-*.*.*.*amd64.deb")
    # THOUGHT          local CODENAME="PhpStorm-4.3.3.24545_amd64.deb"
    local URL="https://download-cf.jetbrains.com/webide/${CODENAME}"
    enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
    cd ${DOWNLOADFOLDER}/
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
} # end _ubuntu__64

_ubuntu__32() {
    local CODENAME=$(_version "linux" "PhpStorm-*.*.*.*i386.deb")
    # THOUGHT local CODENAME="PhpStorm-4.3.3.24545_i386.deb"
    local URL="https://download-cf.jetbrains.com/webide/${CODENAME}"
    local DOWNLOADFOLDER="$(_find_downloads_folder)"
    enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
    cd ${DOWNLOADFOLDER}/
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
} # end _ubuntu__32

_fedora__32() {
  local CODENAME=$(_version "linux" "PhpStorm*.*.*.*.i386.rpm")
  # THOUGHT                          PhpStorm-4.3.3.24545.i386.rpm
  local TARGET_URL="https://download-cf.jetbrains.com/webide/${CODENAME}"
  local DOWNLOADFOLDER="$(_find_downloads_folder)"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  file_exists_with_spaces ${DOWNLOADFOLDER}
  cd ${DOWNLOADFOLDER}
  _download "${TARGET_URL}"
  file_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
  ensure tar or "Canceling Install. Could not find tar command to execute unzip"

  # provide error handling , once learned goes here. LEarn under if, once learned here.
  # Start loop while ERROR flag in case needs to try again, based on error
  _try "rpm --import https://download-cf.jetbrains.com/webide/RPM-GPG-KEY-scootersoftware"
  local msg=$(_try "rpm -ivh \"${DOWNLOADFOLDER}/${CODENAME}\"" )
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
  ensure PhpStorm or "Failed to install Beyond Compare"
  rm -f "${DOWNLOADFOLDER}/${CODENAME}"
  file_does_not_exist_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
} # end _fedora__32

_centos__64() {
  _fedora__64
} # end _centos__64

_fedora__64() {
  local TARGETFOLDER="${USER_HOME}/_/software"
  enforce_variable_with_value TARGETFOLDER "${TARGETFOLDER}"

  local _target_dir_install="${TARGETFOLDER}/phpstorm"
  enforce_variable_with_value _target_dir_install "${_target_dir_install}"
  # _linux_prepare
  # Lives Samples
  # https://download.jetbrains.com/webide/PhpStorm-2019.3.4.tar.gz
  # https://download-cf.jetbrains.com/webide/PhpStorm-2019.3.4.tar.gz
  # https://download.jetbrains.com/webide/PhpStorm-2021.3.2.tar.gz
  local CODENAME=$(_version "linux" "PhpStorm-*.*.*.tar.gz")
  # echo "CODENAME:${CODENAME}"
  enforce_variable_with_value CODENAME "${CODENAME}"

  CODENAME="PhpStorm-${CODENAME}"
  passed "CODENAME:${CODENAME}"
  local TARGET_URL="https://download-cf.jetbrains.com/webide/${CODENAME}.tar.gz"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  local DOWNLOADFOLDER="$(_find_downloads_folder)"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}.tar.gz"
  _untar_gz_download "${DOWNLOADFOLDER}"  "${DOWNLOADFOLDER}/${CODENAME}.tar.gz"
  _move_to_target_dir "${DOWNLOADFOLDER}" "${_target_dir_install}" "${TARGETFOLDER}"

  [ -e "${DOWNLOADFOLDER}/${CODENAME}.tar.gz" ] && rm "${DOWNLOADFOLDER}/${CODENAME}.tar.gz"
  directory_does_not_exist_with_spaces "${DOWNLOADFOLDER}/${CODENAME}.tar.gz"


  directory_exists_with_spaces "${_target_dir_install}/bin"
  mkdir -p "$USER_HOME/.local/share/applications"
  directory_exists_with_spaces "$USER_HOME/.local/share/applications"
  mkdir -p "$USER_HOME/.local/share/mime/packages"
  directory_exists_with_spaces "$USER_HOME/.local/share/mime/packages"
  file_exists_with_spaces "${_target_dir_install}/bin/phpstorm.sh"

  chown $SUDO_USER:$SUDO_USER -R "${_target_dir_install}"

  # Now Proceed to register REF:  https://gist.github.com/c80609a/752e566093b1489bd3aef0e56ee0426c
  ensure cat or "Failed to use cat command does not exists"
  ensure xdg-mime or "Failed to install run xdg-mime"

   cat << EOF > ${_target_dir_install}/bin/pstorm-open.rb
#!/usr/bin/env ruby

# ${_target_dir_install}/bin/pstorm-open.rb
# script opens URL in format phpstorm://open?file=%{file}:%{line} in phpstorm

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
  file_exists_with_spaces "${_target_dir_install}/bin/pstorm-open.rb"
  chown $SUDO_USER:$SUDO_USER -R "${_target_dir_install}/bin/pstorm-open.rb"
  chmod +x ${_target_dir_install}/bin/pstorm-open.rb


    cat << EOF > ${_target_dir_install}/bin/pstorm-open.sh
#!/usr/bin/env bash
#encoding: UTF-8
# ${_target_dir_install}/bin/pstorm-open.sh
# script opens URL in format phpstorm://open?file=%{file}:%{line} in phpstorm

echo "spaceSpace"
echo "spaceSpace"
echo "spaceSpace"
echo "<\${@}> <--- There should be something here between <>"
echo "<\${*}> <--- There should be something here between <>"
echo "\${@}" >>  $USER_HOME/_/work/requested.log
last_line=\$(tail -1<<<\$(grep 'file='<$USER_HOME/_/work/requested.log))
${_target_dir_install}/bin/pstorm-open.rb \${last_line}
filetoopen=\$(${_target_dir_install}/bin/pstorm-open.rb "\${last_line}")
echo filetoopen "\${filetoopen}"
echo "\${filetoopen}" >>  $USER_HOME/_/work/requestedfiletoopen.log
pstorm "\${filetoopen}"

EOF
  mkdir -p $USER_HOME/_/work/
  directory_exists_with_spaces $USER_HOME/_/work/
  chown $SUDO_USER:$SUDO_USER $USER_HOME/_/work/
  touch $USER_HOME/_/work/requestedfiletoopen.log
  file_exists_with_spaces $USER_HOME/_/work/requestedfiletoopen.log
  chown $SUDO_USER:$SUDO_USER -R $USER_HOME/_/work/requestedfiletoopen.log
  file_exists_with_spaces "${_target_dir_install}/bin/pstorm-open.sh"
  chown $SUDO_USER:$SUDO_USER -R "${_target_dir_install}/bin/pstorm-open.sh"
  chmod +x ${_target_dir_install}/bin/pstorm-open.sh

 cat << EOF > $USER_HOME/.local/share/mime/packages/application-x-pstorm.xml
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-pstorm">
    <comment>new mime type</comment>
    <glob pattern="*.x-pstorm;*.rb;*.html;*.html.erb;*.js.erb;*.html.haml;*.js.haml;*.erb;*.haml;*.js"/>
  </mime-type>
</mime-info>
EOF
  file_exists_with_spaces "$USER_HOME/.local/share/mime/packages/application-x-pstorm.xml"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/.local/share/mime/packages/application-x-pstorm.xml"




  cat << EOF > $USER_HOME/.local/share/applications/jetbrains-phpstorm.desktop
# $USER_HOME/.local/share/applications/jetbrains-phpstorm.desktop
[Desktop Entry]
Encoding=UTF-8
Version=2020.2
Type=Application
Name=phpstorm
Icon=${_target_dir_install}/bin/phpstorm.svg
Exec=${_target_dir_install}/bin/phpstorm.sh %f
MimeType=application/x-pstorm;text/x-pstorm;text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;x-directory/normal;inode/directory;
Comment=The Most Intelligent Php IDE
Categories=Development;IDE;
Terminal=true
StartupWMClass=jetbrains-phpstorm
EOF
  file_exists_with_spaces "$USER_HOME/.local/share/applications/jetbrains-phpstorm.desktop"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/.local/share/applications/jetbrains-phpstorm.desktop"


  cat << EOF > $USER_HOME/.local/share/applications/phpstorm.mimeinfo.cache
# $USER_HOME/.local/share/applications/mimeinfo.cache

[MIME Cache]
x-scheme-handler/phpstorm=pstorm-open.desktop;
EOF
  file_exists_with_spaces "$USER_HOME/.local/share/applications/phpstorm.mimeinfo.cache"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/.local/share/applications/phpstorm.mimeinfo.cache"

  cat << EOF > $USER_HOME/.local/share/applications/pstorm-open.desktop
# $USER_HOME/.local/share/applications/pstorm-open.desktop
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Terminal=true
Exec=${_target_dir_install}/bin/pstorm-open.sh %f
MimeType=application/phpstorm;x-scheme-handler/phpstorm;
Name=PhpStormOpen
Comment=BetterErrors
EOF
  file_exists_with_spaces "$USER_HOME/.local/share/applications/pstorm-open.desktop"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/.local/share/applications/pstorm-open.desktop"

  # xdg-mime default jetbrains-phpstorm.desktop text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;x-directory/normal;inode/directory;
  # xdg-mime default pstorm-open.desktop x-scheme-handler/phpstorm
  # msg=$(_try "xdg-mime default pstorm-open.desktop x-scheme-handler/phpstorm" )
  su - "${SUDO_USER}" -c "xdg-mime default pstorm-open.desktop x-scheme-handler/phpstorm"
  su - "${SUDO_USER}" -c "xdg-mime default pstorm-open.desktop text/phpstorm"
  su - "${SUDO_USER}" -c "xdg-mime default pstorm-open.desktop application/phpstorm"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-phpstorm.desktop x-scheme-handler/x-pstorm"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-phpstorm.desktop text/x-pstorm"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-phpstorm.desktop application/x-pstorm"

#   cat << EOF > $USER_HOME/.config/mimeapps.list
#   cat << EOF > $USER_HOME/.local/share/applications/mimeapps.list
# [Default Applications]
# x-scheme-handler/phpstorm=pstorm-open.desktop
# text/phpstorm=pstorm-open.desktop
# application/phpstorm=pstorm-open.desktop
# x-scheme-handler/x-pstorm=jetbrains-phpstorm.desktop
# text/x-pstorm=jetbrains-phpstorm.desktop
# application/x-pstorm=jetbrains-phpstorm.desktop

# [Added Associations]
# x-scheme-handler/phpstorm=pstorm-open.desktop;
# text/phpstorm=pstorm-open.desktop;
# application/phpstorm=pstorm-open.desktop;
# x-scheme-handler/x-pstorm=jetbrains-phpstorm.desktop;
# text/x-pstorm=jetbrains-phpstorm.desktop;
# application/x-pstorm=jetbrains-phpstorm.desktop;
# EOF
#   file_exists_with_spaces "$USER_HOME/.local/share/applications/mimeapps.list"
#   file_exists_with_spaces "$USER_HOME/.config/mimeapps.list"
ln -fs "$USER_HOME/.config/mimeapps.list" "$USER_HOME/.local/share/applications/mimeapps.list"
softlink_exists_with_spaces "$USER_HOME/.local/share/applications/mimeapps.list>$USER_HOME/.config/mimeapps.list"
chown $SUDO_USER:$SUDO_USER -R  "$USER_HOME/.local/share/applications/mimeapps.list"

file_exists_with_spaces "${_target_dir_install}/bin/pstorm-open.sh"

  su - "${SUDO_USER}" -c "xdg-mime query default x-scheme-handler/phpstorm"
  su - "${SUDO_USER}" -c "xdg-mime query default x-scheme-handler/x-pstorm"
  su - "${SUDO_USER}" -c "xdg-mime query default text/x-pstorm"
  su - "${SUDO_USER}" -c "xdg-mime query default application/x-pstorm"
  su - "${SUDO_USER}" -c "xdg-mime query default text/phpstorm"
  su - "${SUDO_USER}" -c "xdg-mime query default application/phpstorm"
  msg=$(_try "su - \"${SUDO_USER}\" -c \"xdg-mime query default x-scheme-handler/phpstorm\"")
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
  su - "${SUDO_USER}" -c "update-mime-database \"$USER_HOME/.local/share/mime\""
  su - "${SUDO_USER}" -c "update-desktop-database \"$USER_HOME/.local/share/applications\""
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

  su - "${SUDO_USER}" -c "gio mime x-scheme-handler/phpstorm"
  su - "${SUDO_USER}" -c "gio mime x-scheme-handler/x-pstorm"
  su - "${SUDO_USER}" -c "gio mime text/x-pstorm"
  su - "${SUDO_USER}" -c "gio mime application/x-pstorm"
  su - "${SUDO_USER}" -c "gio mime text/phpstorm"
  su - "${SUDO_USER}" -c "gio mime application/phpstorm"
  su - "${SUDO_USER}" -c "rm test12345.rb"
  su - "${SUDO_USER}" -c "rm test12345.erb"
  su - "${SUDO_USER}" -c "rm test12345.js.erb"
  su - "${SUDO_USER}" -c "rm test12345.html.erb"
  su - "${SUDO_USER}" -c "rm test12345.haml"
  su - "${SUDO_USER}" -c "rm test12345.js.haml"
  su - "${SUDO_USER}" -c "rm test12345.html.haml"
  echo " "
  echo "HINT: Add this to your config/initializers/better_errors.php file "
  echo "better_errors.rb
  # ... /path_to_php_project/ ... /config/initializers/better_errors.php

  if (defined?(\$BetterErrors) {
    \$BetterErrors.editor = \"phpstorm://open?file=%{file}:%{line}\"
    \$BetterErrors.editor = \"x-pstorm://open?file=%{file}:%{line}\"
  }
  "
} # end _fedora__64

_mingw__64() {
    local CODENAME=$(_version "win" "PhpStorm*.*.*.*.exe")
    # THOUGHT        local CODENAME="PhpStorm-4.3.3.24545.exe"
    local URL="https://download-cf.jetbrains.com/webide/${CODENAME}"
    cd $HOMEDIR
    local DOWNLOADFOLDER="$(_find_downloads_folder)"
    enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
    cd "${DOWNLOADFOLDER}"
    curl -O $URL
    ${CODENAME}
} # end _mingw__64

_mingw__32() {
    local CODENAME=$(_version "win" "PhpStorm*.*.*.*.exe")
    # THOUGHT        local CODENAME="PhpStorm-4.3.3.24545.exe"
    local URL="https://download-cf.jetbrains.com/webide/${CODENAME}"
    cd $HOMEDIR
    local DOWNLOADFOLDER="$(_find_downloads_folder)"
    enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
    cd "${DOWNLOADFOLDER}"
    curl -O $URL
    ${CODENAME}
} # end


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo ":)"



 #--------/\/\/\/\-- tasks_templates_sudo/phpstorm …install_phpstorm.bash” -- Custom code-/\/\/\/\-------


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo "🥦"
exit 0
