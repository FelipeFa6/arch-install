DRIVE="/dev/sda";

SYSTEMPARTITION="/dev/sda1";

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
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
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

pacman -Rs --noconfirm sudo
echo "permit nopass :wheel" >> /etc/doas.conf

systemctl enable NetworkManager

echo "Enter a username: "
read username
useradd -mG wheel $username
passwd $username
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

git clone --depth=1 https://github.com/felipefa6/dotfiles.git $HOME/.dotfiles
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

