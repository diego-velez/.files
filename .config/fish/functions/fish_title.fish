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

