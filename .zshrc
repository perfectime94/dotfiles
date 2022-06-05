export ZSH="$HOME/.shells/zsh/oh-my-zsh"

ZSH_THEME="jispwoso"

plugins=(git)

source $ZSH/oh-my-zsh.sh

## Completions for gentoo
autoload -U compinit promptinit
compinit
promptinit; prompt gentoo
zstyle ':completion::complete:*' use-cache 1
