ORIGINAL_PATH=$PATH


# ------------------ setup other paths
OTHER_PATHS=()

# User bins
OTHER_PATHS+=(~/.bin)

# OSX bins
OTHER_PATHS+=(/usr/local/bin)

# Ruby bins
OTHER_PATHS+=(~/.rvm/bin)

# Lua bins
OTHER_PATHS+=(~/.luarocks/bin)

# adb & fastboot PATH, installed using install.sh script at
# https://github.com/corbindavenport/nexus-tools
OTHER_PATHS+=(~/.nexustools)

# Python bins
OTHER_PATHS+=(~/.local/bin)

# NodeJS bins
OTHER_PATHS+=(~/node_modules/.bin)



# ------------------ load local per-machine config

[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local

# TMP: during nix testing, make nix be opt-in
function nix::load-paths
{
  source /etc/profile.d/nix.sh
}


# ------------------ set $PATH & env avrs

typeset -U path
path=(
    "${OTHER_PATHS[@]}" # Expand all other paths by elements
    $path
)

export GOPATH=$HOME/gocode

export PAGER="most"

# man in vim!
export MANPAGER='nvim -R -c "set ft=man" -'

export EDITOR="nvim"
export VISUAL="$EDITOR"

export GIT_EDITOR="$EDITOR"


# ------------------ fzf config

FZF_KEYBINDINGS=()

# input nav
FZF_KEYBINDINGS+=(--bind 'alt-h:backward-char' --bind 'alt-l:forward-char')
FZF_KEYBINDINGS+=(--bind 'alt-b:backward-word' --bind 'alt-w:forward-word')

# suggestions nav
FZF_KEYBINDINGS+=(--bind 'alt-j:down' --bind 'alt-k:up')
FZF_KEYBINDINGS+=(--bind 'tab:down' --bind 'shift-tab:up' --bind 'alt-g:jump')

# other
FZF_KEYBINDINGS+=(--bind 'ctrl-j:accept')
FZF_KEYBINDINGS+=(--bind 'alt-a:toggle+down')
FZF_KEYBINDINGS+=(--bind 'change:top') # select best result on input change

FZF_LAYOUT=(--height=40% --reverse --inline-info --border)

export FZF_BEW_KEYBINDINGS="${(j: :)FZF_KEYBINDINGS}"
export FZF_BEW_LAYOUT="${(j: :)FZF_LAYOUT}"
