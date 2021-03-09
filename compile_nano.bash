#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
  export THISSCRIPTCOMPLETEPATH
  typeset -gr THISSCRIPTCOMPLETEPATH="$(basename "$0")"   # § This goes in the FATHER-MOTHER script
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
} # end sudo_it

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
   # Find the line like around line 35186 in mycase
   # add this line: $(aclocal --print-ac-dir)/pkg.m4
   # inside the string error output
  # run the ./configure again and it should output the place where it wants to find the
  # pkg.m4
  # for me it was:  /usr/local/Cellar/automake/1.16.3/share/aclocal/pkg.m4
  # now locate the pkg.m4: locate pkg.m4

  # I got several answers:
  # /Users/user/.cargo/registry/src/github.com-1ecc6299db9ec823/harfbuzz-sys-0.2.0/harfbuzz/m4/pkg.m4
  # /Users/user/.cargo/registry/src/github.com-1ecc6299db9ec823/mozjs_sys-0.51.3/mozjs/build/autoconf/pkg.m4
  # /Users/user/_/itch/emacs/m4/pkg.m4
  # /usr/local/Cellar/php/8.0.0_1/lib/php/build/pkg.m4
  # /usr/local/Cellar/php@7.4/7.4.13_1/lib/php/build/pkg.m4
  # /usr/local/Cellar/pkg-config/0.29.2_3/share/aclocal/pkg.m4
  #
  # now pick one.

  # In my case I checked the pkg-config version installed: pkg-config --version
  # So I got: 0.29.2

  # So I picked /usr/local/Cellar/pkg-config/0.29.2_3/share/aclocal/pkg.m4
  # and I copy that to the location where ./configure error is looking into

  # cp /usr/local/Cellar/pkg-config/0.29.2_3/share/aclocal/pkg.m4 /usr/local/Cellar/automake/1.16.3/share/aclocal/

  # Now try again from the autogen.sh script

  ./autogen.sh  --disable-dependency-tracking  --disable-wrapping-as-root --enable-color  --enable-debug  --enable-extra  --enable-libmagic  --enable-multibuffer  --enable-nanorc  --enable-speller  --enable-utf8  --prefix=/usr/local/opt  --sysconfdir=/usr/local/etc

  # Now try ./configure script

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

  # The resulting executable is located under for me: /usr/local/opt/bin/nano
  # Still need to link it

   ln -s  /usr/local/opt/bin/nano /usr/local/bin/nano

 #  if nano from Brew exsits then move it :

     mv /usr/local/bin/gnano /usr/local/bin/brewnano

  #   ls -la  /usr/local/bin/brewnano
  # lrwxr-xr-x  1 benutzer  admin  27 Dec 21 09:56 /usr/local/bin/brewnano -> ../Cellar/nano/5.4/bin/nano

  #  if your /usr/local/bin/ is in your path then /usr/local/bin/nano
  #   should be seen
  # which nano === /usr/local/bin/nano  correct
  # which nano === /usr/bin/nano   wrong

  # make sure that /usr/local/bin/nano points to -->  /usr/local/opt/bin/nano
  # and not to brew nano

  ls -la  /usr/local/bin/nano
  #  lrwxr-xr-x  1 benutzer  admin  27 Dec 21 09:56 /usr/local/bin/nano -> ../Cellar/nano/5.4/bin/nano  wrong
  #  lrwxr-xr-x  1 benutzer  admin  23 Dec 26 15:20 /usr/local/bin/nano -> /usr/local/opt/bin/nano  correct

} # end _darwin__64

_ubuntu__64() {

  sudo_it
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home

  # install_nano.bash
  sudo add-apt-repository ppa:n-muench/programs-ppa
  sudo apt install nano
  sudo apt update nano

  enforce_variable_with_value USER_HOME "${USER_HOME}"
  local TARGET_URL=$(_get_dowload_target "https://www.nano-editor.org/dist/v5")
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  local CODENAME=$(basename "${TARGET_URL}")
  enforce_variable_with_value CODENAME "${CODENAME}"
  local DOWNLOADFOLDER="${USER_HOME}/Downloads"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  directory_exists_with_spaces "${DOWNLOADFOLDER}"
  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}" "${CODENAME}"

  cd "${DOWNLOADFOLDER}"
  tar -xvf "${CODENAME}"
  cd nano-*

  cat -n INSTALL | grep configure
  install_requirements "
    libncursesw5-dev
    groff
  "
  # sudo apt install libncursesw5-dev -y
  # sudo apt install groff -y
  ./install-sh
  ./autogen.sh
  ./configure
  make -j3 -B --debug
  make -j3
  sudo make install

  cd "${DOWNLOADFOLDER}"
  rm -rf nano-*
  # Make sure we are using nano we compiled and not the boring system nano
  nano --version
    # should match 5.2
  which nano
  # /usr/local/share/nano --version
  # sudo /usr/local/share/nano --version
  # sudo /usr/local/bin/nano --version
  # sudo mv /bin/nano /bin/nano_old
  # nano --version

  # REF: https://github.com/scopatz/nanorc
  # curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh
  wget https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh -O- | sh

  #
  # .nanorc
  # ~/.nano/
  # cp ~/.nano/javascript.nanorc ~/.nano/typescript.nanorc
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

    # PORT=3000
    # curl -X POST http://$HOST:$PORT -H "accept: application/json" -H "Content-Type: application/json" -d "{}"
    # curl -X POST http://$HOST:$PORT -H "accept: application/json" -H "Content-Type: application/json" -d "{"":"" }"
} # end _ubuntu__64

_ubuntu__32() {
  sudo_it
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home

    local CODENAME=$(_version "linux" "nano-*.*.*.*i386.deb")
    # THOUGHT local CODENAME="nano-4.3.3.24545_i386.deb"
    local URL="https://www.nano-editor.org/dist/v5/${CODENAME}"
    cd $USER_HOME/Downloads/
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
} # end _ubuntu__32

_fedora__32() {
  sudo_it
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home
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

_get_dowload_target(){
  # Sample call:
  #
  #  _get_dowload_target https://linux.dropbox.com/packages/fedora/
  #
  # VERBOSE=1
  local URL="${1}"   #           param order    varname    varvalue     sample_value
  enforce_parameter_with_value           1        URL      "${URL}"     "https://linux.dropbox.com/packages/fedora/"
  #
  #
  # (( VERBOSE )) && echo "CODEFILE=\"\"\"\$(wget --quiet --no-check-certificate  \"${URL}\" -O -  2>/dev/null)\"\"\""
  local CODEFILE="""$(wget --quiet --no-check-certificate  "${URL}" -O -  2>/dev/null )""" # suppress only wget download messages, but keep wget output for variable
  enforce_variable_with_value CODEFILE "${CODEFILE}"
  #
  #
  local CODELASTESTBUILD=$(_extract_version "${CODEFILE}")
  enforce_variable_with_value CODEFILE "${CODEFILE}"
  local TARGETNAME=$(echo -n "${CODELASTESTBUILD}" | grep "${PLATFORM}" | grep "${PLATFORM}" |  tail -1)
  enforce_variable_with_value TARGETNAME "${TARGETNAME}"
  echo -n "${URL}${TARGETNAME}"
  return 0
} # end _get_dowload_target

_extract_version(){
  echo "${*}" |  sed s/\>/\>\\n/g | sed "s/&apos;/\'/g" | sed 's/&nbsp;/ /g'  | grep "<a" | grep ".xz" | grep -v "xz.asc" | cut -d'"' -f2| sort | uniq | tail -1
} # end _extract_version


_fedora__64() {
  sudo_it
  [ $? -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  local TARGET_URL=$(_get_dowload_target "https://www.nano-editor.org/dist/v5/")
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  local CODENAME=$(basename "${TARGET_URL}")
  enforce_variable_with_value CODENAME "${CODENAME}"
  local DOWNLOADFOLDER="${USER_HOME}/Downloads"
  # VERBOSE=1
  (( VERBOSE )) && echo -n "${TARGET_URL}"
  (( VERBOSE )) && echo "DEBUG EXIT 0"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  (( VERBOSE )) && echo  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
  if it_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}" ; then
  {
    rm -rf "${DOWNLOADFOLDER}/${CODENAME}"
  }
  fi
  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
  (( VERBOSE )) && exit 0

  cd "${DOWNLOADFOLDER}"
  tar -xvf "${CODENAME}"
  [ $? -gt 0 ] && failed to untar: tar -xvf "${CODENAME}"

  local FOLDER="$(echo "${CODENAME}" | cuet ".tar.xz")"
  directory_exists_with_spaces "${FOLDER}"
  cd "${FOLDER}"

  ./configure
  [ $? -gt 0 ] && failed to ./configure
  make -j3
  [ $? -gt 0 ] && failed to make
  sudo make install
  [ $? -gt 0 ] && failed to make install

  cd "${DOWNLOADFOLDER}"
  rm -rf nano-*
  # Make sure we are using nano we compiled and not the boring system nano
  nano --version
  # should match 5.2
  which nano
  # REF: https://github.com/scopatz/nanorc
  wget https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh -O- | sh
  [ $? -gt 0 ] && failed to make wget scopatz script or running it
  return 0
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
  return 0
} # end _main

_main

echo ":)"


