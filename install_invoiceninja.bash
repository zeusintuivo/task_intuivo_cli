#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
if ! ( command -v realpath >/dev/null 2>&1; ) ; then # MAC  # updated realpath macos 20210902
{
  # updated realpath macos 20210902
  export realpath    # updated realpath macos 20210902
  function realpath() ( # Macos after BigSur is missing realpath  # updated realpath macos 20210902
    local OURPWD=$PWD
    cd "$(dirname "$1")"
    local LINK=$(readlink "$(basename "$1")")
    while [ "$LINK" ]; do
      cd "$(dirname "$LINK")"
      LINK=$(readlink "$(basename "$1")")
    done
    local REALPATH="$PWD/$(basename "$1")"
    cd "$OURPWD"
    echo "$REALPATH"
  )
}
fi

# 20200415 Compatible with Fedora, Mac, Ubuntu "sudo_up" "load_struct"
set -E -o functrace
export THISSCRIPTCOMPLETEPATH
typeset -r THISSCRIPTCOMPLETEPATH="$(realpath  "$0")" # updated realpath macos 20210902
export BASH_VERSION_NUMBER
typeset BASH_VERSION_NUMBER=$(echo $BASH_VERSION | cut -f1 -d.)

export  THISSCRIPTNAME
typeset -r THISSCRIPTNAME="$(basename "$0")"

export _err
typeset -i _err=0
  function _trap_on_error(){
    echo -e "\\n \033[01;7m*** ERROR TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n ERR ...\033[0m"
    exit 1
  }
  trap _trap_on_error ERR
  function _trap_on_int(){
    echo -e "\\n \033[01;7m*** INTERRUPT TRAP $THISSCRIPTNAME \\n${BASH_SOURCE}:${BASH_LINENO[-0]} ${FUNCNAME[-0]}() \\n$0:${BASH_LINENO[1]} ${FUNCNAME[1]}() \\n  INT ...\033[0m"
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
  trap  '_trap_on_error $0 "${?}" LINENO BASH_LINENO FUNCNAME BASH_COMMAND $FUNCNAME $BASH_LINENO $LINENO   $BASH_COMMAND'  ERR
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



 #--------\/\/\/\/-- Work here below \/, test, and transfer to tasks_templates/invoiceninja having a working version -\/\/\/\/-------



_debian_flavor_install() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _debian_flavor_install

_redhat_flavor_install() {
  echo REF:	https://forum.invoiceninja.com/t/install-invoice-ninja-v5-on-enterprise-linux-8/4293
  echo Installing InvoiceNinja v5 Beta on Enterprise Linux 8 (RHEL, AlmaLinux, Rocky Linux)
  ensure php or "Need to install php first
  Use brew
  brew install php@7.4
  or
  this suggested procedure:
  sudo dnf install yum-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
  sudo dnf module reset php -y
  sudo dnf module enable php:remi-7.4 -y
  "
  ensure mysql or "Need to install mysql first
  Use brew
  bre install mariadb
  or
  sudo install mariadb
  sudo systemctl start mariadb
  sudo systemctl enable mariadb
  mysql_secure_installation

  Set the password for the root user of the SQL database. Make sure to keep record of this and do not lose it. You will need it in the next step, and for future maintenance of DB

	Remove anonymous users? [Y/n] y
	Disallow root login remotely? [Y/n] y
	Remove test database and access to it? [Y/n] y
	Reload privilege tables now? [Y/n] y

  "
  ensure node or "Need to install nodejs first
  Use asdf or volta o nvm or brew
  or
  curl -sL https://rpm.nodesource.com/setup_14.x | sudo -E bash
  sudo yum install nodejs -y
  "
  # verify_installed_version "node --version"  "14.16.1"
  # verify_installed_version "npm --version"  "6.14.7"
  dnf install gcc-c++ make php php-{fpm,bcmath,ctype,fileinfo,json,mbstring,pdo,tokenizer,xml,curl,zip,gmp,gd,mysqli} mariadb-server -y
  dnf install libXcomposite libXcursor libXdamage libXext libXi libXtst libmng libXScrnSaver libXrandr libXv alsa-lib cairo pango atk at-spi2-atk gtk3 -y

   ensure nginx or "Need to install nginx  first
  Use brew
  or
  sudo dnf install nginx -y
  sudo vim /etc/nginx/conf.d/invoiceninja.conf
  server {
    listen       443 ssl http2 default_server;
    listen       [::]:443 ssl http2 default_server;
    server_name  invoices.example.ca;
    # Here, enter the path to your invoiceninja directory, in the public dir.
    root         /usr/share/nginx/invoiceninja/public;
    client_max_body_size 20M;

    gzip on;
    gzip_types application/javascript application/x-javascript text/javascript text/plain application/xml application/json;
    gzip_proxied    no-cache no-store private expired auth;
    gzip_min_length 1000;

    index index.php index.html index.htm;

    # Enter the path to your existing ssl certificate file, and certificate private key file
    # If you don’t have one yet, you can configure one with openssl in the next step.
    ssl_certificate \"/etc/nginx/cert/ninja.crt\";
    ssl_certificate_key \"/etc/nginx/cert/ninja.key\";
    ssl_session_cache shared:SSL:1m;
    ssl_session_timeout  10m;
    ssl_ciphers 'AES128+EECDH:AES128+EDH:!aNULL';
    ssl_prefer_server_ciphers on;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

    charset utf-8;

    # Load configuration files for the default server block.
    include /etc/nginx/default.d/*.conf;

    location / {
            try_files $uri $uri/ /index.php?$query_string;
    }

    if (!-e $request_filename) {
            rewrite ^(.+)$ /index.php?q= last;
    }

    location ~ \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            # Here we pass to php-fpm listen socket.  For configuration see /etc/php-fpm.d/*.conf.
            fastcgi_pass unix:/var/run/php-fpm/www.sock;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_intercept_errors off;
            fastcgi_buffer_size 16k;
            fastcgi_buffers 4 16k;
    }

    location ~ /\.ht {
        deny all;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt { access_log off; log_not_found off; }

    access_log /var/log/nginx/ininja.access.log;
    error_log /var/log/nginx/ininja.error.log;

    sendfile off;

}

server {
    listen      80;
    server_name invoices.example.ca;
    add_header Strict-Transport-Security max-age=2592000;
    rewrite ^ https://$server_name$request_uri? permanent;
}
  "
  echo "Create a directory to store your ssl for nginx to access"
  mkdir -p /etc/nginx/cert/
  directory_exists_with_spaces /etc/nginx/cert/
  echo "Generate SSL certificate, and follow the prompts to configure it appropriately."
  openssl req -new -x509 -days 365 -nodes -out /etc/nginx/cert/ninja.crt -keyout /etc/nginx/cert/ninja.key
  chmod 600 /etc/nginx/cert/*

  echo "Create the invoiceninja directory we will be installing to later, and start and enable NGINX"

  mkdir -p /usr/share/nginx/invoiceninja
  chown -R nginx:nginx /usr/share/nginx/invoiceninja
  systemctl start nginx
  systemctl enable nginx

  echo "Configure firewalld
  Below steps will open ports 80 and 443 to the public on firewalld permanently.

  sudo firewall-cmd --zone=public --add-service=http --permanent
  sudo firewall-cmd --zone=public --add-service=https --permanent
  sudo firewall-cmd --reload
"
  echo "run mysql and create a db and user like this

CREATE DATABASE IF NOT EXISTS  \`invoiceninja\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER 'ninja'@'localhost' identified by 'ninjapass';
GRANT ALL privileges on invoiceninja.* to 'ninja'@'localhost';
FLUSH privileges;

"
} # end _redhat_flavor_install

_arch_flavor_install() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _readhat_flavor_install

_arch_flavor_install() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _readhat_flavor_install

_arch__32() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _arch__32

_arch__64() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _arch__64

_centos__32() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _centos__32

_centos__64() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _centos__64

_debian__32() {
  _debian_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _debian__32

_debian__64() {
  _debian_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _debian__64

_fedora__32() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _fedora__32

_fedora__64() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _fedora__64

_gentoo__32() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _gentoo__32

_gentoo__64() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _gentoo__64

_madriva__32() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _madriva__32

_madriva__64() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _madriva__64

_suse__32() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _suse__32

_suse__64() {
  _redhat_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _suse__64

_ubuntu__32() {
  _debian_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _ubuntu__32

_ubuntu__64() {
  _debian_flavor_install
  echo "Procedure not yet implemented. I don't know what to do."
} # end _ubuntu__64

_darwin__64() {
  echo "Procedure not yet implemented. I don't know what to do."
} # end _darwin__64



 #--------/\/\/\/\-- Work here above /\, test, and transfer to tasks_templates/invoiceninja having a working version -/\/\/\/\-------


_main() {
  determine_os_and_fire_action
} # end _main

_main

echo "🥦"
exit 0
