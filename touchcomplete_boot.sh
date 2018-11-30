
_zsh_touchcomplete_start() {
	add-zsh-hook -d precmd _zsh_touchcomplete_start

	# Bind helpers for entry transfer
	bindkey '^X^X^D1' digit-argument #F1
	bindkey '^X^X^D2' digit-argument #F2
	bindkey '^X^X^D3' digit-argument #F3
	bindkey '^X^X^D4' digit-argument #F4
	bindkey '^X^X^D5' digit-argument #F5
	bindkey '^X^X^D6' digit-argument #F6
	bindkey '^X^X^D7' digit-argument #F7
	bindkey '^X^X^D8' digit-argument #F8
	bindkey '^X^X^D9' digit-argument #F9
	bindkey '^X^X^P' touchbar-complete-accept

	# Bind utility methods
	zle -N touchbar-complete-fetch _zsh_touchcomplete_fetch
	zle -N touchbar-complete-suggest _zsh_touchcomplete_suggest
	zle -N touchbar-complete-accept _zsh_touchcomplete_accept
	zle -N touchbar-complete-reset _zsh_touchcomplete_async_pty_recreate

	_zsh_touchcomplete_async_start
	
	_zsh_touchcomplete_bind_widgets
}
