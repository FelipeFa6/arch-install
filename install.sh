DRIVE="/dev/sda";
SYSTEMPARTITION="/dev/sda1";

# Choose your drivers
DRIVERS="AMD";
#DRIVERS="INTEL";
#DRIVERS="NVIDIA";

#part1
echo "Arch install script\n";
pacman --noconfirm -Sy archlinux-keyring
timedatectl set-ntp true
lsblk

echo "Installation will be performed in the $DRIVE drive"
read -p "Is this correct? [y/n]" answer
if [[ $answer = n ]] ; then
  lsblk
  echo "Select the desired drive (/dev/sdX)"
  read DRIVE
fi
cfdisk $DRIVE

echo "Arch Linux will be installed in $SYSTEMPARTITION partition"
read -p "Is this correct? [y/n]" answer
if [[ $answer = n ]] ; then
  lsblk
  echo "Enter the base system partition (/dev/sdX1)"
  read SYSTEMPARTITION
fi
mkfs.ext4 $SYSTEMPARTITION

read -p "Did you create a SWAP partition? [y/n]" answer
if [[ $answer = y ]] ; then
  lsblk
  echo "Enter the SWAP partition: "
  read swapPartition
  mkswap $swapPartition
  swapon $swapPartition
fi

mount $SYSTEMPARTITION /mnt
pacstrap /mnt base base-devel linux-lts linux-firmware

#Personal
mkdir /mnt/mnt/st1
mkdir /mnt/mnt/st2

mount /dev/sdb1 /mnt/mnt/st1
mount /dev/sdc1 /mnt/mnt/st2

genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' `basename $0` > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit 


#part2
printf '\033c'
ln -sf /usr/share/zoneinfo/Chile/Continental /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "Enter your Hostname: "
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
mkinitcpio -P
passwd

pacman --noconfirm -S grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg 

pacman -S --noconfirm vim git networkmanager \
  xorg-server xorg-xinit libxinerama libxft webkit2gtk xorg-xsetroot xwallpaper \
  gcr gstreamer gst-plugins-good gst-libav gst-plugins-base xdg-utils \
  pipewire pipewire-pulse pulsemixer \
  bluez bluez-utils \
  zsh doas zathura zathura-pdf-poppler sxiv inetutils

#Video Drivers
echo "Installing $DRIVERS Drivers"
case $DRIVERS in
        "AMD")
					pacman -S --noconfirm xf86-video-amdgpu mesa
					;;
        "INTEL")
					pacman -S --noconfirm xf86-video-intel mesa
          ;;
        "NVIDIA")
					pacman -S --noconfirm nvidia nvidia-utils
          ;;
esac

pacman -Rs --noconfirm sudo
# doas config
echo "permit nopass :wheel" >> /etc/doas.conf
systemctl enable NetworkManager

echo "Enter a username: "
read username
useradd -mG wheel $username
passwd $username
doas chsh -s $(which zsh) $username
echo "Pre-Installation Finish Reboot now"
ai3_path=/home/$username/arch_install3.sh
sed '1,/^#part3$/d' arch_install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/sh $username
exit 

#part3
printf '\033c'
cd $HOME

git clone --depth=1 https://github.com/felipefa6/.vim
git clone --depth=1 https://github.com/felipefa6/dotfiles.git $HOME/.dotfiles
cp -r $HOME/.dotfiles/.config $HOME/
cp -r $HOME/.dotfiles/bin $HOME/
cp $HOME/.dotfiles/.zprofile $HOME/

# Post installation software
installdir="/usr/src/"
doas mkdir $installdir

doas git clone --depth=1 https://git.suckless.org/dwm $installdir/dwm
doas make -C $installdir/dwm install

doas git clone --depth=1 https://git.suckless.org/st $installdir/st
doas make -C $installdir/st install

doas git clone --depth=1 https://git.suckless.org/dmenu $installdir/dmenu
doas make -C $installdir/dmenu install

doas git clone --depth=1 https://git.suckless.org/surf $installdir/surf
doas make -C $installdir/surf install

exit

