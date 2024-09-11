# Lines configured by zsh-newuser-install
HISTFILE=~/dotfiles/.histfile
HISTSIZE=5000
SAVEHIST=5000
setopt autocd beep extendedglob nomatch
unsetopt notify
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/edgelordkirito/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

alias ll='ls -alF'
alias vim='nvim'
alias try='echo "Testing aliaTesting alias"'


eval "$(starship init zsh)"
#End of File
