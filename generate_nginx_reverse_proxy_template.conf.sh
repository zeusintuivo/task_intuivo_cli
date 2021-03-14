#!/usr/bin/env bash

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


._dirs() {
    find * -maxdepth 0 -type d   # mac and linux tested
}
._replace_all_hashes(){
  local found
  local one_item="${1}"
  local one_action="${2}"
  while :  # replace all {#} to $one_item value
  do
    one_action="${one_action/\{\#\}/$one_item}"  # replace value inside string substitution expresion bash
    found=$(echo -n "${one_action}" | grep "{#}")
    [ $? -eq 1 ] &&  break
  done
  echo "${one_action}"
}
.loopsubdirs() {
  # Perform all actions in
  #        LIST1
  #          for each element in
  #                           LIST2
  local _curdir="${1}"
  local ACTIONS="${2}"
  cd "${_curdir}"
  local local_items="$(._dirs)"
  local one_item  action _cwd
  while read -r one_item; do
  {
    if [[ -n "${one_item}" ]] ; then  # if not empty
    {
      _cwd="${_curdir}/${one_item}"
      cd "${_cwd}"
ls -p1 | grep -v / | xargs -I {} echo "    location = /{} {
        access_log off; log_not_found off;
        alias $(pwd)/{};
    }"
      
      .loopsubdirs "${_cwd}"  "${ACTIONS}"
    }
    fi
  }
  done <<< "${local_items}"
  return 0
}

CWD="${PWD}"
CURDIR="${PWD}/public"
cd  "${CURDIR}"
STATICFILES="$(ls -p1 | grep -v / | xargs -I {} echo "    location = /{} {
        access_log off; log_not_found off;
        alias $(pwd)/{};
    }")"
ACTIONS="
ls -p1 | grep -v / | xargs -I {} echo \"    location = /{} {
        access_log off; log_not_found off;
        alias \$(pwd)/{};
    }\"
  .loopsubdirs \"{#}\" \"${ACTIONS}\"

"

STATICFILES="${STATICFILES}
$(.loopsubdirs  "${CURDIR}" "${ACTIONS}")"

cd "${CWD}"

# echo -e ";;;;;;;\n${STATICFILES}\n;;;;;;"
# exit 0 


echo "upstream ${PROJECTNAME} {
    # Path to Puma SOCK file, as defined previously
    # NodeJS Express Etc ANything with custom port localhost:8080 localhost:3000 etc
    # server ${TARGETSERVER}:${TARGETPORT} fail_timeout=0;
    # Ruby Puma Sample:
    # server unix://${PROJECTFOLDER}/sockets/puma.sock fail_timeout=0;
    server unix://${PROJECTFOLDER}/shared/sockets/puma.sock fail_timeout=0;
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
    # -- between here 
    # here starts
${STATICFILES}
    # here ends 
    # --- and here 
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
    # -- between here 
    # here starts
${STATICFILES}
    # here ends 
    # --- and here 
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
