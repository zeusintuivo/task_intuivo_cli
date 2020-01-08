#!/usr/bin/env bash
#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
THISSCRIPTNAME=`basename "$0"`
load_struct_testing_wget(){
    local provider="$HOME/_/clis/execute_command_intuivo_cli/struct_testing"
    [   -e "${provider}"  ] && source "${provider}"
    [ ! -e "${provider}"  ] && eval """$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing -O -  2>/dev/null )"""   # suppress only wget download messages, but keep wget output for variable
    ( ( ! command -v type passed >/dev/null 2>&1; ) && echo -e "\n \n  ERROR! Loading struct_testing \n \n " && exit 69; )
} # end load_struct_testing_wget
load_struct_testing_wget


# Brew

Installing Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"






Installing Rbev
    version_of_Ruby_to_install="2.4.0"
    version_of_Ruby_to_install="2.3.3"
    version_of_Ruby_to_install="2.2.6"
    version_of_Ruby_to_install="2.1.10"
    version_of_Ruby_to_install="2.0.0-p648"
Installing Ruby "${version_of_Ruby_to_install}"
    brew install rbenv ruby-build

    # Add rbenv to bash so that it loads every time you open a terminal
    echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
    source ~/.bash_profile

    # Install Ruby
    rbenv install "${version_of_Ruby_to_install}"
    rbenv global "${version_of_Ruby_to_install}"
    ruby -v







    YOUR_NAME="YOUR NAME"
    YOUR_EMAIL="YOUR@EMAIL.com"
Configuring Git

    git config --global color.ui true
    git config --global user.name "${YOUR_NAME}"
    git config --global user.email "${YOUR_EMAIL}"
    ssh-keygen -t rsa -C "${YOUR_EMAIL}"


    cat ~/.ssh/id_rsa.pub

    ssh -T git@github.com

    #expect "Hi "${YOUR_NAME}"! You've successfully authenticated, but GitHub does not provide shell access."






    version_of_Rails_to_install="5.0.1"
    version_of_Rails_to_install="4.2.7.1"
    version_of_Rails_to_install="4.1.16"
    version_of_Rails_to_install="4.0.13"
    version_of_Rails_to_install="3.2.22.5"
Installing Rails

    gem install rails -v "${version_of_Rails_to_install}"
    rbenv rehash
    rails -v







Setting Up A Database

Installing sqlite3
    brew install sqlite3

Installing mysql
    brew install mysql
    # To have launchd start mysql at login:
    ln -sfv /usr/local/opt/mysql/*plist ~/Library/LaunchAgents
    # Then to load mysql now:
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist

Installing PostgreSQL
    brew install postgresql
    # To have launchd start postgresql at login:
    ln -sfv /usr/local/opt/postgresql/*plist ~/Library/LaunchAgents
    # Then to load postgresql now:
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist








Final Steps
    rails new myapp

    #### If you want to use MySQL
    rails new myapp -d mysql

    #### If you want to use Postgres
    # Note you will need to change config/database.yml's username to be
    # the same as your OSX user account. (for example, mine is 'chris')
    rails new myapp -d postgresql

    # Move into the application directory
    cd myapp

    # If you setup MySQL or Postgres with a username/password, modify the
    # config/database.yml file to contain the username/password that you specified

    # Create the database
    rake db:create

    rails server

echo ":)"
