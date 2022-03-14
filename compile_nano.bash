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
  # function _trap_on_error(){
  #   echo -e "\\n \033[01;7m*** ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m"
  #   exit 1
  # }
  # trap _trap_on_error ERR
  function _trap_on_int(){
    echo -e "\\n \033[01;7m*** INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n  INT ...\033[0m"
    exit 0
  }

  trap _trap_on_int INT

load_struct_testing(){
  # function _trap_on_error(){
  #   local -ir __trapped_error_exit_num="${2:-0}"
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
  #   exit 1
  # }
  # trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
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
    echo "Temp location ${_temp_dir}/struct_testing"
    source "${_temp_dir}/struct_testing"
    _err=$?
    [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. Occured while running 'source' err:$_err  \n \n  " && exit 1
    if  ! typeset -f passed >/dev/null 2>&1; then
      echo -e "\n \n  ERROR! Loading struct_testing. Passed was not loaded !!!  \n \n "
      exit 69;
    fi
    return $_err
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
  # USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)   # Get the caller's of sudo home dir LINUX
  enforce_variable_with_value USER_HOME "${USER_HOME}"
# }  # end _linux_prepare


# _linux_prepare

enforce_variable_with_value USER_HOME $USER_HOME
enforce_variable_with_value SUDO_USER $SUDO_USER
passed Caller user identified:$SUDO_USER
passed Home identified:$USER_HOME
directory_exists_with_spaces "$USER_HOME"


_darwin__64() {
  # Using homebrew seemed like the best choice so far
  # /usr/bin/curl --disable --globoff --show-error --user-agent Homebrew/2.6.2-222-g880eb2d\ \(Macintosh\;\ Intel\ Mac\ OS\ X\ 10.15.7\)\ curl/7.64.1 --header Accept-Language:\ en --retry 3 --location --silent --head --request GET https://homebrew.bintray.com/bottles/nano-5.4.catalina.bottle.tar.gz
  # tar xof /Users/benutzer/Library/Caches/Homebrew/downloads/91845ed41d14ccff1a66f16db7c7ec93f7d7958bb08be637dae24d2aa70a214d--nano-5.4.catalina.bottle.tar.gz -C /var/folders/8x/9phrghz97g38v9m8m6r59_0w0000gn/T/d20201221-96141-1fi6gd9
  # cp -pR /var/folders/8x/9phrghz97g38v9m8m6r59_0w0000gn/T/d20201221-96141-1fi6gd9/nano/. /usr/local/Cellar/nano
  # chmod -Rf +w /var/folders/8x/9phrghz97g38v9m8m6r59_0w0000gn/T/d20201221-96141-1fi6gd9
  if ! (su - "${SUDO_USER}" -c "brew install nano") ; then
  {
    local _orr=$?
    if ! (su - "${SUDO_USER}" -c "brew reinstall nano") ; then
    {
      _err=$?
      failed "- err: $_orr for su - \"${SUDO_USER}\" -c \"brew install nano\"    and  later also failed - err $_err for   su - \"${SUDO_USER}\" -c \"brew reinstall nano\"   "
      brew reinstall nano
      exit 1
    }
    fi
  }
  fi
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
  directory_exists_with_spaces "$USER_HOME"

  # install_nano.bash
  sudo add-apt-repository ppa:n-muench/programs-ppa
  sudo apt install nano
  sudo apt update nano
  install_requirements "linux" "
    curl
    wget
    libncurses-dev
    libncursesw5-dev
    groff
  "
  verify_is_installed "
    curl
    wget
  "
  _download_compile_install
    return 0
} # end _ubuntu__64

_ubuntu__32() {
    local CODENAME=$(_version "linux" "nano-*.*.*.*i386.deb")
    # THOUGHT local CODENAME="nano-4.3.3.24545_i386.deb"
    _download_compile_install
    #local URL="https://www.nano-editor.org/dist/v6/${CODENAME}"
    cd $USER_HOME/Downloads/
    _download "${URL}"
    sudo dpkg -i ${CODENAME}
} # end _ubuntu__32

_fedora__32() {
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  install_requirements "linux" "
    curl
    wget
    ncurses-devel
    tar
  "
  verify_is_installed "
    curl
    wget
    tar
  "
  _download_compile_install

  local CODENAME=$(_version "linux" "nano*.*.*.*.i386.rpm")
  # THOUGHT                          nano-4.3.3.24545.i386.rpm
  local TARGET_URL="https://www.nano-editor.org/dist/v6/${CODENAME}"
  local DOWNLOADFOLDER="$(_find_downloads_folder)"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  directory_exists_with_spaces "${DOWNLOADFOLDER}"
  cd "${DOWNLOADFOLDER}"
  # _download "${TARGET_URL}"
  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
  file_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
  ensure tar or "Canceling Install. Could not find tar command to execute unzip"

  # provide error handling , once learned goes here. Learn under if, once learned here.
  # Start loop while ERROR flag in case needs to try again, based on error
  _try "rpm --import https://www.nano-editor.org/dist/v6/RPM-GPG-KEY-nano"
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
  _download_compile_install
  return 0
} # end _fedora__32

_centos__64() {
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  directory_exists_with_spaces "$USER_HOME"
  install_requirements "linux" "
    curl
    wget
    ncurses-devel
    tar
  "
  verify_is_installed "
    curl
    wget
    tar
  "
  _download_compile_install
  return 0
} # end _centos__64

_get_dowload_target() {
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
  local _newURL=$(echo -n "${URL}" | sed 's/\/download.php//g')
  echo -n "${_newURL}${TARGETNAME}"
  return 0
} # end _get_dowload_target

_extract_version() {
  echo "${*}" |  sed s/\>/\>\\n/g | sed "s/&apos;/\'/g" | sed 's/&nbsp;/ /g'  | grep "<a" | grep ".xz" | grep -v "xz.asc" | cut -d'"' -f2| sort | uniq | tail -1
} # end _extract_version


_fedora__64() {
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  directory_exists_with_spaces "$USER_HOME"
  install_requirements "linux" "
    curl
    wget
    ncurses-devel
    tar
  "
  verify_is_installed "
    curl
    wget
    tar
  "
  _download_compile_install
  return 0
} # end _fedora__64

_download_compile_install() {
  # Sample use
  #   _download_compile_install
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  # local TARGET_URL=$(_get_dowload_target "https://www.nano-editor.org/dist/v6/")
  local TARGET_URL=$(_get_dowload_target "https://www.nano-editor.org/download.php")
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  local CODENAME=$(basename "${TARGET_URL}")
  enforce_variable_with_value CODENAME "${CODENAME}"
  local DOWNLOADFOLDER="$(_find_downloads_folder)"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  directory_exists_with_spaces "${DOWNLOADFOLDER}"
  # VERBOSE=1
  (( VERBOSE )) && echo "
  DOWNLOADFOLDER:$DOWNLOADFOLDER
  CODENAME:$CODENAME
  TARGET_URL:$TARGET_URL
  "
  enforce_contains "nano-" "${CODENAME}"
  enforce_contains ".tar.xz" "${CODENAME}"
  enforce_contains "https://www.nano-editor.org/dist/v" "${TARGET_URL}"
  enforce_contains "nano-" "${TARGET_URL}"
  enforce_contains ".tar.xz" "${TARGET_URL}"
  (( VERBOSE )) && echo "DEBUG EXIT 0"
  (( VERBOSE )) && exit 0
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
  _build_add_nanorc "${DOWNLOADFOLDER}" "${CODENAME}"  "${USER_HOME}"
  ensure nano or "Failed to install nano"
  rm -f "${DOWNLOADFOLDER}/${CODENAME}"
  file_does_not_exist_with_spaces "${DOWNLOADFOLDER}/${CODENAME}"
  return 0
} # end _download_and_install
_build_add_nanorc(){
  # Sample use
  #  _build_add_nanorc "${DOWNLOADFOLDER}" "${CODENAME}" "${USER_HOME}"
  local DOWNLOADFOLDER="${1}"
  local CODENAME="${2}"
  local USER_HOME="${3}"
  local FOLDER="$(echo "${CODENAME}" | sed 's/.tar.xz//g')"
  local VERSION="$(echo "${FOLDER}" | sed 's/nano-//g')"
  directory_exists_with_spaces "${FOLDER}"
  cd "${FOLDER}"
  ./configure
  [ $? -gt 0 ] && failed to ./configure
  make -j3
  [ $? -gt 0 ] && failed to make
  make install
  [ $? -gt 0 ] && failed to make install

  cd "${DOWNLOADFOLDER}"
  rm -rf nano-*
  mv  /usr/bin/nano /usr/bin/nano_old$(date +"%Y%m%d%H%M")  # military date format
  mv /usr/local/bin/nano /usr/local/bin/nano_old$(date +"%Y%m%d%H%M")  # military date format
  mv /usr/local/bin/nano_old$(date +"%Y%m%d%H%M")  /usr/local/bin/nano   # military date format
  cp /usr/local/bin/nano /usr/bin/nano
  # Make sure we are using nano we compiled and not the boring system nano

  verify_installed_version "/usr/bin/nano --version"  "${VERSION}"
  verify_installed_version "/usr/local/bin/nano --version"  "${VERSION}"
  # should match 5.2
  which nano
  # REF: https://github.com/scopatz/nanorc
  cd "${USER_HOME}"
  _do_not_downloadtwice https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh "${DOWNLOADFOLDER}"  install.sh
  # curl -O https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh
  file_exists_with_spaces "${DOWNLOADFOLDER}/install.sh"
  chown  "${SUDO_USER}" "${DOWNLOADFOLDER}/install.sh"
  chmod a+x "${DOWNLOADFOLDER}/install.sh"
  cd "${DOWNLOADFOLDER}"
  # bash "${DOWNLOADFOLDER}/install.sh"
  echo Install for user nanorc
  su - "${SUDO_USER}" -c "${DOWNLOADFOLDER}/install.sh"
  echo Install for user root
  "${DOWNLOADFOLDER}/install.sh"
  directory_exists_with_spaces "${USER_HOME}/.nano"
  chown -R "${SUDO_USER}" "${USER_HOME}/.nano"
  directory_exists_with_spaces "/root/.nano"
  file_exists_with_spaces "/root/.nanorc"
  cp "/root/.nanorc" "${USER_HOME}/.nanorc"
  file_exists_with_spaces "${USER_HOME}/.nanorc"
  chown  "${SUDO_USER}" "${USER_HOME}/.nanorc"
  [[ ! -e "/root/.nano/syntax"  ]] && git clone https://github.com/YSakhno/nanorc.git "/root/.nano/syntax"
  [[ ! -e "${USER_HOME}/.nano/syntax"  ]] && git clone https://github.com/YSakhno/nanorc.git "${USER_HOME}/.nano/syntax"
  chown -R "${SUDO_USER}" "${USER_HOME}/.nano"
  directory_exists_with_spaces "/root/.nano/syntax"
  directory_exists_with_spaces "${USER_HOME}/.nano/syntax"
  cd "${USER_HOME}/.nano/syntax"
  make install
  chown -R "${SUDO_USER}" "${USER_HOME}/.nano/syntax"
  cd "/root/.nano/syntax"
  make install
  echo Append missing definitions
  echo " " >> "/root/.nanorc"
  echo " " >> "${USER_HOME}/.nanorc"
  echo "set linenumbers" >> "/root/.nanorc"
  echo "set linenumbers" >> "${USER_HOME}/.nanorc"
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
  directory_exists_with_spaces "/root/.nano/syntax/build"
  directory_exists_with_spaces "${USER_HOME}/.nano/syntax/build"
  diff -q "${USER_HOME}/.nano/syntax/build" "${USER_HOME}/.nano" |grep "Only in" | grep "syntax" | grep ".nanorc" | cut -d":" -f2 | xargs -I {} echo "include \"~/.nano/syntax/build/{}\"" >> "${USER_HOME}/.nanorc"
  diff -q "/root/.nano/syntax/build" "/root/.nano" |grep "Only in" | grep "syntax" | grep ".nanorc" | cut -d":" -f2 | xargs -I {} echo "include \"~/.nano/syntax/build/{}\"" >> "/root/.nanorc"
  which nano
  nano --version
  return 0
} # end _build_add_nanorc
_mingw__64() {
    local CODENAME=$(_version "win" "nano*.*.*.*.exe")
    # THOUGHT        local CODENAME="nano-4.3.3.24545.exe"
    local URL="https://www.nano-editor.org/dist/v6/${CODENAME}"
    cd $HOMEDIR
    cd Downloads
    curl -O $URL
    ${CODENAME}
} # end _mingw__64

_mingw__32() {
    local CODENAME=$(_version "win" "nano*.*.*.*.exe")
    # THOUGHT        local CODENAME="nano-4.3.3.24545.exe"
    _download_compile_install
    local URL="https://www.nano-editor.org/dist/v6/${CODENAME}"
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


