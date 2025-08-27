# Automatically setup Git repo for university work
function git_uni --description "Setup Git repo for university work"
    if not git rev-parse --is-inside-work-tree > /dev/null 2>&1
        echo "Not inside Git repo"
        return
    end

    echo "Setting Name"
    git config --local user.name "Diego A. Velez Torres"

    echo "Setting Email"
    git config --local user.email "diego.velez6@upr.edu"

    echo "Set Signing Key"
    git config --local user.signingkey "~/.ssh/github_university"
end

