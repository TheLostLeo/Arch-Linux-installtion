# Linux Manual - Arch Linux Installation Guide

This repository contains resources and instructions for installing and configuring Arch Linux, with both manual and automatic installation options.

## Table of Contents

- [Common Preparation](#common-preparation)
  - [1. Getting Started](#1-getting-started)
  - [2. Disk Partitioning](#2-disk-partitioning)
  - [3. Format and Mount Partitions](#3-format-and-mount-partitions)
- [Installation Options](#installation-options)
  - [Manual Installation](#manual-installation)
  - [Automatic Installation](#automatic-installation)
- [Windows Detection in GRUB](#windows-detection-in-grub)

## Common Preparation

### 1. Getting Started

#### 1.1. Download ISO

Download the latest Arch Linux ISO from the [official website](https://archlinux.org/download/).

#### 1.2. Create Bootable USB

Create a bootable USB drive using tools like `dd`, Rufus, Ventoy, or Etcher

#### 1.3. Boot from USB

- Restart your computer and boot from the USB
- When the boot menu appears, select "Arch Linux install medium" and press Enter

#### 1.4. Verify Internet Connection

Once booted into the live environment:

```bash
# Verify network connection
ping -c 3 archlinux.org

# If using WiFi, connect using iwctl
iwctl
[iwd]# device list
[iwd]# station wlan0 scan
[iwd]# station wlan0 get-networks
[iwd]# station wlan0 connect SSID
[iwd]# exit
```

### 2. Disk Partitioning

#### 2.1. Identify Your Disk

```bash
lsblk
```

#### 2.2. Partition the Disk

```bash
# Start fdisk for your disk (replace sdX)
fdisk /dev/sdX
```

Create the following partitions:
- EFI System Partition (ESP): 200-500MB (type: EFI System) [do not need to create if window is there and want to use the same EFI partition]
- Swap partition: any size (type: Linux swap)
- Root partition: Remainder (type: Linux filesystem)

### 3. Format and Mount Partitions

```bash
# Format EFI partition (skip if window is there)
mkfs.fat -F32 /dev/sdX1

# Create and activate swap
mkswap /dev/sdX2
swapon /dev/sdX2

# Format root partition
mkfs.ext4 /dev/sdX3

# Mount partitions
mount /dev/sdX3 /mnt
mkdir -p /mnt/boot/efi
mount /dev/sdX1 /mnt/boot/efi
```

## Installation Options

After completing the common preparation steps above, you can choose either the manual or automatic installation method.

### Manual Installation

#### 1. Install Essential Packages

```bash
pacstrap /mnt base linux linux-firmware base-devel
```

#### 2. Install Additional Useful Packages

```bash
pacstrap /mnt vim nano git os-prober
```

#### 3. Generate fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

#### 4. Chroot into the New System

```bash
arch-chroot /mnt
```

#### 5. Clone and Run the Installation Script

```bash
# Install git if not already installed
pacman -S git

# Clone this repository
git clone https://github.com/TheLostLeo/Linux-Manual.git

# Navigate to the repository
cd Linux-Manual

# Make the script executable
chmod +x install.sh

# Run the installation script
./install.sh
```

#### 6. Install and Configure GRUB

```bash
# Install GRUB
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# Generate GRUB configuration
grub-mkconfig -o /boot/grub/grub.cfg
```

### Automatic Installation

The Arch Linux ISO includes a guided installation tool called `archinstall` that automates many installation steps.

#### 1. Start the Archinstall Tool

```bash
pacman -S archinstall archlinux-keyring
archinstall
```

#### 2. Follow the Interactive Prompts

The tool will guide you through:
- Selecting keyboard layout
- Selecting mirror region
- Disk partitioning and formatting
- Selecting desktop environment (if desired)
- Setting username and password
- Additional packages to install

#### 3. Apply Configuration and Install

- Review your selections
- Confirm to begin installation
- Wait for installation to complete
- Reboot when prompted

## Windows Detection in GRUB

If you have Windows installed and want to dual boot with Arch Linux, follow these steps to ensure Windows appears in your GRUB menu:

### Install Required Packages

```bash
sudo pacman -S os-prober 
```

### Enable OS Prober in GRUB

1. Edit the GRUB configuration:
   ```bash
   sudo nano /etc/default/grub
   ```

2. Add or uncomment this line:
   ```
   GRUB_DISABLE_OS_PROBER=false
   ```

3. Save and exit the editor

### Mount Windows Partition (if necessary)

only If Windows EFI is installed on a separate drive or partition:

```bash
# Create a mount point
sudo mkdir -p /mnt/windows

# List all partitions to find Windows
lsblk -f

# Mount the Windows partition (replace sdXY with your Windows partition)
sudo mount /dev/sdXY /mnt/windows
```

### Update GRUB Configuration

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

You should see output like:
```
Found Windows Boot Manager on /dev/sdXY
```
