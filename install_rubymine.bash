#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
# Compatible start with low version bash, like mac before zsh change and after
# type -a realpath
realpath ()                                                                                                                                                                                   
{                                                                                                                                                                                             
    f=$@;                                                                                                                                                                                     
    if [ -d "$f" ]; then                                                                                                                                                                      
        base="";                                                                                                                                                                              
        dir="$f";                                                                                                                                                                             
    else                                                                                                                                                                                      
        base="/$(basename "$f")";                                                                                                                                                             
        dir=$(dirname "$f");                                                                                                                                                                  
    fi;                                                                                                                                                                                       
    dir=$(cd "$dir" && /bin/pwd);                                                                                                                                                             
    echo "$dir$base"                                                                                                                                                                          
}         

export USER_HOME
export THISSCRIPTCOMPLETEPATH
typeset -r THISSCRIPTCOMPLETEPATH="$(realpath $(which $(basename "$0")))"   # § This goes in the FATHER-MOTHER script

export BASH_VERSION_NUMBER
typeset BASH_VERSION_NUMBER=$(echo $BASH_VERSION | cut -f1 -d.)

export  THISSCRIPTNAME
typeset -r THISSCRIPTNAME="$(realpath $(which $(basename "$0")))"

export _err
typeset -i _err=0

load_struct_testing_wget(){
    local provider="$HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    [   -e "${provider}"  ] && source "${provider}" && echo "Loaded locally"
    [ ! -e "${provider}"  ] && eval """$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing -O -  2>/dev/null )"""   # suppress only wget download messages, but keep wget output for variable
    ( ( ! command -v passed >/dev/null 2>&1; ) && echo -e "\n \n  ERROR! Loading struct_testing \n \n " && exit 69; )
} # end load_struct_testing_wget
load_struct_testing_wget

export sudo_it
function sudo_it() {
  raise_to_sudo_and_user_home
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
  enforce_variable_with_value SUDO_USER "${SUDO_USER}"
  enforce_variable_with_value SUDO_UID "${SUDO_UID}"
  enforce_variable_with_value SUDO_COMMAND "${SUDO_COMMAND}"
  # Override bigger error trap  with local
  function _trap_on_error(){
    _err=$?
    echo -e "\033[01;7m*** ERROR TRAP $THISSCRIPTNAME err<$_err>  \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}\(\) \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}\(\) \\n ERR ...\033[0m"
    pkill curl 
    pkill wget 
    
    if [ $_err -eq 2 ] && [[ "${FUNCNAME[1]}" == "_unzip" ]]  ; then 
    {
      touch /tmp/corrupted.tar.gzeraseit
      determine_os_and_fire_action
    } 
    else 
    {
      exit 1
    }
    fi
  }
  function _trap_on_int(){
    _err=$?
    echo -e "\033[01;7m*** INT TRAP $THISSCRIPTNAME err<$_err> \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}\(\) \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}\(\) \\n INT ...\033[0m"
    pkill curl 
    pkill wget 
    exit 1
  }
  trap _trap_on_error ERR 
  trap _trap_on_int INT
} # end sudo_it


function _linux_prepare(){
  sudo_it
  [ $? -gt 0 ] && (failed to sudo_it raise_to_sudo_and_user_home  || exit 1)
  export USER_HOME="/home/${SUDO_USER}"
  enforce_variable_with_value USER_HOME "${USER_HOME}"
}  # end _linux_prepare

_version() {
  local PLATFORM="${1}" # mac windows linux
  local PATTERN="${2}"
  # THOUGHT:   https://download-cf.jetbrains.com/ruby/RubyMine-2020.3.dmg
  local CODEFILE="""$(wget --quiet --no-check-certificate  https://www.jetbrains.com/ruby/ -O -  2>/dev/null )""" # suppress only wget download messages, but keep wget output for variable
  # enforce_variable_with_value CODEFILE "${CODEFILE}"
  wait
  local CODELASTESTBUILD=$(echo "${CODEFILE}" | sed s/\</\\n\</g | sed s/\>/\>\\n/g | sed "s/&apos;/\'/g" | sed 's/&nbsp;/ /g' | grep  "New in RubyMine ${PATTERN}" | sed s/\ /\\n/g | tail -1 ) # | grep "What&apos;s New in&nbsp;RubyMine&nbsp;" | sed 's/\;/\;'\\n'/g' | sed s/\</\\n\</g  )
  enforce_variable_with_value CODELASTESTBUILD "${CODELASTESTBUILD}"

  local CODENAME=""
  case ${PLATFORM} in
  mac)
    CODENAME="https://download-cf.jetbrains.com/ruby/RubyMine-${CODELASTESTBUILD}.dmg"
    ;;

  windows)
    CODENAME="https://download-cf.jetbrains.com/ruby/RubyMine-${CODELASTESTBUILD}.exe"
    CODENAME="https://download-cf.jetbrains.com/ruby/RubyMine-${CODELASTESTBUILD}.win.zip"
    ;;

  linux)
    CODENAME="https://download-cf.jetbrains.com/ruby/RubyMine-${CODELASTESTBUILD}.tar.gz"
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

_darwin__64() {
  local CODENAME=$(_version "mac" "*.*")
  echo "${CODENAME}";
  local TARGET_URL="$(echo -en "${CODENAME}" | tail -1)"
  CODENAME="$(basename "${TARGET_URL}" )"
  local VERSION="$(echo -en "${CODENAME}" | sed 's/RubyMine-//g' | sed 's/.dmg//g' )"
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
  local CODENAME=$(_version "linux" "RubyMine-*.*.*.*amd64.deb")
  # THOUGHT          local CODENAME="RubyMine-4.3.3.24545_amd64.deb"
  local URL="https://download-cf.jetbrains.com/ruby/${CODENAME}"
  cd $USER_HOME/Downloads/
  _download "${URL}"
  sudo dpkg -i ${CODENAME}
} # end _ubuntu__64

_ubuntu__32() {
  local CODENAME=$(_version "linux" "RubyMine-*.*.*.*i386.deb")
  # THOUGHT local CODENAME="RubyMine-4.3.3.24545_i386.deb"
  local URL="https://download-cf.jetbrains.com/ruby/${CODENAME}"
  cd $USER_HOME/Downloads/
  _download "${URL}"
  sudo dpkg -i ${CODENAME}
} # end _ubuntu__32

_fedora__32() {
  _linux_prepare
  local CODENAME=$(_version "linux" "RubyMine*.*.*.*.i386.rpm")
  # THOUGHT                          RubyMine-4.3.3.24545.i386.rpm
  local TARGET_URL="https://download-cf.jetbrains.com/ruby/${CODENAME}"
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
  _try "rpm --import https://download-cf.jetbrains.com/ruby/RPM-GPG-KEY-scootersoftware"
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
  ensure RubyMine or "Failed to install RubyMine"
  rm -f "$USER_HOME/Downloads/${CODENAME}"
  file_does_not_exist_with_spaces "$USER_HOME/Downloads/${CODENAME}"
} # end _fedora__32

_centos__64() {
  _fedora__64
} # end _centos__64
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

  if  it_exists_with_spaces "${TARGETFOLDER}/rubymine" ; then
  {
     local folder_date=$(date +"%Y%m%d")
     if  it_exists_with_spaces "${TARGETFOLDER}/rubymine_${folder_date}" ; then
     {
       warning A backup already exists for today "${ret}:${msg} \n ... adding time"
       folder_date=$(date +"%Y%m%d%H%M")
     }
     fi
     local msg=$(mv "${TARGETFOLDER}/rubymine" "${TARGETFOLDER}/rubymine_${folder_date}")
     local ret=$?
     if [ $ret -gt 0 ] ; then
     {
       warning failed to move backup "${ret}:${msg} \n"
     }
     fi
     directory_exists_with_spaces "${TARGETFOLDER}/rubymine_${folder_date}"
     file_does_not_exist_with_spaces "${TARGETFOLDER}/rubymine"
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

  mv "${FROM_DOWNLOADEDFOLDER_UNZIPPED}" "${TARGETFOLDER}/rubymine"
  _err=$?
  if [ $ret -gt 0 ] ; then
   {
     failed to move "${FROM_DOWNLOADEDFOLDER_UNZIPPED}" to "${TARGETFOLDER}/rubymine"  "${ret}:${msg} \n"
   }
   fi
  directory_exists_with_spaces "${TARGETFOLDER}/rubymine"
  directory_exists_with_spaces "${TARGETFOLDER}/rubymine/bin"
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
  file_exists_with_spaces "${TARGETFOLDER}/rubymine/bin/rubymine.sh"
  chown $SUDO_USER:$SUDO_USER -R "${TARGETFOLDER}/rubymine"
  # Now Proceed to register REF:  https://gist.github.com/c80609a/752e566093b1489bd3aef0e56ee0426c
  ensure cat or "Failed to use cat command does not exists"
  ensure xdg-mime or "Failed to install run xdg-mime"

   cat << EOF > ${TARGETFOLDER}/rubymine/bin/mine-open.rb
#!/usr/bin/env ruby

# ${TARGETFOLDER}/rubymine/bin/mine-open.rb
# script opens URL in format rubymine://open?file=%{file}:%{line} in RubyMine

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
  file_exists_with_spaces "${TARGETFOLDER}/rubymine/bin/mine-open.rb"
  chown $SUDO_USER:$SUDO_USER -R "${TARGETFOLDER}/rubymine/bin/mine-open.rb"
  chmod +x ${TARGETFOLDER}/rubymine/bin/mine-open.rb


    cat << EOF > ${TARGETFOLDER}/rubymine/bin/mine-open.sh
#!/usr/bin/env bash
#encoding: UTF-8
# ${TARGETFOLDER}/rubymine/bin/mine-open.sh
# script opens URL in format rubymine://open?file=%{file}:%{line} in RubyMine

echo "\${@}"
echo "\${@}" >>  ${LOGGERFOLDER}/requested.log
${TARGETFOLDER}/rubymine/bin/mine-open.rb \${@}
filetoopen=\$(${TARGETFOLDER}/rubymine/bin/mine-open.rb "\${@}")
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
  file_exists_with_spaces "${TARGETFOLDER}/rubymine/bin/mine-open.sh"
  chown $SUDO_USER:$SUDO_USER -R "${TARGETFOLDER}/rubymine/bin/mine-open.sh"
  chmod +x ${TARGETFOLDER}/rubymine/bin/mine-open.sh

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




  cat << EOF > ${LOCALSHAREFOLDER}/applications/jetbrains-rubymine.desktop
# ${LOCALSHAREFOLDER}/applications/jetbrains-rubymine.desktop
[Desktop Entry]
Encoding=UTF-8
Version=2019.3.2
Type=Application
Name=RubyMine
Icon=${TARGETFOLDER}/rubymine/bin/rubymine.svg
Exec="${TARGETFOLDER}/rubymine/bin/rubymine.sh" %f
MimeType=application/x-mine;text/x-mine;text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;x-directory/normal;inode/directory;
Comment=The Most Intelligent Ruby and Rails IDE
Categories=Development;IDE;
Terminal=true
StartupWMClass=jetbrains-rubymine
EOF
  file_exists_with_spaces "${LOCALSHAREFOLDER}/applications/jetbrains-rubymine.desktop"
  chown $SUDO_USER:$SUDO_USER -R "${LOCALSHAREFOLDER}/applications/jetbrains-rubymine.desktop"


  cat << EOF > ${LOCALSHAREFOLDER}/applications/mimeinfo.cache
# ${LOCALSHAREFOLDER}/applications/mimeinfo.cache

[MIME Cache]
x-scheme-handler/rubymine=mine-open.desktop;
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
Exec="${TARGETFOLDER}/rubymine/bin/mine-open.sh" %f
MimeType=application/rubymine;x-scheme-handler/rubymine;
Name=MineOpen
Comment=BetterErrors
EOF
  file_exists_with_spaces "${LOCALSHAREFOLDER}/applications/mine-open.desktop"
  chown $SUDO_USER:$SUDO_USER -R "${LOCALSHAREFOLDER}/applications/mine-open.desktop"

  # xdg-mime default jetbrains-rubymine.desktop text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;x-directory/normal;inode/directory;
  # xdg-mime default mine-open.desktop x-scheme-handler/rubymine
  # msg=$(_try "xdg-mime default mine-open.desktop x-scheme-handler/rubymine" )
  su - "${SUDO_USER}" -c "xdg-mime default mine-open.desktop x-scheme-handler/rubymine"
  su - "${SUDO_USER}" -c "xdg-mime default mine-open.desktop text/rubymine"
  su - "${SUDO_USER}" -c "xdg-mime default mine-open.desktop application/rubymine"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-rubymine.desktop x-scheme-handler/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-rubymine.desktop text/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime default jetbrains-rubymine.desktop application/x-mine"

  #   cat << EOF > $USER_HOME/.config/mimeapps.list
  #   cat << EOF > ${LOCALSHAREFOLDER}/applications/mimeapps.list
  # [Default Applications]
  # x-scheme-handler/rubymine=mine-open.desktop
  # text/rubymine=mine-open.desktop
  # application/rubymine=mine-open.desktop
  # x-scheme-handler/x-mine=jetbrains-rubymine.desktop
  # text/x-mine=jetbrains-rubymine.desktop
  # application/x-mine=jetbrains-rubymine.desktop

  # [Added Associations]
  # x-scheme-handler/rubymine=mine-open.desktop;
  # text/rubymine=mine-open.desktop;
  # application/rubymine=mine-open.desktop;
  # x-scheme-handler/x-mine=jetbrains-rubymine.desktop;
  # text/x-mine=jetbrains-rubymine.desktop;
  # application/x-mine=jetbrains-rubymine.desktop;
  # EOF
  #   file_exists_with_spaces "${LOCALSHAREFOLDER}/applications/mimeapps.list"
  #   file_exists_with_spaces "$USER_HOME/.config/mimeapps.list"
  ln -fs "$USER_HOME/.config/mimeapps.list" "${LOCALSHAREFOLDER}/applications/mimeapps.list"
  softlink_exists_with_spaces "${LOCALSHAREFOLDER}/applications/mimeapps.list>$USER_HOME/.config/mimeapps.list"
  chown $SUDO_USER:$SUDO_USER -R  "${LOCALSHAREFOLDER}/applications/mimeapps.list"

  file_exists_with_spaces "${TARGETFOLDER}/rubymine/bin/mine-open.sh"

  su - "${SUDO_USER}" -c "xdg-mime query default x-scheme-handler/rubymine"
  su - "${SUDO_USER}" -c "xdg-mime query default x-scheme-handler/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime query default text/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime query default application/x-mine"
  su - "${SUDO_USER}" -c "xdg-mime query default text/rubymine"
  su - "${SUDO_USER}" -c "xdg-mime query default application/rubymine"
  msg=$(_try "su - \"${SUDO_USER}\" -c \"xdg-mime query default x-scheme-handler/rubymine\"")
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

  su - "${SUDO_USER}" -c "gio mime x-scheme-handler/rubymine"
  su - "${SUDO_USER}" -c "gio mime x-scheme-handler/x-mine"
  su - "${SUDO_USER}" -c "gio mime text/x-mine"
  su - "${SUDO_USER}" -c "gio mime application/x-mine"
  su - "${SUDO_USER}" -c "gio mime text/rubymine"
  su - "${SUDO_USER}" -c "gio mime application/rubymine"
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
    BetterErrors.editor = \"rubymine://open?file=%{file}:%{line}\"
    BetterErrors.editor = \"x-mine://open?file=%{file}:%{line}\"
  end
  "
} # end _add_mine_associacions_and_browser_click_to_open

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
    local CODENAME=$(_version "win" "*.*")
    # THOUGHT        local CODENAME="RubyMine-4.3.3.24545.exe"
    local URL="https://download-cf.jetbrains.com/ruby/${CODENAME}"
    cd $HOMEDIR
	  cd Downloads
    curl -O $URL
    ${CODENAME}
} # end _mingw__64

_mingw__32() {
    local CODENAME=$(_version "win" "*.*")
    # THOUGHT        local CODENAME="RubyMine-4.3.3.24545.exe"
    local URL="https://download-cf.jetbrains.com/ruby/${CODENAME}"
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


