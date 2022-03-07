# == MY ARCH SETUP INSTALLER == #
#part1
printf '\033c'
echo "Welcome to bugswriter's arch installer script"
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true
lsblk
echo "Enter the drive: "
read drive
cfdisk $drive 
echo "Enter the linux partition: "
read partition
mkfs.ext4 $partition 
read -p "Did you also create efi partition? [y/n]" answer
if [[ $answer = y ]] ; then
  echo "Enter EFI partition: "
  read efipartition
  mkfs.vfat -F 32 $efipartition
fi
mount $partition /mnt 
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' `basename $0` > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit 

#part2
printf '\033c'
pacman -S --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Chile/continental /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "Hostname: "
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
mkinitcpio -P
passwd
pacman --noconfirm -S grub efibootmgr os-prober
echo "Enter EFI partition: " 
read efipartition
mkdir /boot/efi
mount $efipartition /boot/efi 
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
sed -i 's/quiet/pci=noaer/g' /etc/default/grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg


pacman -S --noconfirm vim git networkmanager \
  xorg-server xorg-xinit libxinerama libxft webkit2gtk xorg-xsetroot xwallpaper \
  pipewire pipewire-pulse pulsemixer \
  bluez bluez-utils \
  zsh doas zathura zathura-pdf-poppler sxiv inetutils

systemctl enable NetworkManager.service 
rm /bin/sh
ln -s dash /bin/sh
echo "permit nopass :wheel" >> /etc/doas.conf
echo "Enter Username: "
read username
useradd -m -G wheel -s /bin/zsh $username
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
git clone --depth=1 https://github.com/felipefa6/.vim
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

cd $HOME
rm -rf .bash*

exit

