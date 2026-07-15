ZSH=$HOME/.oh-my-zsh

# You can change the theme with another one from https://github.com/robbyrussell/oh-my-zsh/wiki/themes
ZSH_THEME="robbyrussell"

# Useful oh-my-zsh plugins for Le Wagon bootcamps
plugins=(git gitfast last-working-dir common-aliases zsh-syntax-highlighting history-substring-search)

# (macOS-only) Prevent Homebrew from reporting - https://github.com/Homebrew/brew/blob/master/docs/Analytics.md
export HOMEBREW_NO_ANALYTICS=1
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Disable warning about insecure completion-dependent directories
ZSH_DISABLE_COMPFIX=true

# Actually load Oh-My-Zsh
source "${ZSH}/oh-my-zsh.sh"
unalias rm # No interactive rm by default (brought by plugins/common-aliases)
unalias lt # we need `lt` for https://github.com/localtunnel/localtunnel

# Load rbenv if installed (to manage your Ruby versions)
export PATH="${HOME}/.rbenv/bin:${PATH}" # Needed for Linux/WSL
type -a rbenv > /dev/null && eval "$(rbenv init -)"

# Load pyenv (to manage your Python versions)
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
type -a pyenv > /dev/null && eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init - 2> /dev/null)" && RPROMPT+='[🐍 $(pyenv version-name)]'

# Rails and Ruby uses the local `bin` folder to store binstubs.
# So instead of running `bin/rails` like the doc says, just run `rails`
# Same for `./node_modules/.bin` and nodejs
export PATH="./bin:./node_modules/.bin:${PATH}:/usr/local/sbin"

# Store your own aliases in the ~/.aliases file and load the here.
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# Encoding stuff for the terminal
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export BUNDLER_EDITOR=code
if command -v code >/dev/null 2>&1; then export EDITOR=code; else export EDITOR=vim; fi

# Set ipdb as the default Python debugger
export PYTHONBREAKPOINT=ipdb.set_trace

# pnpm
export PNPM_HOME="/Users/rabi/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end
# Added by Windsurf
export PATH="/Users/rabi/.codeium/windsurf/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# bun completions
[ -s "/Users/rabi/.bun/_bun" ] && source "/Users/rabi/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"




# Rust toolchain
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
# Quidkey Platform Tools - START
export MISE_EXPERIMENTAL=1
export QK_MISE_ROOT="$HOME"
export QK_DEV_ROOT="${QK_DEV_ROOT:-$HOME/code/quidkey/services/quidkey-monorepo}"
if [[ -d "$QK_DEV_ROOT" ]]; then
  export PATH="$QK_DEV_ROOT/platform/bin:$PATH"
  command -v qk >/dev/null 2>&1 && eval "$(qk completion zsh 2>/dev/null)"
fi
# Quidkey Platform Tools - END

# qkvps: Claude-on-VPS CLI, lives in the monorepo (platform/qkvps). platform/bin
# is on PATH via the Quidkey Platform Tools block; this only loads the zsh
# completion, resolving the CLI directly so it works regardless of block order.
QKVPS_CLI="${QK_DEV_ROOT:-$HOME/code/quidkey/services/quidkey-monorepo}/platform/bin/qkvps"
[[ -x "$QKVPS_CLI" ]] && eval "$("$QKVPS_CLI" --completion 2>/dev/null)"
unset QKVPS_CLI

[[ -d /opt/homebrew/opt/mysql-client/bin ]] && export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
