#!/usr/bin/env bash

function main(){

  # AFTER
	sudo dnf install rpmconf -y
	sudo rpmconf -a
	sudo dnf install remove-retired-packages -y
	yes | sudo remove-retired-packages -y
	sudo dnf repoquery --duplicates
	sudo dnf remove --duplicates
	sudo dnf list --extras
	sudo dnf autoremove -y
  sudo dnf upgrade --refresh -y
  sudo dnf distro-sync -y
	old_kernels=($(sudo dnf repoquery --installonly --latest-limit=-1 -q))
  if [ "${#old_kernels[@]}" -eq 0 ]; then
    echo "No old kernels found"
	else
    if ! sudo dnf remove "${old_kernels[@]}"; then
      echo "Failed to remove old kernels"
    fi
	fi
	sudo dnf install clean-rpm-gpg-pubkey -y
	sudo clean-rpm-gpg-pubkey -y
	sudo dnf install symlinks -y
	sudo symlinks -r /usr | grep dangling
	sudo symlinks -r -d /usr
  sudo rm /boot/*rescue*
  sudo kernel-install add "$(uname -r)" "/lib/modules/$(uname -r)/vmlinuz"
	sudo dnf install dracut-config-rescue -y
	sudo rpm --rebuilddb
	sudo dnf distro-sync --allowerasing -y
  sudo dnf install --allowerasing --nobest https://rpms.remirepo.net/fedora/remi-release-$(rpm -E %fedora).rpm -y
	# sudo dnf install https://rpms.remirepo.net/fedora/remi-release-${target}.rpm -y
	sudo fixfiles -B onboot
} # end main

main


#
