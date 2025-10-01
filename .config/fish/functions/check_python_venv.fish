# Automatically activate or deactivate a Python Virtual Environment
# Expects the venv folder name to be `.venv`

set is_active false

function check_python_venv --on-event fish_prompt
    # Check if this directory does not contain a `.venv` folder
    # Deactivate venv if necessary
    if not test -d .venv
        if test $is_active = true
            deactivate
            set -g is_active false
            notify-send \
                -i python \
                -t 3000 \
                "Python Virtual Environment" \
                "The Python Virtual Environment was deactivated"
        end
        return
    end

    # Do not re-activate Python Virtual Environment
    if test $is_active = true
        return
    end

    # Activate venv
    source ./.venv/bin/activate.fish
    set -g is_active true
    notify-send \
        -i python \
        -t 3000 \
        "Python Virtual Environment" \
        "The Python Virtual Environment was activated"
end

