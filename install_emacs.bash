#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
# em script Emacs on mac experience  REF: https://medium.com/@holzman.simon/emacs-on-macos-catalina-10-15-in-2019-79ff713c1ccc
# Compile emacs mac REF: https://emacs.stackexchange.com/questions/58526/how-do-i-build-emacs-from-sources-on-macos-catalina-version-10-15-4

ensure git 
checkversion $(makeinfo --version)>=4.13
Install it 
# REF: https://stackoverflow.com/questions/44379909/how-to-upgrade-update-makeinfo-texinfo-from-version-4-8-to-4-13-on-macosx-termin
brew info textinfo
echo 'export PATH="/usr/local/opt/texinfo/bin:$PATH"' >> ~/.zshrc
checkversion $(makeinfo --version)>=4.13
makeinfo --version

echo mac: 
git clone -b master git://git.sv.gnu.org/emacs.git
cd emacs 
./autogen.sh
./configure
make -j3 -B --debug
make check -j3 -B --debug
make install -j3 -B --debug



load_struct_testing_wget(){
    local provider="$HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    [   -e "${provider}"  ] && source "${provider}" && echo "Loaded locally"
    [ ! -e "${provider}"  ] && eval """$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing -O -  2>/dev/null )"""   # suppress only wget download messages, but keep wget output for variable
    ( ( ! command -v passed >/dev/null 2>&1; ) && echo -e "\n \n  ERROR! Loading struct_testing \n \n " && exit 69; )
} # end load_struct_testing_wget
load_struct_testing_wget

function _linux_prepare(){
  export  THISSCRIPTNAME
  typeset -gr THISSCRIPTNAME="$(pwd)/$(basename "$0")"
  export _err
  typeset -i _err=0
  load_execute_boot_basic_with_sudo(){
      if ( typeset -p "SUDO_USER"  &>/dev/null ) ; then
        export USER_HOME
        typeset -rg USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
      else
        local USER_HOME=$HOME
      fi
      local -r provider="$USER_HOME/_/clis/execute_command_intuivo_cli/execute_boot_basic.sh"
      echo source "${provider}"
      [   -e "${provider}"  ] && source "${provider}"
      [ ! -e "${provider}"  ] && eval """$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/execute_boot_basic.sh -O -  2>/dev/null )"""   # suppress only wget download messages, but keep wget output for variable
      if ( command -v failed >/dev/null 2>&1; ) ; then
      {
        return 0
      }
      else
      {
        echo -e "\n \n  ERROR! Loading execute_boot_basic.sh \n \n "
        exit 1;
      }
      fi
      return 0
  } # end load_execute_boot_basic_with_sudo

  load_execute_boot_basic_with_sudo
  _err=$?
  if [ $_err -ne 0 ] ;  then
  {
    >&2 echo -e "ERROR There was an error loading load_execute_boot_basic_with_sudo Err:$_err "
    exit $_err
  }
  fi

  function _trap_on_exit(){
    echo -e "\033[01;7m*** TRAP $THISSCRIPTNAME EXITS ...\033[0m"
  
  }
  #trap kill ERR
  trap _trap_on_exit EXIT
  #trap kill INT
} # end _linux_prepare

_version() {
  local PLATFORM="${1}" # mac windows linux 
  local PATTERN="${2}"
  # THOUGHT:   https://download-cf.jetbrains.com/webstorm/WebStorm-2020.3.dmg
  local CODEFILE="""$(wget --quiet --no-check-certificate  https://www.jetbrains.com/webstorm/ -O -  2>/dev/null )""" # suppress only wget download messages, but keep wget output for variable
  # assert not empty "${CODEFILE}"
  wait
  local CODELASTESTBUILD=$(echo "${CODEFILE}" | sed s/\</\\n\</g | sed s/\>/\>\\n/g | sed "s/&apos;/\'/g" | sed 's/&nbsp;/ /g' | grep  "New in WebStorm ${PATTERN}" | sed s/\ /\\n/g | tail -1 ) # | grep "What&apos;s New in&nbsp;WebStorm&nbsp;" | sed 's/\;/\;'\\n'/g' | sed s/\</\\n\</g  )
  assert not empty "${CODELASTESTBUILD}"

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
  assert not empty "${CODENAME}"
  unset PATTERN
  unset PLATFORM
  unset CODEFILE
  unset CODELASTESTBUILD
  echo "${CODENAME}"
  return 0
} # end _version

_darwin__64() {
  local CODENAME=$(_version "mac" "*.*")
  echo "${CODENAME}";
  local TARGET_URL="$(echo -en "${CODENAME}" | tail -1)"
  CODENAME="$(basename "${TARGET_URL}" )"
  local VERSION="$(echo -en "${CODENAME}" | sed 's/WebStorm-//g' | sed 's/.dmg//g' )"
  assert not empty "${VERSION}"
  local UNZIPDIR="$(echo -en "${CODENAME}" | sed 's/'"${VERSION}"'//g' | sed 's/.dmg//g'| sed 's/-//g')"
  local APPDIR="$(echo -en "${CODENAME}" | sed 's/'"${VERSION}"'//g' | sed 's/.dmg//g'| sed 's/-//g').app"
  # echo "${CODENAME}";
  # echo "${URL}";
  echo "CODENAME: ${CODENAME}"
  assert not empty "${CODENAME}"
  assert not empty "${TARGET_URL}"
  assert not empty "${HOME}"
  echo "UNZIPDIR: ${UNZIPDIR}"
  assert not empty "${UNZIPDIR}"
  echo "APPDIR: ${APPDIR}"
  assert not empty "${APPDIR}"
  local DOWNLOADFOLDER="${HOME}/Downloads"
  assert not empty "${DOWNLOADFOLDER}"
  directory_exists_with_spaces "${DOWNLOADFOLDER}"

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
  assert not empty "${CODENAME}"
  assert not empty "${TARGET_URL}"
  assert not empty "${USER_HOME}"
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
 local CODENAME=$(_version "linux" "*.*")
  echo "${CODENAME}";
  local TARGET_URL="$(echo "${CODENAME}" | tail -1)"
  CODENAME="$(basename "${TARGET_URL}" )"
  local UNZIPDIR="$(echo "${CODENAME}" | sed 's/.tar.gz//g' )"
  assert not empty "${CODENAME}"
  assert not empty "${TARGET_URL}"
  assert not empty "${HOME}"
  assert not empty "${USER_HOME}"
  assert not empty "${UNZIPDIR}"

  if  it_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}" ; then
  {
    file_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}"
  }
  else
  {
    file_exists_with_spaces $USER_HOME/Downloads
    cd $USER_HOME/Downloads
    _download "${TARGET_URL}" $USER_HOME/Downloads  ${CODENAME}
    file_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}"
  }
  fi
  if  it_exists_with_spaces "$USER_HOME/Downloads/${UNZIPDIR}" ; then
  {
    rm -rf "$USER_HOME/Downloads/${UNZIPDIR}"
    directory_does_not_exist_with_spaces "$USER_HOME/Downloads/${UNZIPDIR}"
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
  cd $USER_HOME/Downloads
  #_try "tar xvzf  \"$USER_HOME/Downloads/${CODENAME}.tar.gz\"--directory=$USER_HOME/Downloads"
  # GROw bar with tar Progress bar tar REF: https://superuser.com/questions/168749/is-there-a-way-to-see-any-tar-progress-per-file
  # Compress tar cvfj big-files.tar.bz2 folder-with-big-files
  # Compress tar cf - $USER_HOME/Downloads/${CODENAME}.tar.gz --directory=$USER_HOME/Downloads -P | pv -s $(du -sb $USER_HOME/Downloads/${CODENAME}.tar.gz | awk '{print $1}') | gzip > big-files.tar.gz
  # Extract tar Progress bar REF: https://coderwall.com/p/l_m2yg/tar-untar-on-osx-linux-with-progress-bars
  # Extract tar sample pv file.tgz | tar xzf - -C target_directory
  # Working simplme tar:  tar xvzf $USER_HOME/Downloads/${CODENAME}.tar.gz --directory=$USER_HOME/Downloads
  pv $USER_HOME/Downloads/${CODENAME}  | tar xzf - -C $USER_HOME/Downloads
  #local msg=$(_try "tar xvzf  \"$USER_HOME/Downloads/${CODENAME}.tar.gz\" --directory=$USER_HOME/Downloads " )
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

  local NEWDIRCODENAME=$(ls -1tr "$USER_HOME/Downloads/"  | tail  -1)
  local FROMUZIPPED="$USER_HOME/Downloads/${NEWDIRCODENAME}"
  directory_exists_with_spaces  "${FROMUZIPPED}"
  # directory_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}"


  if  it_exists_with_spaces "$USER_HOME/_/software/webstorm" ; then
  {
     folder_date=$(date +"%Y%m%d")
     if  it_exists_with_spaces "$USER_HOME/_/software/webstorm_${folder_date}" ; then
     {
       warning A backup already exists for today "${ret}:${msg} \n ... adding time"
       folder_date=$(date +"%Y%m%d%H%M")
     }
     fi
     msg=$(mv "$USER_HOME/_/software/webstorm" "$USER_HOME/_/software/webstorm_${folder_date}")
     ret=$?
     if [ $ret -gt 0 ] ; then
     {
       warning failed to move backup "${ret}:${msg} \n"
     }
     fi
     directory_exists_with_spaces "$USER_HOME/_/software/webstorm_${folder_date}"
     file_does_not_exist_with_spaces "$USER_HOME/_/software/webstorm"
  }
  fi
  mkdir -p "$USER_HOME/_/software"
  directory_exists_with_spaces "$USER_HOME/_/software"
  mv "${FROMUZIPPED}" "$USER_HOME/_/software/webstorm"
  directory_does_not_exist_with_spaces "${FROMUZIPPED}"
  directory_exists_with_spaces "$USER_HOME/_/software/webstorm"
  directory_exists_with_spaces "$USER_HOME/_/software/webstorm/bin"
  mkdir -p "$USER_HOME/.local/share/applications"
  directory_exists_with_spaces "$USER_HOME/.local/share/applications"
  mkdir -p "$USER_HOME/.local/share/mime/packages"
  directory_exists_with_spaces "$USER_HOME/.local/share/mime/packages"
  file_exists_with_spaces "$USER_HOME/_/software/webstorm/bin/webstorm.sh"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/_/software/webstorm"
  # Now Proceed to register REF:  https://gist.github.com/c80609a/752e566093b1489bd3aef0e56ee0426c
  ensure cat or "Failed to use cat command does not exists"
  ensure xdg-mime or "Failed to install run xdg-mime"

   cat << EOF > $USER_HOME/_/software/webstorm/bin/webstorm-open.rb
#!/usr/bin/env ruby

# $USER_HOME/_/software/webstorm/bin/webstorm-open.rb
# script opens URL in format webstorm://open?file=%{file}:%{line} in webstorm

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
  file_exists_with_spaces "$USER_HOME/_/software/webstorm/bin/webstorm-open.rb"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/_/software/webstorm/bin/webstorm-open.rb"
  chmod +x $USER_HOME/_/software/webstorm/bin/webstorm-open.rb


    cat << EOF > $USER_HOME/_/software/webstorm/bin/webstorm-open.sh
#!/usr/bin/env bash
#encoding: UTF-8
# $USER_HOME/_/software/webstorm/bin/webstorm-open.sh
# script opens URL in format webstorm://open?file=%{file}:%{line} in webstorm

echo "\${@}"
echo "\${@}" >>  $USER_HOME/_/work/requested.log
$USER_HOME/_/software/webstorm/bin/webstorm-open.rb \${@}
filetoopen=\$($USER_HOME/_/software/webstorm/bin/webstorm-open.rb "\${@}")
echo filetoopen "\${filetoopen}"
echo "\${filetoopen}" >>  $USER_HOME/_/work/requestedfiletoopen.log
mine "\${filetoopen}"

EOF
  mkdir -p $USER_HOME/_/work/
  directory_exists_with_spaces $USER_HOME/_/work/
  chown $SUDO_USER:$SUDO_USER $USER_HOME/_/work/
  touch $USER_HOME/_/work/requestedfiletoopen.log
  file_exists_with_spaces $USER_HOME/_/work/requestedfiletoopen.log
  chown $SUDO_USER:$SUDO_USER -R $USER_HOME/_/work/requestedfiletoopen.log
  file_exists_with_spaces "$USER_HOME/_/software/webstorm/bin/webstorm-open.sh"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/_/software/webstorm/bin/webstorm-open.sh"
  chmod +x $USER_HOME/_/software/webstorm/bin/webstorm-open.sh

 cat << EOF > $USER_HOME/.local/share/mime/packages/application-x-wstorm.xml
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-mine">
    <comment>new mime type</comment>
    <glob pattern="*.x-mine;*.rb;*.html;*.html.erb;*.js.erb;*.html.haml;*.js.haml;*.erb;*.haml;*.js"/>
  </mime-type>
</mime-info>
EOF
  file_exists_with_spaces "$USER_HOME/.local/share/mime/packages/application-x-wstorm.xml"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/.local/share/mime/packages/application-x-wstorm.xml"




  cat << EOF > $USER_HOME/.local/share/applications/jetbrains-webstorm.desktop
# $USER_HOME/.local/share/applications/jetbrains-webstorm.desktop
[Desktop Entry]
Encoding=UTF-8
Version=2019.3.2
Type=Application
Name=webstorm
Icon=$USER_HOME/_/software/webstorm/bin/webstorm.svg
Exec="$USER_HOME/_/software/webstorm/bin/webstorm.sh" %f
MimeType=application/x-mine;text/x-mine;text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;x-directory/normal;inode/directory;
Comment=The Most Intelligent Js IDE
Categories=Development;IDE;
Terminal=true
StartupWMClass=jetbrains-webstorm
EOF
  file_exists_with_spaces "$USER_HOME/.local/share/applications/jetbrains-webstorm.desktop"
   chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/.local/share/applications/jetbrains-webstorm.desktop"


  cat << EOF > $USER_HOME/.local/share/applications/webstorm.mimeinfo.cache
# $USER_HOME/.local/share/applications/mimeinfo.cache

[MIME Cache]
x-scheme-handler/webstorm=webstorm-open.desktop;
EOF
  file_exists_with_spaces "$USER_HOME/.local/share/applications/webstorm.mimeinfo.cache"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/.local/share/applications/webstorm.mimeinfo.cache"

  cat << EOF > $USER_HOME/.local/share/applications/webstorm-open.desktop
# $USER_HOME/.local/share/applications/webstorm-open.desktop
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Terminal=true
Exec="$USER_HOME/_/software/webstorm/bin/webstorm-open.sh" %f
MimeType=application/webstorm;x-scheme-handler/webstorm;
Name=MineOpen
Comment=BetterErrors
EOF
  file_exists_with_spaces "$USER_HOME/.local/share/applications/webstorm-open.desktop"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/.local/share/applications/webstorm-open.desktop"

  # xdg-mime default jetbrains-webstorm.desktop text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;x-directory/normal;inode/directory;
  # xdg-mime default webstorm-open.desktop x-scheme-handler/webstorm
  # msg=$(_try "xdg-mime default webstorm-open.desktop x-scheme-handler/webstorm" )
  su - "${SUDO_USER}" -c "xdg-mime default webstorm-open.desktop x-scheme-handler/webstorm"
  su - "${SUDO_USER}" -c "xdg-mime default webstorm-open.desktop text/webstorm"
  su - "${SUDO_USER}" -c "xdg-mime default webstorm-open.desktop application/webstorm"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-webstorm.desktop x-scheme-handler/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-webstorm.desktop text/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-webstorm.desktop application/x-mine"

#   cat << EOF > $USER_HOME/.config/mimeapps.list
#   cat << EOF > $USER_HOME/.local/share/applications/mimeapps.list
# [Default Applications]
# x-scheme-handler/webstorm=webstorm-open.desktop
# text/webstorm=webstorm-open.desktop
# application/webstorm=webstorm-open.desktop
# x-scheme-handler/x-mine=jetbrains-webstorm.desktop
# text/x-mine=jetbrains-webstorm.desktop
# application/x-mine=jetbrains-webstorm.desktop

# [Added Associations]
# x-scheme-handler/webstorm=webstorm-open.desktop;
# text/webstorm=webstorm-open.desktop;
# application/webstorm=webstorm-open.desktop;
# x-scheme-handler/x-mine=jetbrains-webstorm.desktop;
# text/x-mine=jetbrains-webstorm.desktop;
# application/x-mine=jetbrains-webstorm.desktop;
# EOF
#   file_exists_with_spaces "$USER_HOME/.local/share/applications/mimeapps.list"
#   file_exists_with_spaces "$USER_HOME/.config/mimeapps.list"
ln -fs "$USER_HOME/.config/mimeapps.list" "$USER_HOME/.local/share/applications/mimeapps.list"
softlink_exists_with_spaces "$USER_HOME/.local/share/applications/mimeapps.list>$USER_HOME/.config/mimeapps.list"
chown $SUDO_USER:$SUDO_USER -R  "$USER_HOME/.local/share/applications/mimeapps.list"
file_exists_with_spaces "$USER_HOME/_/software/webstorm/bin/webstorm-open.sh"


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
  echo "HINT: Add this to your config/initializers/better_errors.js file "
  echo "better_errors.rb
  # ... /path_to_js_project/ ... /config/initializers/better_errors.js

  if (defined?(\$BetterErrors) {
    \$BetterErrors.editor = \"webstorm://open?file=%{file}:%{line}\"
    \$BetterErrors.editor = \"x-mine://open?file=%{file}:%{line}\"
  }
  "
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


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo ":)"


