#!/usr/bin/env bash




function main() {
  export  THISSCRIPTNAME
  typeset -r THISSCRIPTNAME="$(basename "$0")"

  function _trap_on_error(){
    echo -e "\033[01;7m*** TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR INT ...\033[0m"
    exit 0
  }
  trap _trap_on_error ERR INT

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
  {
    # Do something under Mac OS X platform
    VALETHOME="${HOME}/.config/valet"
    SERVERVALET="${HOME}/.composer/vendor/laravel/valet/server.php"
    NGINXBASE="/usr/local/etc/nginx"
    FPMSOCK="unix:/usr/local/var/run/php-www.sock"
    NGINXUSERS="\"${USER}\" staff"
    NGINXPID="/usr/local/var/run/nginx.pid"
  }
  elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]] || \
       [[ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]] ; then
  {

    # Do something under GNU/Linux platform
    # Do something under Windows NT platform  # nothing here
    VALETHOME="${HOME}/.valet"
    SERVERVALET="${HOME}/.config/composer/vendor/cpriego/valet-linux/server.php"
    NGINXBASE="/etc/nginx"
    FPMSOCK="unix:/run/php-fpm/www.sock"
    NGINXUSERS="\"${USER}\" wheel"
    NGINXPID="/run/nginx.pid"
  }
  fi

  CERTIFICATECRTPATHFROM="${VALETHOME}/Certificates/${SERVERNAME}.crt"
  CERTIFICATEKEYPATHFROM="${VALETHOME}/Certificates/${SERVERNAME}.key"
  CERTIFICATECRTPATH="${VALETHOME}/LocalCertificates/${SERVERNAME}.crt"
  CERTIFICATEKEYPATH="${VALETHOME}/LocalCertificates/${SERVERNAME}.key"
  FROMSERVERSCRIPT="${VALETHOME}/Nginx/${SERVERNAME}"
  SERVERSCRIPT="${VALETHOME}/Local/${SERVERNAME}"
  FASTCGIPASS="unix:${VALETHOME}/valet.sock"
  ERRORLOG="${VALETHOME}/Log/nginx-error.log"

  NGINXGENERATED="${NGINXBASE}/generated"
  NGINXCONF="${NGINXBASE}/nginx.conf"

  local _control="
  TARGETPORT=${TARGETPORT}
  PROJECTFOLDER=${PROJECTFOLDER}
  PROJECTROOTFOLDER=${PROJECTROOTFOLDER}
  PROJECTNAME=${PROJECTNAME}
  FROMSERVERSCRIPT=${FROMSERVERSCRIPT}
  SERVERNAME=${SERVERNAME}
  SERVERSCRIPT=${SERVERSCRIPT}
  CERTIFICATECRTPATH=${CERTIFICATECRTPATH}
  CERTIFICATEKEYPATH=${CERTIFICATEKEYPATH}
  ERRORLOG=${ERRORLOG}
  FASTCGIPASS=${FASTCGIPASS}
  SERVERVALET=${SERVERVALET}
  NGINXGENERATED=${NGINXGENERATED}
  NGINXCONF=${NGINXCONF}
  FPMSOCK=${FPMSOCK}
  VALETHOME=${VALETHOME}
  VALETHOME=${VALETHOME}
  hosts file = /etc/hosts
  "
  if ( command -v sift >/dev/null 2>&1; ) ; then
  {
    echo "${_control}" | sift "="
  }
  else
  {
    echo "${_control}"
  }
  fi
  echo -e "${PURPLE_BLUE} === Continue with this settings ? ${RESET}"
  yes_or_no
  _err=$?
  [ $_err -gt 0 ] && exit 0

  [[ ! -d "${NGINXGENERATED}" ]] && mkdir -p "${NGINXGENERATED}"
  [[ ! -d "${NGINXGENERATED}/sites-enabled" ]] && mkdir -p "${NGINXGENERATED}/sites-enabled"
  [[ ! -d "${PROJECTFOLDER}/sockets" ]] && mkdir -p "${PROJECTFOLDER}/sockets"
  [[ ! -d "${PROJECTFOLDER}/shared/sockets" ]] && mkdir -p "${PROJECTFOLDER}/shared/sockets"
  [[ ! -d "$(dirname "${SERVERSCRIPT}")" ]] && mkdir -p "$(dirname "${SERVERSCRIPT}")"


  if [[ ! -f "${CERTIFICATECRTPATH}" ]] ; then
  {
    echo "Copy Certificates from valet"
    [[ ! -d "$(dirname "${CERTIFICATECRTPATH}")" ]] && mkdir -p "$(dirname "${CERTIFICATECRTPATH}")"
    cp  "${FROMSERVERSCRIPT}" "${SERVERSCRIPT}_backed"
    cp  "${FROMSERVERSCRIPT}" "${SERVERNAME}_backed"
    cp  "${CERTIFICATECRTPATHFROM}" "${CERTIFICATECRTPATH}"
    cp  "${CERTIFICATEKEYPATHFROM}" "${CERTIFICATEKEYPATH}"
  }
  fi

  if [[ "$(</etc/hosts)" != *"${SERVERNAME}"* ]] ; then
  {
    echo "sudo echo \"${SERVERNAME}\" >> /etc/hosts"
    if ( command -v tee >/dev/null 2>&1; ) ; then
    {
  echo "
127.0.0.1   ${SERVERNAME} www.${SERVERNAME} api.${SERVERNAME};
::1         ${SERVERNAME} www.${SERVERNAME} api.${SERVERNAME};
" | sudo tee "/etc/hosts"
    }
    else
    {
  echo "Make sure to add this lines to your \"/etc/hosts\" file
127.0.0.1   ${SERVERNAME} www.${SERVERNAME} api.${SERVERNAME};
::1         ${SERVERNAME} www.${SERVERNAME} api.${SERVERNAME};
"
    }
    fi
  }
  fi

  if ( command -v nurindatei >/dev/null 2>&1; ) ; then
  {
    nurindatei /etc/hosts "${SERVERNAME}"
  }
  else
  {
    grep  "${SERVERNAME}" /etc/hosts
  }
  fi
  #   yes_or_no
  # _err=$?
  # [ $_err -gt 0 ] && exit 0
  local -i _err
  local links="$( ls -1 "${FROMSERVERSCRIPT}"   2>&1; )"
  _err=$?
  if [ ${_err} -eq 0 ] && [[ "${links}" == *"${PROJECTNAME}"* ]] &&  [[ "${links}" != *"No such file"* ]]; then
  {
    #  yes_or_no
    # _err=$?
    # [ $_err -gt 0 ] && exit 0
    echo "Unregister valet project sudo"
    echo "valet unlink \"${PROJECTNAME}\""
    valet unlink "${PROJECTNAME}"
    valet restart
  }
  else
  {
    echo "Valet server not found"
  }
  fi

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
        alias \"$(pwd)/{}\";
    }")"
ACTIONS="
ls -p1 | grep -v / | xargs -I {} echo \"    location = /{} {
        access_log off; log_not_found off;
        alias \"\$(pwd)/{}\";
    }\"
  .loopsubdirs \"{#}\" \"${ACTIONS}\"

"

STATICFILES="${STATICFILES}
$(.loopsubdirs  "${CURDIR}" "${ACTIONS}")"

}
else
{
  echo "I identified a Wordpress-like structure using \"wp-root\" folder"
  CURDIR="${PWD}"
}
fi
[[ ! -d  "${CURDIR}" ]] && echo "Failed to find  "${CURDIR}"" && exit 1

cd "${CWD}"

# echo -e ";;;;;;;\n${STATICFILES}\n;;;;;;"
# exit 0


echo "# ${SERVERNAME}_upstream.conf
upstream ${PROJECTNAME} {
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
" > "${SERVERNAME}_upstream.conf"


echo "# ${NGINXGENERATED}/${SERVERNAME}
# Redirect http to https
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
# Suggestions to redirect ${SERVERNAME} to www.${SERVERNAME} REF: https://www.digitalocean.com/community/tutorials/how-to-configure-single-and-multiple-wordpress-site-settings-with-nginx
# server {
    # URL: Correct way to redirect URL's
    # server_name ${SERVERNAME};
    # rewrite ^/(.*)\$ http://www.${SERVERNAME}/\$1 permanent;
# }
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    # multisite installation with subdomains  must add  domain with a wildcard:  *.${SERVERNAME};
    server_name ${SERVERNAME} www.${SERVERNAME} *.${SERVERNAME};
    root ${PROJECTROOTFOLDER};
    charset utf-8;

    # ssl_session_timeout  5m;  Also in ssl.conf \"${NGINXGENERATED}/ssl.conf\";

    # Uncomment error pages one you place make them accesible
    # error_page 500 502 503 504 /500.html;
    # Place generated invidual cases here too
    # -- between here
    # here starts
${STATICFILES}
    # here ends
    # --- and here
    # try_files \$uri/index.html \$uri @${PROJECTNAME};

    # Prioritize index.php first for requests
    index index.php index.html index.htm;

    #
    # Generic restrictions for things like PHP files in uploads
    #
    include \"${NGINXGENERATED}/restrictions.conf\";

    #
    # Gzip rules
    #
    include \"${NGINXGENERATED}/gzip.conf\";

    #
    # WordPress Rules
    #
    # {{#unless site.multiSite}}
    # include \"${NGINXGENERATED}/wordpress-single.conf\";
    # {{else}}
    include \"${NGINXGENERATED}/wordpress-multi.conf\";
    # {{/unless}}

    ssl_certificate \"${CERTIFICATECRTPATH}\";
    ssl_certificate_key \"${CERTIFICATEKEYPATH}\";

    #
    # TLS SSL rules
    #
    include \"${NGINXGENERATED}/ssl.conf\";

    # location / {
    #    rewrite ^ \"${SERVERVALET}\" last;
    # }

    # location = /favicon.ico { access_log off; log_not_found off; }
    # location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log \"${ERRORLOG}\";

    # error_page 404 \"${SERVERVALET}\";

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
        rewrite ^ \"${SERVERVALET}\" last;
    }

    access_log off;
    error_log \"${ERRORLOG}\";

    error_page 404 \"${SERVERVALET}\";

    location ~ \\.php\$ {
        fastcgi_split_path_info ^(.+\\.php)(/.+)\$;
        fastcgi_pass ${FASTCGIPASS};
        fastcgi_index \"${SERVERVALET}\";
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \"${SERVERVALET}\";
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
        rewrite ^ \"${SERVERVALET}\" last;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log \"${ERRORLOG}\";

    error_page 404 \"${SERVERVALET}\";

    location ~ [^/]\\.php(/|\$) {
        fastcgi_split_path_info ^(.+\\.php)(/.+)\$;
        fastcgi_pass ${FASTCGIPASS};
        fastcgi_index \"${SERVERVALET}\";
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \"${SERVERVALET}\";
        fastcgi_param PATH_INFO \$fastcgi_path_info;
    }

    location ~ /\.ht {
        deny all;
    }
}
" > "${SERVERNAME}_nginx.conf" > "${NGINXGENERATED}/${SERVERNAME}"


if [[ ! -e "${NGINXGENERATED}/mime.types" ]] ; then
{
echo "# ${NGINXGENERATED}/mime.types
types {
application/A2L					a2l;
application/AML					aml;
application/andrew-inset			ez;
application/ATF					atf;
application/ATFX				atfx;
application/ATXML				atxml;
application/atom+xml				atom;
application/atomcat+xml				atomcat;
application/atomdeleted+xml			atomdeleted;
application/atomsvc+xml				atomsvc;
application/atsc-dwd+xml			dwd;
application/atsc-held+xml			held;
application/atsc-rsat+xml			rsat;
application/auth-policy+xml			apxml;
application/bacnet-xdd+zip			xdd;
application/calendar+xml			xcs;
application/cbor				cbor;
application/cccex				c3ex;
application/ccmp+xml				ccmp;
application/ccxml+xml				ccxml;
application/CDFX+XML				cdfx;
application/cdmi-capability			cdmia;
application/cdmi-container			cdmic;
application/cdmi-domain				cdmid;
application/cdmi-object				cdmio;
application/cdmi-queue				cdmiq;
application/CEA					cea;
application/cellml+xml				cellml cml;
application/clr                     1clr;
application/clue_info+xml			clue;
application/cms					cmsc;
application/cpl+xml				cpl;
application/csrattrs				csrattrs;
application/dash+xml				mpd;
application/dashdelta				mpdd;
application/davmount+xml			davmount;
application/DCD					dcd;
application/dicom				dcm;
application/DII					dii;
application/DIT					dit;
application/dskpp+xml				xmls;
application/dssc+der				dssc;
application/dssc+xml				xdssc;
application/dvcs				dvc;
application/ecmascript				es;
application/efi					efi;
application/emma+xml				emma;
application/emotionml+xml			emotionml;
application/epub+zip				epub;
application/exi					exi;
application/fastinfoset				finf;
application/fdt+xml				fdt;
application/font-tdpfr				pfr;
application/geo+json				geojson;
application/geopackage+sqlite3			gpkg;
application/gltf-buffer				glbin glbuf;
application/gml+xml				gml;
application/gzip				gz tgz;
application/hyperstudio				stk;
application/inkml+xml				ink inkml;
application/ipfix				ipfix;
application/its+xml				its;
application/javascript				js;
application/jrd+json				jrd;
application/json				json;
application/json-patch+json			json-patch;
application/ld+json				jsonld;
application/lgr+xml				lgr;
application/link-format				wlnk;
application/lost+xml				lostxml;
application/lostsync+xml			lostsyncxml;
application/lpf+zip				lpf;
application/LXF					lxf;
application/mac-binhex40			hqx;
application/mads+xml				mads;
application/marc				mrc;
application/marcxml+xml				mrcx;
application/mathematica				nb ma mb;
application/mathml+xml				mml;
application/mbox				mbox;
application/metalink4+xml			meta4;
application/mets+xml				mets;
application/MF4					mf4;
application/mipc                h5;
application/mmt-aei+xml				maei;
application/mmt-usd+xml				musd;
application/mods+xml				mods;
application/mp21				m21 mp21;
application/msword				doc;
application/mxf					mxf;
application/n-quads				nq;
application/n-triples				nt;
application/ocsp-request			orq;
application/ocsp-response			ors;
application/octet-stream		bin lha lzh exe class so dll img iso;
application/ODA					oda;
application/ODX					odx;
application/oebps-package+xml			opf;
application/ogg					ogx;
application/opc-nodeset+xml     ;
application/oxps				oxps;
application/p2p-overlay+xml			relo;
application/pdf					pdf;
application/PDX					pdx;
application/pem-certificate-chain		pem;
application/pgp-encrypted			pgp;
application/pgp-signature			sig;
application/pkcs10				p10;
application/pkcs12				p12 pfx;
application/pkcs7-mime				p7m p7c;
application/pkcs7-signature			p7s;
application/pkcs8				p8;
application/pkcs8-encrypted			p8e;
application/pkix-cert				cer;
application/pkix-crl				crl;
application/pkix-pkipath			pkipath;
application/pkixcmp				pki;
application/pls+xml				pls;
application/postscript				ps eps ai;
application/provenance+xml			provx;
application/prs.cww				cw cww;
application/prs.hpub+zip			hpub;
application/prs.nprend				rnd rct;
application/prs.rdf-xml-crypt			rdf-crypt;
application/prs.xsf+xml				xsf;
application/pskc+xml				pskcxml;
application/rdf+xml				rdf;
application/route-apd+xml			rapd;
application/route-s-tsid+xml			sls;
application/route-usd+xml			rusd;
application/reginfo+xml				rif;
application/relax-ng-compact-syntax		rnc;
application/resource-lists-diff+xml		rld;
application/resource-lists+xml			rl;
application/rfc+xml				rfcxml;
application/rls-services+xml			rs;
application/rpki-ghostbusters			gbr;
application/rpki-manifest			mft;
application/rpki-roa				roa;
application/rtf					rtf;
application/sarif-external-properties+json sarif-external-properties sarif-external-properties.json;
application/sarif+json          sarif sarif.json;
application/scim+json				scim;
application/scvp-cv-request			scq;
application/scvp-cv-response			scs;
application/scvp-vp-request			spq;
application/scvp-vp-response			spp;
application/sdp					sdp;
application/senml-etch+cbor			senml-etchc;
application/senml-etch+json			senml-etchj;
application/senml+cbor				senmlc;
application/senml+json				senml;
application/senml+xml				senmlx;
application/senml-exi				senmle;
application/sensml+cbor				sensmlc;
application/sensml+json				sensml;
application/sensml+xml				sensmlx;
application/sensml-exi				sensmle;
application/sgml-open-catalog			soc;
application/shf+xml				shf;
application/sieve				siv sieve;
application/simple-filter+xml			cl;
application/smil+xml				smil smi sml;
application/sparql-query			rq;
application/sparql-results+xml			srx;
application/sql					sql;
application/srgs				gram;
application/srgs+xml				grxml;
application/sru+xml				sru;
application/ssml+xml				ssml;
application/stix+json				stix;
application/swid+xml				swidtag;
application/tamp-apex-update			tau;
application/tamp-apex-update-confirm		auc;
application/tamp-community-update		tcu;
application/tamp-community-update-confirm	cuc;
application/td+json				jsontd;
application/tamp-error				ter;
application/tamp-sequence-adjust		tsa;
application/tamp-sequence-adjust-confirm	sac;
application/tamp-update				tur;
application/tamp-update-confirm			tuc;
application/tei+xml				tei teiCorpus odd;
application/thraud+xml				tfi;
application/timestamp-query			tsq;
application/timestamp-reply			tsr;
application/timestamped-data			tsd;
application/trig				trig;
application/ttml+xml				ttml;
application/urc-grpsheet+xml			gsheet;
application/urc-ressheet+xml			rsheet;
application/urc-targetdesc+xml			td;
application/urc-uisocketdesc+xml		uis;
application/vnd.1000minds.decision-model+xml	1km;
application/vnd.3gpp.5gnas              ;
application/vnd.3gpp.pic-bw-large		plb;
application/vnd.3gpp.pic-bw-small		psb;
application/vnd.3gpp.pic-bw-var			pvb;
application/vnd.3gpp2.sms			sms;
application/vnd.3gpp2.tcap			tcap;
application/vnd.3lightssoftware.imagescal	imgcal;
application/vnd.3M.Post-it-Notes		pwn;
application/vnd.accpac.simply.aso		aso;
application/vnd.accpac.simply.imp		imp;
application/vnd.acucobol			acu;
application/vnd.acucorp				atc acutc;
application/vnd.adobe.flash.movie		swf;
application/vnd.adobe.formscentral.fcdt		fcdt;
application/vnd.adobe.fxp			fxp fxpl;
application/vnd.adobe.xdp+xml			xdp;
application/vnd.adobe.xfdf			xfdf;
application/vnd.afpc.modca			list3820 listafp afp pseg3820;
application/vnd.afpc.modca-overlay		ovl;
application/vnd.afpc.modca-pagesegment		psg;
application/vnd.ahead.space			ahead;
application/vnd.airzip.filesecure.azf		azf;
application/vnd.airzip.filesecure.azs		azs;
application/vnd.amazon.mobi8-ebook		azw3;
application/vnd.americandynamics.acc		acc;
application/vnd.amiga.ami			ami;
application/vnd.android.ota			ota;
application/vnd.anki				apkg;
application/vnd.anser-web-certificate-issue-initiation	cii;
application/vnd.anser-web-funds-transfer-initiation	fti;
application/vnd.apple.installer+xml		dist distz pkg mpkg;
application/vnd.apple.keynote			keynote;
application/vnd.apple.mpegurl			m3u8;
application/vnd.apple.numbers			numbers;
application/vnd.apple.pages			pages;
application/vnd.aristanetworks.swi		swi;
application/vnd.artisan+json			artisan;
application/vnd.astraea-software.iota		iota;
application/vnd.audiograph			aep;
application/vnd.autopackage			package;
application/vnd.balsamiq.bmml+xml		bmml;
application/vnd.banana-accounting		ac2;
application/vnd.balsamiq.bmpr			bmpr;
application/vnd.blueice.multipass		mpm;
application/vnd.bluetooth.ep.oob		ep;
application/vnd.bluetooth.le.oob		le;
application/vnd.bmi				bmi;
application/vnd.businessobjects			rep;
application/vnd.cendio.thinlinc.clientconf	tlclient;
application/vnd.chemdraw+xml			cdxml;
application/vnd.chess-pgn			pgn;
application/vnd.chipnuts.karaoke-mmd		mmd;
application/vnd.cinderella			cdy;
application/vnd.citationstyles.style+xml	csl;
application/vnd.claymore			cla;
application/vnd.cloanto.rp9			rp9;
application/vnd.clonk.c4group			c4g c4d c4f c4p c4u;
application/vnd.cluetrust.cartomobile-config	c11amc;
application/vnd.cluetrust.cartomobile-config-pkg	c11amz;
application/vnd.coffeescript			coffee;
application/vnd.collabio.xodocuments.document	xodt;
application/vnd.collabio.xodocuments.document-template	xott;
application/vnd.collabio.xodocuments.presentation	xodp;
application/vnd.collabio.xodocuments.presentation-template	xotp;
application/vnd.collabio.xodocuments.spreadsheet	xods;
application/vnd.collabio.xodocuments.spreadsheet-template	xots;
application/vnd.comicbook-rar			cbr;
application/vnd.comicbook+zip			cbz;
application/vnd.commerce-battelle	ica icf icd ic0 ic1 ic2 ic3 ic4 ic5 ic6 ic7 ic8;
application/vnd.commonspace			csp cst;
application/vnd.contact.cmsg			cdbcmsg;
application/vnd.coreos.ignition+json		ign ignition;
application/vnd.cosmocaller			cmc;
application/vnd.crick.clicker			clkx;
application/vnd.crick.clicker.keyboard		clkk;
application/vnd.crick.clicker.palette		clkp;
application/vnd.crick.clicker.template		clkt;
application/vnd.crick.clicker.wordbank		clkw;
application/vnd.criticaltools.wbs+xml		wbs;
application/vnd.crypto-shade-file		ssvc;
application/vnd.cryptomator.encrypted   c9r c9s;
application/vnd.cryptomator.vault       cryptomator;
application/vnd.ctc-posml			pml;
application/vnd.cups-ppd			ppd;
application/vnd.curl				curl;
application/vnd.dart				dart;
application/vnd.data-vision.rdz			rdz;
application/vnd.dbf				dbf;
application/vnd.debian.binary-package		deb udeb;
application/vnd.dece.data			uvf uvvf uvd uvvd;
application/vnd.dece.ttml+xml			uvt uvvt;
application/vnd.dece.unspecified		uvx uvvx;
application/vnd.dece.zip			uvz uvvz;
application/vnd.denovo.fcselayout-link		fe_launch;
application/vnd.desmume.movie			dsm;
application/vnd.dna				dna;
application/vnd.document+json			docjson;
application/vnd.doremir.scorecloud-binary-document	scld;
application/vnd.dpgraph				dpg mwc dpgraph;
application/vnd.dreamfactory			dfac;
application/vnd.dtg.local.flash			fla;
application/vnd.dvb.ait				ait;
application/vnd.dvb.service			svc;
application/vnd.dynageo				geo;
application/vnd.dzr				dzr;
application/vnd.ecowin.chart			mag;
application/vnd.enliven				nml;
application/vnd.epson.esf			esf;
application/vnd.epson.msf			msf;
application/vnd.epson.quickanime		qam;
application/vnd.epson.salt			slt;
application/vnd.epson.ssf			ssf;
application/vnd.ericsson.quickcall		qcall qca;
application/vnd.espass-espass+zip		espass;
application/vnd.eszigno3+xml			es3 et3;
application/vnd.etsi.asic-e+zip			asice sce;
application/vnd.etsi.asic-s+zip			asics;
application/vnd.etsi.timestamp-token		tst;
application/vnd.exstream-empower+zip		mpw;
application/vnd.exstream-package		pub;
application/vnd.evolv.ecig.profile		ecigprofile;
application/vnd.evolv.ecig.settings		ecig;
application/vnd.evolv.ecig.theme		ecigtheme;
application/vnd.ezpix-album			ez2;
application/vnd.ezpix-package			ez3;
application/vnd.fastcopy-disk-image		dim;
application/vnd.fdf				fdf;
application/vnd.fdsn.mseed			msd mseed;
application/vnd.fdsn.seed			seed dataless;
application/vnd.ficlab.flb+zip			flb;
application/vnd.filmit.zfc			zfc;
application/vnd.FloGraphIt			gph;
application/vnd.fluxtime.clip			ftc;
application/vnd.font-fontforge-sfd		sfd;
application/vnd.framemaker			fm;
application/vnd.frogans.fnc			fnc;
application/vnd.frogans.ltf			ltf;
application/vnd.fsc.weblaunch			fsc;
application/vnd.fujitsu.oasys			oas;
application/vnd.fujitsu.oasys2			oa2;
application/vnd.fujitsu.oasys3			oa3;
application/vnd.fujitsu.oasysgp			fg5;
application/vnd.fujitsu.oasysprs		bh2;
application/vnd.fujixerox.ddd			ddd;
application/vnd.fujixerox.docuworks     xdw;
application/vnd.fujixerox.docuworks.binder      xbd;
application/vnd.fujixerox.docuworks.container       xct;
application/vnd.fuzzysheet			fzs;
application/vnd.genomatix.tuxedo		txd;
application/vnd.geocube+xml			g3 g³;
application/vnd.geogebra.file			ggb;
application/vnd.geogebra.slides         ggs;
application/vnd.geogebra.tool			ggt;
application/vnd.geometry-explorer		gex gre;
application/vnd.geonext				gxt;
application/vnd.geoplan				g2w;
application/vnd.geospace			g3w;
application/vnd.gmx				gmx;
application/vnd.google-earth.kml+xml		kml;
application/vnd.google-earth.kmz		kmz;
application/vnd.grafeq				gqf gqs;
application/vnd.groove-account			gac;
application/vnd.groove-help			ghf;
application/vnd.groove-identity-message		gim;
application/vnd.groove-injector			grv;
application/vnd.groove-tool-message		gtm;
application/vnd.groove-tool-template		tpl;
application/vnd.groove-vcard			vcg;
application/vnd.hal+xml				hal;
application/vnd.HandHeld-Entertainment+xml	zmm;
application/vnd.hbci				hbci hbc kom upa pkd bpd;
application/vnd.hdt				hdt;
application/vnd.hhe.lesson-player		les;
application/vnd.hp-HPGL				hpgl;
application/vnd.hp-hpid				hpi hpid;
application/vnd.hp-hps				hps;
application/vnd.hp-jlyt				jlt;
application/vnd.hp-PCL				pcl;
application/vnd.hydrostatix.sof-data		sfd-hdstx;
application/vnd.hzn-3d-crossword		x3d;
application/vnd.ibm.electronic-media		emm;
application/vnd.ibm.MiniPay			mpy;
application/vnd.ibm.rights-management		irm;
application/vnd.ibm.secure-container		sc;
application/vnd.iccprofile			icc icm;
application/vnd.ieee.1905			1905.1;
application/vnd.igloader			igl;
application/vnd.imagemeter.folder+zip		imf;
application/vnd.imagemeter.image+zip		imi;
application/vnd.immervision-ivp			ivp;
application/vnd.immervision-ivu			ivu;
application/vnd.ims.imsccv1p1			imscc;
application/vnd.insors.igm			igm;
application/vnd.intercon.formnet		xpw xpx;
application/vnd.intergeo			i2g;
application/vnd.intu.qbo			qbo;
application/vnd.intu.qfx			qfx;
application/vnd.ipunplugged.rcprofile		rcprofile;
application/vnd.irepository.package+xml		irp;
application/vnd.is-xpr				xpr;
application/vnd.isac.fcs			fcs;
application/vnd.jam				jam;
application/vnd.jcp.javame.midlet-rms		rms;
application/vnd.jisp				jisp;
application/vnd.joost.joda-archive		joda;
application/vnd.kahootz				ktz ktr;
application/vnd.kde.karbon			karbon;
application/vnd.kde.kchart			chrt;
application/vnd.kde.kformula			kfo;
application/vnd.kde.kivio			flw;
application/vnd.kde.kontour			kon;
application/vnd.kde.kpresenter			kpr kpt;
application/vnd.kde.kspread			ksp;
application/vnd.kde.kword			kwd kwt;
application/vnd.kenameaapp			htke;
application/vnd.kidspiration			kia;
application/vnd.Kinar				kne knp sdf;
application/vnd.koan				skp skd skm skt;
application/vnd.kodak-descriptor		sse;
application/vnd.las                 las;
application/vnd.las.las+json			lasjson;
application/vnd.las.las+xml			lasxml;
application/vnd.llamagraphics.life-balance.desktop	lbd;
application/vnd.llamagraphics.life-balance.exchange+xml	lbe;
application/vnd.logipipe.circuit+zip		lcs lca;
application/vnd.loom				loom;
application/vnd.lotus-1-2-3			123 wk4 wk3 wk1;
application/vnd.lotus-approach			apr vew;
application/vnd.lotus-freelance			prz pre;
application/vnd.lotus-notes			nsf ntf ndl ns4 ns3 ns2 nsh nsg;
application/vnd.lotus-organizer			or3 or2 org;
application/vnd.lotus-screencam			scm;
application/vnd.lotus-wordpro			lwp sam;
application/vnd.macports.portpkg		portpkg;
application/vnd.mapbox-vector-tile		mvt;
application/vnd.marlin.drm.mdcf			mdc;
application/vnd.maxmind.maxmind-db		mmdb;
application/vnd.mcd				mcd;
application/vnd.medcalcdata			mc1;
application/vnd.mediastation.cdkey		cdkey;
application/vnd.MFER				mwf;
application/vnd.mfmp				mfm;
application/vnd.micrografx.flo			flo;
application/vnd.micrografx.igx			igx;
application/vnd.mif				mif;
application/vnd.Mobius.DAF			daf;
application/vnd.Mobius.DIS			dis;
application/vnd.Mobius.MBK			mbk;
application/vnd.Mobius.MQY			mqy;
application/vnd.Mobius.MSL			msl;
application/vnd.Mobius.PLC			plc;
application/vnd.Mobius.TXF			txf;
application/vnd.mophun.application		mpn;
application/vnd.mophun.certificate		mpc;
application/vnd.mozilla.xul+xml			xul;
application/vnd.ms-3mfdocument			3mf;
application/vnd.ms-artgalry			cil;
application/vnd.ms-asf				asf;
application/vnd.ms-cab-compressed		cab;
application/vnd.ms-excel			xls xlm xla xlc xlt xlw;
application/vnd.ms-excel.template.macroEnabled.12	xltm;
application/vnd.ms-excel.addin.macroEnabled.12	xlam;
application/vnd.ms-excel.sheet.binary.macroEnabled.12	xlsb;
application/vnd.ms-excel.sheet.macroEnabled.12	xlsm;
application/vnd.ms-fontobject			eot;
application/vnd.ms-htmlhelp			chm;
application/vnd.ms-ims				ims;
application/vnd.ms-lrm				lrm;
application/vnd.ms-officetheme			thmx;
application/vnd.ms-powerpoint			ppt pps pot;
application/vnd.ms-powerpoint.addin.macroEnabled.12	ppam;
application/vnd.ms-powerpoint.presentation.macroEnabled.12	pptm;
application/vnd.ms-powerpoint.slide.macroEnabled.12	sldm;
application/vnd.ms-powerpoint.slideshow.macroEnabled.12	ppsm;
application/vnd.ms-powerpoint.template.macroEnabled.12	potm;
application/vnd.ms-project			mpp mpt;
application/vnd.ms-tnef				tnef tnf;
application/vnd.ms-word.document.macroEnabled.12	docm;
application/vnd.ms-word.template.macroEnabled.12	dotm;
application/vnd.ms-works			wcm wdb wks wps;
application/vnd.ms-wpl				wpl;
application/vnd.ms-xpsdocument			xps;
application/vnd.msa-disk-image			msa;
application/vnd.mseq				mseq;
application/vnd.multiad.creator			crtr;
application/vnd.multiad.creator.cif		cif;
application/vnd.musician			mus;
application/vnd.muvee.style			msty;
application/vnd.mynfc				taglet;
application/vnd.nebumind.line       nebul line;
application/vnd.nervana				entity request bkm kcm;
application/vnd.nimn				nimn;
application/vnd.nitf				nitf;
application/vnd.neurolanguage.nlu		nlu;
application/vnd.nintendo.nitro.rom		nds;
application/vnd.nintendo.snes.rom		sfc smc;
application/vnd.noblenet-directory		nnd;
application/vnd.noblenet-sealer			nns;
application/vnd.noblenet-web			nnw;
application/vnd.nokia.n-gage.ac+xml		ac;
application/vnd.nokia.n-gage.data		ngdat;
application/vnd.nokia.n-gage.symbian.install	n-gage;
application/vnd.nokia.radio-preset		rpst;
application/vnd.nokia.radio-presets		rpss;
application/vnd.novadigm.EDM			edm;
application/vnd.novadigm.EDX			edx;
application/vnd.novadigm.EXT			ext;
application/vnd.oasis.opendocument.chart			odc;
application/vnd.oasis.opendocument.chart-template		otc;
application/vnd.oasis.opendocument.database			odb;
application/vnd.oasis.opendocument.formula			odf;
application/vnd.oasis.opendocument.graphics			odg;
application/vnd.oasis.opendocument.graphics-template		otg;
application/vnd.oasis.opendocument.image			odi;
application/vnd.oasis.opendocument.image-template		oti;
application/vnd.oasis.opendocument.presentation			odp;
application/vnd.oasis.opendocument.presentation-template	otp;
application/vnd.oasis.opendocument.spreadsheet			ods;
application/vnd.oasis.opendocument.spreadsheet-template		ots;
application/vnd.oasis.opendocument.text				odt;
application/vnd.oasis.opendocument.text-master			odm;
application/vnd.oasis.opendocument.text-template		ott;
application/vnd.oasis.opendocument.text-web			oth;
application/vnd.olpc-sugar			xo;
application/vnd.oma.dd2+xml			dd2;
application/vnd.onepager			tam;
application/vnd.onepagertamp			tamp;
application/vnd.onepagertamx			tamx;
application/vnd.onepagertat			tat;
application/vnd.onepagertatp			tatp;
application/vnd.onepagertatx			tatx;
application/vnd.openblox.game+xml		obgx;
application/vnd.openblox.game-binary		obg;
application/vnd.openeye.oeb			oeb;
application/vnd.openofficeorg.extension		oxt;
application/vnd.openstreetmap.data+xml		osm;
application/vnd.openxmlformats-officedocument.presentationml.presentation pptx;
application/vnd.openxmlformats-officedocument.presentationml.slide	sldx;
application/vnd.openxmlformats-officedocument.presentationml.slideshow	ppsx;
application/vnd.openxmlformats-officedocument.presentationml.template	potx;
application/vnd.openxmlformats-officedocument.spreadsheetml.sheet	xlsx;
application/vnd.openxmlformats-officedocument.spreadsheetml.template	xltx;
application/vnd.openxmlformats-officedocument.wordprocessingml.document	docx;
application/vnd.openxmlformats-officedocument.wordprocessingml.template	dotx;
application/vnd.osa.netdeploy			ndc;
application/vnd.osgeo.mapguide.package		mgp;
application/vnd.osgi.dp				dp;
application/vnd.osgi.subsystem			esa;
application/vnd.oxli.countgraph			oxlicg;
application/vnd.palm				prc pdb pqa oprc;
application/vnd.panoply				plp;
application/vnd.patentdive			dive;
application/vnd.pawaafile			paw;
application/vnd.pg.format		    	str;
application/vnd.pg.osasli			ei6;
application/vnd.piaccess.application-licence	pil;
application/vnd.picsel				efif;
application/vnd.pmi.widget			wg;
application/vnd.pocketlearn			plf;
application/vnd.powerbuilder6			pbd;
application/vnd.preminet			preminet;
application/vnd.previewsystems.box		box vbox;
application/vnd.proteus.magazine		mgz;
application/vnd.psfs				psfs;
application/vnd.publishare-delta-tree		qps;
application/vnd.pvi.ptid1			ptid;
application/vnd.qualcomm.brew-app-res		bar;
application/vnd.Quark.QuarkXPress		qxd qxt qwd qwt qxl qxb;
application/vnd.quobject-quoxdocument		quox quiz;
application/vnd.rainstor.data			tree;
application/vnd.rar				rar;
application/vnd.realvnc.bed			bed;
application/vnd.recordare.musicxml		mxl;
application/vnd.rig.cryptonote			cryptonote;
application/vnd.route66.link66+xml		link66;
application/vnd.sailingtracker.track		st;
application/vnd.sar				SAR;
application/vnd.scribus				scd sla slaz;
application/vnd.sealed.3df			s3df;
application/vnd.sealed.csf			scsf;
application/vnd.sealed.doc			sdoc sdo s1w;
application/vnd.sealed.eml			seml sem;
application/vnd.sealed.mht			smht smh;
application/vnd.sealed.ppt			sppt s1p;
application/vnd.sealed.tiff			stif;
application/vnd.sealed.xls			sxls sxl s1e;
application/vnd.sealedmedia.softseal.html	stml s1h;
application/vnd.sealedmedia.softseal.pdf	spdf spd s1a;
application/vnd.seemail				see;
application/vnd.sema				sema;
application/vnd.semd				semd;
application/vnd.semf				semf;
application/vnd.shade-save-file			ssv;
application/vnd.shana.informed.formdata		ifm;
application/vnd.shana.informed.formtemplate	itp;
application/vnd.shana.informed.interchange	iif;
application/vnd.shana.informed.package		ipk;
application/vnd.shp				shp;
application/vnd.shx				shx;
application/vnd.sigrok.session			sr;
application/vnd.SimTech-MindMapper		twd twds;
application/vnd.smaf				mmf;
application/vnd.smart.notebook			notebook;
application/vnd.smart.teacher			teacher;
application/vnd.snesdev-page-table		ptrom pt;
application/vnd.software602.filler.form+xml	fo;
application/vnd.software602.filler.form-xml-zip	zfo;
application/vnd.solent.sdkm+xml			sdkm sdkd;
application/vnd.spotfire.dxp			dxp;
application/vnd.spotfire.sfs			sfs;
application/vnd.sqlite3				sqlite sqlite3;
application/vnd.stepmania.package		smzip;
application/vnd.stepmania.stepchart		sm;
application/vnd.sun.wadl+xml			wadl;
application/vnd.sus-calendar			sus susp;
application/vnd.sycle+xml           scl;
application/vnd.syncml+xml			xsm;
application/vnd.syncml.dm+wbxml			bdm;
application/vnd.syncml.dm+xml			xdm;
application/vnd.syncml.dmddf+xml		ddf;
application/vnd.tao.intent-module-archive	tao;
application/vnd.tcpdump.pcap			pcap cap dmp;
application/vnd.theqvd				qvd;
application/vnd.think-cell.ppttc+json		ppttc;
application/vnd.tml				vfr viaframe;
application/vnd.tmobile-livetv			tmo;
application/vnd.trid.tpt			tpt;
application/vnd.triscape.mxs			mxs;
application/vnd.trueapp				tra;
application/vnd.ufdl				ufdl ufd frm;
application/vnd.uiq.theme			utz;
application/vnd.umajin				umj;
application/vnd.unity				unityweb;
application/vnd.uoml+xml			uoml uo;
application/vnd.uri-map				urim urimap;
application/vnd.valve.source.material		vmt;
application/vnd.vcx				vcx;
application/vnd.vd-study			mxi study-inter model-inter;
application/vnd.vectorworks			vwx;
application/vnd.veryant.thin			istc isws;
application/vnd.ves.encrypted			VES;
application/vnd.vidsoft.vidconference		vsc;
application/vnd.visio				vsd vst vsw vss;
application/vnd.visionary			vis;
application/vnd.vsf				vsf;
application/vnd.wap.sic				sic;
application/vnd.wap.slc				slc;
application/vnd.wap.wbxml			wbxml;
application/vnd.wap.wmlc			wmlc;
application/vnd.wap.wmlscriptc			wmlsc;
application/vnd.webturbo			wtb;
application/vnd.wfa.p2p				p2p;
application/vnd.wfa.wsc				wsc;
application/vnd.wmc				wmc;
application/vnd.wolfram.mathematica.package	m;
application/vnd.wolfram.player			nbp;
application/vnd.wordperfect			wpd;
application/vnd.wqd				wqd;
application/vnd.wt.stf				stf;
application/vnd.wv.csp+wbxml			wv;
application/vnd.xara				xar;
application/vnd.xfdl				xfdl xfd;
application/vnd.xmpie.cpkg			cpkg;
application/vnd.xmpie.dpkg			dpkg;
application/vnd.xmpie.ppkg			ppkg;
application/vnd.xmpie.xlim			xlim;
application/vnd.yamaha.hv-dic			hvd;
application/vnd.yamaha.hv-script		hvs;
application/vnd.yamaha.hv-voice			hvp;
application/vnd.yamaha.openscoreformat		osf;
application/vnd.yamaha.smaf-audio		saf;
application/vnd.yamaha.smaf-phrase		spf;
application/vnd.yaoweme				yme;
application/vnd.yellowriver-custom-menu		cmp;
application/vnd.zul				zir zirz;
application/vnd.zzazz.deck+xml			zaz;
application/voicexml+xml			vxml;
application/voucher-cms+json			vcj;
application/wasm                    wasm;
application/watcherinfo+xml			wif;
application/widget				wgt;
application/wsdl+xml				wsdl;
application/wspolicy+xml			wspolicy;
application/xcap-att+xml			xav;
application/xcap-caps+xml			xca;
application/xcap-diff+xml			xdf;
application/xcap-el+xml				xel;
application/xcap-error+xml			xer;
application/xcap-ns+xml				xns;
application/xhtml+xml				xhtml xhtm xht;
application/xliff+xml				xlf;
application/xml-dtd				dtd;
application/xop+xml				xop;
application/xslt+xml				xsl xslt;
application/xv+xml				mxml xhvml xvml xvm;
application/yang				yang;
application/yin+xml				yin;
application/zip					zip;
application/zstd				zst;
audio/32kadpcm					726;
audio/aac					adts aac ass;
audio/ac3					ac3;
audio/AMR					amr;
audio/AMR-WB					awb;
audio/asc					acn;
audio/ATRAC-ADVANCED-LOSSLESS			aal;
audio/ATRAC-X					atx;
audio/ATRAC3					at3 aa3 omg;
audio/basic					au snd;
audio/dls					dls;
audio/EVRC					evc;
audio/EVRCB					evb;
audio/EVRCNW					enw;
audio/EVRCWB					evw;
audio/iLBC					lbc;
audio/L16					l16;
audio/mhas					mhas;
audio/mobile-xmf				mxmf;
audio/mp4					m4a;
audio/mpeg					mp3 mpga mp1 mp2;
audio/ogg					oga ogg opus spx;
audio/prs.sid					sid psid;
audio/QCELP					qcp;
audio/SMV					smv;
audio/sofa                  sofa;
audio/usac					loas xhe;
audio/vnd.audiokoz				koz;
audio/vnd.dece.audio				uva uvva;
audio/vnd.digital-winds				eol;
audio/vnd.dolby.mlp				mlp;
audio/vnd.dts					dts;
audio/vnd.dts.hd				dtshd;
audio/vnd.everad.plj				plj;
audio/vnd.lucent.voice				lvp;
audio/vnd.ms-playready.media.pya		pya;
audio/vnd.nortel.vbk				vbk;
audio/vnd.nuera.ecelp4800			ecelp4800;
audio/vnd.nuera.ecelp7470			ecelp7470;
audio/vnd.nuera.ecelp9600			ecelp9600;
audio/vnd.presonus.multitrack			multitrack;
audio/vnd.rip					rip;
audio/vnd.sealedmedia.softseal.mpeg		smp3 smp s1m;
font/collection					ttc;
font/otf					otf;
font/ttf					ttf;
font/woff					woff;
font/woff2					woff2;
image/aces					exr;
image/avci					avci;
image/avcs					avcs;
image/avif                  avif hif;
image/bmp					bmp dib;
image/cgm					cgm;
image/dicom-rle					drle;
image/emf					emf;
image/fits					fits fit fts;
image/heic					heic;
image/heic-sequence				heics;
image/heif					heif;
image/heif-sequence				heifs;
image/hej2k					hej2;
image/hsj2					hsj2;
image/gif					gif;
image/ief					ief;
image/jls					jls;
image/jp2					jp2 jpg2;
image/jph					jph;
image/jphc					jhc;
image/jpeg					jpg jpeg jpe jfif;
image/jpm					jpm jpgm;
image/jpx					jpx jpf;
image/jxl                   jxl;
image/jxr					jxr;
image/jxrA					jxra;
image/jxrS					jxrs;
image/jxs					jxs;
image/jxsc					jxsc;
image/jxsi					jxsi;
image/jxss					jxss;
image/ktx					ktx;
image/ktx2                  ktx2;
image/png					png;
image/prs.btif					btif btf;
image/prs.pti					pti;
image/svg+xml					svg svgz;
image/t38					t38;
image/tiff					tiff tif;
image/tiff-fx					tfx;
image/vnd.adobe.photoshop			psd;
image/vnd.airzip.accelerator.azv		azv;
image/vnd.dece.graphic				uvi uvvi uvg uvvg;
image/vnd.djvu					djvu djv;
image/vnd.dwg					dwg;
image/vnd.dxf					dxf;
image/vnd.fastbidsheet				fbs;
image/vnd.fpx					fpx;
image/vnd.fst					fst;
image/vnd.fujixerox.edmics-mmr			mmr;
image/vnd.fujixerox.edmics-rlc			rlc;
image/vnd.globalgraphics.pgb			pgb;
image/vnd.microsoft.icon			ico;
image/vnd.mozilla.apng				apng;
image/vnd.ms-modi				mdi;
image/vnd.pco.b16               b16;
image/vnd.radiance				hdr rgbe xyze;
image/vnd.sealed.png				spng spn s1n;
image/vnd.sealedmedia.softseal.gif		sgif sgi s1g;
image/vnd.sealedmedia.softseal.jpg		sjpg sjp s1j;
image/vnd.tencent.tap				tap;
image/vnd.valve.source.texture			vtf;
image/vnd.wap.wbmp				wbmp;
image/vnd.xiff					xif;
image/vnd.zbrush.pcx				pcx;
image/wmf					wmf;
message/global					u8msg;
message/global-delivery-status			u8dsn;
message/global-disposition-notification		u8mdn;
message/global-headers				u8hdr;
message/rfc822					eml mail art;
model/gltf-binary				glb;
model/gltf+json					gltf;
model/iges					igs iges;
model/mesh					msh mesh silo;
model/mtl					mtl;
model/obj					obj;
model/stl					stl;
model/vnd.collada+xml				dae;
model/vnd.dwf					dwf;
model/vnd.gdl					gdl gsm win dor lmp rsm msm ism;
model/vnd.gtw					gtw;
model/vnd.moml+xml				moml;
model/vnd.mts					mts;
model/vnd.opengex				ogex;
model/vnd.parasolid.transmit.binary		x_b xmt_bin;
model/vnd.parasolid.transmit.text		x_t xmt_txt;
model/vnd.pytha.pyox            pyo pyox;
model/vnd.sap.vds               vds;
model/vnd.usdz+zip				usdz;
model/vnd.valve.source.compiled-map		bsp;
model/vnd.vtu					vtu;
model/vrml					wrl vrml;
model/x3d+xml					x3db;
model/x3d-vrml					x3dv x3dvz;
multipart/vnd.bint.med-plus			bmed;
multipart/voice-message				vpm;
text/cache-manifest				appcache manifest;
text/calendar					ics ifb;
text/cql                    CQL;
text/css					css;
text/csv					csv;
text/csv-schema					csvs;
text/dns					soa zone;
text/gff3                   gff3;
text/html					html htm;
text/jcr-cnd					cnd;
text/markdown					markdown md;
text/mizar					miz;
text/n3						n3;
text/plain		txt asc text pm el c h cc hh cxx hxx f90 conf log;
text/provenance-notation			provn;
text/prs.fallenstein.rst			rst;
text/prs.lines.tag				tag dsc;
text/richtext					rtx;
text/SGML					sgml sgm;
text/shaclc                 shaclc shc;
text/spdx                   spdx;
text/tab-separated-values			tsv;
text/troff					t tr roff;
text/turtle					ttl;
text/uri-list					uris uri;
text/vcard					vcf vcard;
text/vnd.a					a;
text/vnd.abc					abc;
text/vnd.ascii-art				ascii;
text/vnd.debian.copyright			copyright;
text/vnd.DMClientScript				dms;
text/vnd.dvb.subtitle				sub;
text/vnd.esmertec.theme-descriptor		jtd;
text/vnd.ficlab.flt				flt;
text/vnd.fly					fly;
text/vnd.fmi.flexstor				flx;
text/vnd.graphviz				gv dot;
text/vnd.hans                   hans;
text/vnd.hgl					hgl;
text/vnd.in3d.3dml				3dml 3dm;
text/vnd.in3d.spot				spot spo;
text/vnd.ms-mediapackage			mpf;
text/vnd.net2phone.commcenter.command		ccc;
text/vnd.senx.warpscript			mc2;
text/vnd.si.uricatalogue			uric;
text/vnd.sun.j2me.app-descriptor		jad;
text/vnd.sosi					sos;
text/vnd.trolltech.linguist			ts;
text/vnd.wap.si					si;
text/vnd.wap.sl					sl;
text/vnd.wap.wml				wml;
text/vnd.wap.wmlscript				wmls;
text/vtt					vtt;
text/xml					xml xsd rng;
text/xml-external-parsed-entity			ent;
video/3gpp					3gp 3gpp;
video/3gpp2					3g2 3gpp2;
video/iso.segment				m4s;
video/mj2					mj2 mjp2;
video/mp4					mp4 mpg4 m4v;
video/mpeg					mpeg mpg mpe m1v m2v;
video/ogg					ogv;
video/quicktime					mov qt;
video/vnd.dece.hd				uvh uvvh;
video/vnd.dece.mobile				uvm uvvm;
video/vnd.dece.mp4				uvu uvvu;
video/vnd.dece.pd				uvp uvvp;
video/vnd.dece.sd				uvs uvvs;
video/vnd.dece.video				uvv uvvv;
video/vnd.dvb.file				dvb;
video/vnd.fvt					fvt;
video/vnd.mpegurl				mxu m4u;
video/vnd.ms-playready.media.pyv		pyv;
video/vnd.nokia.interleaved-multimedia		nim;
video/vnd.radgamettools.bink			bik bk2;
video/vnd.radgamettools.smacker			smk;
video/vnd.sealed.mpeg1				smpg s11;
video/vnd.sealed.mpeg4				s14;
video/vnd.sealed.swf				sswf ssw;
video/vnd.sealedmedia.softseal.mov		smov smo s1q;
video/vnd.youtube.yt				yt;
video/vnd.vivo					viv;
application/mac-compactpro			cpt;
application/metalink+xml			metalink;
application/owl+xml				owx;
application/rss+xml				rss;
application/vnd.android.package-archive		apk;
application/vnd.oma.dd+xml			dd;
application/vnd.oma.drm.content			dcf;
application/vnd.oma.drm.dcf			o4a o4v;
application/vnd.oma.drm.message			dm;
application/vnd.oma.drm.rights+wbxml		drc;
application/vnd.oma.drm.rights+xml		dr;
application/vnd.sun.xml.calc			sxc;
application/vnd.sun.xml.calc.template		stc;
application/vnd.sun.xml.draw			sxd;
application/vnd.sun.xml.draw.template		std;
application/vnd.sun.xml.impress			sxi;
application/vnd.sun.xml.impress.template	sti;
application/vnd.sun.xml.math			sxm;
application/vnd.sun.xml.writer			sxw;
application/vnd.sun.xml.writer.global		sxg;
application/vnd.sun.xml.writer.template		stw;
application/vnd.symbian.install			sis;
application/vnd.wap.mms-message			mms;
application/x-annodex				anx;
application/x-bcpio				bcpio;
application/x-bittorrent			torrent;
application/x-bzip2				bz2;
application/x-cdlink				vcd;
application/x-chrome-extension			crx;
application/x-cpio				cpio;
application/x-csh				csh;
application/x-director				dcr dir dxr;
application/x-dvi				dvi;
application/x-futuresplash			spl;
application/x-gtar				gtar;
application/x-hdf				hdf;
application/x-java-archive			jar;
application/x-java-jnlp-file			jnlp;
application/x-java-pack200			pack;
application/x-killustrator			kil;
application/x-latex				latex;
application/x-netcdf				nc cdf;
application/x-perl				pl;
application/x-rpm				rpm;
application/x-sh				sh;
application/x-shar				shar;
application/x-stuffit				sit;
application/x-sv4cpio				sv4cpio;
application/x-sv4crc				sv4crc;
application/x-tar				tar;
application/x-tcl				tcl;
application/x-tex				tex;
application/x-texinfo				texinfo texi;
application/x-troff-man				man 1 2 3 4 5 6 7 8;
application/x-troff-me				me;
application/x-troff-ms				ms;
application/x-ustar				ustar;
application/x-wais-source			src;
application/x-xpinstall				xpi;
application/x-xspf+xml				xspf;
application/x-xz				xz;
audio/midi					mid midi kar;
audio/x-aiff					aif aiff aifc;
audio/x-annodex					axa;
audio/x-flac					flac;
audio/x-matroska				mka;
audio/x-mod					mod ult uni m15 mtm 669 med;
audio/x-mpegurl					m3u;
audio/x-ms-wax					wax;
audio/x-ms-wma					wma;
audio/x-pn-realaudio				ram rm;
audio/x-realaudio				ra;
audio/x-s3m					s3m;
audio/x-stm					stm;
audio/x-wav					wav;
chemical/x-xyz					xyz;
image/webp					webp;
image/x-cmu-raster				ras;
image/x-portable-anymap				pnm;
image/x-portable-bitmap				pbm;
image/x-portable-graymap			pgm;
image/x-portable-pixmap				ppm;
image/x-rgb					rgb;
image/x-targa					tga;
image/x-xbitmap					xbm;
image/x-xpixmap					xpm;
image/x-xwindowdump				xwd;
text/html-sandboxed				sandboxed;
text/x-pod					pod;
text/x-setext					etx;
video/webm					webm;
video/x-annodex					axv;
video/x-flv					flv;
video/x-javafx					fxm;
video/x-matroska				mkv;
video/x-matroska-3d				mk3d;
video/x-ms-asf					asx;
video/x-ms-wm					wm;
video/x-ms-wmv					wmv;
video/x-ms-wmx					wmx;
video/x-ms-wvx					wvx;
video/x-msvideo					avi;
video/x-sgi-movie				movie;
x-conference/x-cooltalk				ice;
x-epoc/x-sisx-app				sisx;
}
" > "${NGINXGENERATED}/mime.types"
}
fi



if [[ ! -e "${NGINXGENERATED}/gzip.conf"  ]] ; then
{
echo "# ${NGINXGENERATED}/gzip.conf
    gzip              on;
    gzip_disable      \"msie6\";
    gzip_comp_level   5;
    gzip_min_length   256;
    gzip_proxied      any;
    gzip_vary         on;


    # gzip on;
    # gzip_disable \"msie6\";
    # gzip_comp_level 5;
    # gzip_min_length 256;
    # gzip_proxied any;
    # gzip_vary on;

    # gzip_types
    # application/atom+xml
    # application/javascript
    # application/json
    # application/rss+xml
    # application/vnd.ms-fontobject
    # application/x-font-ttf
    # application/x-web-app-manifest+json
    # application/xhtml+xml
    # application/xml
    # font/opentype
    # image/svg+xml
    # image/x-icon
    # text/css
    # text/plain
    # text/x-component;

    gzip_types
    application/atom+xml
    application/javascript
    application/json
    application/ld+json
    application/manifest+json
    application/rss+xml
    application/vnd.geo+json
    application/vnd.ms-fontobject
    application/x-font-ttf
    application/x-web-app-manifest+json
    application/xhtml+xml
    application/xml
    font/opentype
    image/bmp
    image/svg+xml
    image/x-icon
    text/cache-manifest
    text/css
    text/plain
    text/vcard
    text/vnd.rim.location.xloc
    text/vtt
    text/x-component
    text/x-cross-domain-policy;


" > "${NGINXGENERATED}/gzip.conf"
}
fi


if [[ ! -e "${NGINXGENERATED}/php-fpm.conf"  ]] ; then
{
echo "# ${NGINXGENERATED}/php-fpm.conf

# PHP-FPM FastCGI server
# network or unix domain socket configuration

upstream php-fpm {
        server \"${FPMSOCK}\";
}
" > "${NGINXGENERATED}/php-fpm.conf"
}
fi





if [[ ! -e "${NGINXGENERATED}/restrictions.conf"  ]] ; then
{
echo "# ${NGINXGENERATED}/restrictions.conf
# Global restrictions configuration file.
# Designed to be included in any server {} block.
# ESSENTIAL : no favicon logs
location = /favicon.ico {
	log_not_found off;
	access_log off;
}
# ESSENTIAL : robots.txt
location = /robots.txt {
	allow all;
	log_not_found off;
	access_log off;
}
# ESSENTIAL : Configure 404 Pages
error_page 404 /404.html;
# ESSENTIAL : Configure 50x Pages
error_page 500 502 503 504 /50x.html;
# location = /50x.html {
    # root /usr/share/nginx/www;
# }
# SECURITY : Deny all attempts to access hidden files .abcde
# Deny all attempts to access hidden files such as .htaccess, .htpasswd, .DS_Store (Mac).
# Keep logging the requests to parse later (or to pass to firewall utilities such as fail2ban)
location ~ /\\. {
	deny all;
	return 404;
}
# SECURITY : Deny all attempts to access PHP Files in the uploads directory
# Deny access to any files with a .php extension in the uploads directory
# Works in sub-directory installs and also in multisite network
# Keep logging the requests to parse later (or to pass to firewall utilities such as fail2ban)
# location ~* /(?:uploads)/.*\\.php\$ {
location ~* /(?:uploads|files)/.*\\.php\$ {
	deny all;
}
# PERFORMANCE : Set expires headers for static files and turn off logging.
location ~* \^.+\\.(js|css|swf|xml|txt|ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf)\$ {
    access_log off; log_not_found off; expires 30d;
}
" > "${NGINXGENERATED}/restrictions.conf"
}
fi


if [[ ! -e "${NGINXGENERATED}/wordpress-multi.conf"  ]] ; then
{
echo "# ${NGINXGENERATED}/wordpress-multi.conf
# Rewrite rules for WordPress Multi-site.

# Deny access to any files with a .php extension in the files directory
# Works in sub-directory installs and also in multisite network
# Keep logging the requests to parse later (or to pass to firewall utilities such as fail2ban)
location ~* /(?:files)/.*\\.php\$ {
	deny all;
}

location ~ ^/([^/]+/)?files/(.+) {
	try_files /wp-content/blogs.dir/0/files/\$2 /wp-includes/ms-files.php?file=\$2;
	access_log off;
	log_not_found off;
	expires 5m;
}

if (!-e \$request_filename) {
	rewrite /wp-admin\$ \$resolved_scheme://\$host\$uri/ permanent;
	# rewrite /wp-admin\$ \$scheme://\$host\$uri/ permanent;  # alternate digitalocean REF:https://www.digitalocean.com/community/tutorials/how-to-configure-single-and-multiple-wordpress-site-settings-with-nginx
	rewrite ^(/[^/]+)?(/wp-.*) \$2 last;
	# rewrite ^/[_0-9a-zA-Z-]+(/wp-.*) \$1 last;
	rewrite ^(/[^/]+)?(/.*\\.php) \$2 last;
	# rewrite ^/[_0-9a-zA-Z-]+(/.*\\.php)\$ \$1 last;
}

location / {
	try_files index.php\$is_args\$args \$uri\$is_args\$args \$uri/\$is_args\$args ;
}

# Add trailing slash to */wp-admin requests.
rewrite /wp-admin\$ \$resolved_scheme://\$host\$uri/ permanent;
" > "${NGINXGENERATED}/wordpress-multi.conf"
}
fi

if [[ ! -e "${NGINXGENERATED}/wordpress-single.conf"  ]] ; then
{
echo "# ${NGINXGENERATED}/wordpress-single.conf
# WordPress single blog rules.
# Designed to be included in any server {} block.

# WORDPRESS : Rewrite rules, sends everything through index.php and keeps the appended query string intact
# This order might seem weird - this is attempted to match last if rules below fail.
# http://wiki.nginx.org/HttpCoreModule
location / {
	try_files index.php\$is_args\$args \$uri\$is_args\$args \$uri/\$is_args\$args ;
	# try_files \$uri \$uri/ /index.php?q=\$uri&\$args;  # suggested from REF: https://www.digitalocean.com/community/tutorials/how-to-configure-single-and-multiple-wordpress-site-settings-with-nginx
}

# Add trailing slash to */wp-admin requests.
rewrite /wp-admin\$ \$resolved_scheme://\$host\$uri/ permanent;

" > "${NGINXGENERATED}/wordpress-single.conf"
}
fi

if [[ ! -e "${NGINXGENERATED}/ssl.conf"  ]] ; then
{
echo "# ${NGINXGENERATED}/ssl.conf
    # Paths to certificate files.
    # ssl_certificate /etc/letsencrypt/live/ssl.com/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/ssl.com/privkey.pem;

    # Don't use outdated SSLv3 protocol. Protects against BEAST and POODLE attacks.
    ssl_protocols TLSv1.2 TLSv1.3;

ssl_ciphers EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
#ssl_prefer_server_ciphers on;

    # Use secure ciphers
 #   ssl_ciphers EECDH+CHACHA20:EECDH+AES;
    ssl_ecdh_curve X25519:prime256v1:secp521r1:secp384r1;
    ssl_prefer_server_ciphers on;

    # Define the size of the SSL session cache in MBs.
    ssl_session_cache shared:SSL:1m;

    # Define the time in minutes to cache SSL sessions.
    ssl_session_timeout 90000h;

    # Tell browsers the site should only be accessed via https.
    add_header Strict-Transport-Security \"max-age=31536000; includeSubDomains\" always;


" > "${NGINXGENERATED}/ssl.conf"
}
fi


if [[ ! -e "${NGINXGENERATED}/nginx.conf"  ]] ; then
{
echo "# ${NGINXGENERATED}/nginx.conf
user ${NGINXUSERS};
worker_processes auto;
pid \"${NGINXPID}\";

events {
    worker_connections 1024;
    # multi_accept on;
}

http {
    include \"${NGINXGENERATED}/mime.types\";
    default_type application/octet-stream;
    # set client body size to 2M #
    client_max_body_size 1000M;
    #
    # ; Maximum allowed size for uploaded files.
    # upload_max_filesize 512M;
    server_names_hash_max_size 128;
    server_names_hash_bucket_size 128;
    # ; Must be greater than or equal to upload_max_filesize
    # post_max_size 512M;
    #
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 4096;
    # server_tokens off;
    fastcgi_buffers 32 32k;
    fastcgi_buffer_size 32k;
    fastcgi_read_timeout 1800s;
    #
    map \$http_x_forwarded_proto \$resolved_scheme {
        default \"http\";
        \"https\" \"https\";
    }
    #
    map \$resolved_scheme \$fastcgi_https {
        default '';
        https on;
    }
    # gzip on;
    # gzip_disable \"msie6\";
    # gzip_comp_level 5;
    # gzip_min_length 256;
    # gzip_proxied any;
    # gzip_vary on;
    #
    # gzip_types
    # application/atom+xml
    # application/javascript
    # application/json
    # application/rss+xml
    # application/vnd.ms-fontobject
    # application/x-font-ttf
    # application/x-web-app-manifest+json
    # application/xhtml+xml
    # application/xml
    # font/opentype
    # image/svg+xml
    # image/x-icon
    # text/css
    # text/plain
    # text/x-component;
    #
    #
    # Gzip rules
    include \"${NGINXGENERATED}/gzip.conf\";

    # Php fpm rules
    include \"${NGINXGENERATED}/php-fpm.conf\";

    include \"${NGINXGENERATED}/sites-enabled/*\";
    include \"${VALETHOME}/Local/*\";
    include \"${VALETHOME}/Nginx/*\";
    autoindex on;
}

" > "${NGINXGENERATED}/nginx.conf"
}
fi

echo "
./:"
ls -la \
"${SERVERNAME}_nginx.conf" \
"${SERVERNAME}_upstream.conf"

echo "
${NGINXGENERATED}:"
ls -la \
"${NGINXGENERATED}"

cp  "${NGINXGENERATED}/${SERVERNAME}" "${SERVERSCRIPT}"
echo "
$(dirname "${SERVERSCRIPT}"):"
ls -la \
"${SERVERSCRIPT}"


  if ( command -v bcomp >/dev/null 2>&1; ) ; then
  {
    bcomp "${NGINXGENERATED}/nginx.conf" "${NGINXCONF}" &
  }
  elif ( command -v bcompare >/dev/null 2>&1; ) ; then
  {
    bcompare "${NGINXGENERATED}/nginx.conf" "${NGINXCONF}" &
  }
  elif ( command -v colordiff >/dev/null 2>&1; ) ; then
  {
    colordiff "${NGINXGENERATED}/nginx.conf" "${NGINXCONF}" &
  }
  elif ( command -v diff >/dev/null 2>&1; ) ; then
  {
    diff "${NGINXGENERATED}/nginx.conf" "${NGINXCONF}" &
  }
  else
  {
    echo "Make sure to compare to nginx conf server"
    echo "${NGINXGENERATED}/nginx.conf" "${NGINXCONF}"
  }
  fi

  if ! ( command -v nodemon >/dev/null 2>&1; ) ; then
  {
    npm -g i nodemon
  }
  fi
  echo "sudo again"
  if ( command -v nodemon >/dev/null 2>&1; ) ; then
  {
    sudo  nodemon --watch "${NGINXCONF}" --exec nginx -t
  }
  elif ( command -v watch >/dev/null 2>&1; ) ; then
  {
    sudo watch  -cx nginx -t
  }
  else
  {
    echo Could not find nodemon or watch
    echo Watch for changes until config is correct
    echo sudo  nodemon --watch "${NGINXCONF}" --exec nginx -t
    echo sudo watch  -cx nginx -t
  }
  fi
} # end main
main

