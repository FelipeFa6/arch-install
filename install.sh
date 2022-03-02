#Arch Install Script

#part1
printf '\033c'
echo "Auto Arch install script"
timedatectl set-ntp true
lsblk
# Drive
echo "Enter the drive: "
read drive
cfdisk $drive
# System Partition
echo "Enter the linux partition: "
read partition
mkfs.ext4 $partition
mount $partition /mnt
#SWAP mount
read -p "Did you create a SWAP partition? [y/n]" answer
if [[ $answer = y ]] ; then
	lsblk
  echo "Enter the SWAP partition: "
  read swapPartition
  mkswap $swapPartition
	swapon $swapPartition
fi
pacstrap /mnt base base-devel linux-lts linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' `basename $0` > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit

#part2
printf '\033c'
ln -sf /usr/share/zoneinfo/Chile/Continental /etc/localtime #Change this to your location
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "Enter your Hostname: "
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
mkinitcpio -P
passwd # password for root user
# Bootloader
pacman --noconfirm -S grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
# Programs to be installed
pacman -S --noconfirm vim git networkmanager \
	# dwm, st, dmenu dependencies
	xorg-server xorg-xinit libxinerama libxft webkit2gtk xorg-xsetroot xwallpaper \
	# surf browser dependencies
	gcr gstreamer gst-plugins-good gst-libav gst-plugins-base xdg-utils \
	# audio
	pipewire pipewire-pulse pulsemixer \
	# bluetooth (enable it by uncommenting)
  #bluez bluez-utils \
	#utilities
	zsh doas zathura zathura-pdf-poppler sxiv inetutils
systemctl enable NetworkManager
pacman -Rs --noconfirm sudo
echo "permit nopass :wheel" >> /etc/doas.conf
# User creation
echo "Enter a username: "
read username
useradd -m -G wheel -s $(which zsh) $username
passwd $username
echo "Pre-Installation finish reboot now"
ai3_path=/home/$username/arch_install3.sh
sed '1,/^#part3$/d' arch_install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/sh $username
exit

#part3
printf '\033c'
cd $HOME
git clone --depth=1 https://github.com/felipe/dotfiles.git $HOME/.dotfiles
cp -r $HOME/.dotfiles/.config $HOME/
cp -r $HOME/.dotfiles/bin $HOME/
cp $HOME/.dotfiles/.zprofile $HOME/

# Post installation software
mkdir $HOME/.local/src
installdir="$HOME/.local/src"
git clone --depth=1 https://github.com/felipefa6/dwm.git $installdir/dwm
doas make -C $installdir/dwm install
git clone --depth=1 https://github.com/felipefa6/st.git $installdir/st
doas make -C $installdir/st install
git clone --depth=1 https://git.suckless.org/dmenu $installdir/dmenu
doas make -C $installdir/dmenu install
git clone --depth=1 https://git.suckless.org/surf $installdir/surf
doas make -C $installdir/surf install
exit

