USERNAME="felipe";
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
mount /dev/sdb1 /mnt/mnt/st1

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

pacman -S --noconfirm vim git networkmanager doas
	# xorg-server xorg-xinit libxinerama libxft webkit2gtk xorg-xsetroot xwallpaper \
	# chromium \
	# bluez bluez-utils \
	# pulseaudio pulseaudio-bluetooth pulsemixer \
	# doas

cd


git clone https://aur.archlinux.org/rtl88x2bu-dkms-git.git wifi
pacman -S linux-headers

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
clear

echo "Password for => $USERNAME"
useradd -mG wheel $USERNAME
passwd $USERNAME
