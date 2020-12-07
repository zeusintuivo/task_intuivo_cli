!#/bin/bash

su - root {
pwd
users
last
df -h
sudo dnf -y update
sudo dnf check-update
sudo dnf -y update
sudo dnf -y clean all
sudo dnf -y install nano vim wget curl net-tools lsof bash-completion
ping -c2 google.com
ethtool enp0s3
ifconfig
ethtool eth0
mii-tool eth0
netstat -tulpn
ss -tulpn
lsof -i4 -6
lsof -i4 -i6
useradd zeus
passwd zeus
usermod -aG wheel zeus
su - zeus
echo "changed the line PermitRootLogin yes to no" this could have been done with sed
pause
vi /etc/ssh/sshd_config
systemctl restart sshd
nmtui-hostname
nmtui-edit
nmtui-connect
ls
pwd
exit
history
}


su - zeus
echo setup_centos_8
sudo dnf -y update

cd
mkdir _
cd _
mkdir clis
cd clis
sudo dnf -y install git
git clone https://github.com/zeusintuivo/ssh_intuivo_cli.git
cd ssh_intuivo_cli/
./sshgeneratekeys zeus
./sshswitchkey zeus
cd ..
rm -rf ssh_intuivo_cli/
sudo dnf install -y gcc binutils make glibc-devel patch libgomp glibc-headers
