# Configuration files

The repo for my configuration files, all managed using this [guide](https://www.atlassian.com/git/tutorials/dotfiles)

![Super Ultrawide Hyprland](.config/desktop_1.jpg)
![Super Ultrawide Hyprland](.config/desktop_2.jpg)

## Shortcuts

- [Installing](#installing)
- [Icons and Mouse Cursors](#icons-and-mouse-cursors)
- [Themes](#themes)
- [BtrFS Snapshot System](.other_dotfiles_stuff/README.md#btrfs-snapshot-system)

## Installing

### On Fedora Hyprland

```bash
sudo dnf install -y python git
git clone --bare https://github.com/diego-velez/.files.git $HOME/.files
alias config='git --git-dir=$HOME/.files/ --work-tree=$HOME'
config checkout -f
```

### On Fedora Cinnamon

This setup script was written to work on Fedora Cinnamon, simply copy paste the lines below on a terminal

```bash
sudo dnf install -y python git
git clone --bare https://github.com/diego-velez/.files.git $HOME/.files
alias config='git --git-dir=$HOME/.files/ --work-tree=$HOME'
config checkout -f
config config --local status.showUntrackedFiles no
python .config/setup-scripts/main.py
```

## Icons and Mouse Cursors

User-wide directory: `~/.icons`

System-wide icons directory: `/usr/share/icons`

## Themes

User-wide directory: `~/.themes`

System-wide themes directory: `/usr/share/themes`
