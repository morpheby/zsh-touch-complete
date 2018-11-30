
# Post a request for new suggestions based on what's currently in the buffer
_zsh_touchcomplete_fetch() {
	_zsh_touchcomplete_async_request "$BUFFER" "$CURSOR"
}

# Post a suggestion to the touch bar
_zsh_touchcomplete_suggest() {
	emulate -L zsh

	local suggestion="$1"
	local digitArg
	
	# Clear unused keys if we are at the end of the list
	if [[ "${suggestion}" = '_ZSH_TOUCHCOMPLETE_<<ENDLIST>>' ]] && (( $_ZSH_TOUCHCOMPLETE_LAST_KEY <= 19 )); then
		for i ({$(($_ZSH_TOUCHCOMPLETE_LAST_KEY+1))..20}); do
			_touchbar_clearKey $i
		done
		return
	fi

	# Post a suggestion
	if [[ -n "$suggestion" ]] && (( $#BUFFER )) && (( $_ZSH_TOUCHCOMPLETE_LAST_KEY <= 19 )); then
		_ZSH_TOUCHCOMPLETE_LAST_KEY=$(( $_ZSH_TOUCHCOMPLETE_LAST_KEY + 1 ))
		
		# Prepare a numeric-argument for the widget invocation
		digitArg=$(printf "%s" "$_ZSH_TOUCHCOMPLETE_LAST_KEY" | sed -e 's/\([0-9]\)/^X^X^D\1/g')
		
		# Set a key and bind the execution to a numeric-argument + escape
		_touchbar_setKey "${_ZSH_TOUCHCOMPLETE_LAST_KEY}" "${suggestion}" "${digitArg}^X^X^P" '-z'
		
		# Preserve the suggestion
		_ZSH_TOUCHCOMPLETE_SUGGESTIONS_TEMP[$_ZSH_TOUCHCOMPLETE_LAST_KEY]="$suggestion"
	fi
}