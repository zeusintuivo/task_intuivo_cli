sudo grub2-editenv create
sudo grub2-mkconfig -o /etc/grub2-efi.cfg
sudo dracut -f --regenerate-all
