#!/usr/bin/env bash

# Script to install all clis once downloaded

# SUDO_USER only exists during execution of sudo
# REF: https://stackoverflow.com/questions/7358611/get-users-home-directory-when-they-run-a-script-as-root
# Global:
  export THISSCRIPTCOMPLETEPATH
  typeset -r THISSCRIPTCOMPLETEPATH="$(pwd)/$(basename "$0")"   # § This goes in the FATHER-MOTHER script

  export BASH_VERSION_NUMBER
  typeset BASH_VERSION_NUMBER=$(echo $BASH_VERSION | cut -f1 -d.)

  export  THISSCRIPTNAME
  typeset -r THISSCRIPTNAME="$(pwd)/$(basename "$0")"

  export _err
  typeset -i _err=0

execute_as_sudo(){
  if [ -z $SUDO_USER ] ; then
    if [[ -z "$THISSCRIPTNAME" ]] ; then
    {
        echo "error You need to add THISSCRIPTNAME variable like this:"
        echo "     THISSCRIPTNAME=\`basename \"\$0\"\`"
    }
    else
    {
        if [ -f "./$THISSCRIPTNAME" ] ; then
        {
          sudo "./$THISSCRIPTNAME"
        }
        elif ( command -v "$THISSCRIPTNAME" >/dev/null 2>&1 );  then
        {
          echo "sudo sudo sudo "
          sudo "$THISSCRIPTNAME"
        }
        else
        {
          echo -e "\033[05;7m*** Failed to find script to recall it as sudo ...\033[0m"
          exit 1
        }
        fi
    }
    fi
    wait
    exit 0
  fi
  # REF: http://superuser.com/questions/93385/run-part-of-a-bash-script-as-a-different-user
  # REF: http://superuser.com/questions/195781/sudo-is-there-a-command-to-check-if-i-have-sudo-and-or-how-much-time-is-left
  local CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
  if [ ${CAN_I_RUN_SUDO} -gt 0 ]; then
    echo -e "\033[01;7m*** Installing as sudo...\033[0m"
  else
    echo "Needs to run as sudo ... ${0}"
  fi
}
execute_as_sudo

export USER_HOME
      # shellcheck disable=SC2046
      # shellcheck disable=SC2031
      typeset -r USER_HOME="$(echo -n $(bash -c "cd ~${SUDO_USER} && pwd"))"  # Get the caller's of sudo home dir LINUX and MAC
# USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)

load_struct_testing_wget(){
    local provider="$USER_HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    [   -e "${provider}"  ] && source "${provider}"
    [ ! -e "${provider}"  ] && eval """$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing -O -  2>/dev/null )"""   # suppress only wget download messages, but keep wget output for variable
    ( ( ! command -v passed >/dev/null 2>&1; ) && echo -e "\n \n  ERROR! Loading struct_testing \n \n " && exit 69; )
} # end load_struct_testing_wget
load_struct_testing_wget

enforce_variable_with_value USER_HOME $USER_HOME
enforce_variable_with_value SUDO_USER $SUDO_USER
passed Caller user identified:$SUDO_USER
passed Home identified:$USER_HOME
file_exists_with_spaces "$USER_HOME"

# exit 0
COMANDDER=""
_checka_node_commander() {
    local COMANDDER="$1"
    is_not_installed npm &&  $COMANDDER install -y npm             # Ubuntu only
    is_not_installed node && $COMANDDER install -y nodejs          # In Fedora installs npm and node
    is_not_installed node && $COMANDDER install -y nodejs-legacy   # Ubuntu only
    verify_is_installed npm
    verify_is_installed node
}

_checka_tools_commander(){

    install_requirements "linux" "
    xclip
    tree
    ag@the_silver_searcher
    # Ubuntu only
    ag@silversearcher-ag
    ack
    # Ubuntu only
    ack@ack-grep
    vim
    nano
    pv
    "
    verify_is_installed "
    xclip
    tree
    ag
    ack
    pv
    nano
    vim
    pip
    "
    is_not_installed pygmentize &&    pip install pygments
    verify_is_installed pygmentize

}

_ubuntu__64() {
    # debian sudo usermod -aG sudo $SUDO_USER
    # chown $SUDO_USER:$SUDO_USER -R /home
    # sudo groupadd docker
    # sudo usermod -aG docker $SUDO_USER

    COMANDDER="apt install -y"
    _checka_tools_commander
    if it_does_not_exist_with_spaces /etc/apt/sources.list.d/cloudfoundry-cli.list ; then
    {
        Installing cloudfoundry cf 7
        wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
        echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
        echo  ...then, update your local package index, then finally install the cf CLI
        apt update -y
        $COMANDDER cf-cli
        snap install cf-cli
    }
    fi
    chown $SUDO_USER -R $USER_HOME/.cf
    verify_is_installed cf

}

_centos__64() {
  _fedora__64
} # end _centos__64

_fedora__64() {
    COMANDDER="dnf install -y"
    _checka_tools_commander
    if  it_does_not_exist_with_spaces /etc/yum.repos.d/cloudfoundry-cli.repo ; then
    {
        Installing cloudfoundry cf 7
        wget -O /etc/yum.repos.d/cloudfoundry-cli.repo https://packages.cloudfoundry.org/fedora/cloudfoundry-cli.repo
        # sudo yum install cf6-cli
        $COMANDDER cf7-cli
    }
    fi
    verify_is_installed cf

}
export is_not_installed
function is_not_installed (){
	if ( command -v $1 >/dev/null 2>&1; ) ; then
	  return 1
	else
	  return 0
	fi
}

_darwin__64() {
    COMANDDER="_run_command /usr/local/bin/brew install "
    # $COMANDDER install nodejs
    # version 6 brew install cloudfoundry/tap/cf-cli
    install_requirements "darwin" "
      tree
      the_silver_searcher
      # ag|the_silver_searcher
      ack
      vim
      nano
      pv
      powerlevel10k@romkatv/powerlevel10k/powerlevel10k
      powerline-go

    "
    verify_is_installed pip3
    if ( ! command -v pygmentize >/dev/null 2>&1; ) ;  then
    	pip3 install pigments
    fi
    if ( ! command -v cf >/dev/null 2>&1; ) ;  then
    	npm i -g cloudfoundry/tap/cf-cli@7
    fi
	verify_is_installed "
    tree
    ag
    ack
    pv
    nano
    vim
    cf
    pygmentize
    "
}

determine_os_and_fire_action
# exit 0

ensure pygmentize or "Canceling Install. Could not find pygmentize.  pip install pigments"
ensure npm or "Canceling Install. Could not find npm"
ensure node or "Canceling Install. Could not find node"
ensure cf or "Canceling Install. Could not find cf"
#MTASCHECK=$(su - $SUDO_USER -c 'cf mtas --help' >/dev/null 2>&1)
#if [[ -n "$MTASCHECK" ]] &&  [[ "$MTASCHECK" == *"FAILED"* ]]  ; then
#{
#    su - $SUDO_USER -c 'yes | cf install-plugin multiapps'
#}
#fi
#
#if [[ -n "$MTASCHECK" ]] &&  [[ "$MTASCHECK" != *"FAILED"* ]]  ; then
#{
#    passed Installed cf mtas plugin
#}
#fi
ensure git or "Canceling Install. Could not find git"
CURRENTGITUSER=$(su - $SUDO_USER -c 'git config --global --get user.name')
CURRENTGITEMAIL=$(su - $SUDO_USER -c 'git config --global --get user.email')
# exit 0

if [[ -z "$CURRENTGITEMAIL" ]] ; then
{
    Configuring git user.email with  $SUDO_USER@$(hostname)
    su - $SUDO_USER -c 'git config --global user.email '$SUDO_USER'@$(hostname)'
}
fi
# exit 0
if [[ -z "$CURRENTGITUSER" ]] ; then
{
    Configuring git user.name with  $SUDO_USER
    su - $SUDO_USER -c 'git config --global user.name '$SUDO_USER
}
fi

_install_npm_utils() {
    chown $SUDO_USER -R $USER_HOME/.npm
    chown $SUDO_USER -R $USER_HOME/.nvm
    # Global node utils
    is_not_installed nodemon  && npm i -g nodemon
    if  is_not_installed live-server  ; then
    {
        npm i -g live-server
    }
    fi
    verify_is_installed live-server
    verify_is_installed nodemon
    # is_not_installed jest &&  npm i -g jest
    # verify_is_installed jest
    CHAINSTALLED=$(su - $SUDO_USER -c 'npm -g info chai >/dev/null 2>&1')
    if [[ -n "$CHAINSTALLED" ]] &&  [[ "$CHAINSTALLED" == *"npm ERR"* ]]  ; then
    {
        Installing npm chai
        npm i -g chai
    }
    fi
    MOCHAINSTALLED=$(su - $SUDO_USER -c 'npm -g info mocha >/dev/null 2>&1')
    if [[ -n "$MOCHAINSTALLED" ]] &&  [[ "$MOCHAINSTALLED" == *"npm ERR"* ]]  ; then
    {
        npm i -g mocha
    }
    fi
    local ret msg
    #msg=$(su - $SUDO_USER -c 'cds >/dev/null 2>&1')
    #ret=$?
    #if [ $ret -gt 0 ] ; then
    #{
        Installing --skipped npm cds
    #    npm i -g @sap/cds-dk
    #    msg=$(su - $SUDO_USER -c 'cds')
    #    ret=$?
    #    if [ $ret -gt 0 ] ; then
    #    {
    #        echo failed "${ret}:${msg}"
    #    }
    #    else
    #    {
    #        passed that: cds got installed
    #    }
    #    fi
    #}
    #else
    #{
    #    passed that: cds is installed
    #}
    #fi
}
# exit 0
_if_not_is_installed(){
	local -i ret
	local msg
	ret=0
	msg=$($COMANDDER info $1  >/dev/null 2>&1)
	ret=$?
	[ $ret -gt 0 ] && return 1
	[[ "$msg" == *"No such"* ]] && return 1
	[[ "$msg" == *"nicht gefunden"* ]] && return 1
	[[ "$msg" == *"Error"*   ]] && return 1
	return 0
}
_if_not_contains(){
	local -i ret
	local msg
	ret=0
	[ ! -e "$1" ] && return 1
	msg=$(cat -n "$1" >/dev/null 2>&1)
	ret=$?
	[ $ret -gt 0 ] && return 1
	[[ "$msg" == *"No such"* ]] && return 1
	[[ "$msg" == *"nicht gefunden"* ]] && return 1
	[[ "$msg" == *"Permission denied"* ]] && return 1
	ret=0
	msg=$(echo "$msg" | grep "$2" >/dev/null 2>&1)
	ret=$?
	[ $ret -gt 0 ] && return 1
	[[ "$msg" == *"No such"* ]] && return 1
	[[ "$msg" == *"nicht gefunden"* ]] && return 1
	[[ "$msg" == *"Permission denied"* ]] && return 1
	return 0
}

_install_nvm() {
    local -i ret
    local msg
    chown $SUDO_USER -R $USER_HOME/.config
    [ -s "$USER_HOME/.nvm/nvm.sh" ] && . "$USER_HOME/.nvm/nvm.sh" # This loads nvm

    msg=$(nvm >/dev/null 2>&1)
    ret=$?

    if is_not_installed nvm ; then  # [ $ret -gt 0 ] ; then
    {
        Installing nvm Node Version Manager
        Installing  nvm setup
        su - $SUDO_USER -c 'HOME='$USER_HOME' curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash'

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${USER_HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$USER_HOME/.nvm/nvm.sh" ] && \. "$USER_HOME/.nvm/nvm.sh" # This loads nvm

Configuring  nvm setup

_if_not_contains "$USER_HOME/.bash_profile" "NVM_DIR/nvm.sh" && echo '
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
'  >> $USER_HOME/.bash_profile

file_exists_with_spaces "$USER_HOME/.bash_profile"

_if_not_contains "$USER_HOME/.bashrc" "NVM_DIR/nvm.sh" &&  echo '
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
'  >> $USER_HOME/.bashrc

file_exists_with_spaces "$USER_HOME/.bashrc"


_if_not_contains "$USER_HOME/.zshrc" "NVM_DIR/nvm.sh" &&  echo '
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
'  >> $USER_HOME/.zshrc

file_exists_with_spaces "$USER_HOME/.zshrc"

        msg=$(su - $SUDO_USER -c 'nvm' >/dev/null 2>&1)
        ret=$?
        if [ $ret -gt 0 ] ; then
        {
            echo nvm second check failed "${ret}:${msg}"
        }
        else
        {
            passed that: nvm got installed
        }
        fi

    }
    else
    {
        passed that: nvm is installed
    }
    fi
}


_install_nvm_version(){
    local TARGETVERSION="${1}"
    Configuring nvm node ${TARGETVERSION}
    [ -s "$USER_HOME/.nvm/nvm.sh" ] && . "$USER_HOME/.nvm/nvm.sh" # This loads nvm


    local VERSION12=$(nvm ls | grep "v${TARGETVERSION}" |tail -1 >/dev/null 2>&1 )
    if [[ -n "$VERSION12" ]] ; then
    {
        if [[ "$VERSION12" == *"not found"* ]] || [[ "$VERSION12" == *"nvm help"* ]]  ; then
        {
            failed "Nvm command not found or failed! It should have been installed by this point."
        }
        fi
        if [[ "$VERSION12" == *"v${TARGETVERSION}"* ]]  ; then
        {
            passed that: node ${TARGETVERSION} installed. Version Found $VERSION12
        }
        else
        {
            Installing node using nvm install  "${TARGETVERSION}"
	    VERSION12=$(nvm ls | grep "v${TARGETVERSION}" |tail -1 >/dev/null 2>&1 )
            if [[ -n "$VERSION12" ]] ; then
            {
                if [[ "$VERSION12" == *"not found"* ]] || [[ "$VERSION12" == *"nvm help"* ]]  ; then
                {
                    failed "Nvm command not found or failed! It should have been installed by this point."
                }
                fi
                if [[ "$VERSION12" == *"v${TARGETVERSION}"* ]]  ; then
                {
                    passed that: node ${TARGETVERSION} installed. Version Found $VERSION12
                }
                else
                {
                    failed to install node using nvm for version ${TARGETVERSION}
                }
                fi
            }
            fi
        }
        fi
    }
    fi
    if [[ "$VERSION12" == *"v${TARGETVERSION}"* ]]  ; then
    {
        passed that: node ${TARGETVERSION} installed. Version Found $VERSION12
    }
    else
    {
        Installing node using nvm install  "${TARGETVERSION}"
	VERSION12=$(nvm ls | grep "v${TARGETVERSION}" |tail -1 >/dev/null 2>&1 )
            if [[ -n "$VERSION12" ]] ; then
            {
                if [[ "$VERSION12" == *"not found"* ]] || [[ "$VERSION12" == *"nvm help"* ]]  ; then
                {
                    failed "Nvm command not found or failed! It should have been installed by this point."
                }
                fi
                if [[ "$VERSION12" == *"v${TARGETVERSION}"* ]]  ; then
                {
                    passed that: node ${TARGETVERSION} installed. Version Found $VERSION12
                }
                else
                {
                    failed to install node using nvm for version ${TARGETVERSION}
                }
                fi
            }
            fi
        }
    fi
    Setting . nvm use "${TARGETVERSION}"
    # su - $SUDO_USER -c '. ${USER_HOME}/.nvm/nvm.sh && ${USER_HOME}/.nvm/nvm.sh use "${TARGETVERSION}"'
    chown -R $SUDO_USER:$SUDO_USER $USER_HOME/.nvm
    nvm install ${TARGETVERSION}
    chown -R $SUDO_USER:$SUDO_USER $USER_HOME/.nvm
    nvm use ${TARGETVERSION}
    # su - $SUDO_USER -c ''${USER_HOME}'/.nvm/nvm.sh && . '${USER_HOME}'/.nvm/nvm.sh && nvm use "${TARGETVERSION}"'
    # node --version
    #nvm use "${TARGETVERSION}"
}

# _install_npm_utils

# _install_nvm
#_install_nvm_version 10
#_install_npm_utils

#_install_nvm_version 12
#_install_npm_utils

#_install_nvm_version 14
#_install_npm_utils


_install_nerd_fonts(){

  if  it_does_not_exist_with_spaces "$USER_HOME/.nerd-fonts" ; then
  {
    cd $USER_HOME
    su - $SUDO_USER -c  "git clone --depth=1 https://github.com/ryanoasis/nerd-fonts $USER_HOME/.nerd-fonts"
    directory_exists_with_spaces "$USER_HOME/.nerd-fonts"
    file_exists_with_spaces "$USER_HOME/.nerd-fonts/install.sh"
	chown -R $SUDO_USER $USER_HOME/.nerd-fonts

	cd $USER_HOME/.nerd-fonts
	su - $SUDO_USER -c  "bash -c $USER_HOME/.nerd-fonts/install.sh"
   }
   fi
}

_setup_ohmy(){
    if  it_does_not_exist_with_spaces "$USER_HOME/.oh-my-zsh/" ; then
    {
        Installing ohmy
        if [[ "$COMANDDER" == *"apt-get"* ]]  ; then
        {
           wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
        }
        elif [[ "$COMANDDER" == *"dnf"* ]]  ; then
        {
	       $COMANDDER git wget curl ruby ruby-devel zsh util-linux-user redhat-rpm-config gcc gcc-c++ make
        }
        fi


		_install_nerd_fonts
		if ( command -v brew >/dev/null 2>&1; ) ; then
		{
		  su - "${SUDO_USER}" -c "brew install --cask font-fontawesome"
		  err_buff=$?
		} else {
		  _if_not_is_installed fontawesome-fonts && $COMANDDER fontawesome-fonts
		  _if_not_is_installed powerline && $COMANDDER powerline vim-powerline tmux-powerline powerline-fonts
		  echo REF: https://fedoramagazine.org/tuning-your-bash-or-zsh-shell-in-workstation-and-silverblue/
		  if [ -f `which powerline-daemon` ]; then
			{
			  powerline-daemon -q
			  POWERLINE_BASH_CONTINUATION=1
			  POWERLINE_BASH_SELECT=1
			  . /usr/share/powerline/bash/powerline.sh
			}
			fi
		}
		fi


        # install ohmyzsh
        su - $SUDO_USER -c 'sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
		chown -R $SUDO_USER $USER_HOME/.oh-my-zsh
        Testing ohmyzsh
        directory_exists_with_spaces "$USER_HOME/.oh-my-zsh"
    }
    else
    {
        passed that: ohmy is installed
    }
    fi


	if it_does_not_exist_with_spaces ${USER_HOME}/.oh-my-zsh/themes/powerlevel10k ; then
	{
	  su - $SUDO_USER -c "git clone https://github.com/romkatv/powerlevel10k.git ${USER_HOME}/.oh-my-zsh/themes/powerlevel10k"
	  _if_not_contains "$USER_HOME/.zshrc" "powerlevel10k" && echo "ZSH_THEME=powerlevel10k/powerlevel10k" >> $USER_HOME/.zshrc
    }
    fi
	if it_does_not_exist_with_spaces ${USER_HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ; then
	{
	  su - $SUDO_USER -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${USER_HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
	}
	fi
	if it_does_not_exist_with_spaces ${USER_HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions ; then
	{
	  su - $SUDO_USER -c "git clone https://github.com/zsh-users/zsh-autosuggestions ${USER_HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
	  _if_not_contains "$USER_HOME/.zshrc" "zsh-syntax-highlighting" echo "plugins=(git zsh-syntax-highlighting zsh-autosuggestions)"   >> $USER_HOME/.zshrc
    }
    fi
}
# rm -rf ${USER_HOME}/.oh-my-zsh
_setup_ohmy
# exit 0

_install_colorls(){
( gem list colorls | grep -q "^colorls" ) && return 0
( gem list colorls | grep -q "^colorls" ) || (su - $SUDO_USER -c "yes | gem install colorls") && ( su - $SUDO_USER -c "yes | gem update colorls")

_if_not_contains "$USER_HOME/.zshrc" "colorls" && echo "alias ll='colorls -lA --sd --gs --group-directories-first'" >> $USER_HOME/.zshrc
_if_not_contains "$USER_HOME/.zshrc" "colorls" && echo "alias ls='colorls --group-directories-first'" >> $USER_HOME/.zshrc

_if_not_contains "$USER_HOME/.bashrc" "colorls" && echo "alias ll='colorls -lA --sd --gs --group-directories-first'" >> $USER_HOME/.bashrc
_if_not_contains "$USER_HOME/.bashrc" "colorls" && echo "alias ls='colorls --group-directories-first'" >> $USER_HOME/.bashrc
return 0
}
_install_colorls

# exit 0
_setup_clis(){
  local -i ret
  local msg
  ret=0
  if  it_exists_with_spaces "$USER_HOME/_/clis" ; then
  {
   directory_exists_with_spaces $USER_HOME/_/clis
    return 0
  }
  fi
  Installing Clis
  if  it_does_not_exist_with_spaces "$USER_HOME/_/clis" ; then
  {
    su - $SUDO_USER -c "mkdir -p $USER_HOME/_/clis"
    chown $SUDO_USER:$SUDO_USER -R $USER_HOME/_
    cd $USER_HOME/_/clis
  } else {
    passed clis: clis folder exists
  }
  fi
  if  it_does_not_exist_with_spaces "$USER_HOME/_/clis/bash_intuivo_cli" ; then
  {
	cd $USER_HOME/_/clis
	Installing Clis pre work  bash_intuivo_cli  for link_folder_scripts
	su - $SUDO_USER -c "yes | git clone git@github.com:zeusintuivo/bash_intuivo_cli.git $USER_HOME/_/clis/bash_intuivo_cli"
	if it_does_not_exist_with_spaces ${USER_HOME}/_/clis/bash_intuivo_cli ; then
	{
	  su - $SUDO_USER -c "yes | git clone https://github.com/zeusintuivo/bash_intuivo_cli.git $USER_HOME/_/clis/bash_intuivo_cli"
	}
	fi
	cd $USER_HOME/_/clis/bash_intuivo_cli
	git remote remove origin
	git remote add origin git@github.com:zeusintuivo/bash_intuivo_cli.git
	bash -c $USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts
  } else {
	passed clis: bash_intuivo_cli folder exists
  }
  fi
  if  is_not_installed link_folder_scripts ; then
  {
	cd $USER_HOME/_/clis
	Installing No. 2 Clis pre work  bash_intuivo_cli  for link_folder_scripts
	su - $SUDO_USER -c "yes | git clone git@github.com:zeusintuivo/bash_intuivo_cli.git  $USER_HOME/_/clis/bash_intuivo_cli"
	if it_does_not_exist_with_spaces ${USER_HOME}/_/clis/bash_intuivo_cli ; then
	{
	  su - $SUDO_USER -c "yes | git clone https://github.com/zeusintuivo/bash_intuivo_cli.git $USER_HOME/_/clis/bash_intuivo_cli"
	}
	fi
	chown -R $SUDO_USER:$SUDO_USER $USER_HOME/_/clis/bash_intuivo_cli
	cd $USER_HOME/_/clis/bash_intuivo_cli
	git remote remove origin
	git remote add origin git@github.com:zeusintuivo/bash_intuivo_cli.git
	bash -c $USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts
  } else {
	passed clis: bash_intuivo_cli folder exists
  }
  fi
  if  it_does_not_exist_with_spaces ${USER_HOME}/_/clis/ssh_intuivo_cli ; then
  {
	cd $USER_HOME/_/clis
	Installing No. 3 Clis pre work ssh_intuivo_cli  for link_folder_scripts
	yes | git clone git@github.com:zeusintuivo/ssh_intuivo_cli.git
	if it_does_not_exist_with_spaces ${USER_HOME}/_/clis/ssh_intuivo_cli ; then
	{
	  su - $SUDO_USER -c "yes | git clone https://github.com/zeusintuivo/ssh_intuivo_cli.git  $USER_HOME/_/clis/ssh_intuivo_cli"
	}
	fi
	cd $USER_HOME/_/clis/ssh_intuivo_cli
	chown -R $SUDO_USER:$SUDO_USER $USER_HOME/_/clis/ssh_intuivo_cli
	chown -R $SUDO_USER:$SUDO_USER $USER_HOME/.ssh
	git remote remove origin
	git remote add origin git@github.com:zeusintuivo/ssh_intuivo_cli.git
	bash -c $USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts
	./sshswitchkey zeus
  } else {
	passed clis: ssh_intuivo_cli folder exists
  }
  fi
# rm -rf $USER_HOME/_/clis/ssh_intuivo_cli

clis="
bin
box_intuivo_cli
docker_intuivo_cli
execute_command_intuivo_cli
git_intuivo_cli
guake_intuivo_cli
journal_intuivo_cli
ruby_intuivo_cli
ssh_intuivo_cli
task_intuivo_cli
"


while read -r ONE ; do
{
    if [ -n "$ONE" ] ; then  # is not empty
    {
        Installing "$ONE"
        if  it_does_not_exist_with_spaces "$USER_HOME/_/clis/${ONE}" ; then
        {
            cd $USER_HOME/_/clis
            su - $SUDO_USER -c "yes | git clone git@github.com:zeusintuivo/${ONE}.git  $USER_HOME/_/clis/${ONE}"
            if it_does_not_exist_with_spaces ${USER_HOME}/_/clis/${ONE} ; then
            {
              su - $SUDO_USER -c "yes | git clone https://github.com/zeusintuivo/${ONE}.git  $USER_HOME/_/clis/${ONE}"
            }
            fi
            cd $USER_HOME/_/clis/${ONE}
            chown -R $SUDO_USER $USER_HOME/_/clis/${ONE}
	        git remote remove origin
            git remote add origin git@github.com:zeusintuivo/${ONE}.git
            directory_exists_with_spaces $USER_HOME/_/clis/${ONE}
            bash -c $USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts
			if [[ "$ONE" == "git_intuivo_cli" ]] ; then  # is not empty
			{
      	      cd $USER_HOME/_/clis/${ONE}/en
              bash -c $USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts
			}
			fi
        } else {
            Installing else $ONE
            passed clis: ${ONE} folder exists
			cd $USER_HOME/_/clis/${ONE}
			chown -R $SUDO_USER $USER_HOME/_/clis/${ONE}
			pwd
			bash -c $USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts
			if [[ "$ONE" == "git_intuivo_cli" ]] ; then  # is not empty
			{
			  cd $USER_HOME/_/clis/${ONE}/en
			  bash -c $USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts
			}
			fi
			# msg=$(link_folder_scripts)
			ret=$?
			Configuring existed with $ret
			[ $ret -gt 0 ] && Configuring $ONE existed with $ret
			# [ $ret -gt 0 ] && failed clis: execute link_folder_scripts && echo -E $msg && pwd

        }
        fi
    }
    fi
}
done <<< "${clis}"
unlink /usr/local/bin/ag # Bug path we need to do something abot this

if  softlink_exists_with_spaces "/usr/local/bin/added>$USER_HOME/_/clis/git_intuivo_cli/en/added" ; then
{
    passed clis: git_intuivo_cli/en folder exists and is linked
} else {
    Configuring extra work git_intuivo_cli/en
    directory_exists_with_spaces $USER_HOME/_/clis/git_intuivo_cli/en
    cd $USER_HOME/_/clis/git_intuivo_cli/en
    bash -c $USER_HOME/_/clis/bash_intuivo_cli/link_folder_scripts
}
fi

chown -R $SUDO_USER $USER_HOME/_/clis
return 0
}
_setup_clis
# exit 0
_setup_mycd(){
    if it_does_not_exist_with_spaces $USER_HOME/.mycd  ; then
    {
        # My CD
        cd $USER_HOME
        su - $SUDO_USER -c "yes | git clone https://gist.github.com/jesusalc/b14a57ec9024ff1a3889be6b2c968bb7 $USER_HOME/.mycd"
        chown -R $SUDO_USER  $USER_HOME/.mycd
        chmod +x  $USER_HOME/.mycd/mycd.sh

        # Add to MAC Bash:
        _if_not_contains "$USER_HOME/.bash_profile" "mycd" && echo '. $HOME/.mycd/mycd.sh' >> $USER_HOME/.bash_profile
        # Add to Linux Bash:

        _if_not_contains "$USER_HOME/.bashrc" "mycd" && echo '. $HOME/.mycd/mycd.sh' >> $USER_HOME/.bashrc

        # Add to Zsh:

        _if_not_contains "$USER_HOME/.zshrc" "mycd" &&  echo '. $HOME/.mycd/mycd.sh' >> $USER_HOME/.zshrc

        # OR - Add .dir_bash_history to the GLOBAL env .gitignore, ignore:
        mkdir -p   $USER_HOME/.config/git
        chown -R $SUDO_USER $USER_HOME/.config/git
        touch  $USER_HOME/.config/git/ignore
        _if_not_contains $USER_HOME/.config/git/ignore  ".dir_bash_history" &&  echo '.dir_bash_history' >> $USER_HOME/.config/git/ignore
    } else {
        passed that: mycd is installed
    }
    fi
    return 0
}
_setup_mycd

#echo "🥦"
#exit 0

_password_simple(){

local policies
if is_installed pwpolicy ; then
{
	policies=$(pwpolicy getaccountpolicies  2>&1; )
	ret=$?
	if [ $ret -gt 0 ] ; then
	{
		echo reading policies failed  "ERR:${ret} \n MSG:${policies}"
		return 1
	}
	else
	{
		passed Reading policies for passwords pwpolicy
		echo :dd to delete --> "Getting global account policies"
		echo press i  to edit  --> {4,} to {1,}.  press "esc" to exit edit mode
		policies="$(echo "${policies}" |  grep -v "^Getting" | sed -E 's/\{4\,\}/\{1\,\}/')"
		echo "${policies}" > temp.xml
		pwpolicy setaccountpolicies temp.xml
		rm temp.xml
	}
	fi
}
fi
# Password simple
(
sudo passwd <<< "\\
\\
"
#\"
)

(
sudo passwd root <<< "\\
\\
"
#\"
)

(
sudo passwd $SUDO_USER <<< "\\
\\
"
#\"
)
return 0
}

_password_simple2(){

# Password simple
(
sudo passwd <<< "#
#
"
#\"
)

(
sudo passwd root <<< "#
#
"
#\"
)

(
sudo passwd $SUDO_USER <<< "#
#
"
#\"
)
return 0
}
 _password_simple
# _password_simple2

echo "🥦"
exit 0


