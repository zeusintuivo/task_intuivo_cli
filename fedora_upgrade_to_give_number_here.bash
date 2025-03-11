#!/usr/bin/env bash

function main(){
	local -i target="${1-}"
	[[ -z "${1-}" ]] && echo -e "error give me number version 45 46 47 etc " && exit 1
  sudo dnf upgrade --refresh -y
  sudo dnf distro-sync -y
	sudo dnf install symlinks -y
	sudo symlinks -r /usr | grep dangling
	sudo symlinks -r -d /usr
	sudo dnf remove java-11-openjdk-devel -y
	sudo dnf remove golang-github-cespare-xxhash-devel -y
	sudo dnf remove compat-golang-github-chzyer-readline-devel -y
	sudo dnf remove bazel4 -y
	sudo dnf system-upgrade download --releasever=${target} -y
	sudo dnf system-upgrade reboot -y
} # end main

main "${1}"


#
