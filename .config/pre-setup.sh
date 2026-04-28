#!/usr/bin/bash

# See https://github.com/devangshekhawat/Fedora-44-Post-Install-Guide

FLAG_PART1_FILE="$HOME/.fedora_post_install_part_1_done"
FLAG_PART2_FILE="$HOME/.fedora_post_install_part_2_done"

echo "Running Fedora 44 Post Install Guide"

if [[ ! -f "$FLAG_PART1_FILE" ]]; then
    echo "RPM Fusion & Terra"
    sudo dnf install \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
    sudo dnf group upgrade core
    sudo dnf4 group install core

    echo "Update System"
    sudo dnf -y update

    touch "$FLAG_PART1_FILE"

    echo "Rebooting in 10 seconds..."
    sleep 10s
    reboot
    exit
fi

echo "Part 1 of Post Install Complete"

echo "Firmware"
sudo fwupdmgr refresh --force
sudo fwupdmgr get-devices # Lists devices with available updates.
sudo fwupdmgr get-updates # Fetches list of available updates.
sudo fwupdmgr update

echo "Flatpak"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "AppImage"
sudo dnf in fuse-libs

if [[ ! -f "$FLAG_PART2_FILE" ]]; then
    echo "Nvidia Drivers"
    read -p "Do you need the Nvidia drivers? [y/n]: " useNvidia
    if [[ "$useNvidia" != "n" ]]; then
        sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda

        touch "$FLAG_PART2_FILE"

        echo "Waiting 10 minutes for kernel module to be built..."
        time 10m

        echo "Rebooting..."
        sleep 3s
        reboot
    fi
fi

echo "Part 2 of Post Install Complete"

echo "Media Codecs"
sudo dnf4 group install multimedia
sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing # Switch to full FFMPEG.
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin # Installs gstreamer components. Required if you use Gnome Videos and other dependent applications.
sudo dnf group install -y sound-and-video # Installs useful Sound and Video complementary packages.

echo "H/W Video Acceleration"
sudo dnf install ffmpeg-libs libva libva-utils

read -p "Are you on an Intel CPU? [y/n]: " intelCPU
if [[ "$intelCPU" != "n" ]]; then
    echo "Installing Intel Specific Packages"
    sudo dnf swap libva-intel-media-driver intel-media-driver --allowerasing
    sudo dnf install libva-intel-driver
fi

read -p "Are you on an AMD CPU? [y/n]: " amdCPU
if [[ "$amdCPU" != "n" ]]; then
    echo "Installing AMD Specific Packages"
    sudo dnf install mesa-va-drivers-freeworld
    sudo dnf install mesa-va-drivers-freeworld.i686
fi

echo "OpenH264 for Firefox"
sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
echo "### Remember to enable the OpenH264 Plugin in Firefox's settings! ###"

echo "Disabling bitch ass wait online service"
sudo systemctl disable NetworkManager-wait-online.service

echo "Deleting all autostart programs"
sudo rm /etc/xdg/autostart/*

echo "Launching DVT setup in 10 seconds"
sleep 10s
./setup.sh
