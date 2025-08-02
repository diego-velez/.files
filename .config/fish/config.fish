set os (lsb_release --id --short)
set is_glinux false
if string match -q 'Debian' $os
    set is_glinux true
end

# Change title based on the last command ran
#
# If this function runs after a command, it still shows the previous command ran, instead of nothing.
function fish_title
    # Either use the current command ran, or the previous command
    set -l command $argv
    if test -z $argv; and not test -z $previous_command
        set command $previous_command
    else
        set -g previous_command $argv
    end

    # If command has . for current directory, expand directory for title
    if string match -q "*." $command
        set command (string replace "." "$PWD" $command)
    end

    # Show the last command ran if there is any
    if test -z $command
        echo "$USER@$HOSTNAME:$PWD";
    else
        echo "$USER@$HOSTNAME:$PWD - $command";
    end
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
    alias update "sudo apt update"
    alias search "apt search"
    alias install "sudo apt install"
    alias remove "sudo apt remove"
else
    # dnf
    alias update "sudo dnf update"
    alias search "dnf search"
    alias install "sudo dnf install"
    alias remove "sudo dnf remove"
end

# Used for config-files repo
alias config 'git --git-dir=$HOME/.files/ --work-tree=$HOME'

# University
alias rumad "ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=ssh-rsa estudiante@rumad.uprm.edu"

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

if test $is_glinux = false
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
end

alias mdi "mvn -N wrapper:wrapper && ./mvnw clean install -X -U"
alias skaf "skaffold run --profile dev --kube-context=gke_diveto-louhi-test_us-central1_louhi --skip-tests --default-repo=\"us-central1-docker.pkg.dev/diveto-louhi-test/microservices\""

zoxide init fish | source
starship init fish | source
