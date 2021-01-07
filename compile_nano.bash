#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
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
    # shellcheck disable=SC2030
    if ( typeset -p "SUDO_USER"  &>/dev/null ) ; then
    {
      export USER_HOME
      # typeset -rg USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)  # Get the caller's of sudo home dir Just Linux
      # shellcheck disable=SC2046
      # shellcheck disable=SC2031
      typeset -rg USER_HOME="$(echo -n $(bash -c "cd ~${SUDO_USER} && pwd"))"  # Get the caller's of sudo home dir LINUX and MAC
    }
    else
    {
      local USER_HOME=$HOME
    }
    fi
    local -r provider="$USER_HOME/_/clis/execute_command_intuivo_cli/execute_boot_basic.sh"
    echo source "${provider}"
    # shellcheck disable=SC1090
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

_darwin__64() {
  # Using homebrew seemed like the best choice so far
  # /usr/bin/curl --disable --globoff --show-error --user-agent Homebrew/2.6.2-222-g880eb2d\ \(Macintosh\;\ Intel\ Mac\ OS\ X\ 10.15.7\)\ curl/7.64.1 --header Accept-Language:\ en --retry 3 --location --silent --head --request GET https://homebrew.bintray.com/bottles/nano-5.4.catalina.bottle.tar.gz
  # tar xof /Users/benutzer/Library/Caches/Homebrew/downloads/91845ed41d14ccff1a66f16db7c7ec93f7d7958bb08be637dae24d2aa70a214d--nano-5.4.catalina.bottle.tar.gz -C /var/folders/8x/9phrghz97g38v9m8m6r59_0w0000gn/T/d20201221-96141-1fi6gd9
  # cp -pR /var/folders/8x/9phrghz97g38v9m8m6r59_0w0000gn/T/d20201221-96141-1fi6gd9/nano/. /usr/local/Cellar/nano
  # chmod -Rf +w /var/folders/8x/9phrghz97g38v9m8m6r59_0w0000gn/T/d20201221-96141-1fi6gd9
  brew install nano
  nano --version

  # REF: https://github.com/scopatz/nanorc
  # curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh
  wget https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh -O- | sh
  ls ~/.nanorc
  cd ~/.nano/
  cp ~/.nano/javascript.nanorc ~/.nano/typescript.nanorc
  ersetzeindatei ~/.nano/typescript.nanorc "JavaScript" "Typescript"
  ersetzeindatei ~/.nano/typescript.nanorc "\.js$"  "\.ts$"
  sed -i'' 's/\.js$/\.ts$/g' ~/.nano/typescript.nanorc
  # from
  # syntax "JavaScript" "\.js$"
  # syntax "Typescript" "\.ts$"
  # in   ~/.nano/typescript.nanorc
  ersetzeindatei ~/.nanorc 'include "~/.nano/tex.nanorc"' 'include "~/.nano/tex.nanorc"\ninclude "~/.nano/typescript.nanorc"'
} # end _darwin__64


_darwin__64_manual() {

  git clone -b https://git.savannah.gnu.org/git/nano.git
  cd nano
  Requirements:
   brew install automake
   brew install pkg-config
   brew install groff
   brew install ncurses
   brew install make
   brew install libtool
   ln -s  /usr/local/Cellar/libtool/2.4.6_2/bin/glibtool /usr/local/bin/libtool
  git pull
  git config pull.rebase false
  # // inside .bash_profile and or .zprofile  --- start
      # PKG_CONFIG points to the executable
      # PKG_CONFIG_PATH points to where path to where the .pc files are located
      # PKG_CONFIG_LIBDIR overrides PKG_CONFIG_PATH
      # Ncurses is about UTF8 support
        # Makeinfo Textinfo From Homebrew
      [[ -d "/usr/local/opt/texinfo/bin" ]] && export PATH="/usr/local/opt/texinfo/bin:$PATH"

      # PKG_CONFIG
      [[ -d "/usr/local/bin/pkg-config" ]] && export PKG_CONFIG="/usr/local/bin/pkg-config"
      # [[ -d "/usr/local/lib/pkgconfig" ]] && export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"
      # [[ -d "/usr/local/lib/pkgconfig" ]] && export PKG_CONFIG_LIBDIR="/usr/local/lib/pkgconfig"

      # If when compiling get something about UTF8 error. Adding this lines fixed it.
      # Brew NCurses
      [[ -d "/usr/local/opt/ncurses/lib" ]] && export LDFLAGS="-L/usr/local/opt/ncurses/lib"
      [[ -d "/usr/local/opt/ncurses/include" ]] && export CPPFLAGS="-I/usr/local/opt/ncurses/include"
      [[ -d "/usr/local/opt/ncurses/lib/pkgconfig" ]] &&  export PKG_CONFIG_PATH="/usr/local/opt/ncurses/lib/pkgconfig"

      # Brew
      [[ -d "/usr/local/sbin" ]] && export PATH="/usr/local/sbin:$PATH"

      # Brew Make
      [[ -d "/usr/local/opt/make/libexec/gnubin" ]] && export PATH="/usr/local/opt/make/libexec/gnubin:$PATH"
  # // inside .bash_profile and or .zprofile  --- end

  Confirm the right executables

  which automake === /usr/bin/automake error
  which automake === /usr/local/bin/automake  correct

  which make === /usr/bin/make error
  which make === /usr/local/opt/make/libexec/gnubin/make correct

  which pkg-config === /usr/bin/pkg-config error
  which pkg-config === /usr/local/bin/pkg-config correct

  which libtool === /usr/bin/libtool error
  which libtool === /usr/local/bin/libtool correct

  which groff === /usr/bin/groff error
  which groff === /usr/local/bin/groff correct

  # Sometimes there is an error of pkg.m4 missing
  locate pkg.m4
   nur "macros are missing"
   Find the line like around line 35186 in mycase
   add this line: $(aclocal --print-ac-dir)/pkg.m4
   inside the string error output
  run the ./configure again and it should output the place where it wants to find the
  pkg.m4
  for me it was:  /usr/local/Cellar/automake/1.16.3/share/aclocal/pkg.m4
  now locate the pkg.m4: locate pkg.m4

I got several answers:
/Users/user/.cargo/registry/src/github.com-1ecc6299db9ec823/harfbuzz-sys-0.2.0/harfbuzz/m4/pkg.m4
/Users/user/.cargo/registry/src/github.com-1ecc6299db9ec823/mozjs_sys-0.51.3/mozjs/build/autoconf/pkg.m4
/Users/user/_/itch/emacs/m4/pkg.m4
/usr/local/Cellar/php/8.0.0_1/lib/php/build/pkg.m4
/usr/local/Cellar/php@7.4/7.4.13_1/lib/php/build/pkg.m4
/usr/local/Cellar/pkg-config/0.29.2_3/share/aclocal/pkg.m4

  now pick one.

  In my case I checked the pkg-config version installed: pkg-config --version
  So I got: 0.29.2

  So I picked /usr/local/Cellar/pkg-config/0.29.2_3/share/aclocal/pkg.m4
  and I copy that to the location where ./configure error is looking into

  cp /usr/local/Cellar/pkg-config/0.29.2_3/share/aclocal/pkg.m4 /usr/local/Cellar/automake/1.16.3/share/aclocal/

  Now try again from the autogen.sh script

  ./autogen.sh  --disable-dependency-tracking  --disable-wrapping-as-root --enable-color  --enable-debug  --enable-extra  --enable-libmagic  --enable-multibuffer  --enable-nanorc  --enable-speller  --enable-utf8  --prefix=/usr/local/opt  --sysconfdir=/usr/local/etc

  Now try ./configure script

  ./configure  --disable-dependency-tracking  --disable-wrapping-as-root --enable-color  --enable-debug  --enable-extra  --enable-libmagic  --enable-multibuffer  --enable-nanorc  --enable-speller  --enable-utf8  --prefix=/usr/local/opt  --sysconfdir=/usr/local/etc

  # ./autogen.sh
  # ./configure
  # PKG_CONFIG="/usr/local/bin/pkg-config" \Z~
  # PKG_CONFIG_PATH="/usr/local/lib/pkgconfig" \
  # PKG_CONFIG_LIBDIR="/usr/local/lib/pkgconfig" \
  #   ./configure --enable-debug \
  #               --disable-dependency-tracking \
  #               --prefix=/usr/local/opt \
  #                           --sysconfdir=/usr/local/etc \
  #                           --enable-color \
  #                           --enable-extra \
  #                           --enable-multibuffer \
  #                           --enable-nanorc \
  #                           --enable-utf8
  # make -j3 -B --debug --enable-debug
  # make check -j3 -B --debug
  # make install  -j3 -B --debug

  # PKG_CONFIG="/usr/local/bin/pkg-config" PKG_CONFIG_PATH="/usr/local/lib/pkgconfig" PKG_CONFIG_LIBDIR="/usr/local/lib/pkgconfig"
  # make -j3 -B --debug  // This failed
  # make -j3 -B  // Takes longer and fails
  make -j3 --debug   # Passes
  make -j7 --debug   # Passes
  make  --debug   # Passes
  make # Passes

  # make check -j3 -B --debug # // Fails
  make check -j3 --debug # // Passes

  # make install  -j3 -B --debug # // Fails
  make install  -j3 --debug # // Passes

  The resulting executable is located under for me: /usr/local/opt/bin/nano
  Still need to link it

   ln -s  /usr/local/opt/bin/nano /usr/local/bin/nano

#  if nano from Brew exsits then move it :

     mv /usr/local/bin/gnano /usr/local/bin/brewnano

  #   ls -la  /usr/local/bin/brewnano
  lrwxr-xr-x  1 benutzer  admin  27 Dec 21 09:56 /usr/local/bin/brewnano -> ../Cellar/nano/5.4/bin/nano

  #  if your /usr/local/bin/ is in your path then /usr/local/bin/nano
    should be seen
  which nano === /usr/local/bin/nano  correct
  which nano === /usr/bin/nano   wrong

  make sure that /usr/local/bin/nano points to -->  /usr/local/opt/bin/nano
  and not to brew nano

  ls -la  /usr/local/bin/nano
#  lrwxr-xr-x  1 benutzer  admin  27 Dec 21 09:56 /usr/local/bin/nano -> ../Cellar/nano/5.4/bin/nano  wrong
#  lrwxr-xr-x  1 benutzer  admin  23 Dec 26 15:20 /usr/local/bin/nano -> /usr/local/opt/bin/nano  correct

} # end _darwin__64

_ubuntu__64() {
  _linux_prepare
    local CODENAME=$(_version "linux" "nano-*.*.*.*amd64.deb")
    # THOUGHT          local CODENAME="nano-4.3.3.24545_amd64.deb"
    local URL="https://www.nano-editor.org/dist/v5/${CODENAME}"
    https://www.nano-editor.org/dist/v5/
        cd $USER_HOME/Downloads/
        _download "${URL}"
        sudo dpkg -i ${CODENAME}
    # install lastest nano
    sudo add-apt-repository ppa:n-muench/programs-ppa
    sudo apt install nano
    sudo apt update nano

    # task_compile_lastest_nano
    # _get_version()
    # _download
    cd $USER_HOME
    cd $HOME

    curl -O https://www.nano-editor.org/dist/v5/nano-5.2.tar.gz
    tar -xvf nano-5.2.tar.gz
    cd nano-5.2

    cat -n INSTALL | grep configure
    sudo apt install libncursesw5-dev -y
    sudo apt install groff -y
    ./install-sh
    ./autogen.sh
    ./configure
    make -j3 -B --debug
    make -j3
    sudo make install | grep

    # Make sure we are using nano we compiled and not the boring system nano
    nano --version  should match 5.2
    which nano
    /usr/local/share/nano --version
    sudo /usr/local/share/nano --version
    sudo /usr/local/bin/nano --version
    sudo mv /bin/nano /bin/nano_old
    nano --version

    # REF: https://github.com/scopatz/nanorc
    curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh
    wget https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh -O- | sh

    #
    .nanorc
    ~/.nano/
    cp ~/.nano/javascript.nanorc ~/.nano/typescript.nanorc
    # ersetseindatei
    # syntax "JavaScript" "\.js$"
    # >
    # syntax "Typescript" "\.ts$"
    # in   ~/.nano/typescript.nanorc

    # ersetseindatei
    # include "~/.nano/tex.nanorc"
    # >
    # include "~/.nano/tex.nanorc"
    # include "~/.nano/typescript.nanorc"
    # in .nanorc

    PORT=3000
    curl -X POST http://$HOST:$PORT -H "accept: application/json" -H "Content-Type: application/json" -d "{}"
    curl -X POST http://$HOST:$PORT -H "accept: application/json" -H "Content-Type: application/json" -d "{"":"" }"
} # end _ubuntu__64

_ubuntu__32() {
  _linux_prepare
    local CODENAME=$(_version "linux" "nano-*.*.*.*i386.deb")
    # THOUGHT local CODENAME="nano-4.3.3.24545_i386.deb"
    local URL="https://www.nano-editor.org/dist/v5/${CODENAME}"
    cd $USER_HOME/Downloads/
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
} # end _ubuntu__32

_fedora__32() {
  _linux_prepare
  local CODENAME=$(_version "linux" "nano*.*.*.*.i386.rpm")
  # THOUGHT                          nano-4.3.3.24545.i386.rpm
  local TARGET_URL="https://www.nano-editor.org/dist/v5/${CODENAME}"
  file_exists_with_spaces $USER_HOME/Downloads
  cd $USER_HOME/Downloads
  _download "${TARGET_URL}"
  file_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}"
  ensure tar or "Canceling Install. Could not find tar command to execute unzip"

  # provide error handling , once learned goes here. LEarn under if, once learned here.
  # Start loop while ERROR flag in case needs to try again, based on error
  _try "rpm --import https://www.nano-editor.org/dist/v5/RPM-GPG-KEY-nano"
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
  ensure nano or "Failed to install Beyond Compare"
  rm -f "$USER_HOME/Downloads/${CODENAME}"
  file_does_not_exist_with_spaces "$USER_HOME/Downloads/${CODENAME}"
} # end _fedora__32

_centos__64() {
  _fedora__64
} # end _centos__64

_fedora__64() {
  _linux_prepare
  # Lives Samples
  # https://www.nano-editor.org/dist/v5/nano-2019.3.4.tar.gz
  cd "$USER_HOME/_/software"
  # git clone -b https://git.savannah.gnu.org/git/nano.git

  local CODENAME=$(_version "linux" "nano*.*.*.tar.gz")
  echo $CODENAME
  exit 0
  CODENAME=$(echo "nano-2020.2")
  local TARGET_URL="https://www.nano-editor.org/dist/v5/${CODENAME}.tar.gz"
  if  it_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}.tar.gz" ; then
  {
    file_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}.tar.gz"
  }
  else
  {
    file_exists_with_spaces $USER_HOME/Downloads
    cd $USER_HOME/Downloads
    _download "${TARGET_URL}" $USER_HOME/Downloads  ${CODENAME}.tar.gz
    file_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}.tar.gz"
  }
  fi
  if  it_exists_with_spaces "$USER_HOME/Downloads/${CODENAME}" ; then
  {
    rm -rf "$USER_HOME/Downloads/${CODENAME}"
    directory_does_not_exist_with_spaces "$USER_HOME/Downloads/${CODENAME}"
  }
  fi

  ensure tar or "Canceling Install. Could not find tar command to execute unzip"
  ensure awk or "Canceling Install. Could not find awk command to execute unzip"
  ensure pv or "Canceling Install. Could not find pv command to execute unzip"
  ensure du or "Canceling Install. Could not find du command to execute unzip"
  ensure gzip or "Canceling Install. Could not find gzip command to execute unzip"
  ensure gio or "Canceling Install. Could not find gio command to execute gio"
  ensure update-mime-database or "Canceling Install. Could not find update-mime-database command to execute update-mime-database"
  ensure update-desktop-database or "Canceling Install. Could not find update-desktop-database command to execute update"
  ensure touch or "Canceling Install. Could not find touch command to execute touch"

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
  pv $USER_HOME/Downloads/${CODENAME}.tar.gz  | tar xzf - -C $USER_HOME/Downloads
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

  local NEWDIRCODENAME=$(ls -1tr /home/zeus/Downloads/  | tail  -1)
  local FROMUZIPPED="$USER_HOME/Downloads/${NEWDIRCODENAME}"
  directory_exists_with_spaces  "${FROMUZIPPED}"


  if  it_exists_with_spaces "$USER_HOME/_/software/nano" ; then
  {
     folder_date=$(date +"%Y%m%d")
     if  it_exists_with_spaces "$USER_HOME/_/software/nano_${folder_date}" ; then
     {
       warning A backup already exists for today "${ret}:${msg} \n ... adding time"
       folder_date=$(date +"%Y%m%d%H%M")
     }
     fi
     msg=$(mv "$USER_HOME/_/software/nano" "$USER_HOME/_/software/nano_${folder_date}")
     ret=$?
     if [ $ret -gt 0 ] ; then
     {
       warning failed to move backup "${ret}:${msg} \n"
     }
     fi
     directory_exists_with_spaces "$USER_HOME/_/software/nano_${folder_date}"
     file_does_not_exist_with_spaces "$USER_HOME/_/software/nano"
  }
  fi
  mkdir -p "$USER_HOME/_/software"
  directory_exists_with_spaces "$USER_HOME/_/software"
  mv "${FROMUZIPPED}" "$USER_HOME/_/software/nano"
  directory_does_not_exist_with_spaces "${FROMUZIPPED}"
  directory_exists_with_spaces "$USER_HOME/_/software/nano"
  directory_exists_with_spaces "$USER_HOME/_/software/nano/bin"
  mkdir -p "$USER_HOME/.local/share/applications"
  directory_exists_with_spaces "$USER_HOME/.local/share/applications"
  mkdir -p "$USER_HOME/.local/share/mime/packages"
  directory_exists_with_spaces "$USER_HOME/.local/share/mime/packages"
  file_exists_with_spaces "$USER_HOME/_/software/nano/bin/nano.sh"

  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/_/software/nano"

  # Now Proceed to register REF:  https://gist.github.com/c80609a/752e566093b1489bd3aef0e56ee0426c
  ensure cat or "Failed to use cat command does not exists"
  ensure xdg-mime or "Failed to install run xdg-mime"

   cat << EOF > $USER_HOME/_/software/nano/bin/nano-open.rb
#!/usr/bin/env ruby

# $USER_HOME/_/software/nano/bin/nano-open.rb
# script opens URL in format nano://open?file=%{file}:%{line} in nano

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
  file_exists_with_spaces "$USER_HOME/_/software/nano/bin/nano-open.rb"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/_/software/nano/bin/nano-open.rb"
  chmod +x $USER_HOME/_/software/nano/bin/nano-open.rb


    cat << EOF > $USER_HOME/_/software/nano/bin/nano-open.sh
#!/usr/bin/env bash
#encoding: UTF-8
# $USER_HOME/_/software/nano/bin/nano-open.sh
# script opens URL in format nano://open?file=%{file}:%{line} in nano

echo "\${@}"
echo "\${@}" >>  $USER_HOME/_/work/requested.log
$USER_HOME/_/software/nano/bin/nano-open.rb \${@}
filetoopen=\$($USER_HOME/_/software/nano/bin/nano-open.rb "\${@}")
echo filetoopen "\${filetoopen}"
echo "\${filetoopen}" >>  $USER_HOME/_/work/requestedfiletoopen.log
nano "\${filetoopen}"

EOF
  mkdir -p $USER_HOME/_/work/
  directory_exists_with_spaces $USER_HOME/_/work/
  chown $SUDO_USER:$SUDO_USER $USER_HOME/_/work/
  touch $USER_HOME/_/work/requestedfiletoopen.log
  file_exists_with_spaces $USER_HOME/_/work/requestedfiletoopen.log
  chown $SUDO_USER:$SUDO_USER -R $USER_HOME/_/work/requestedfiletoopen.log
  file_exists_with_spaces "$USER_HOME/_/software/nano/bin/nano-open.sh"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/_/software/nano/bin/nano-open.sh"
  chmod +x $USER_HOME/_/software/nano/bin/nano-open.sh

 cat << EOF > $USER_HOME/.local/share/mime/packages/application-x-nano.xml
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-nano">
    <comment>new mime type</comment>
    <glob pattern="*.x-nano;*.rb;*.html;*.html.erb;*.js.erb;*.html.haml;*.js.haml;*.erb;*.haml;*.js"/>
  </mime-type>
</mime-info>
EOF
  file_exists_with_spaces "$USER_HOME/.local/share/mime/packages/application-x-nano.xml"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/.local/share/mime/packages/application-x-nano.xml"




  cat << EOF > $USER_HOME/.local/share/applications/gnu-nano.desktop
# $USER_HOME/.local/share/applications/gnu-nano.desktop
[Desktop Entry]
Encoding=UTF-8
Version=2020.2
Type=Application
Name=nano
Icon=$USER_HOME/_/software/nano/bin/nano.svg
Exec="$USER_HOME/_/software/nano/bin/nano.sh" %f
MimeType=application/x-nano;text/x-nano;text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;x-directory/normal;inode/directory;
Comment=The Most Intelligent Php IDE
Categories=Development;IDE;
Terminal=true
StartupWMClass=gnu-nano
EOF
  file_exists_with_spaces "$USER_HOME/.local/share/applications/gnu-nano.desktop"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/.local/share/applications/gnu-nano.desktop"


  cat << EOF > $USER_HOME/.local/share/applications/nano.mimeinfo.cache
# $USER_HOME/.local/share/applications/mimeinfo.cache

[MIME Cache]
x-scheme-handler/nano=nano-open.desktop;
EOF
  file_exists_with_spaces "$USER_HOME/.local/share/applications/nano.mimeinfo.cache"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/.local/share/applications/nano.mimeinfo.cache"

  cat << EOF > $USER_HOME/.local/share/applications/nano-open.desktop
# $USER_HOME/.local/share/applications/nano-open.desktop
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Terminal=true
Exec="$USER_HOME/_/software/nano/bin/nano-open.sh" %f
MimeType=application/nano;x-scheme-handler/nano;
Name=MineOpen
Comment=BetterErrors
EOF
  file_exists_with_spaces "$USER_HOME/.local/share/applications/nano-open.desktop"
  chown $SUDO_USER:$SUDO_USER -R "$USER_HOME/.local/share/applications/nano-open.desktop"

  # xdg-mime default gnu-nano.desktop text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;x-directory/normal;inode/directory;
  # xdg-mime default nano-open.desktop x-scheme-handler/nano
  # msg=$(_try "xdg-mime default nano-open.desktop x-scheme-handler/nano" )
  su - "${SUDO_USER}" -c "xdg-mime default nano-open.desktop x-scheme-handler/nano"
  su - "${SUDO_USER}" -c "xdg-mime default nano-open.desktop text/nano"
  su - "${SUDO_USER}" -c "xdg-mime default nano-open.desktop application/nano"
  su - "${SUDO_USER}" -c "xdg-mime default gnu-nano.desktop x-scheme-handler/x-nano"
  su - "${SUDO_USER}" -c "xdg-mime default gnu-nano.desktop text/x-nano"
  su - "${SUDO_USER}" -c "xdg-mime default gnu-nano.desktop application/x-nano"

#   cat << EOF > $USER_HOME/.config/mimeapps.list
#   cat << EOF > $USER_HOME/.local/share/applications/mimeapps.list
# [Default Applications]
# x-scheme-handler/nano=nano-open.desktop
# text/nano=nano-open.desktop
# application/nano=nano-open.desktop
# x-scheme-handler/x-nano=gnu-nano.desktop
# text/x-nano=gnu-nano.desktop
# application/x-nano=gnu-nano.desktop

# [Added Associations]
# x-scheme-handler/nano=nano-open.desktop;
# text/nano=nano-open.desktop;
# application/nano=nano-open.desktop;
# x-scheme-handler/x-nano=gnu-nano.desktop;
# text/x-nano=gnu-nano.desktop;
# application/x-nano=gnu-nano.desktop;
# EOF
#   file_exists_with_spaces "$USER_HOME/.local/share/applications/mimeapps.list"
#   file_exists_with_spaces "$USER_HOME/.config/mimeapps.list"
ln -fs "$USER_HOME/.config/mimeapps.list" "$USER_HOME/.local/share/applications/mimeapps.list"
softlink_exists_with_spaces "$USER_HOME/.local/share/applications/mimeapps.list>$USER_HOME/.config/mimeapps.list"
chown $SUDO_USER:$SUDO_USER -R  "$USER_HOME/.local/share/applications/mimeapps.list"

file_exists_with_spaces "$USER_HOME/_/software/nano/bin/nano-open.sh"

  su - "${SUDO_USER}" -c "xdg-mime query default x-scheme-handler/nano"
  su - "${SUDO_USER}" -c "xdg-mime query default x-scheme-handler/x-nano"
  su - "${SUDO_USER}" -c "xdg-mime query default text/x-nano"
  su - "${SUDO_USER}" -c "xdg-mime query default application/x-nano"
  su - "${SUDO_USER}" -c "xdg-mime query default text/nano"
  su - "${SUDO_USER}" -c "xdg-mime query default application/nano"
  msg=$(_try "su - \"${SUDO_USER}\" -c \"xdg-mime query default x-scheme-handler/nano\"")
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

  su - "${SUDO_USER}" -c "gio mime x-scheme-handler/nano"
  su - "${SUDO_USER}" -c "gio mime x-scheme-handler/x-nano"
  su - "${SUDO_USER}" -c "gio mime text/x-nano"
  su - "${SUDO_USER}" -c "gio mime application/x-nano"
  su - "${SUDO_USER}" -c "gio mime text/nano"
  su - "${SUDO_USER}" -c "gio mime application/nano"
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
    \$BetterErrors.editor = \"nano://open?file=%{file}:%{line}\"
    \$BetterErrors.editor = \"x-nano://open?file=%{file}:%{line}\"
  }
  "
} # end _fedora__64

_mingw__64() {
    local CODENAME=$(_version "win" "nano*.*.*.*.exe")
    # THOUGHT        local CODENAME="nano-4.3.3.24545.exe"
    local URL="https://www.nano-editor.org/dist/v5/${CODENAME}"
    cd $HOMEDIR
	  cd Downloads
    curl -O $URL
    ${CODENAME}
} # end _mingw__64

_mingw__32() {
    local CODENAME=$(_version "win" "nano*.*.*.*.exe")
    # THOUGHT        local CODENAME="nano-4.3.3.24545.exe"
    local URL="https://www.nano-editor.org/dist/v5/${CODENAME}"
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


