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
    ( ( ! command -v passed >/dev/null 2>&1; ) && echo -e "\n \n  ERROR! Loading struct_testing \n \n " && exit 69; )
} # end load_struct_testing_wget
load_struct_testing_wget






    version_of_Ruby_to_install="2.4.0"
    version_of_Ruby_to_install="2.3.3"
    version_of_Ruby_to_install="2.2.6"
    version_of_Ruby_to_install="2.1.10"
    version_of_Ruby_to_install="2.0.0-p648"
Installing Ruby "${version_of_Ruby_to_install}"

sudo apt-get update
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nodejs










Installing Rbenv
    cd
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    exec $SHELL

    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
    exec $SHELL

Installing Ruby using Rbenv
    rbenv install "${version_of_Ruby_to_install}"
    rbenv global "${version_of_Ruby_to_install}"
    ruby -v








Installing Rvm
    sudo apt-get install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    curl -sSL https://get.rvm.io | bash -s stable
    source ~/.rvm/scripts/rvm

Installing Ruby using Rvm
    rvm install "${version_of_Ruby_to_install}"
    rvm use "${version_of_Ruby_to_install}" --default
    ruby -v








Installing From Source
    cd
    IFS=. read MAJOR MINOR MICRO BUILD <<EOF
${version_of_Ruby_to_install##*-}
EOF
    wget http://ftp.ruby-lang.org/pub/ruby/"${MAJOR}"."${MINOR}"/ruby-"${version_of_Ruby_to_install}".tar.gz
    tar -xzvf ruby-"${version_of_Ruby_to_install}".tar.gz
    cd ruby-"${version_of_Ruby_to_install}"/
    ./configure
    make
    sudo make install
    ruby -v








Installing Bundler
    gem install bundler





    YOUR_NAME="YOUR NAME"
    YOUR_EMAIL="YOUR@EMAIL.com"
Configuring Git

    git config --global color.ui true
    git config --global user.name "${YOUR_NAME}"
    git config --global user.email "${YOUR_EMAIL}"
    ssh-keygen -t rsa -b 4096 -C "${YOUR_EMAIL}"


    cat ~/.ssh/id_rsa.pub

    ssh -T git@github.com

    #expect "Hi "${YOUR_NAME}"! You've successfully authenticated, but GitHub does not provide shell access."






    version_of_Rails_to_install="5.0.1"
    version_of_Rails_to_install="4.2.7.1"
    version_of_Rails_to_install="4.1.16"
    version_of_Rails_to_install="4.0.13"
    version_of_Rails_to_install="3.2.22.5"

Installing NodeJS
    curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
    sudo apt-get install -y nodejs

Installing Rails
    gem install rails -v "${version_of_Rails_to_install}"
    command -v rbenv && rbenv rehash
    rails -v






Setting Up A Database

Installing mysql
    sudo apt-get install mysql-server mysql-client libmysqlclient-dev

Installing PostgreSQL
    sudo sh -c "echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
    wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
    sudo apt-get update
    sudo apt-get install postgresql-common
    sudo apt-get install postgresql-9.5 libpq-dev

    sudo -u postgres createuser chris -s

    # If you would like to set a password for the user, you can do the following
    sudo -u postgres psql
    postgres=# \password chris





Final Steps
    #### If you want to use SQLite (not recommended)
    rails new myapp

    #### If you want to use MySQL
    rails new myapp -d mysql

    #### If you want to use Postgres
    # Note that this will expect a postgres user with the same username
    # as your app, you may need to edit config/database.yml to match the
    # user you created earlier
    rails new myapp -d postgresql

    # Move into the application directory
    cd myapp

    # If you setup MySQL or Postgres with a username/password, modify the
    # config/database.yml file to contain the username/password that you specified

    # Create the database
    rake db:create

    rails server

echo ":)"
