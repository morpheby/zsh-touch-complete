
# Modify the buffer and get a new suggestion
_zsh_touchcomplete_modify() {
	emulate -L zsh

	local -i retval

	# Only available in zsh >= 5.4
	local -i KEYS_QUEUED_COUNT

	# Save the contents of the buffer/postdisplay
	local orig_buffer="$BUFFER"

	# Original widget may modify the buffer
	_zsh_touchcomplete_invoke_original_widget $@
	retval=$?

	# Don't fetch a new suggestion if there's more input to be read immediately
	if (( $PENDING > 0 )) || (( $KEYS_QUEUED_COUNT > 0 )); then
		return $retval
	fi

	# Don't fetch a new suggestion if the buffer hasn't changed
	if [[ "$BUFFER" = "$orig_buffer" ]]; then
		return $retval
	fi

	# Bail out if suggestions are disabled
	if [[ -n "${_ZSH_TOUCHCOMPLETE_DISABLED+x}" ]]; then
		return $?
	fi

	# Get a new suggestion if the buffer is not empty after modification
	if (( $#BUFFER > 0 )); then
		_toucbar_autocompleteLayout
		if [[ -z "$ZSH_TOUCHCOMPLETE_BUFFER_MAX_SIZE" ]] || (( $#BUFFER <= $ZSH_TOUCHCOMPLETE_BUFFER_MAX_SIZE )); then
			_zsh_touchcomplete_fetch
		fi
	else
		_zsh_touchcomplete_clear
	fi

	return $retval
}

# Clear the suggestion
_zsh_touchcomplete_clear() {
	_touchbar_defaultLayout $@
}

# Accept the suggestion from the touchbar
_zsh_touchcomplete_accept() {
	local insertion="$_ZSH_TOUCHCOMPLETE_SUGGESTIONS_TEMP[$NUMERIC]"

	local leftBuffer=$BUFFER[0,$CURSOR]
	local rightBuffer=$BUFFER[$CURSOR+1,${#BUFFER}]
	local cutBuffer
	local matched="no"
	
	if [[ $SUFFIX_ACTIVE = 1 ]]; then
		leftBuffer="$leftBuffer[0,$SUFFIX_START]$leftBuffer[$(( $SUFFIX_END + 1 )),${#leftBuffer}]"
	fi
	
	for i ({${#insertion}..0}); do
		local ins1="$leftBuffer[$(( ${#leftBuffer} - $i + 1 )),${#leftBuffer}]"
		local ins2="$insertion[0,$i]"
		
		# lowercase each
		ins1=$(printf "%s" "$ins1" | tr '[:upper:]' '[:lower:]')
		ins2=$(printf "%s" "$ins2" | tr '[:upper:]' '[:lower:]')
		
		if [[ "$ins1" = "$ins2" ]]; then
			cutBuffer="$leftBuffer[0,(( ${#leftBuffer} - $i ))]"
			leftBuffer="$cutBuffer$insertion"
			matched="yes"
			break
		fi
	done
	
	if [[ "$matched" = "no" ]]; then
		cutInsertion=$insertion
		leftBuffer=$leftBuffer$cutInsertion
	fi
	
	# Add the suggestion to the buffer
	BUFFER="$leftBuffer$rightBuffer"

	# Move the cursor to the end of the buffer
	CURSOR=$(( $CURSOR + ${#insertion} - $i ))
}
