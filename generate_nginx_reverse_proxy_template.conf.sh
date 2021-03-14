# Run this to generate template
TARGETSERVER=127.0.0.1
TARGETPORT=3005
PROJECTFOLDER=$(pwd)
PROJECTROOTFOLDER=$(pwd)/public
PROJECTNAME=$(basename $(pwd))
SERVERNAME=${PROJECTNAME}.test
CERTIFICATECRTPATH=${HOME}/.valet/Certificates/${SERVERNAME}.crt;
CERTIFICATEKEYPATH=${HOME}/.valet/Certificates/${SERVERNAME}.key;


STATICFILES=""


.dirs() {
    find * -maxdepth 0 -type d   # mac and linux tested
}
# DEBUG=1
# REMOVECACHE=1
.subdir() {
  # Perform all actions in
  #        LIST1
  #          for each element in
  #                           LIST2

  local _curdir="${1}"
  local _subdir=""
  local local_actions="${2}"
  local local_items="$(.dirs)"
  local one_item
  local one_action
  local action
  # local _subdirs
  local _actions
  cd "${_curdir}"
  local _cwd="$(pwd)"

  while read -r one_item; do
  {
    if [ ! -z "${one_item}" ] ; then  # if not empty
    {
      action="${one_actions/\{\#\}/$one_item}"  # replace value inside string substitution expresion bash
      echo ${action}
        _subdir="${_cwd}/${one_item}"
      cd "${_subdir}"
      pwd
      [[ -d .git/ ]] && pull
      if [[ ! -d .git/ ]] ; then
      {
        _actions="echo -e \".\"
        echo \" \"
        echo \"Subdirectory:\"
        echo \". \"
        echo \". . . . . . .       {#} \"
        cd \"${_subdir}/{#}\"
        pwd
        [[ -d .git/ ]] && pull
        "
        .subdir "${_subdir}" "${_actions}"
      }
      fi
    }
    fi
  }
  done <<< "${local_items}"
}


CURDIR="${PWD}"
ACTIONS="echo -e \".\"
echo \" \"
echo \"Directory:\"
echo \". \"
echo \". . . . . . .       {#} \"
cd \"${CURDIR}/{#}\"
pwd
[[ -d .git/ ]] && pull
"

.subdir  "${CURDIR}" "${ACTIONS}" 


echo "upstream ${PROJECTNAME} {
    # Path to Puma SOCK file, as defined previously
    # NodeJS Express Etc ANything with custom port localhost:8080 localhost:3000 etc
    server ${TARGETSERVER}:${TARGETPORT} fail_timeout=0;
    # Ruby Puma Sample:
    # server unix://${PROJECTFOLDER}/sockets/puma.sock fail_timeout=0;
}

server {
    listen 80;
    server_name ${SERVERNAME} www.${SERVERNAME} *.${SERVERNAME};
    charset utf-8;

    root ${PROJECTROOTFOLDER};

    # Uncomment error pages one you place make them accesible
    # error_page 500 502 503 504 /500.html;
# Use this to generate individual accesses
# ls -p1 | grep -v / | xargs -I {} echo \"    location = /{} {
#         access_log off; log_not_found off;
#         alias \$(pwd)/{};
#     }\"
    # Place generated invidual cases here
    # --
    # here
    # ---
    try_files \$uri/index.html \$uri @${PROJECTNAME};

    location @${PROJECTNAME} {
        proxy_pass http://${PROJECTNAME};
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Forwarded-Proto http;
        proxy_redirect off;
    }

    client_max_body_size 4G;
    keepalive_timeout 10;
}
# REF: https://gist.github.com/tadast/9932075  see this script about how to build the script from ground up and read the comments
# REF: https://gist.github.com/rkjha/d898e225266f6bbe75d8  See that script as reference for these confs and read the comments
server {
    listen  443 ssl;
    server_name ${SERVERNAME} www.${SERVERNAME} *.${SERVERNAME};
    charset utf-8;

    root ${PROJECTROOTFOLDER};

    # Additional rules go here.
    # ssl on;   [warn] the \"ssl\" directive is deprecated, use the \"listen ... ssl\"
    ssl_certificate ${CERTIFICATECRTPATH};
    ssl_certificate_key ${CERTIFICATEKEYPATH};

    ssl_session_timeout  5m;

    # Uncomment error pages one you place make them accesible
    # error_page 500 502 503 504 /500.html;
    # Place generated invidual cases here too
    # --
    # here
    # ---
    try_files \$uri/index.html \$uri @${PROJECTNAME};

    location @${PROJECTNAME} {
        proxy_pass http://${PROJECTNAME};
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Forwarded-Proto https;
        proxy_redirect off;
    }
    client_max_body_size 4G;
    keepalive_timeout 10;
}
" > ${SERVERNAME}.conf
