#!/bin/bash

# This script automates a basic Arch Linux installation for UEFI systems.
# It provides interactive prompts for disk selection, partitioning, bootloader,
# timezone, locale, user creation, graphics drivers, and desktop environment.

echo "--- Arch Linux Automated Installation Script (UEFI Only) ---"
echo "This script is designed for UEFI systems. Ensure your VM or physical machine is configured for UEFI boot."

# --- 1. Pre-installation setup ---

echo "--- Updating system clock ---"
timedatectl set-ntp true

echo "--- Identifying target disk ---"
echo "Available disks:"
# List disks, excluding loop devices and showing size and model
# Corrected: --noheadings instead of noheadings
lsblk -dpl --noheadings -o NAME,SIZE,MODEL | grep -E 'sd|nvme|vd'

DISK=""
while [ -z "$DISK" ]; do
    read -p "Enter the target disk (e.g., /dev/sda, /dev/nvme0n1): " DISK
    if [ ! -b "$DISK" ]; then
        echo "Error: $DISK is not a valid block device. Please try again."
        DISK=""
    fi
done

echo "--- Partitioning the disk ($DISK) using cfdisk ---"
echo "You will create the following partitions:"
echo "  1. EFI System Partition (e.g., 512M, type EFI System)"
echo "  2. Swap Partition (e.g., 2G-4G, type Linux swap)"
echo "  3. Root Partition (e.g., 20G+, type Linux filesystem)"
echo "  4. (Optional) Home Partition (rest of disk, type Linux filesystem)"
echo "After partitioning, remember the full paths for each (e.g., ${DISK}1, ${DISK}2, etc.)."
read -p "Press Enter to launch cfdisk..."
cfdisk "$DISK"

echo "--- Formatting partitions ---"
read -p "Enter the EFI partition (e.g., ${DISK}1): " EFI_PART
read -p "Enter the Swap partition (e.g., ${DISK}2): " SWAP_PART
read -p "Enter the Root partition (e.g., ${DISK}3): " ROOT_PART
read -p "Enter the (optional) Home partition (e.g., ${DISK}4, leave empty if no home partition): " HOME_PART

mkfs.fat -F32 "$EFI_PART"
mkswap "$SWAP_PART"
swapon "$SWAP_PART"
mkfs.ext4 "$ROOT_PART"

if [ -n "$HOME_PART" ]; then
    mkfs.ext4 "$HOME_PART"
fi

echo "--- Mounting partitions ---"
mount "$ROOT_PART" /mnt

if [ -n "$HOME_PART" ]; then
    mkdir /mnt/home
    mount "$HOME_PART" /mnt/home
fi

mkdir -p /mnt/boot/efi
mount "$EFI_PART" /mnt/boot/efi

# --- 2. Installation ---

echo "--- Choosing bootloader ---"
echo "Select your preferred bootloader:"
echo "  1) GRUB (Recommended for general use, highly compatible)"
echo "  2) systemd-boot (Simpler, UEFI-only, integrates with systemd)"
echo "  3) rEFInd (Graphical, auto-detects boot entries, user-friendly)"
BOOTLOADER_CHOICE=""
while [[ ! "$BOOTLOADER_CHOICE" =~ ^[1-3]$ ]]; do
    read -p "Enter choice (1, 2, or 3): " BOOTLOADER_CHOICE
    if [[ ! "$BOOTLOADER_CHOICE" =~ ^[1-3]$ ]]; then
        echo "Invalid choice. Please enter 1, 2, or 3."
    fi
done

BOOTLOADER_PACKAGES=""
case "$BOOTLOADER_CHOICE" in
    1)
        BOOTLOADER_PACKAGES="grub efibootmgr"
        BOOTLOADER_NAME="GRUB"
        ;;
    2)
        # systemd is part of base, no extra package needed here for bootloader itself
        BOOTLOADER_PACKAGES=""
        BOOTLOADER_NAME="systemd-boot"
        ;;
    3)
        BOOTLOADER_PACKAGES="refind"
        BOOTLOADER_NAME="rEFInd"
        ;;
esac

echo "--- Choosing graphics driver ---"
echo "Select your graphics card type:"
echo "  1) Intel"
echo "  2) AMD"
echo "  3) NVIDIA"
echo "  4) Virtual Machine / None (for basic VESA or VM drivers)"
GRAPHICS_CHOICE=""
while [[ ! "$GRAPHICS_CHOICE" =~ ^[1-4]$ ]]; do
    read -p "Enter choice (1, 2, 3, or 4): " GRAPHICS_CHOICE
    if [[ ! "$GRAPHICS_CHOICE" =~ ^[1-4]$ ]]; then
        echo "Invalid choice. Please enter 1, 2, 3, or 4."
    fi
done

GRAPHICS_PACKAGES=""
case "$GRAPHICS_CHOICE" in
    1) GRAPHICS_PACKAGES="xf86-video-intel vulkan-intel mesa" ;;
    2) GRAPHICS_PACKAGES="xf86-video-amdgpu vulkan-radeon mesa" ;;
    3) GRAPHICS_PACKAGES="nvidia nvidia-utils nvidia-settings" ;; # Consider nvidia-dkms for custom kernels
    4) GRAPHICS_PACKAGES="" ;; # No specific driver, relies on basic VESA or VM integration
esac


echo "--- Installing essential packages, $BOOTLOADER_NAME, and graphics drivers ---"
# base: essential system files
# linux: the Linux kernel
# linux-firmware: firmware for various hardware
# networkmanager: network management service
# sudo: for user privilege escalation
# vim: a text editor
# git: version control
# dialog: for potential future interactive prompts
pacstrap /mnt base linux linux-firmware networkmanager sudo vim git dialog $BOOTLOADER_PACKAGES $GRAPHICS_PACKAGES

echo "--- Generating fstab ---"
genfstab -U /mnt >> /mnt/etc/fstab

echo "--- Entering chroot environment ---"
# The following commands will be executed inside the new Arch installation
arch-chroot /mnt /bin/bash <<EOF

echo "--- Setting timezone ---"
# List common timezones, user can input their desired one
echo "Example timezones: America/New_York, Europe/London, Asia/Tokyo"
read -p "Enter your desired timezone (e.g., Europe/Oslo): " TIMEZONE_INPUT
ln -sf "/usr/share/zoneinfo/$TIMEZONE_INPUT" /etc/localtime || echo "Warning: Timezone $TIMEZONE_INPUT might be invalid or not found."
hwclock --systohc

echo "--- Setting locale ---"
echo "Common locales: en_US.UTF-8, de_DE.UTF-8, fr_FR.UTF-8"
read -p "Enter your primary locale (e.g., en_US.UTF-8): " PRIMARY_LOCALE
echo "$PRIMARY_LOCALE UTF-8" >> /etc/locale.gen
read -p "Do you want to add more locales? (y/N): " ADD_MORE_LOCALES
if [[ "$ADD_MORE_LOCALES" =~ ^[Yy]$ ]]; then
    echo "Enter additional locales, one per line. Press Ctrl+D when finished."
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            echo "$line UTF-8" >> /etc/locale.gen
        fi
    done
fi
locale-gen
echo "LANG=$PRIMARY_LOCALE" > /etc/locale.conf

echo "--- Setting hostname ---"
read -p "Enter hostname: " HOSTNAME
echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

echo "--- Setting root password ---"
echo "Set password for root user:"
passwd

echo "--- Creating a new user ---"
read -p "Enter new username: " USERNAME
useradd -m -g users -G wheel "$USERNAME"
echo "Set password for $USERNAME:"
passwd "$USERNAME"

echo "--- Granting sudo privileges to wheel group ---"
# Uncomment the wheel group line in /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "--- Installing and configuring $BOOTLOADER_NAME for EFI ---"
case "$BOOTLOADER_CHOICE" in
    1)
        # GRUB installation
        grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux --recheck
        grub-mkconfig -o /boot/grub/grub.cfg
        ;;
    2)
        # systemd-boot installation
        bootctl install
        # Create loader.conf
        echo "default arch" > /boot/efi/loader/loader.conf
        echo "timeout 3" >> /boot/efi/loader/loader.conf
        echo "console-mode max" >> /boot/efi/loader/loader.conf
        # Create Arch Linux boot entry
        mkdir -p /boot/efi/loader/entries
        echo "title   Arch Linux" > /boot/efi/loader/entries/arch.conf
        echo "linux   /vmlinuz-linux" >> /boot/efi/loader/entries/arch.conf
        echo "initrd  /initramfs-linux.img" >> /boot/efi/loader/entries/arch.conf
        # Get root PARTUUID for kernel parameters
        ROOT_PART_UUID=$(blkid -s PARTUUID -o value "$ROOT_PART")
        echo "options root=PARTUUID=$ROOT_PART_UUID rw" >> /boot/efi/loader/entries/arch.conf
        ;;
    3)
        # rEFInd installation
        refind-install
        ;;
esac

echo "--- Enabling NetworkManager service ---"
systemctl enable NetworkManager

echo "--- Optional: Install Desktop Environment ---"
echo "Select a Desktop Environment to install (or skip):"
echo "  1) GNOME"
echo "  2) KDE Plasma"
echo "  3) XFCE"
echo "  4) None (minimal CLI system)"
DE_CHOICE=""
while [[ ! "$DE_CHOICE" =~ ^[1-4]$ ]]; do
    read -p "Enter choice (1, 2, 3, or 4): " DE_CHOICE
    if [[ ! "$DE_CHOICE" =~ ^[1-4]$ ]]; then
        echo "Invalid choice. Please enter 1, 2, 3, or 4."
    fi
done

DE_PACKAGES=""
DISPLAY_MANAGER_SERVICE=""
case "$DE_CHOICE" in
    1)
        DE_PACKAGES="gnome gnome-extra"
        DISPLAY_MANAGER_SERVICE="gdm"
        ;;
    2)
        DE_PACKAGES="plasma kde-applications"
        DISPLAY_MANAGER_SERVICE="sddm"
        ;;
    3)
        DE_PACKAGES="xfce4 xfce4-goodies"
        DISPLAY_MANAGER_SERVICE="lightdm"
        ;;
    4)
        echo "Skipping Desktop Environment installation."
        ;;
esac

if [ -n "$DE_PACKAGES" ]; then
    echo "--- Installing Desktop Environment: $DE_PACKAGES ---"
    pacman -S --noconfirm "$DE_PACKAGES"

    if [ -n "$DISPLAY_MANAGER_SERVICE" ]; then
        echo "--- Enabling Display Manager: $DISPLAY_MANAGER_SERVICE ---"
        systemctl enable "$DISPLAY_MANAGER_SERVICE"
    fi
fi

echo "--- Installation complete! ---"
echo "You can now exit the chroot, unmount, and reboot."

EOF

echo "--- Exiting chroot ---"
echo "--- Unmounting all partitions ---"
umount -R /mnt

echo "--- Rebooting the system ---"
echo "Remove the installation media before rebooting."
read -p "Press Enter to reboot..."
reboot
