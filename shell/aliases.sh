alias list-packages="dpkg-query -W -f='\${Package}=\${Version}\n' | sort"
alias environment="printenv | sort"
alias path="echo $PATH | tr ':' '\n' | sort"

alias ll="ls --all --human-readable --color=auto --group-directories-first -l"
alias la="ls --almost-all --human-readable --color=auto"
alias dux="du --human-readable --max-depth=1"
alias dfx="df --human-readable --print-type"
alias mkdirp="mkdir --parents"
alias grepv="grep --invert-match"
alias cpv="cp --verbose"
alias rmf="rm --force --recursive"
alias touchn="touch --no-create"  # Just update timestamp

alias psg="ps --no-headers --format pid,ppid,cmd --sort=-pid"
alias topc="top --interactive --delay=1"
alias freeh="free --human"
alias historyt="history | tail --lines=50"
