#!/bin/bash

### Install programs ###

echo "Installing programs"

sudo apt install -y git vim fzf fish rofi ripgrep fd-find eza bat i3 i3blocks zoxide starship ninja-build gettext cmake curl build-essential

### Follow go/i3#setting-up-chrome-remote-desktop ###

echo "Setting up i3"

cat > ~/.xsessionrc << EOF
#!/bin/sh

# Necessary to make chrome pick up the proxy settings stored in gconf.
export DESKTOP_SESSION=cinnamon  # gnome for trusty.

# NOTE: This may break your compose key.
# See http://g/i3-users/YBexXGbik7E for more details.
export GTK_IM_MODULE=xim

# Desktop background color.
xsetroot -solid "#333333"
EOF


cat > ~/.xsession << EOF
#!/bin/sh

# Necessary to make chrome pick up the proxy settings stored in gconf.
export DESKTOP_SESSION=cinnamon  # gnome for trusty.

# NOTE: This may break your compose key.
# See http://g/i3-users/YBexXGbik7E for more details.
export GTK_IM_MODULE=xim

# Desktop background color.
xsetroot -solid "#333333"

# Comment out the following if this is .xsessionrc file,
# as opposed to .xsession. See https://wiki.debian.org/Xsession for details.
exec i3
EOF

cat > ~/.chrome-remote-desktop-session << EOF
# To load ~/.Xresources while chromoting
exec /etc/X11/Xsession /usr/bin/i3
EOF

sudo usermod -a -G chrome-remote-desktop $USER

### Download and set up .files ###

echo "Setting up .files"

DOTFILES="$HOME/Downloads/DVT_.files"

git clone https://github.com/diego-velez/.files.git $DOTFILES

rm -rf ~/.config
rm -rf ~/.fonts

cp -r $DOTFILES/.fonts ~/.fonts
cp $DOTFILES/.vimrc ~/.vimrc
cp $DOTFILES/.ideavimrc ~/.ideavimrc
cp -r $DOTFILES/.config ~/.config

fc-cache -f

### Installing Neovim ###

echo "Installing Neovim"

git clone https://github.com/neovim/neovim.git ~/neovim

make CMAKE_BUILD_TYPE=RelWithDebInfo -C ~/neovim
sudo make -C ~/neovim install

### Install Wezterm ###

echo "Installing Wezterm"

curl -LO https://github.com/wezterm/wezterm/releases/download/20240203-110809-5046fc22/wezterm-20240203-110809-5046fc22.Ubuntu22.04.deb

sudo apt install -y ./wezterm-20240203-110809-5046fc22.Ubuntu22.04.deb

### Reboot gLinux ###

echo "DONE"

sudo systemctl restart chrome-remote-desktop@diveto
