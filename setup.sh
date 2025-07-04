#!/bin/bash

# This script automates a basic Arch Linux installation for both UEFI and BIOS systems.
# It provides interactive prompts for system type, disk selection, partitioning, bootloader,
# timezone, locale, user creation, graphics drivers, and desktop environment.

# --- Configuration and Setup ---
set -e # Exit immediately if a command exits with a non-zero status.

# Function to clean up mounts if the script exits prematurely
cleanup_mounts() {
    echo "Attempting to unmount /mnt..."
    umount -R /mnt &>/dev/null || true # Ignore errors if not mounted
    echo "Cleanup complete."
}
trap cleanup_mounts EXIT # Ensure cleanup_mounts runs on script exit

clear
echo "--- ARCH LINUX AUTOMATED INSTALLATION SCRIPT ---"
echo "This script supports both UEFI and BIOS boot modes."

# --- 0. System Type Selection ---
echo -e "\n--- CHOOSING SYSTEM BOOT MODE ---"
echo "Is this a UEFI or BIOS (Legacy) system?"
echo "  1) UEFI (Modern systems, required for EFI System Partition)"
echo "  2) BIOS (Older systems, MBR-based boot)"

SYSTEM_TYPE_CHOICE=""
while true; do
    echo
    read -p "Enter choice (1 for UEFI, 2 for BIOS): " SYSTEM_TYPE_CHOICE
    case "$SYSTEM_TYPE_CHOICE" in
        1) SYSTEM_TYPE="UEFI"; echo -e "\nSelected: UEFI system."; break ;;
        2) SYSTEM_TYPE="BIOS"; echo -e "\nSelected: BIOS system."; break ;;
        *) echo "Invalid choice. Please enter 1 or 2." ;;
    esac
done

# --- 1. Pre-installation setup ---

echo -e "\n--- Updating system clock ---"
timedatectl set-ntp true || { echo "Error: Failed to set NTP. Check internet connection."; exit 1; }

echo -e "\n--- Identifying target disk ---"
echo "Available disks (excluding loop devices):"
# List disks, showing name, size, and model
lsblk -dpl --noheadings -o NAME,SIZE,MODEL | grep -E 'sd|nvme|vd' || { echo "Error: No disks found or lsblk failed."; exit 1; }

DISK=""
while true; do
    echo
    read -p "Enter the target disk (e.g., /dev/sda, /dev/nvme0n1): " DISK
    if [[ -b "$DISK" ]]; then
        echo -e "\nSelected disk: $DISK"
        break
    else
        echo "Error: '$DISK' is not a valid block device. Please try again."
    fi
done

# --- Hibernation and Swap Size Recommendation ---
echo -e "\n--- Hibernation and Swap Recommendation ---"
read -p "Do you plan to use hibernation (suspend-to-disk)? (y/N): " HIBERNATE_CHOICE
if [[ "$HIBERNATE_CHOICE" =~ ^[Yy]$ ]]; then
    TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    # Convert KB to GB for display, round up
    RECOMMENDED_SWAP_GB=$(( (TOTAL_RAM_KB + 1024*1024 - 1) / (1024*1024) )) # Round up to nearest GB
    echo -e "\n--- IMPORTANT: Hibernation requires swap space at least equal to your RAM. ---"
    echo "Detected RAM: $((TOTAL_RAM_KB / 1024)) MB (~$((TOTAL_RAM_KB / (1024*1024))) GB)"
    echo "Recommended minimum swap size for hibernation: ${RECOMMENDED_SWAP_GB}G"
    echo "Please ensure your Swap Partition is at least this size during partitioning."
    echo -e "-------------------------------------------------------------------\n"
fi

echo -e "\n--- Partitioning the disk ($DISK) using cfdisk ---"
echo "You will create the following partitions:"
if [ "$SYSTEM_TYPE" == "UEFI" ]; then
    echo "  1. EFI System Partition (e.g., 512M, type 'EFI System')"
else # BIOS
    echo "  1. BIOS Boot Partition (e.g., 1M, type 'BIOS Boot' - essential for GRUB on BIOS)"
fi
echo "  2. Swap Partition (e.g., 2G-4G, type 'Linux swap' - or ${RECOMMENDED_SWAP_GB}G for hibernation if chosen)"
echo "  3. Root Partition (e.g., 20G+, type 'Linux filesystem')"
echo "  4. (Optional) Home Partition (rest of disk, type 'Linux filesystem')"
echo "After partitioning, remember the full paths for each (e.g., ${DISK}1, ${DISK}2, etc.)."
echo
read -p "Press Enter to launch cfdisk. Create your partitions and write changes. Then exit cfdisk."
cfdisk "$DISK" || { echo "Error: cfdisk failed. Exiting."; exit 1; }

echo -e "\n--- Formatting partitions ---"
EFI_PART=""
if [ "$SYSTEM_TYPE" == "UEFI" ]; then
    while true; do
        read -p "Enter the EFI partition (e.g., ${DISK}1): " EFI_PART
        if [[ -b "$EFI_PART" ]]; then
            mkfs.fat -F32 "$EFI_PART" || { echo "Error: Failed to format EFI partition."; exit 1; }
            echo "EFI partition formatted: $EFI_PART"
            break
        else
            echo "Error: '$EFI_PART' is not a valid block device. Please try again."
        fi
    done
fi

SWAP_PART=""
while true; do
    read -p "Enter the Swap partition (e.g., ${DISK}2): " SWAP_PART
    if [[ -b "$SWAP_PART" ]]; then
        mkswap "$SWAP_PART" || { echo "Error: Failed to create swap space."; exit 1; }
        swapon "$SWAP_PART" || { echo "Error: Failed to enable swap."; exit 1; }
        echo "Swap partition configured: $SWAP_PART"
        break
    else
        echo "Error: '$SWAP_PART' is not a valid block device. Please try again."
    fi
done

ROOT_PART=""
while true; do
    read -p "Enter the Root partition (e.g., ${DISK}3): " ROOT_PART
    if [[ -b "$ROOT_PART" ]]; then
        mkfs.ext4 "$ROOT_PART" || { echo "Error: Failed to format root partition."; exit 1; }
        echo "Root partition formatted: $ROOT_PART"
        break
    else
        echo "Error: '$ROOT_PART' is not a valid block device. Please try again."
    fi
done

HOME_PART=""
read -p "Enter the (optional) Home partition (e.g., ${DISK}4, leave empty if no home partition): " HOME_PART_INPUT
if [ -n "$HOME_PART_INPUT" ]; then
    if [[ -b "$HOME_PART_INPUT" ]]; then
        HOME_PART="$HOME_PART_INPUT"
        mkfs.ext4 "$HOME_PART" || { echo "Error: Failed to format home partition."; exit 1; }
        echo "Home partition formatted: $HOME_PART"
    else
        echo "Warning: '$HOME_PART_INPUT' is not a valid block device. Skipping home partition."
        HOME_PART=""
    fi
fi

echo -e "\n--- Mounting partitions ---"
mount "$ROOT_PART" /mnt || { echo "Error: Failed to mount root partition."; exit 1; }

if [ -n "$HOME_PART" ]; then
    mkdir -p /mnt/home
    mount "$HOME_PART" /mnt/home || { echo "Error: Failed to mount home partition."; exit 1; }
fi

if [ "$SYSTEM_TYPE" == "UEFI" ]; then
    mkdir -p /mnt/boot/efi
    mount "$EFI_PART" /mnt/boot/efi || { echo "Error: Failed to mount EFI partition."; exit 1; }
fi

# --- 2. Installation ---

echo -e "\n--- Choosing bootloader ---"
BOOTLOADER_CHOICE=""
if [ "$SYSTEM_TYPE" == "UEFI" ]; then
    echo "Select your preferred bootloader:"
    echo "  1) GRUB (Recommended for general use, highly compatible)"
    echo "  2) systemd-boot (Simpler, UEFI-only, integrates with systemd)"
    echo "  3) rEFInd (Graphical, auto-detects boot entries, user-friendly)"
    while true; do
        read -p "Enter choice (1, 2, or 3): " BOOTLOADER_CHOICE
        case "$BOOTLOADER_CHOICE" in
            1|2|3) break ;;
            *) echo "Invalid choice. Please enter 1, 2, or 3." ;;
        esac
    done
else # BIOS
    echo "For BIOS systems, GRUB is the recommended bootloader."
    BOOTLOADER_CHOICE=1 # Force GRUB for BIOS
fi

BOOTLOADER_PACKAGES=""
BOOTLOADER_NAME=""
case "$BOOTLOADER_CHOICE" in
    1)
        if [ "$SYSTEM_TYPE" == "UEFI" ]; then
            BOOTLOADER_PACKAGES="grub efibootmgr"
        else # BIOS
            BOOTLOADER_PACKAGES="grub"
        fi
        BOOTLOADER_NAME="GRUB"
        ;;
    2)
        BOOTLOADER_PACKAGES="" # systemd is part of base, bootctl comes with systemd
        BOOTLOADER_NAME="systemd-boot"
        ;;
    3)
        BOOTLOADER_PACKAGES="refind"
        BOOTLOADER_NAME="rEFInd"
        ;;
esac

echo -e "\n--- Choosing graphics driver ---"
echo "Select your graphics card type:"
echo "  1) Intel"
echo "  2) AMD"
echo "  3) NVIDIA (proprietary)"
echo "  4) Virtual Machine / Generic (for basic VESA or VM drivers like virtio-gpu, vmware-guest)"
GRAPHICS_CHOICE=""
while true; do
    read -p "Enter choice (1, 2, 3, or 4): " GRAPHICS_CHOICE
    case "$GRAPHICS_CHOICE" in
        1|2|3|4) break ;;
        *) echo "Invalid choice. Please enter 1, 2, 3, or 4." ;;
    esac
done

GRAPHICS_PACKAGES=""
case "$GRAPHICS_CHOICE" in
    1) GRAPHICS_PACKAGES="xf86-video-intel vulkan-intel mesa" ;;
    2) GRAPHICS_PACKAGES="xf86-video-amdgpu vulkan-radeon mesa" ;;
    3) GRAPHICS_PACKAGES="nvidia nvidia-utils nvidia-settings" # Consider nvidia-dkms for custom kernels
       echo "Note: For custom kernels or DKMS, you might need 'nvidia-dkms' instead of 'nvidia'." ;;
    4) GRAPHICS_PACKAGES="xf86-video-vesa open-vm-tools virtio-gpu" ;; # Basic VESA and common VM drivers
esac

echo -e "\n--- Installing essential packages, $BOOTLOADER_NAME, and graphics drivers ---"
# base: essential system files
# linux: the Linux kernel
# linux-firmware: firmware for various hardware
# networkmanager: network management service
# sudo: for user privilege escalation
# vim: a text editor
# git: version control
# dialog: for potential future interactive prompts
# xorg-server, xorg-xinit: basic Xorg for graphical environments
INSTALL_PACKAGES="base linux linux-firmware networkmanager sudo vim git dialog xorg-server xorg-xinit $BOOTLOADER_PACKAGES $GRAPHICS_PACKAGES"
echo "Packages to install: $INSTALL_PACKAGES"
pacstrap /mnt $INSTALL_PACKAGES || { echo "Error: pacstrap failed. Check your internet connection and mirrorlist."; exit 1; }

echo -e "\n--- Generating fstab ---"
genfstab -U /mnt >> /mnt/etc/fstab || { echo "Error: Failed to generate fstab."; exit 1; }

echo -e "\n--- Entering chroot environment for post-installation setup ---"
# Export variables needed inside the chroot environment
export SYSTEM_TYPE BOOTLOADER_CHOICE DISK ROOT_PART EFI_PART

arch-chroot /mnt /bin/bash <<EOF
set -e # Exit immediately if a command exits with a non-zero status inside chroot

echo -e "\n--- Setting timezone ---"
echo "Listing common timezones for reference (e.g., Europe/Oslo, America/New_York, Asia/Tokyo):"
# You can uncomment the line below to list all timezones, but it's very long.
# timedatectl list-timezones | less
read -p "Enter your desired timezone (e.g., Europe/Oslo): " TIMEZONE_INPUT
ln -sf "/usr/share/zoneinfo/$TIMEZONE_INPUT" /etc/localtime || echo "Warning: Timezone '$TIMEZONE_INPUT' might be invalid or not found. Please verify manually."
hwclock --systohc || echo "Warning: Failed to set hardware clock."

echo -e "\n--- Setting locale ---"
echo "Common locales: en_US.UTF-8, de_DE.UTF-8, fr_FR.UTF-8"
read -p "Enter your primary locale (e.g., en_US.UTF-8): " PRIMARY_LOCALE
echo "$PRIMARY_LOCALE UTF-8" >> /etc/locale.gen
read -p "Do you want to add more locales? (y/N): " ADD_MORE_LOCALES
if [[ "$ADD_MORE_LOCALES" =~ ^[Yy]$ ]]; then
    echo "Enter additional locales, one per line (e.g., es_ES.UTF-8). Press Ctrl+D when finished."
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            echo "$line UTF-8" >> /etc/locale.gen
        fi
    done
fi
locale-gen || { echo "Error: Failed to generate locales."; exit 1; }
echo "LANG=$PRIMARY_LOCALE" > /etc/locale.conf

echo -e "\n--- Setting hostname ---"
read -p "Enter hostname for your system: " HOSTNAME
echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

echo -e "\n--- Setting root password ---"
echo "Set password for root user:"
passwd || { echo "Error: Failed to set root password."; exit 1; }

echo -e "\n--- Creating a new user ---"
read -p "Enter new username: " USERNAME
useradd -m -g users -G wheel "$USERNAME" || { echo "Error: Failed to create new user."; exit 1; }
echo "Set password for $USERNAME:"
passwd "$USERNAME" || { echo "Error: Failed to set user password."; exit 1; }

echo -e "\n--- Granting sudo privileges to wheel group ---"
# Uncomment the wheel group line in /etc/sudoers to allow sudo access
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers || { echo "Error: Failed to configure sudoers."; exit 1; }

echo -e "\n--- Installing and configuring $BOOTLOADER_NAME ---"
if [ "$SYSTEM_TYPE" == "UEFI" ]; then
    case "$BOOTLOADER_CHOICE" in
        1)
            # GRUB UEFI installation
            grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux --recheck --removable || { echo "Error: GRUB UEFI installation failed."; exit 1; }
            grub-mkconfig -o /boot/grub/grub.cfg || { echo "Error: GRUB configuration failed."; exit 1; }
            ;;
        2)
            # systemd-boot installation
            bootctl install || { echo "Error: systemd-boot installation failed."; exit 1; }
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
            # ROOT_PART is passed from the outer script and expanded here
            ROOT_PART_UUID=$(blkid -s PARTUUID -o value "$ROOT_PART") || { echo "Error: Failed to get ROOT_PART_UUID for systemd-boot."; exit 1; }
            echo "options root=PARTUUID=$ROOT_PART_UUID rw" >> /boot/efi/loader/entries/arch.conf
            ;;
        3)
            # rEFInd installation
            refind-install || { echo "Error: rEFInd installation failed."; exit 1; }
            ;;
    esac
else # BIOS
    # GRUB BIOS installation
    grub-install --target=i386-pc "$DISK" || { echo "Error: GRUB BIOS installation failed."; exit 1; }
    grub-mkconfig -o /boot/grub/grub.cfg || { echo "Error: GRUB configuration failed."; exit 1; }
fi

echo -e "\n--- Enabling NetworkManager service ---"
systemctl enable NetworkManager || { echo "Error: Failed to enable NetworkManager."; exit 1; }

echo -e "\n--- Optional: Install Desktop Environment ---"
echo "Select a Desktop Environment to install (or skip):"
echo "  1) GNOME (Full-featured, modern)"
echo "  2) KDE Plasma (Customizable, feature-rich)"
echo "  3) XFCE (Lightweight, stable)"
echo "  4) None (minimal CLI system)"
DE_CHOICE=""
while true; do
    read -p "Enter choice (1, 2, 3, or 4): " DE_CHOICE
    case "$DE_CHOICE" in
        1|2|3|4) break ;;
        *) echo "Invalid choice. Please enter 1, 2, 3, or 4." ;;
    esac
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
    pacman -S --noconfirm "$DE_PACKAGES" || { echo "Error: Failed to install Desktop Environment."; exit 1; }

    if [ -n "$DISPLAY_MANAGER_SERVICE" ]; then
        echo "--- Enabling Display Manager: $DISPLAY_MANAGER_SERVICE ---"
        systemctl enable "$DISPLAY_MANAGER_SERVICE" || { echo "Error: Failed to enable Display Manager."; exit 1; }
    fi
fi

echo -e "\n--- Post-installation steps complete! ---"

EOF

echo -e "\n--- Exiting chroot ---"
echo "--- Syncing filesystem ---"
sync

echo "--- Unmounting all partitions ---"
umount -R /mnt || { echo "Error: Failed to unmount /mnt. You may need to unmount manually."; exit 1; }

echo -e "\n--- Installation complete! ---"
echo "You can now reboot your system."
echo "IMPORTANT: Remove the installation media (USB drive/CD) before rebooting."
read -p "Press Enter to reboot..."
reboot
