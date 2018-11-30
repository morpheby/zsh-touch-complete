
# Create request to server
_zsh_touchcomplete_async_request() {
	# Reset the key counter
	_ZSH_TOUCHCOMPLETE_LAST_KEY=0
	
	# Erase the text in the server
	zpty -w -n $ZSH_TOUCHCOMPLETE_ASYNC_PTY_NAME $'\x03\x15'
	
	# Form a query
	local query=$(printf "%s" "${1}" | tr -d $'\b')
	
	# Get cursor position
	local cursor="${2}"
	
	# For now, just cut query to cursor (maybe think of a better solution later)
	query="$query[0,$cursor]"
	
	# Write the query to the zpty process to fetch a suggestion
	zpty -w -n $ZSH_TOUCHCOMPLETE_ASYNC_PTY_NAME "${query}"$'\t'
}

# Called when new data is ready to be read from the pty
# First arg will be fd ready for reading
# Second arg will be passed in case of error
_zsh_touchcomplete_async_response() {
	setopt LOCAL_OPTIONS EXTENDED_GLOB

	local suggestion

	# Unfortunately, we have to slightly wait, since this is a non-blocking call
	# If we don't, results will be out of order, if we do, they will be just
	# slow to come
	sleep 0.05
	zpty -rt $ZSH_TOUCHCOMPLETE_ASYNC_PTY_NAME suggestion '*'$'\0' 2>/dev/null
	
	# Ignore special lines (clear, etc)
	if [[ "$suggestion" = *$'\r'* ]]; then
		return
	fi
	
	# Invoke next widget to draw suggestion on touchbar
	zle touchbar-complete-suggest -- "${suggestion%%$'\0'##}"
}

_zsh_touchcomplete_async_pty_create() {
	# With newer versions of zsh, REPLY stores the fd to read from
	typeset -h REPLY

	# If we won't get a fd back from zpty, try to guess it
	if (( ! $_ZSH_TOUCHCOMPLETE_ZPTY_RETURNS_FD )); then
		integer -l zptyfd
		exec {zptyfd}>&1  # Open a new file descriptor (above 10).
		exec {zptyfd}>&-  # Close it so it's free to be used by zpty.
	fi

	# Fork a zpty process running the server function
	zpty -b $ZSH_TOUCHCOMPLETE_ASYNC_PTY_NAME zsh -f -i

	# Store the fd so we can remove the handler later
	if (( REPLY )); then
		_ZSH_TOUCHCOMPLETE_PTY_FD=$REPLY
	else
		_ZSH_TOUCHCOMPLETE_PTY_FD=$zptyfd
	fi

	# Run initialization scripts
	zpty -w $ZSH_TOUCHCOMPLETE_ASYNC_PTY_NAME "source ${_TOUCHCOMPLETE_ROOT_SOURCE_DIR}/async_server.sh"
	zpty -w $ZSH_TOUCHCOMPLETE_ASYNC_PTY_NAME "_zsh_touchcomplete_async_init"
	
	# Wait for initialization
	while ! zpty -r $ZSH_TOUCHCOMPLETE_ASYNC_PTY_NAME __LINE || [[ $__LINE != *"BOOTED"* ]]; do
	done
	
	# Set up input handler from the zpty
	zle -F $_ZSH_TOUCHCOMPLETE_PTY_FD _zsh_touchcomplete_async_response	
}

_zsh_touchcomplete_async_pty_destroy() {
	# Remove the input handler
	zle -F $_ZSH_TOUCHCOMPLETE_PTY_FD &>/dev/null

	# Destroy the zpty
	zpty -d $ZSH_TOUCHCOMPLETE_ASYNC_PTY_NAME &>/dev/null
}

_zsh_touchcomplete_async_pty_recreate() {
	_zsh_touchcomplete_async_pty_destroy
	_zsh_touchcomplete_async_pty_create
}

_zsh_touchcomplete_feature_detect_zpty_returns_fd() {
	typeset -g _ZSH_TOUCHCOMPLETE_ZPTY_RETURNS_FD
	typeset -h REPLY

	zpty zsh_touchcomplete_feature_detect '{ zshexit() { kill -KILL $$; sleep 1 } }'

	if (( REPLY )); then
		_ZSH_TOUCHCOMPLETE_ZPTY_RETURNS_FD=1
	else
		_ZSH_TOUCHCOMPLETE_ZPTY_RETURNS_FD=0
	fi

	zpty -d zsh_touchcomplete_feature_detect
}

_zsh_touchcomplete_async_start() {
	typeset -g _ZSH_TOUCHCOMPLETE_PTY_FD

	_zsh_touchcomplete_feature_detect_zpty_returns_fd
	_zsh_touchcomplete_async_pty_recreate

	# Let's play with fire and never restart shell (it's terribly slow, actually)
	# add-zsh-hook precmd _zsh_touchcomplete_async_pty_recreate
	
	# Update on pwd change
	add-zsh-hook chpwd _zsh_touchcomplete_async_pty_recreate
}
