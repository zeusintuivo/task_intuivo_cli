#!/usr/bin/env bash
#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
# Helper copying MariaDB and some Mysql to another external drive, usb, folder, ...
function fullpath(){
  # echo $(dirname "$(pwd)/bash_intuivo_cli/loeschen_seo_nur_datei")  # get name of directory name without full path in bas,,, everything before the last /
  echo $(dirname """${1}""")
}
function filename(){
  # echo $(basename "$(pwd)/bash_intuivo_cli/nur/asdf/asdf")          # get filename,,  or last string after last /
  echo $(basename """${1}""")
}
function file_exists(){
   [ -f  """${1}""" ] || return 1
}
function is_a_file(){
   [ -f  """${1}""" ] || return 1
}
function is_a_directory(){
   [ -d  """${1}""" ] || return 1
}
function is_a_softlink(){
   [ -L  """${1}""" ] || return 1
}
function it_exists(){
   [ -e  """${1}""" ] || return 1
}
function file_does_not_exist(){
   [ ! -f  """${1}""" ] || return 1
}
function not_empty(){
   [ -n  """${1}""" ]  || return 1
}
function fail_if(){
  if """${1}""" """${2}"""  ; then
  {
    echo """${1}""" """${2}"""
    exit 1
  }
  fi
}
function cache_results(){ # void
  local t
  if file_does_not_exist  """${2}""" ; then
  {
    echo "Caching file """${2}""""
    t=$(ö  """${1}"""  2>&1)
    echo "${t}" > """${2}"""
  }
  fi
}
function filter(){
  local t
  t=$(<"""${1}""")
  files=$(echo "${t}" \
  | ohne "^find:" \
  | ohne "^_\/" \
  | ohne flatpak \
  | ohne .rbenv \
  | ohne "^run\/media" \
  | ohne "^home\/zeus" \
  | ohne ".sock" \
  )
  echo "${files}"
} # mysqlfiles
function glue_path(){
  local L
          if not_empty "${1}" ; then
          {
            if [[ "${1}" == "/" ]] ; then
            {
              L="""${1}${2}"""
            } else {
              L="""${1}/${2}"""
            }
            fi
          } else {
            L="""${2}"""
          }
          fi
 echo """${L}"""
}
function cp_left_to_right(){
  local t L R baseL baseR fullL fullR err cmd
  baseL="""${2}"""
  baseR="""${3}"""
  t=$(filter """${1}""")
  while read -r file; do
  {
    if not_empty "${file}" ; then
    {
      if it_exists "${file}" ; then
      {
        fullL=$(fullpath "${file}")
        fullR="""${baseR}/${fullL}"""
        mkdir -p  """${fullR}"""
        err=$?
        if [ $err -gt 0 ] ; then
        {
          echo "[ERROR] while creating mkdir -p """${fullR}""""
          exit 1
        }
        fi
        if it_exists "${fullR}" ; then
        {

          L=$(glue_path """${baseL}""" """${file}""")
          R=$(glue_path """${baseR}""" """${file}""")
          echo """${L}"""
          if is_a_directory """${L}""" ; then
          {
            cmd="cp -R"
          } elif is_a_softlink """${L}""" ; then
          {
            cmd="cp -R"
          } else {
            cmd="cp "
          }
          fi
          ${cmd} """${L}""" """${R}"""
          err=$?
          if [ $err -gt 0 ] ; then
          {
            echo "[ERROR] while copying  """${cmd}""" """${L}""" """${R}""""
            exit 1
          }
          fi
        } else {
          echo "[ERROR] failed to create """${fullR}""""
          exit 1
        }
        fi
      }
      fi

    }
    fi
  }
  done <<< "${t}"
}
function sift_results(){ # void
  local t
  if file_does_not_exist  """${2}""" ; then
  {
    echo "Sifting file """${2}""""
    t=$(sift  """${1}"""  2>&1)
    echo "${t}" > """${2}"""
  }
  fi
}
# cache_results mysql mysql_list.tmp
# cache_results maria maria_list.tmp
# fail_if file_does_not_exist maria_list.tmp
# fail_if file_does_not_exist mysql_list.tmp
# cp_left_to_right  mysql_list.tmp "/" "/run/media/zeus/2bc0a7af-2695-43fd-8080-512d89931951"
# cp_left_to_right  maria_list.tmp "/" "/run/media/zeus/2bc0a7af-2695-43fd-8080-512d89931951"

cache_results tweener tweener.tmp
sift_results Tweener.js Tweener-sift.js.tmp
sift_results tweener tweener-sift.tmp
filter tweener.tmp
filter Tweener-sift.js.tmp
filter tweener-sift.tmp

_
bin
boot
data
dev
etc
home
include
keybase
lib
lib64
lost+found
maria_list.tmp
media
metainfo
mnt
mysql_list.tmp
opt
proc
root
run
sbin
share
snap
srv
sys
@System.solv
tmp
tweener.tmp
usr
var

# 030 364 28330 Kevin