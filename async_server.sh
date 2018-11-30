
_zsh_touchcomplete_async_init() {
	# There is a bug in zpty module (fixed in zsh/master) by which a
	# zpty that exits will kill all zpty processes that were forked
	# before it. Here we set up a zsh exit hook to SIGKILL the zpty
	# process immediately, before it has a chance to kill any other
	# zpty processes.
	zshexit() {
		kill -KILL $$
		sleep 1 # Block for long enough for the signal to come through
	}

	# Don't add any extra carriage returns
	stty -onlcr

	# Don't translate carriage returns to newlines
	stty -icrnl

	# Silence any error messages
	exec 2>/dev/null

	# Initialize completer
	fpath=(/usr/local/share/zsh-completions /etc/zsh/functions $fpath)
	
	if [[ -e /etc/zsh/functions/ ]]; then
		autoload -U /etc/zsh/functions/*(:t)
	fi
	autoload -U compinit
	compinit -i
	
	# Case-half-independant search
	zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

	# Use our custom completer to sniff out results
	zstyle ':completion:*' completer _zsh_touchcomplete_matchsniff
	
	# Ignore line returns to prevent execution
	bindkey '^M' undefined
	bindkey '^J' undefined
	
	# Disable bell
	unsetopt beep
	
	# Remove prompts and colors
	TERM=''
	PROMPT=''
	PS1=''
	
	# Inform client that we are ready
	echo "BOOTED"
}

_zsh_touchcomplete_matchsniff() {
	[[ _matcher_num -gt 1 ]] && return 1

	local dounfunction
	integer ret=1
	local results

	{
		if (( ! $+functions[compadd] ))
		then
			dounfunction=1 
			compadd () {
				builtin compadd -O tmp_results "$@"
				results=("$tmp_results[@]" "$results[@]")
			}
		fi
	
		_complete
	} always {
		[[ -n $dounfunction ]] && (( $+functions[compadd] )) && unfunction compadd
	}
	
	results=("${(@ou)results}")
	
	# Report all our finds
	for r in "$results[@]"; do
		printf "%s" "$r"$'\0'
	done
	
	# Report that this is the end
	printf "%s" "_ZSH_TOUCHCOMPLETE_<<ENDLIST>>"$'\0'

	return ret
}
