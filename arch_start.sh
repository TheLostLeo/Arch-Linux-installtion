#! /bin/sh

# Script for installing after creating partitions, installing basics, and genfstab.

# Run the script once chrooted.

set -e
# Confirmation prompt
read -s -n 1 -p 'Are you sure that you have gone through the variables before running? (y/n): ' ans
[[ $ans = 'y' ]] || exit 1

_HOSTNAME=""
_USERNAME=""
_DISK="/dev/"

# Very Important:
alias echo="echo -e"

# set local time
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen

locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "${_HOSTNAME}" > /etc/hostname

# Hosts
echo "\n\n127.0.0.1	localhost\n::1		localhost\n127.0.1.1	${_HOSTNAME}.localdomain ${_HOSTNAME}" >> /etc/hosts

mkinitcpio -P

# Password
passwd

pacman -S iwd ranger grub neovim sudo efibootmgr linux-headers

systemctl enable iwd.service

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

useradd -m ${_USERNAME}
passwd ${_USERNAME}

usermod -aG wheel,audio,video,optical,storage,network,input ${_USERNAME}

# DNS server
# echo "DNS=1.1.1.1" >> /etc/systemd/resolved.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
systemctl enable systemd-resolved.service

# UEFI boot
#grub-install --target=i386-pc --recheck $_DISK
#grub-install --target=x86_64-efi --efi-directory=/boot/efi --recheck --removable


#sudo apt install os-prober
#$ sudo os-prober /dev/sda1:Windows 10:Windows:chain
#$ sudo cat /etc/default/grub | grep 'GRUB_DISABLE_OS_PROBER' GRUB_DISABLE_OS_PROBER=true
#$ sudo vi /etc/default/grub GRUB_DISABLE_OS_PROBER=false
#grub-mkconfig -o /boot/grub/grub.cfg
#$ sudo update-grub
#$ sudo reboot -f
