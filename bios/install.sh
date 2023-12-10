DISK="/dev/sda";
SYSTEMPARTITION="/dev/sda1";

HOSTNAME="desktop"
USERNAME="felipe";
PASSWORD="setPassword";

LINUX="linux-lts linux-lts-headers"

LOCATION="/usr/share/zoneinfo/Chile/Continental"

AUDIO     = "pulseaudio pulseaudio-bluetooth pulsemixer"
BLUETOOTH = "bluez bluez-utils"
BROWSER   = "firefox"
DRIVERS   = "xf86-video-amdgpu mesa";
INTERNET  = "dhcpcd iwd"
X11       = "xorg-server xorg-xinit libxinerama libxft webkit2gtk xorg-xsetroot"


#part1
echo "FelipeFa6's arch install script\n";
pacman --noconfirm -Sy archlinux-keyring
timedatectl set-ntp true

./partition $DISK
mkfs.ext4 $SYSTEMPARTITION

mount $SYSTEMPARTITION /mnt
pacstrap /mnt base base-devel linux-firmware $LINUX

# mount personal drive
mkdir /mnt/mnt/st1
mount /dev/sdb1 /mnt/mnt/st1

genfstab -U /mnt >> /mnt/etc/fstab

sed '1,/^#part2$/d' `basename $0` > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh

arch-chroot /mnt ./arch_install2.sh
exit 

#part2
printf '\033c'
ln -sf $LOCATION /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen

echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
mkinitcpio -P
passwd

pacman --noconfirm -S grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg 

pacman -S --noconfirm vim git doas \
    $AUDIO \
    $BLUETOOTH \
    $BROWSER \
    $DRIVERS \
    $INTERNET \
    $X11 \

	# xorg-server xorg-xinit libxinerama libxft webkit2gtk xorg-xsetroot xwallpaper \
	# chromium \
	# bluez bluez-utils \
	# pulseaudio pulseaudio-bluetooth pulsemixer \
	# doas


#video drivers
pacman -S --noconfirm xf86-video-amdgpu mesa

# doas config
echo "permit nopass :wheel" >> /etc/doas.conf
systemctl enable NetworkManager
clear

echo "Password for => $USERNAME"
useradd -mG wheel $USERNAME
passwd $USERNAME
