#!/usr/bin/bash

echo "Starting DVT Setup..."

echo "Add Repos for Programs"
sudo dnf copr enable yalter/niri
sudo dnf copr enable wezfurlong/wezterm-nightly
sudo dnf copr enable jdxcode/mise
sudo dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo

echo "Installing DNF Programs"
sudo dnf install -y niri wezterm fish mise zoxide atuin lsb_release fortune vim eza bat gcc clang \
    fd rhythmbox thunar btop quickshell mako rustup fastfetch asciiquarium cmatrix snapper zathura \
    zathura-pdf-mupdf docker-ce docker-ce-cli containerd.io docker-buildx-plugin \
    docker-compose-plugin swayidle chromium wl-clipboard clipman fuzzel gtk3 webkit2gtk4.1 libusb \
    mpv steam python3-pip cowsay syncthing nix nix-daemon nmtui

echo "Install Flatpak Programs"
flatpak install flathub \
    com.github.tchx84.Flatseal org.keepassxc.KeePassXC org.ferdium.Ferdium it.mijorus.gearlever \
    org.localsend.localsend_app io.github.Qalculate org.onlyoffice.desktopeditors

echo "Install Homebrew and Brews"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install jesseduffield/lazydocker/lazydocker typst babelfish

echo "Configuring Programs"
chsh --shell $(which fish) # I use fish btw ;)
mise install # Install all global mise tools as specified in .config/mise
rustup-init # Install rustup and rust toolchains
sudo systemctl enable --now docker # Enable the docker engine
sudo usermod -a -G docker dvt # You will need to atleast log-out and log back in to see the change

# Enable and setup Nix and home-manager
# See
# https://src.fedoraproject.org/rpms/nix
# https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone
sudo systemctl enable --now nix-daemon
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
export PATH="$HOME/.nix-profile/bin:$PATH" # Add Nix binaries to path
home-manager switch
sudo dnf remove git # BUG: This breaks things

# These systemd service files are part of the dotfiles, and reside in ~/.config/systemd/user
sudo systemctl daemon-reload
systemctl --user add-wants niri.service mako.service # Notification service
systemctl --user add-wants niri.service swayidle.service # Idle service

# I need this for my terminal screensaver :)
pip install terminaltexteffects

# Enable snapper for Btrfs, it automatically creates a snapshot every week, and maintains a max of 3 snapshots at a time
# Follows https://github.com/diego-velez/.files/blob/main/.other_dotfiles_stuff/README.md#btrfs-snapshot-system
sudo snapper -c dvt create-config /
systemctl --user enable --now snapper-weekly@dvt.timer
cat << 'EOF' | sudo tee /etc/snapper/configs/dvt > /dev/null
# subvolume to snapshot
SUBVOLUME="/"

# filesystem type
FSTYPE="btrfs"

# fraction or absolute size of the filesystems space the snapshots may use
SPACE_LIMIT="0.2"

# fraction or absolute size of the filesystems space that should be free
FREE_LIMIT="0.2"


# users and groups allowed to work with config
ALLOW_USERS="dvt"
ALLOW_GROUPS=""

# sync users and groups from ALLOW_USERS and ALLOW_GROUPS to .snapshots
# directory
SYNC_ACL="yes"


# start comparing pre- and post-snapshot in background after creating
# post-snapshot
BACKGROUND_COMPARISON="yes"


# run daily number cleanup
NUMBER_CLEANUP="yes"

# limit for number cleanup
NUMBER_MIN_AGE="0"
NUMBER_LIMIT="3"
NUMBER_LIMIT_IMPORTANT="1"


# create hourly snapshots
TIMELINE_CREATE="no"

# cleanup hourly snapshots after some time
TIMELINE_CLEANUP="no"

# cleanup empty pre-post-pairs
EMPTY_PRE_POST_CLEANUP="yes"

QGROUP="1/0"
EOF

echo "Install Neovim"
cargo install --git https://github.com/MordechaiHadad/bob.git # I use bob to manage Neovim installations
bob use latest

echo "Install Zen Browser"
mkdir -p ~/.local/bin
wget https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz
tar -xf zen.linux-x86_64.tar.xz -C ~/.local/bin
rm zen.linux-x86_64.tar.xz

echo "Setup ZSA keymapp"
# Follow instructions from https://github.com/zsa/wally/wiki/Linux-install
sudo touch /etc/udev/rules.d/50-zsa.rules
cat << 'EOF' | sudo tee /etc/udev/rules.d/50-zsa.rules > /dev/null
# Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
# Keymapp Flashing rules for the Voyager
SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
EOF
sudo groupadd plugdev
sudo usermod -aG plugdev $USER

# Install the actual binary
mkdir -p ~/.local/bin/keymapp
wget https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-latest.tar.gz
tar -xf keymapp-latest.tar.gz -C ~/.local/bin/keymapp
chmod +x ~/.local/bin/keymapp/keymapp
rm keymapp-latest.tar.gz

echo "Install awww"
git clone --depth 1 https://codeberg.org/LGFae/awww.git ~/awww
cd ~/awww
sudo dnf install -y lz4-devel wayland-protocols-devel rust-wayland-client-devel
cargo build --release
mv ./target/release/awww ~/.local/bin/awww
mv ./target/release/awww-daemon ~/.local/bin/awww-daemon
cd ..
rm -rf awww

echo "Laptop Specific Configuration"
read -p "Running on laptop? [y/n]: " isLaptop

if [[ "$isLaptop" != "n" ]]; then
    echo "Applying Laptop Configurations"

    touch ~/.config/home-manager/host.nix
    echo '"laptop"' > ~/.config/home-manager/host.nix

    # Enable and start Kanata
    sudo groupdel uinput 2>/dev/null
    sudo groupadd --system uinput
    sudo usermod -aG input $USER
    sudo usermod -aG uinput $USER
    sudo modprobe uinput
    sudo tee /etc/udev/rules.d/99-input.rules > /dev/null <<EOF
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    EOF
    sudo udevadm control --reload-rules && sudo udevadm trigger
else
    touch ~/.config/home-manager/host.nix
    echo '"desktop"' > ~/.config/home-manager/host.nix
fi

echo "Configuration complete"

echo "Rebooting in 10 seconds"
sleep 10s
reboot
