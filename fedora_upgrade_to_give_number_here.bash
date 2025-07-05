#!/usr/bin/env bash

function main(){
	local -i target="${1-}"
	[[ -z "${1-}" ]] && echo -e "error give me number version 45 46 47 etc " && exit 1
  sudo dnf upgrade --refresh  --releasever=${target}  -y --allowerasing --nobest --disable-repo=remi --disable-repo=remi-modular --disable-repo=rpmfusion-free --disable-repo=rpmfusion-free-updates-testing --disable-repo=rpmfusion-nonfree --disable-repo=rpmfusion-nonfree-nvidia-driver --disable-repo=rpmfusion-nonfree-updates-testing --disable-repo=scootersoftware --disable-repo=sublime-text --disable-repo=fedora-cisco-openh264 --disable-repo=keybase --disable-repo=nordvpn --disable-repo=nordvpn-noarch --disable-repo=cloudfoundry-cli --disable-repo=adoptium-temurin-java-repository --disable-repo=1password --disable-repo=cuda-fedora37-x86_64 --disable-repo=cuda-fedora39-x86_64

  sudo dnf distro-sync  --releasever=${target}  -y --allowerasing --nobest --disable-repo=remi --disable-repo=remi-modular --disable-repo=rpmfusion-free --disable-repo=rpmfusion-free-updates-testing --disable-repo=rpmfusion-nonfree --disable-repo=rpmfusion-nonfree-nvidia-driver --disable-repo=rpmfusion-nonfree-updates-testing --disable-repo=scootersoftware --disable-repo=sublime-text --disable-repo=fedora-cisco-openh264 --disable-repo=keybase --disable-repo=nordvpn --disable-repo=nordvpn-noarch --disable-repo=cloudfoundry-cli --disable-repo=adoptium-temurin-java-repository --disable-repo=1password --disable-repo=cuda-fedora37-x86_64 --disable-repo=cuda-fedora39-x86_64

	sudo dnf install symlinks -y
	sudo symlinks -r /usr | grep dangling
	sudo symlinks -r -d /usr
	sudo dnf remove java-11-openjdk-devel -y
	sudo dnf remove golang-github-cespare-xxhash-devel -y
	sudo dnf remove compat-golang-github-chzyer-readline-devel -y
	sudo dnf remove bazel4 -y
	sudo dnf system-upgrade download --releasever=${target}  -y --allowerasing --nobest --disable-repo=remi --disable-repo=remi-modular --disable-repo=rpmfusion-free --disable-repo=rpmfusion-free-updates-testing --disable-repo=rpmfusion-nonfree --disable-repo=rpmfusion-nonfree-nvidia-driver --disable-repo=rpmfusion-nonfree-updates-testing --disable-repo=scootersoftware --disable-repo=sublime-text --disable-repo=fedora-cisco-openh264 --disable-repo=keybase --disable-repo=nordvpn --disable-repo=nordvpn-noarch --disable-repo=cloudfoundry-cli --disable-repo=adoptium-temurin-java-repository --disable-repo=1password --disable-repo=cuda-fedora37-x86_64 --disable-repo=cuda-fedora39-x86_64
  sudo dnf install https://rpms.remirepo.net/fedora/remi-release-${target}.rpm -y
	sudo dnf system-upgrade reboot -y

} # end main

main "${1}"


#
