# Get sudo rights

sudo usermod -aG sudo jesusa # as root or sudo user

# Install guake terminal
sudo apt instal guake -y

# Intall firefox profiles
firefox -P # setup first topic env in browser, install 1password

# Setup clis
cd
mkdir _
cd _
mkdir clis
cd clis
git clone https://github.com/zeusintuivo/ssh_intuivo_cli.git
cd ssh_intuivo_cli/
./sshgeneratekeys future
./sshgeneratekeys zeus
./sshswitchkey zeus
cd ..
rm -rf ssh_intuivo_cli/
cat /home/jesusa/.ssh/zeus_rsa.pub
cat /home/jesusa/.ssh/future_rsa.pub
git clone git@github.com:zeusintuivo/task_intuivo_cli.git
git clone git@github.com:zeusintuivo/bash_intuivo_cli.git
git clone git@github.com:zeusintuivo/git_intuivo_cli.git
git clone git@github.com:zeusintuivo/journal_intuivo_cli.git
git clone git@github.com:zeusintuivo/execute_command_intuivo_cli.git
git clone git@github.com:zeusintuivo/guake_intuivo_cli.git
git clone git@github.com:zeusintuivo/ssh_intuivo_cli.git

cd bash_intuivo_cli
./link_folder_scripts

cd ..
cd task_intuivo_cli
link_folder_scripts

cd ..
cd git_intuivo_cli
link_folder_scripts

cd ..
cd journal_intuivo_cli
link_folder_scripts

cd ..
cd execute_command_intuivo_cli
link_folder_scripts

cd ..
cd guake_intuivo_cli
link_folder_scripts

cd ..
cd ssh_intuivo_cli
link_folder_scripts

cd ..


# upgrade gnome-shell
sudo apt-get install chrome-gnome-shell -y

# Install tweak tool
sudo apt-get install gnome-tweak-tool gnome-tweaks  -y

# Install helper software - curl
sudo apt install curl -y

# Upgrade bash to latest
sudo apt-get autoclean -y
sudo apt-get install -y --only-upgrade bash
sudo apt-get upgrade -y

# Upgrade gnome terminal to lastest
sudo apt-get autoclean -y
sudo apt-get install -y --only-upgrade gnome-terminal
sudo apt-get upgrade -y

# Upgrade guake to lastest
sudo add-apt-repository ppa:linuxuprising/guake -y
sudo apt update -y
sudo apt install guake -y

# Install nodejs
# REF: https://linuxize.com/post/how-to-install-node-js-on-ubuntu-18.04/
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

