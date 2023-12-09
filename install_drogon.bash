#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
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
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
    local provider="$HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    local _err=0 structsource
    if [   -e "${provider}"  ] ; then
      (( DEBUG )) && echo "$0 tasks_base/load_struct_testing Loading locally"
      structsource="""$(<"${provider}")"""
      _err=$?
      [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. running 'source locally' returned error did not download or is empty err:$_err  \n \n  " && exit 1
    else
      if ( command -v curl >/dev/null 2>&1; )  ; then
        (( DEBUG )) && echo "$0 tasks_base/load_struct_testing curl Loading struct_testing from the net using curl "
        structsource="""$(curl https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing  -so -   2>/dev/null )"""  #  2>/dev/null suppress only curl download messages, but keep curl output for variable
        _err=$?
        [ $_err -gt 0 ] &&  echo -e "\n \n  ERROR! Loading struct_testing. running 'curl' returned error did not download or is empty err:$_err  \n \n  " && exit 1
      elif ( command -v wget >/dev/null 2>&1; ) ; then
        (( DEBUG )) && echo "$0 tasks_base/load_struct_testing wget Loading struct_testing from the net using wget "
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
    (( DEBUG )) && echo "$0 tasks_base/load_struct_testing  Temp location ${_temp_dir}/struct_testing"
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



 #---------/\/\/\-- tasks_base/load_struct_testing -------------/\/\/\--------





 #--------\/\/\/\/-- tasks_templates_sudo/drogon …install_drogon.bash” -- Custom code -\/\/\/\/-------


#!/usr/bin/bash

_debian_flavor_install() {
  sudo apt install git gcc g++ cmake libjsoncpp-dev uuid-dev openssl libssl-dev zlib1g-dev -y
  echo "Procedure not yet implemented. I don't know what to do."
} # end _debian_flavor_install

_redhat_flavor_install() {
  sudo dnf install git gcc gcc-c++ cmake libuuid-devel openssl-devel zlib-devel  -y
  cd $USER_HOME
	git clone https://github.com/drogonframework/drogon 
  cd drogon
  git submodule update --init
  mkdir build
  cd build
	cmake ..
  make && sudo make install
  echo "WIP."
} # end _redhat_flavor_install

_arch_flavor_install() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _readhat_flavor_install

_gentoo_flavor_install(){
  sudo emerge dev-vcs/git jsoncpp ossp-uuid openssl -y
  echo "Procedure not yet implemented. I don't know what to do."

}

_arch__32() {
  _arch_flavor_install
} # end _arch__32

_arch__64() {
  _arch_flavor_install
} # end _arch__64

_centos__32() {
  _redhat_flavor_install
} # end _centos__32

_centos__64() {
  _redhat_flavor_install
} # end _centos__64

_debian__32() {
  _debian_flavor_install
} # end _debian__32

_debian__64() {
  _debian_flavor_install
} # end _debian__64

_fedora__32() {
  _redhat_flavor_install
} # end _fedora__32

_fedora__64() {
  _redhat_flavor_install
} # end _fedora__64


_gentoo__32() {
  sudo emerge dev-vcs/git jsoncpp ossp-uuid openssl
  
  _gentoo_flavor_install
} # end _gentoo__32

_gentoo__64() {
  sudo emerge dev-vcs/git jsoncpp ossp-uuid openssl
  _gentoo_flavor_install
} # end _gentoo__64

_fundoo__64() {
  sudo emerge dev-vcs/git jsoncpp ossp-uuid openssl
  _gentoo_flavor_install
} # end _fundoo__64

_fundoo__32() {
  sudo emerge dev-vcs/git jsoncpp ossp-uuid openssl
  _gentoo_flavor_install
} # end _fundoo__32


_madriva__32() {
  _redhat_flavor_install
} # end _madriva__32

_madriva__64() {
  _redhat_flavor_install
} # end _madriva__64

_suse__32() {
  _redhat_flavor_install
} # end _suse__32

_suse__64() {
  _redhat_flavor_install
} # end _suse__64

_ubuntu__32() {
  _debian_flavor_install
} # end _ubuntu__32

_ubuntu__64() {
  cd $USER_HOME
	git clone https://github.com/drogonframework/drogon 
  cd drogon
  git submodule update --init
  mkdir build
  cd build
  sudo apt-get install -y  apt-utils tzdata dirmngr gnupg2 lsb-release sudo 
  sudo apt-get install -y  build-essential autoconf automake cmake  curl wget gcc g++ git libtool gzip make unzip mc  \
                        lsb-release wgetpkg-config libboost-all-dev  libjsoncpp-dev libconfig++-dev  libprotobuf-dev \
                        protobuf-compiler libgrpc++-dev libgrpc++1 libgrpc-dev protobuf-compiler-grpc

  sudo apt install cmake -vy
  sudo apt-get install cmake -vy
  sudo apt-get install gddrescue -y
  sudo apt-get install cmake -y
  sudo apt install gcc -y
  sudo apt install g++ -y
  sudo apt install libjsoncpp-dev -y
  sudo apt install libjsoncpp -y
  sudo apt install uuid-dev -y
  sudo apt install libssl-dev -y
  sudo apt install zlib1g-dev -y
  sudo apt install zlib1g -y
  sudo apt-get install postgresql-all -y
  sudo apt-get install postgresql-server-dev -y
  sudo apt install libmariadbclient-dev -y
  sudo apt install libmariadb-dev-compat -y
  sudo apt-get install libsqlite3-dev -y
  sudo apt-get install libhiredis-dev -y
  sudo apt-get install cmake  -y
  sudo apt-get install libhiredis-dev -y
  sudo apt-get install libsqlite3-dev -y
  sudo apt install git gcc g++ cmake libjsoncpp-dev uuid-dev openssl libssl-dev zlib1g-dev -y
  cmake ..
  make && sudo make install
} # end _ubuntu__64

_darwin__arm64() {
  _darwin__64
} # end _darwin__arm64

_darwin__64() {
  Comment 'REF: https://terminalroot.com/drogon-cpp-the-fastest-web-framework-in-the-world/'
  export HOMEBREW_NO_AUTO_UPDATE=1
  export HOMEBREW_PREFIX=/usr/local
  brew install jsoncpp
  brew install libcpuid
  brew install ossp-uuid
  brew install openssl
  brew install zlib
  brew install --build-from-source  --HEAD  zlib
  brew install hiredis
  brew install cmake
  brew install g++
  brew install gpp
  brew install gcc 
  brew install git
  brew install  mongo-c-driver
  brew install  mongo-cxx-driver
  brew install --build-from-source  --HEAD  mongo-c-driver
  brew install --build-from-source  --HEAD  mongo-cxx-driver
  brew install   protobuf-c
  brew install grpc
  brew install googletest
  git clone https://github.com/an-tao/drogon
  cd drogon
  git submodule update --init
  mkdir -p build
  cd build
  make clean
  
  # cmake ..
  # REF: https://github.com/eulerto/pgquarrel/issues/27
  # Fix for -- Could NOT find PostgreSQL (missing: PostgreSQL_INCLUDE_DIR)
  # Fix for -- Could NOT find pg (missing: PG_LIBRARIES PG_INCLUDE_DIRS)
  export PostgreSQL_INCLUDE_DIR=/usr/local/opt/postgresql@12/include
  export PG_LIBRARIES=/usr/local/opt/postgresql@12/lib
  export PG_INCLUDE_DIRS=/usr/local/opt/postgresql@12/include
  cmake -DCMAKE_PREFIX_PATH=/usr/local/opt/postgresql@12 ..

  make && sudo make install

} # end _darwin__64

_tar() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end tar

_windows__64() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _windows__64

_windows__32() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _windows__32



 #--------/\/\/\/\-- tasks_templates_sudo/drogon …install_drogon.bash” -- Custom code-/\/\/\/\-------


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo "🥦"
exit 0
