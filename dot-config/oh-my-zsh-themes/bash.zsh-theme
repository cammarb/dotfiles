# Bash-like prompt for zsh
# Includes git info

PROMPT="%{$fg_bold[green]%}%n@%m%{$reset_color%}:%{$fg_bold[blue]%}%~"
PROMPT+='$(git_prompt_info)'
PROMPT+='%{$reset_color%}$ ' 

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg_bold[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
