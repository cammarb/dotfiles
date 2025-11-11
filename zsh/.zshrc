# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="bash"

plugins=(
  zsh-autosuggestions
  colemak
  git
  git-commit
  docker
  docker-compose
  kubectl
  aws
  helm
  fluxcd
  terraform
  mongo-atlas
  brew
  spring
)

source $ZSH/oh-my-zsh.sh

# User configuration

# aliases
alias vim="nvim"
alias py="python3"
alias pip="python3 pip"

# exports
export PATH=/usr/local/bin:$HOME/repos/kafka-sync/rkc/bin:$PATH
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

