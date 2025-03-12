#!/usr/bin/env bash

function main(){
	local -i target="${1-}"
	[[ -z "${1-}" ]] && echo -e "error give me number version 45 46 47 etc " && exit 1
  sudo dnf upgrade --refresh -y --allowerasing --nobest --disable-repo=remi --disable-repo=remi-modular

  sudo dnf distro-sync -y --allowerasing --nobest --disable-repo=remi --disable-repo=remi-modular

	sudo dnf install symlinks -y
	sudo symlinks -r /usr | grep dangling
	sudo symlinks -r -d /usr
	sudo dnf remove java-11-openjdk-devel -y
	sudo dnf remove golang-github-cespare-xxhash-devel -y
	sudo dnf remove compat-golang-github-chzyer-readline-devel -y
	sudo dnf remove bazel4 -y
	sudo dnf system-upgrade download --releasever=${target} -y --allowerasing --nobest --disable-repo=remi --disable-repo=remi-modular
  sudo dnf install https://rpms.remirepo.net/fedora/remi-release-${target}.rpm -y
	sudo dnf system-upgrade reboot -y --allowerasing --nobest --disable-repo=remi --disable-repo=remi-modular

} # end main

main "${1}"


#
