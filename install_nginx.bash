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
    #echo -e "\\n \033[01;7m*** ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m"
    local cero="$0"
    local file1="$(paeth ${BASH_SOURCE})"
    local file2="$(paeth ${cero})"
    echo -e "ERROR TRAP $THISSCRIPTNAME
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
ERR ..."
    exit 1
  }
  trap _trap_on_error ERR
  function _trap_on_int(){
    # echo -e "\\n \033[01;7m*** INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n  INT ...\033[0m"
    local cero="$0"
    local file1="$(paeth ${BASH_SOURCE})"
    local file2="$(paeth ${cero})"
    echo -e "INTERRUPT TRAP $THISSCRIPTNAME
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
INT ..."
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
    if [[ -z "${1}" ]] ; then
    {
       echo "Must call with name of library example: struct_testing execute_command"
       exit 1
    }
    fi
    trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
      local provider="$HOME/_/clis/execute_command_intuivo_cli/${_library}"
      local _err=0 structsource
      if [   -e "${provider}"  ] ; then
        if (( DEBUG )) ; then
          echo "$0: tasks_base/sudoer.bash Loading locally"
        fi
        structsource="""$(<"${provider}")"""
        _err=$?
        if [ $_err -gt 0 ] ; then
        {
           echo -e "\n \n  ERROR! Loading ${_library}. running 'source locally' returned error did not download or is empty err:$_err  \n \n  " 
           exit 1
        }
        fi
      else
        if ( command -v curl >/dev/null 2>&1; )  ; then
          if (( DEBUG )) ; then
            echo "$0: tasks_base/sudoer.bash Loading ${_library} from the net using curl "
          fi
          structsource="""$(curl https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/${_library}  -so -   2>/dev/null )"""  #  2>/dev/null suppress only curl download messages, but keep curl output for variable
          _err=$?
          if [ $_err -gt 0 ] ; then
          {
            echo -e "\n \n  ERROR! Loading ${_library}. running 'curl' returned error did not download or is empty err:$_err  \n \n  "
            exit 1
          }
          fi
        elif ( command -v wget >/dev/null 2>&1; ) ; then
          if (( DEBUG )) ; then
            echo "$0: tasks_base/sudoer.bash Loading ${_library} from the net using wget "
          fi
          structsource="""$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/${_library} -O -   2>/dev/null )"""  #  2>/dev/null suppress only wget download messages, but keep wget output for variable
          _err=$?
          if [ $_err -gt 0 ] ; then
          {
            echo -e "\n \n  ERROR! Loading ${_library}. running 'wget' returned error did not download or is empty err:$_err  \n \n  "
            exit 1
          }
          fi
        else
          echo -e "\n \n  ERROR! Loading ${_library} could not find wget or curl to download  \n \n "
          exit 69
        fi
      fi
      if [[ -z "${structsource}" ]] ; then
      {
        echo -e "\n \n  ERROR! Loading ${_library} into ${_library}_source did not download or is empty " 
        exit 1
      }
      fi
      local _temp_dir="$(mktemp -d 2>/dev/null || mktemp -d -t "${_library}_source")"
      echo "${structsource}">"${_temp_dir}/${_library}"
      if (( DEBUG )) ; then
        echo "$0: tasks_base/sudoer.bash Temp location ${_temp_dir}/${_library}"
      fi
      source "${_temp_dir}/${_library}"
      _err=$?
      if [ $_err -gt 0 ] ; then
      {
        echo -e "\n \n  ERROR! Loading ${_library}. Occured while running 'source' err:$_err  \n \n  "
        exit 1
      }
      fi
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
if [ $_err -ne 0 ] ; then
{
  echo -e "\n \n  ERROR FATAL! load_struct_testing_wget !!! returned:<$_err> \n \n  "
  exit 69;
}
fi

export sudo_it
function sudo_it() {
  raise_to_sudo_and_user_home
  local _err=$?
  if (( DEBUG )) ; then
    Comment _err:${_err}
  fi
  if [ $_err -gt 0 ] ; then
  {
    failed to sudo_it raise_to_sudo_and_user_home
    exit 1
  }
  fi
  # [ $_err -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
  _err=$?
  if (( DEBUG )) ; then
    Comment _err:${_err}
  fi
  enforce_variable_with_value SUDO_USER "${SUDO_USER}"
  enforce_variable_with_value SUDO_UID "${SUDO_UID}"
  enforce_variable_with_value SUDO_COMMAND "${SUDO_COMMAND}"
  # Override bigger error trap  with local
  function _trap_on_err_int(){
    # echo -e "\033[01;7m*** ERROR OR INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR INT ...\033[0m"
    local cero="$0"
    local file1="$(paeth ${BASH_SOURCE})"
    local file2="$(paeth ${cero})"
    echo -e " ERROR OR INTERRUPT  TRAP $THISSCRIPTNAME
${file1}:${BASH_LINENO[-0]}     \t ${FUNCNAME[-0]}()
$file2:${BASH_LINENO[1]}    \t ${FUNCNAME[1]}()
ERR INT ..."
    exit 1
  }
  trap _trap_on_err_int ERR INT
} # end sudo_it

# _linux_prepare(){
  sudo_it
  _err=$?
  if (( DEBUG )) ; then
    Comment _err:${_err}
  fi
  if [ $_err -gt 0 ] ; then
  {
    failed to sudo_it raise_to_sudo_and_user_home
    exit 1
  }
  fi
  # [ $_err -gt 0 ] && failed to sudo_it raise_to_sudo_and_user_home && exit 1
  _err=$?
  if (( DEBUG )) ; then
    Comment _err:${_err}
  fi
  # [ $? -gt 0 ] && (failed to sudo_it raise_to_sudo_and_user_home  || exit 1)
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
if (( DEBUG )) ; then
  passed "Caller user identified:${SUDO_USER}"
fi
  if (( DEBUG )) ; then
    Comment DEBUG_err?:${?}
  fi
if (( DEBUG )) ; then
  passed "Home identified:${USER_HOME}"
fi
  if (( DEBUG )) ; then
    Comment DEBUG_err?:${?}
  fi
directory_exists_with_spaces "${USER_HOME}"



 #---------/\/\/\-- tasks_base/sudoer.bash -------------/\/\/\--------





 #--------\/\/\/\/-- tasks_templates_sudo/nginx …install_nginx.bash” -- Custom code -\/\/\/\/-------


#!/bin/bash

_extract_version() {
  # Extracts a version from a list of published gnu style folder a links
  # and returns it direcctly
  # Sample usage
  #
  #   local CODELASTESTBUILD=$(_extract_version "nginx-" "tar.gz" "${CODEFILE}")
  #   (( VERBOSE )) && echo "CODELASTESTBUILD:${CODELASTESTBUILD}"
  #   enforce_variable_with_value CODELASTESTBUILD "${CODELASTESTBUILD}"
  #
  local prefix_name="${1}"  #           param order    varname        varvalue            sample_value
  enforce_parameter_with_value           1             prefix_name    "${prefix_name}"     "nginx-"
  local zip_type="${2}"     #           param order    varname        varvalue            sample_value
  enforce_parameter_with_value           2             zip_type       "${zip_type}"        "tar.gz"
  # BASH scripting sorting by date REF: https://stackoverflow.com/questions/10041703/bash-scripting-sorting-by-date
  # local get_list="$(echo "${*}" | sed s/\>/\>\\n/g | sed "s/&apos;/\'/g" | sed 's/&nbsp;/ /g'  | grep "<a" | grep ".${zip_type}" | grep -v "${zip_type}.asc" | cut -d'"' -f2  | sed 's/'"${prefix_name}"'//g' | sed 's/.'"${zip_type}"'//g' | awk -F "${prefix_name}" '{print $2}' | sed 's/\///g')"
  # BASH scripting sorting by date REF: https://stackoverflow.com/questions/10041703/bash-scripting-sorting-by-date
  if [[ "${prefix_name}" == 'nginx-' ]] ; then
  {
    echo "${*}" | sed s/\>/\>\\n/g | sed "s/&apos;/\'/g" | sed 's/&nbsp;/ /g'  \
    | grep "<a" | grep ".${zip_type}" | grep -v "${zip_type}.asc" | cut -d'"' -f2  \
    | sed 's/'"${prefix_name}"'//g' | sed 's/.'"${zip_type}"'//g' \
    | while IFS=\. read -r item price date ; \
    do printf '%s|%s|%s|%s\n' "$(( item * 1000000 ))"  \
    "$(( price * 1000 ))" \
    "$(( date * 1 ))" \
    "$item.$price.$date"  ; done \
    |  while IFS=\| read -r item price date was ; \
    do printf '%s|%s\n' "$(( item  + price + date ))" "$was" ; done \
    | sort -n -t\| | cut -d\| -f2- | tail -1
    return 0
  }
  fi
  if [[ "${prefix_name}" == 'pcre2-' ]] ; then
  {
  # VERBOSE=1
  # | grep ".${zip_type}" | grep -v "${zip_type}.asc|${zip_type}.sig"  | cut -d'"' -f2  \
  # | sed 's/'"${prefix_name}"'//g' | sed 's/.'"${zip_type}"'//g' \

  local get_list="$(echo "${*}" | sed s/\>/\>\\n/g | sed "s/&apos;/\'/g" | sed 's/&nbsp;/ /g' \
    | grep "<a" | cut -d'"' -f2 | grep "archive/refs/tags" \
    | awk -F "tags/" '{print $2}' | grep -v '\-RC' | sed 's/\///g' \
    | grep ".${zip_type}" \
     )"
  }
  fi
  if [[ "${prefix_name}" == 'openssl-' ]] ; then
  {
    local get_list="$(echo "${*}" | sed s/\>/\>\\n/g | sed "s/&apos;/\'/g" | sed 's/&nbsp;/ /g' \
    | grep "<a" | cut -d'"' -f2 | grep "${prefix_name}" | grep ".${zip_type}" \
    | grep -v "${zip_type}.asc" | grep -v "${zip_type}.sha" \
    )"
    (( VERBOSE )) && echo "get_list:${get_list}"
  }
  fi
  if [[ "${prefix_name}" == 'openssl-1' ]] ; then
  {
    local get_list="$(echo "${*}" | sed s/\>/\>\\n/g | sed "s/&apos;/\'/g" | sed 's/&nbsp;/ /g' \
    | grep "<a" | cut -d'"' -f2 | grep "${prefix_name}" | grep ".${zip_type}" \
    | grep -v "${zip_type}.asc" | grep -v "${zip_type}.sha" \
    )"
    (( VERBOSE )) && echo "get_list:${get_list}"
  }
  fi
  (( VERBOSE )) && echo "get_list:${get_list}"
  enforce_variable_with_value get_list "${get_list}"
  local one=''
  local just_number=''
  local only_dots=''
  local -i one_count
  local list_new=""

    while read -r one ; do
    {
      [ -z ${one} ] && continue
      just_number="$(sed 's/'"${prefix_name}"'//g'<<<"${one}" | sed 's/m.'"${zip_type}"'//g' | sed 's/.'"${zip_type}"'//g' )"
      [ -z ${just_number} ] && continue
      (( VERBOSE )) && echo "one:${one}"
      (( VERBOSE )) && echo "just_number:${just_number}"
      only_dots="${just_number//[^.]}"
      one_count="${#only_dots}"
      [ -z ${one_count} ] && continue
      [ ${one_count} -lt 1 ] && continue
      if [ ${one_count} -eq  1 ] ; then
      {
        list_new="${list_new}
$(echo "${just_number}" | while IFS=\. read -r price date ; do printf '%s|%s|%s|%s\n' "$(( 1000000 ))"  "$(( price * 1000 ))" "$(( date * 1 ))" "$one"  ; done)"
      }
      fi
      if [ ${one_count} -eq  2 ] ; then
      {
        list_new="${list_new}
$(echo "${just_number}" | while IFS=\. read -r item price date ; do printf '%s|%s|%s|%s\n' "$(( item * 1000000 ))"  "$(( price * 1000 ))" "$(( date * 1 ))" "$one"  ; done)"
      }
      fi
      (( VERBOSE )) && echo "list_new:...<${list_new}>..."
    }
    done <<< "${get_list}"
    (( VERBOSE )) && echo "out loop list_new:...<${list_new}>..."
    # Expected to have a list a like this
    #     echo "1000000|10000|39|pcre2-10.39.tar.gz
    # 1000000|10000|38|pcre2-10.38.tar.gz
    # 1000000|10000|37|pcre2-10.37.tar.gz
    # 1000000|10000|36|pcre2-10.36.tar.gz
    # 1000000|10000|35|pcre2-10.35.tar.gz
    # 1000000|10000|34|pcre2-10.34.tar.gz
    # 1000000|10000|33|pcre2-10.33.tar.gz
    # 1000000|10000|32|pcre2-10.32.tar.gz
    # 1000000|10000|31|pcre2-10.31.tar.gz"
    # ... Then the bottom commands
    # |  while IFS=\| read -r item price date was ; do printf '%s|%s\n' "$(( item  + price + date ))"  "$was" ; done
    # ...Expected to get a new list like this
    # 1010039|pcre2-10.39.tar.gz
    # 1010038|pcre2-10.38.tar.gz
    # 1010037|pcre2-10.37.tar.gz
    # 1010036|pcre2-10.36.tar.gz
    # 1010035|pcre2-10.35.tar.gz
    # 1010034|pcre2-10.34.tar.gz
    # 1010033|pcre2-10.33.tar.gz
    # 1010032|pcre2-10.32.tar.gz
    # 1010031|pcre2-10.31.tar.gz
    # | sort -n -t\| ...sort it numerically
    # | cut -d\| -f2-  .. take only the second term
    # | tail -1  ... get the last one   # ...expected something like this:pcre2-10.39.tar.gz
    # | sed 's/'"pcre2-"'//g' ... remove prefix
    # | sed 's/.'"tar.gz"'//g'  ... remove suffix   # ..expected something like:10.39
    # ...expected 10.39 as end result
    echo "${list_new}" |  while IFS=\| read -r item price date was ; do printf '%s|%s\n' "$(( item  + price + date ))" "$was" ; done \
    | sort -n -t\| | cut -d\| -f2- | tail -1 \
    | sed 's/'"${prefix_name}"'//g' | sed 's/.'"${zip_type}"'//g'
    return 0
} # end _extract_version

_get_dowload_target() {
  # Makes wget call to URL and call extract_version to get latestest url from the list and reconstruct url of latest version
  # and returns it directly
  #
  # Sample call:
  #
  #    local TARGET_URL=$(_get_dowload_target "nginx-" "tar.gz"  "https://nginx.org/download/")
  #    (( VERBOSE )) && echo "TARGET_URL:${TARGET_URL}"
  #    enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  #
  # VERBOSE=1
  local prefix_name="${1}"  #           param order    varname        varvalue            sample_value
  enforce_parameter_with_value           1             prefix_name    "${prefix_name}"     "nginx-"
  local zip_type="${2}"     #           param order    varname        varvalue            sample_value
  enforce_parameter_with_value           2             zip_type       "${zip_type}"        "nginx-"
  local URL="${3}"          #           param order    varname        varvalue            sample_value
  enforce_parameter_with_value           3             URL            "${URL}"             "https://nginx.org/download/"
  local optional_download_url_change="${4}"  # ${optional_download_url_change}
  #
  #
  (( VERBOSE )) && echo "CODEFILE=\"\"\"\$(wget --quiet --no-check-certificate  \"${URL}\" -O -  2>/dev/null)\"\"\""
  local CODEFILE="""$(wget --quiet --no-check-certificate  "${URL}" -O -  2>/dev/null )""" # suppress only wget download messages, but keep wget output for variable
  enforce_variable_with_value CODEFILE "${CODEFILE}"
  #
  #
  local CODELASTESTBUILD=$(_extract_version "${prefix_name}" "${zip_type}" "${CODEFILE}")
  (( VERBOSE )) && echo "CODELASTESTBUILD:${CODELASTESTBUILD}"
  enforce_variable_with_value CODELASTESTBUILD "${CODELASTESTBUILD}"

   # Expecting "https://nginx.org/download/nginx-X.X.X.nginx-"
  local _newURL="${URL}${prefix_name}${CODELASTESTBUILD}.${zip_type}"
  if [[ -n "${optional_download_url_change}" ]] ; then
  {
    if [[ "${optional_download_url_change}" == *"github.com"* ]]  ; then
    {
      # From https://github.com/PhilipHazel/pcre2/releases
      # Expecting https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.39/pcre2-10.39.tar.gz
      _newURL="${optional_download_url_change}${prefix_name}${CODELASTESTBUILD}/${prefix_name}${CODELASTESTBUILD}.${zip_type}"
    }
    else
    {
      # Expecting https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.39.tar.gz
      _newURL="${optional_download_url_change}${prefix_name}${CODELASTESTBUILD}.${zip_type}"
    }
    fi
  }
  fi
  (( VERBOSE )) && echo "_newURL:${_newURL}"
  echo -n "${_newURL}"
  return 0
} # end _get_dowload_target

_download_compile_install() {
  # Downloads and compiles certain package with make provided prefix_name zip_type and URL where to look for versions
  #
  # Sample use
  #   _download_compile_install "pcre2-" "tar.gz"  "https://github.com/PhilipHazel/pcre2/releases" "${DOWNLOADFOLDER}" "https://github.com/PhilipHazel/pcre2/releases/download/"
  #   _download_compile_install "nginx-" "tar.gz"  "https://nginx.org/download/" "${DOWNLOADFOLDER}"
  #
  # VERBOSE=1
  local prefix_name="${1}"  #           param order    varname        varvalue            sample_value
  enforce_parameter_with_value           1             prefix_name    "${prefix_name}"     "nginx-"
  local zip_type="${2}"     #           param order    varname        varvalue            sample_value
  enforce_parameter_with_value           2             zip_type       "${zip_type}"        "tar.gz"
  local URL="${3}"          #           param order    varname        varvalue            sample_value
  enforce_parameter_with_value           3             URL            "${URL}"             "https://nginx.org/download/"
  local DOWNLOADFOLDER="${4}" #         param order    varname        varvalue            sample_value
  enforce_parameter_with_value           4             DOWNLOADFOLDER "${DOWNLOADFOLDER}"  "${USER_HOME}/_/software/nginx"
  directory_exists_with_spaces "${DOWNLOADFOLDER}"
  local optional_download_url_change="${5}" #         param order    varname        "${optional_download_url_change}"            sample_value

  enforce_variable_with_value USER_HOME "${USER_HOME}"
  local TARGET_URL=$(_get_dowload_target "${prefix_name}" "${zip_type}"  "${URL}"  "${optional_download_url_change}"  )
  # VERBOSE=1
  (( VERBOSE )) && echo "TARGET_URL:${TARGET_URL}"
  enforce_variable_with_value TARGET_URL "${TARGET_URL}"
  local CODENAME=$(basename "${TARGET_URL}")
  (( VERBOSE )) && echo "CODENAME:${CODENAME}"
  enforce_variable_with_value CODENAME "${CODENAME}"

  local _version="$(sed 's/'"${prefix_name}"'//g' <<< "${CODENAME}" | sed 's/.'"${zip_type}"'//g' )"
  (( VERBOSE )) && echo "
  DOWNLOADFOLDER:$DOWNLOADFOLDER
  CODENAME:$CODENAME
  _version:$_version
  TARGET_URL:$TARGET_URL
  "
  enforce_contains "${prefix_name}" "${CODENAME}"
  enforce_contains ".${zip_type}" "${CODENAME}"
  enforce_contains "${URL}" "${TARGET_URL}"
  enforce_contains "${prefix_name}" "${TARGET_URL}"
  enforce_contains ".${zip_type}" "${TARGET_URL}"
  (( VERBOSE )) && echo  _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
  if ! it_exists_with_spaces "${DOWNLOADFOLDER}/${CODENAME}" ; then
  {
    # rm -rf "${DOWNLOADFOLDER}/${CODENAME}"
    _do_not_downloadtwice "${TARGET_URL}" "${DOWNLOADFOLDER}"  "${CODENAME}"
    # VERBOSE=1
    if ! it_exists_with_spaces "${DOWNLOADFOLDER}/${prefix_name}${_version}" ; then
    {
      _untar_gz_download  "${DOWNLOADFOLDER}"   "${DOWNLOADFOLDER}/${CODENAME}"
    }
    fi
  }
  fi
  cd "${DOWNLOADFOLDER}/${prefix_name}${_version}"
  cd "${DOWNLOADFOLDER}"
  echo "${prefix_name}${_version}"
  # beatfactor/install_nginx_macos_source.md REF: https://gist.github.com/beatfactor/a093e872824f770a2a0174345cacf171

} # end _download_and_install

_debian_flavor_install() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _debian_flavor_install

_redhat_flavor_install() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _redhat_flavor_install

_arch_flavor_install() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _readhat_flavor_install

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
  _redhat_flavor_install
} # end _gentoo__32

_gentoo__64() {
  _redhat_flavor_install
} # end _gentoo__64

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
  _debian_flavor_install
} # end _ubuntu__64


_darwin__64() {
  failed "error this was made in sed for linux to it will not work on mac sed "
  return 1
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  install_requirements "darwin" "
    curl
    wget
    # ncurses-devel
    # tar
  "
  verify_is_installed "
    curl
    wget
    tar
  "
  enforce_variable_with_value USER_HOME "${USER_HOME}"
  # local DOWNLOADFOLDER="$(_find_downloads_folder)"
  Checking "Doing : openssl1:--- start ---"

  local DOWNLOADFOLDER="${USER_HOME}/_/software/openssl"
  (( VERBOSE )) && echo "DOWNLOADFOLDER:${DOWNLOADFOLDER}"
  Checking "1 DOWNLOADFOLDER:${DOWNLOADFOLDER}"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  mkdir -p "${DOWNLOADFOLDER}"
  directory_exists_with_spaces "${DOWNLOADFOLDER}"
  VERBOSE=0
  local openssl1=''
  if (( ! VERBOSE )) ; then
  {
    openssl1=$(_download_compile_install "openssl-" "m.tar.gz"  "https://www.openssl.org/source/" "${DOWNLOADFOLDER}" | tail -1)
    _err=$?
  } 
  else 
  {
    (( VERBOSE )) && 
    openssl1=$(_download_compile_install "openssl-" "m.tar.gz"  "https://www.openssl.org/source/" "${DOWNLOADFOLDER}" )
    _err=$?
  }
  fi
  Checking "openssl1:--- start ---"
  Checking "openssl1:${openssl1}"
  Checking "openssl1:--- end -----"
  Checking "Doing : openssl1:--- end ---"
  if [ $_err -gt 0 ] || [[ "${openssl1}" == *"KILL EXECUTION"* ]]; then
  {
    return 1
  }
  fi 

  local DOWNLOADFOLDER="${USER_HOME}/_/software/pcre2"
  (( VERBOSE )) && echo "DOWNLOADFOLDER:${DOWNLOADFOLDER}"
  (( VERBOSE )) && echo "VERBOSE"
  (( VERBOSE )) && return 0
  Checking "2 DOWNLOADFOLDER:${DOWNLOADFOLDER}"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  mkdir -p "${DOWNLOADFOLDER}"
  directory_exists_with_spaces "${DOWNLOADFOLDER}"


  local openssl=$(_download_compile_install "openssl-" "tar.gz"  "https://www.openssl.org/source/" "${DOWNLOADFOLDER}" | tail -1)
  echo "openssl:${openssl}"
  # (( VERBOSE )) && echo "VERBOSE"
  # (( VERBOSE )) && exit 0
  local DOWNLOADFOLDER="${USER_HOME}/_/software/pcre2"
  (( VERBOSE )) && echo "DOWNLOADFOLDER:${DOWNLOADFOLDER}"
  Checking "3 DOWNLOADFOLDER:${DOWNLOADFOLDER}"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  mkdir -p "${DOWNLOADFOLDER}"
  directory_exists_with_spaces "${DOWNLOADFOLDER}"

  local pcre2=$(_download_compile_install "pcre2-" "tar.gz"  "https://github.com/PhilipHazel/pcre2/releases/" "${DOWNLOADFOLDER}" "https://github.com/PhilipHazel/pcre2/releases/download/" | tail -1)
  echo "pcre2:${pcre2}"

  Installing  "1 nginx:${USER_HOME}/_/software/nginx"
  local DOWNLOADFOLDER="${USER_HOME}/_/software/nginx"
  (( VERBOSE )) && echo "DOWNLOADFOLDER:${DOWNLOADFOLDER}"
  Checking "4 DOWNLOADFOLDER:${DOWNLOADFOLDER}"
  enforce_variable_with_value DOWNLOADFOLDER "${DOWNLOADFOLDER}"
  mkdir -p "${DOWNLOADFOLDER}"
  directory_exists_with_spaces "${DOWNLOADFOLDER}"

  local nginx=$(_download_compile_install "nginx-" "tar.gz"  "https://nginx.org/download/" "${DOWNLOADFOLDER}" | tail -1)
  echo "nginx:${nginx}"
  cd "${DOWNLOADFOLDER}/${nginx}"
  echo "./configure --with-pcre=../${pcre2}/ --with-http_ssl_module --with-openssl=${DOWNLOADFOLDER}/${openssl}"
  ./configure --with-pcre=../${pcre2}/ --with-http_ssl_module --with-openssl=${DOWNLOADFOLDER}/${openssl}
  make
  make install
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



 #--------/\/\/\/\-- tasks_templates_sudo/nginx …install_nginx.bash” -- Custom code-/\/\/\/\-------


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo "🥦"
exit 0
