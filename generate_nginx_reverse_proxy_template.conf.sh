#!/usr/bin/env bash

# Run this to generate template
TARGETSERVER=127.0.0.1
TARGETPORT=3005
PROJECTFOLDER=$(pwd)

if [[ -d wp-content ]] ; then
{
  PROJECTROOTFOLDER=$(pwd)
}
else
{
  PROJECTROOTFOLDER=$(pwd)/public
}
fi
PROJECTNAME=$(basename $(pwd))
PROJECTNAME=$(echo ${PROJECTNAME} | sed 's/\_//g')
SERVERNAME=${PROJECTNAME}.test

function yes_or_no() {
    while true; do
            read -p "$* [y/n]: " yn
            case $yn in
                    [Yy]*) return 0  ;;
                    [Nn]*) echo "Aborted" ; return  1 ;;
            esac
    done
} # end yes no


# check operation systems
if [[ "$(uname)" == "Darwin" ]] ; then
  # Do something under Mac OS X platform
CERTIFICATECRTPATHFROM="${HOME}/.config/valet/Certificates/${SERVERNAME}.crt"
CERTIFICATEKEYPATHFROM="${HOME}/.config/valet/Certificates/${SERVERNAME}.key"
CERTIFICATECRTPATH="\"${HOME}/.config/valet/LocalCertificates/${SERVERNAME}.crt\""
CERTIFICATEKEYPATH="\"${HOME}/.config/valet/LocalCertificates/${SERVERNAME}.key\""
FROMSERVERSCRIPT="\"${HOME}/.config/valet/Nginx/${SERVERNAME}\""
SERVERSCRIPT="\"${HOME}/.config/valet/Local/${SERVERNAME}\""
SERVERVALET="\"${HOME}/.composer/vendor/laravel/valet/server.php\""
FASTCGIPASS="\"unix:${HOME}/.config/valet/valet.sock\""
ERRORLOG="\"${HOME}/.config/valet/Log/nginx-error.log\""
elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]] ; then
  # Do something under GNU/Linux platform
CERTIFICATECRTPATHFROM="\"${HOME}/.valet/Certificates/${SERVERNAME}.crt\""
CERTIFICATEKEYPATHFROM="\"${HOME}/.valet/Certificates/${SERVERNAME}.key\""
CERTIFICATECRTPATH="\"${HOME}/.valet/LocalCertificates/${SERVERNAME}.crt\""
CERTIFICATEKEYPATH="\"${HOME}/.valet/LocalCertificates/${SERVERNAME}.key\""
FROMSERVERSCRIPT="\"${HOME}/.valet/Nginx/${SERVERNAME}\""
SERVERSCRIPT="\"${HOME}/.valet/Local/${SERVERNAME}\""
SERVERVALET="\"${HOME}/.config/composer/vendor/cpriego/valet-linux/server.php\""
FASTCGIPASS="\"unix:${HOME}/.valet/valet.sock\""
ERRORLOG="\"${HOME}/.valet/Log/nginx-error.log\""
elif [[ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]] ; then
  # Do something under Windows NT platform
CERTIFICATECRTPATHFROM="\"${HOME}/.valet/Certificates/${SERVERNAME}.crt\""
CERTIFICATEKEYPATHFROM="\"${HOME}/.valet/Certificates/${SERVERNAME}.key\""
CERTIFICATECRTPATH="\"${HOME}/.valet/LocalCertificates/${SERVERNAME}.crt\""
CERTIFICATEKEYPATH="\"${HOME}/.valet/LocalCertificates/${SERVERNAME}.key\""
FROMSERVERSCRIPT="\"${HOME}/.valet/Nginx/${SERVERNAME}\""
SERVERSCRIPT="\"${HOME}/.valet/Local/${SERVERNAME}\""
SERVERVALET="\"${HOME}/.config/composer/vendor/cpriego/valet-linux/server.php\""
FASTCGIPASS="\"unix:${HOME}/.valet/valet.sock\""
ERRORLOG="\"${HOME}/.valet/Log/nginx-error.log\""
  # nothing here
fi


echo "
TARGETPORT=${TARGETPORT}
PROJECTFOLDER=${PROJECTFOLDER}
PROJECTROOTFOLDER=${PROJECTROOTFOLDER}
PROJECTNAME=${PROJECTNAME}
SERVERNAME=${SERVERNAME}
CERTIFICATECRTPATH=${CERTIFICATECRTPATH}
CERTIFICATEKEYPATH=${CERTIFICATEKEYPATH}
ERRORLOG=${ERRORLOG}
FASTCGIPASS=${FASTCGIPASS}
SERVERVALET=${SERVERVALET}
"

echo -e "${PURPLE_BLUE} === Continue with this settings ? ${RESET}"
yes_or_no
_err=$?
[ $_err -gt 0 ] && exit 0

echo "Copy Certificates from valet"
mkdir -p "$(dirname "${CERTIFICATECRTPATH}")"
mkdir -p "$(dirname "${SERVERSCRIPT}")"

cp  "${FROMSERVERSCRIPT}" "${SERVERSCRIPT}"
cp  "${CERTIFICATECRTPATHFROM}" "${CERTIFICATECRTPATH}"
cp  "${CERTIFICATEKEYPATHFROM}" "${CERTIFICATEKEYPATH}"

echo "Unregister valet project"
echo "valet unlink "${PROJECTNAME}""
valet unlink "${PROJECTNAME}"

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
if [[ -d "${PWD}/public" ]] ; then
{
  echo "Rails-like structure using public folder"
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

}
else
{
  echo "Wordpress-like structure using root folder"
  CURDIR="${PWD}"
}
fi
[[ ! -d  "${CURDIR}" ]] && echo "Failed to find  "${CURDIR}"" && exit 1

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
" > ${SERVERNAME}_upstream.conf


echo "# Redirect http to https
server {
    listen 80;
    listen [::]:80;
    server_name ${SERVERNAME} www.${SERVERNAME} *.${SERVERNAME};
    return 301 https://\$host\$request_uri;
}
# Redirect www to non-www
#server {
#    listen 443;  just writing a redirect to port 443 with no ssl info fails
#    listen [::]:443;
#    server_name www.${SERVERNAME};
#
#    return 301 https://${SERVERNAME}\$request_uri;
#}
# Suggestiong to redirect demo.com to www.demo.com REF: https://www.digitalocean.com/community/tutorials/how-to-configure-single-and-multiple-wordpress-site-settings-with-nginx
# server {
    # URL: Correct way to redirect URL's
    # server_name demo.com;
    # rewrite ^/(.*)\$ http://www.demo.com/\$1 permanent;
# }
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    # multisite installation with subdomains  must add  domain with a wildcard:  *.demo2.com;
    server_name ${SERVERNAME} www.${SERVERNAME} *.${SERVERNAME};
    root ${PROJECTROOTFOLDER};
    charset utf-8;

    ssl_session_timeout  5m;

    # Uncomment error pages one you place make them accesible
    # error_page 500 502 503 504 /500.html;
    # Place generated invidual cases here too
    # -- between here
    # here starts
${STATICFILES}
    # here ends
    # --- and here
    # try_files \$uri/index.html \$uri @${PROJECTNAME};

    index index.php index.html index.htm;

    #
    # Generic restrictions for things like PHP files in uploads
    #
    include restrictions.conf;

    #
    # Gzip rules
    #
    include gzip.conf;

    #
    # WordPress Rules
    #
    # {{#unless site.multiSite}}
    # include wordpress-single.conf;
    # {{else}}
    include wordpress-multi.conf;
    # {{/unless}}

    ssl_certificate ${CERTIFICATECRTPATH};
    ssl_certificate_key ${CERTIFICATEKEYPATH};

    #
    # TLS SSL rules
    #
    include ssl.conf;

    # location / {
    #    rewrite ^ ${SERVERVALET} last;
    # }

    # location = /favicon.ico { access_log off; log_not_found off; }
    # location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log ${ERRORLOG};

    # error_page 404 ${SERVERVALET};

    # REQUIREMENTS : Enable PHP Support
    location ~ \.php\$ {
        # SECURITY : Zero day Exploit Protection
        try_files \$uri =404;

        # ENABLE : Enable PHP, listen fpm sock
        fastcgi_split_path_info ^(.+\\.php)(/.+)\$;
        fastcgi_pass ${FASTCGIPASS};
        fastcgi_index index.php;
        include fastcgi_params;
    }

    # PLUGINS : Enable Rewrite Rules for Yoast SEO SiteMap
    rewrite ^/sitemap_index\.xml\$ /index.php?sitemap=1 last;
    rewrite ^/([^/]+?)-sitemap([0-9]+)?\.xml\$ /index.php?sitemap=\$1&sitemap_n=\$2 last;

    # Rewrite robots.txt
    rewrite ^/robots.txt\$ /index.php last;

    location ~ /\.ht {
        deny all;
    }
}

server {
    listen 88;
    server_name ${SERVERNAME} www.${SERVERNAME} *.${SERVERNAME};
    root /;
    charset utf-8;
    client_max_body_size 128M;

    location /41c270e4-5535-4daa-b23e-c269744c2f45/ {
        internal;
        alias /;
        try_files \$uri \$uri/;
    }

    location / {
        rewrite ^ ${SERVERVALET} last;
    }

    access_log off;
    error_log ${ERRORLOG};

    error_page 404 ${SERVERVALET};

    location ~ \\.php\$ {
        fastcgi_split_path_info ^(.+\\.php)(/.+)\$;
        fastcgi_pass ${FASTCGIPASS};
        fastcgi_index ${SERVERVALET};
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME ${SERVERVALET};
    }

    location ~ /\.ht {
        deny all;
    }
}

server {
    listen 127.0.0.1:60;
    #listen 127.0.0.1:60; # valet loopback
    server_name ${SERVERNAME} www.${SERVERNAME} *.${SERVERNAME};
    root /;
    charset utf-8;
    client_max_body_size 128M;

    add_header X-Robots-Tag 'noindex, nofollow, nosnippet, noarchive';

    location /41c270e4-5535-4daa-b23e-c269744c2f45/ {
        internal;
        alias /;
        try_files \$uri \$uri/;
    }

    location / {
        rewrite ^ ${SERVERVALET} last;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log ${ERRORLOG};

    error_page 404 ${SERVERVALET};

    location ~ [^/]\\.php(/|\$) {
        fastcgi_split_path_info ^(.+\\.php)(/.+)\$;
        fastcgi_pass ${FASTCGIPASS};
        fastcgi_index ${SERVERVALET};
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME ${SERVERVALET};
        fastcgi_param PATH_INFO \$fastcgi_path_info;
    }

    location ~ /\.ht {
        deny all;
    }
}
" > ${SERVERNAME}_nginx.conf
