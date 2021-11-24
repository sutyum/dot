
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/satyam/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/satyam/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/satyam/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/satyam/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PATH=$PATH:/usr/local/go/bin

source ~/.zplug/init.zsh
source ~/enhancd/init.sh

export SHELL=/bin/zsh

