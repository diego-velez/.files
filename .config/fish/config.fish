if status is-interactive
    # Commands to run in interactive sessions can go here
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
set fish_cursor_default block
set fish_cursor_insert line

# Environment variables
set -x EDITOR nvim

# Prefered optons for common programs
alias df 'df --total -h -T'
alias free 'free -h'
alias nano 'nano -E -S -i -l -q'
alias more less
alias open xdg-open
alias fd 'fd --hidden --no-ignore'

# Change ls for exa
alias ls 'eza --color=always --group-directories-first -a --icons'
alias ll 'eza --color=always --group-directories-first -a -l -h -G --icons'
alias lt 'eza --color=always --group-directories-first -a -T --icons'

# Change cat for bat and other implementations
alias cat 'bat --theme Dracula'
# usage: help <command>
# help() {
#     "$@" 2>&1 | cat --paging=never --language=help
# }

# Colorized grep
alias grep 'grep --colour=always'
alias egrep 'egrep --colour=always'
alias fgrep 'fgrep --colour=always'

# Confirm before overwriting something
alias cp "cp -i"
alias mv "mv -i"
alias rm "rm -I"

# dnf
alias update "sudo dnf update"
alias search "dnf search"
alias install "sudo dnf install"
alias remove "sudo dnf remove"

# Used for config-files repo
alias config 'git --git-dir=$HOME/.files/ --work-tree=$HOME'

# University
alias rumad "ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=ssh-rsa estudiante@rumad.uprm.edu"

# PATH
set -U fish_user_paths $(go env GOPATH)/bin $HOME/.local/bin

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# https://gitlab.com/dwt1/shell-color-scripts
colorscript random

starship init fish | source
