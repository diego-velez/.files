# Activate mise first so that I have access to environment variables immediately
mise activate fish | source

set os (lsb_release --id --short)
set is_glinux false
if string match -q 'Debian' $os
    set is_glinux true
end

# Disable welcome message
set fish_greeting

# Use the vi key binds
set -g fish_key_bindings fish_vi_key_bindings
set fish_vi_force_cursor 1
set fish_cursor_default block
set fish_cursor_insert line

# Environment variables
set -gx EDITOR nvim
set -gx FZF_DEFAULT_OPTS "--layout=reverse"
set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/ripgrep.conf"
set -gx TERMINAL wezterm

# Prefered optons for common programs
alias df 'df --total -h -T'
alias free 'free -h'
alias nano 'nano -E -S -i -l -q'
alias more less
alias open xdg-open

if test $is_glinux = true
    alias fd 'fdfind --hidden --no-ignore'
else
    alias fd 'fd --hidden --no-ignore'
end

# Change ls for exa
alias ls 'eza --color=always --group-directories-first -a --icons'
alias ll 'eza --color=always --group-directories-first -a -l -h -G --icons'
alias lt 'eza --color=always --group-directories-first -a -T --icons'

# Change cat for bat
if test $is_glinux = true
    alias cat 'batcat --theme Dracula'
else
    alias cat 'bat --theme Dracula'
end

# Colorized grep
alias grep 'grep --colour=always'
alias egrep 'egrep --colour=always'
alias fgrep 'fgrep --colour=always'

# Confirm before overwriting something
alias cp "cp -i"
alias mv "mv -i"
alias rm "rm -I"

if test $is_glinux = true
    # apt
    abbr update "sudo apt update"
    abbr search "apt search"
    abbr install "sudo apt install"
    abbr remove "sudo apt remove"
else
    # dnf
    abbr update "sudo dnf update"
    abbr search "dnf search"
    abbr install "sudo dnf install"
    abbr remove "sudo dnf remove"
end

# Used for config-files repo
abbr config 'git --git-dir=$HOME/.files/ --work-tree=$HOME'

# University
abbr rumad "ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=ssh-rsa estudiante@rumad.uprm.edu"

# PATH
if test $is_glinux = true
    set -U fish_user_paths $HOME/.local/bin

    if test -f $HOME/google-cloud-sdk/path.fish.inc
        source ~/google-cloud-sdk/path.fish.inc
    end
else
    set -U fish_user_paths $(go env GOPATH)/bin $HOME/.local/bin $HOME/.cargo/bin
end

if test $is_glinux = false
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
end

if test $is_glinux = false && status is-interactive
    # Display a lil something when starting the shell
    set random_num (math (random) % 2)
    switch $random_num
        case 0
            # https://gitlab.com/dwt1/shell-color-scripts
            colorscript random
        case 1
            fortune ascii-art
        case 2
            fortune wisdom | cowsay
    end
end

# Config sdkman for fish
# See https://github.com/sdkman/sdkman-cli/issues/671#issuecomment-1130004319
function sdk
    bash -c "source '$HOME/.sdkman/bin/sdkman-init.sh'; sdk $argv[1..]"
end

if test $is_glinux = true
    fish_add_path (find $HOME/.sdkman/candidates/*/current/bin -maxdepth 0)
    abbr mdi "mvn -N wrapper:wrapper && ./mvnw clean install -X -U"
    abbr skaf "skaffold run --profile dev --kube-context=gke_diveto-louhi-test_us-central1_louhi --skip-tests --default-repo=\"us-central1-docker.pkg.dev/diveto-louhi-test/microservices\""

    # Set up fish completion
    # See go/fish-shell
    source_google_fish_package acid
    source_google_fish_package autogcert
    source_google_fish_package banshee
    source_google_fish_package benchy
    source_google_fish_package buildfix
    source_google_fish_package citc_prompt
    source_google_fish_package cogd
    source_google_fish_package crow
    source_google_fish_package fst
    source_google_fish_package graphviz
    source_google_fish_package hb
    source_google_fish_package hi
    source_google_fish_package pastebin
    source_google_fish_package perfgate
    source_google_fish_package spool
    source_google_fish_package sut
end

bind -M insert \ce 'nvim'
bind -M insert \co '$HOME/.config/fish/open_project'

zoxide init fish | source
starship init fish | source
atuin init fish | source
