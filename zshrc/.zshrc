# XDG_CONFIG
XDG_CONFIG_HOME="$HOME/.config"

# Homebrew
if [ -d "/opt/homebrew" ]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
  export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
  export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/homebrew"
  export HOMEBREW_NO_AUTO_UPDATE="1"
fi
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
export MANPATH="$MANPATH:$HOMEBREW_PREFIX/share/man"
export INFOPATH="$INFOPATH:$HOMEBREW_PREFIX/share/info"

# If not in tmux, start tmux.
if [[ -z ${TMUX+X}${ZSH_SCRIPT+X}${ZSH_EXECUTION_STRING+X} ]]; then
  exec tmux new -s home
fi

export ZSH_PREFIX="$HOME/.zsh"
export ZSH_PLUGINS="$HOME/.zsh/plugins"
export ZSH_COMPLETIONS="$HOME/.zsh/completions"

function zcompile-many() {
  local f
  for f; do zcompile -R -- "$f".zwc "$f"; done
}

# Clone and compile to wordcode missing plugins.
if [[ ! -e "$ZSH_PLUGINS/zsh-syntax-highlighting" ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_PLUGINS/zsh-syntax-highlighting
  zcompile-many $ZSH_PLUGINS/zsh-syntax-highlighting/{zsh-syntax-highlighting.zsh,highlighters/*/*.zsh}
fi

if [[ ! -e "$ZSH_PLUGINS/zsh-autosuggestions" ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_PLUGINS/zsh-autosuggestions
  zcompile-many $ZSH_PLUGINS/zsh-autosuggestions/{zsh-autosuggestions.zsh,src/**/*.zsh}
fi

if [[ ! -e "$ZSH_PLUGINS/powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_PLUGINS/powerlevel10k"
  make -C $ZSH_PLUGINS/powerlevel10k pkg
fi

# Activate Powerlevel10k Instant Prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable the "new" completion system (compsys).
autoload -Uz compinit && compinit
[[ "$HOME/.zcompdump.zwc" -nt "$HOME/.zcompdump" ]] || zcompile-many "$HOME/.zcompdump"
unfunction zcompile-many

ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Load plugins.
source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$ZSH_PLUGINS/powerlevel10k/powerlevel10k.zsh-theme"
source "$HOME/.p10k.zsh"

# Spack
if [ ! -d "$HOME/spack" ]; then
  git clone -c feature.manyFiles=true git@github.com:spack/spack.git
  (cd $HOME/spack && git maintenance start)
fi
source "$HOME/spack/share/spack/setup-env.sh"

# CMake
export CMAKE_EXPORT_COMPILE_COMMANDS="ON"
export CMAKE_GENERATOR="Ninja"
[ -x "$(command -v ccache)" ] && CMAKE_C_COMPILER_LAUNCHER="ccache"
[ -x "$(command -v ccache)" ] && CMAKE_CXX_COMPILER_LAUNCHER="ccache"

# Aliases
[ -x "$(command -v nvim)" ] && alias vim="nvim"
[ -x "$(command -v bat)" ] && alias cat="bat --color=always"
[ -x "$(command -v lazygit)" ] && alias lg="lazygit"
[ -x "$(command -v eza)" ] && alias ls="eza"

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=5000000
SAVEHIST=$HISTSIZE

setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY

# Fzf
export FZF_DEFAULT_OPTS="
  --height=10% --layout=reverse --info=hidden --wrap
  --pointer '' --marker '' --prompt ''"
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target,__pycache__
  --preview 'cat -n {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'"

# Shell integrations
[ -x "$(command -v fzf)" ] && eval "$(fzf --zsh)"
[ -x "$(command -v zoxide)" ] && eval "$(zoxide init --cmd cd zsh)"
