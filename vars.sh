
# Precmd hooks for initializing the library and starting pty's
autoload -Uz add-zsh-hook

# Asynchronous suggestions are generated in a pty
zmodload zsh/zpty

_ZSH_TOUCHCOMPLETE_SUGGESTIONS_TEMP=('')

: ${_ZSH_TOUCHCOMPLETE_LAST_KEY=0}

# Pty name for calculating autosuggestions asynchronously
: ${ZSH_TOUCHCOMPLETE_ASYNC_PTY_NAME=zsh_touchcomplete_pty}

# Widgets that clear the suggestion list
ZSH_TOUCHCOMPLETE_CLEAR_WIDGETS=(
	history-search-forward
	history-search-backward
	history-beginning-search-forward
	history-beginning-search-backward
	history-substring-search-up
	history-substring-search-down
	up-line-or-beginning-search
	down-line-or-beginning-search
	up-line-or-history
	down-line-or-history
	accept-line
)

