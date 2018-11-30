
# Prefix to use when saving original versions of bound widgets
: ${ZSH_TOUCHCOMPLETE_ORIGINAL_WIDGET_PREFIX=touchcomplete-orig-}

# Widgets that should be ignored (globbing supported but must be escaped)
(( ! ${+ZSH_TOUCHCOMPLETE_IGNORE_WIDGETS} )) && ZSH_TOUCHCOMPLETE_IGNORE_WIDGETS=(
	orig-\*
	beep
	run-help
	set-local-history
	which-command
	yank
	yank-pop
)
	
_zsh_touchcomplete_incr_bind_count() {
	if ((${+_ZSH_TOUCHCOMPLETE_BIND_COUNTS[$1]})); then
		((_ZSH_TOUCHCOMPLETE_BIND_COUNTS[$1]++))
	else
		_ZSH_TOUCHCOMPLETE_BIND_COUNTS[$1]=1
	fi

	typeset -gi bind_count=$_ZSH_TOUCHCOMPLETE_BIND_COUNTS[$1]
}

_zsh_touchcomplete_get_bind_count() {
	if ((${+_ZSH_TOUCHCOMPLETE_BIND_COUNTS[$1]})); then
		typeset -gi bind_count=$_ZSH_TOUCHCOMPLETE_BIND_COUNTS[$1]
	else
		typeset -gi bind_count=0
	fi
}

# Bind a single widget to an autosuggest widget, saving a reference to the original widget
_zsh_touchcomplete_bind_widget() {
	typeset -gA _ZSH_TOUCHCOMPLETE_BIND_COUNTS

	local widget=$1
	local autosuggest_action=$2
	local prefix=$ZSH_TOUCHCOMPLETE_ORIGINAL_WIDGET_PREFIX

	local -i bind_count

	# Save a reference to the original widget
	case $widgets[$widget] in
		# Already bound
		user:_zsh_touchcomplete_(bound|orig)_*);;

		# User-defined widget
		user:*)
			_zsh_touchcomplete_incr_bind_count $widget
			zle -N $prefix${bind_count}-$widget ${widgets[$widget]#*:}
			;;

		# Built-in widget
		builtin)
			_zsh_touchcomplete_incr_bind_count $widget
			eval "_zsh_touchcomplete_orig_${(q)widget}() { zle .${(q)widget} }"
			zle -N $prefix${bind_count}-$widget _zsh_touchcomplete_orig_$widget
			;;

		# Completion widget
		completion:*)
			_zsh_touchcomplete_incr_bind_count $widget
			eval "zle -C $prefix${bind_count}-${(q)widget} ${${(s.:.)widgets[$widget]}[2,3]}"
			;;
	esac

	_zsh_touchcomplete_get_bind_count $widget

	# Pass the original widget's name explicitly into the autosuggest
	# function. Use this passed in widget name to call the original
	# widget instead of relying on the $WIDGET variable being set
	# correctly. $WIDGET cannot be trusted because other plugins call
	# zle without the `-w` flag (e.g. `zle self-insert` instead of
	# `zle self-insert -w`).
	eval "_zsh_touchcomplete_bound_${bind_count}_${(q)widget}() {
		_zsh_touchcomplete_$autosuggest_action $prefix$bind_count-${(q)widget} \$@
	}"

	# Create the bound widget
	zle -N -- $widget _zsh_touchcomplete_bound_${bind_count}_$widget
}

# Map all configured widgets to the right autosuggest widgets
_zsh_touchcomplete_bind_widgets() {
	emulate -L zsh

 	local widget
	local ignore_widgets

	ignore_widgets=(
		.\*
		_\*
		zle-\*
		touchbar-complete-reset
		touchbar-complete-suggest
		touchbar-complete-fetch
		$ZSH_TOUCHCOMPLETE_ORIGINAL_WIDGET_PREFIX\*
		$ZSH_TOUCHCOMPLETE_IGNORE_WIDGETS
	)

	# Find every widget we might want to bind and bind it appropriately
	for widget in ${${(f)"$(builtin zle -la)"}:#${(j:|:)~ignore_widgets}}; do
		# Assume any unspecified widget might modify the buffer
		_zsh_touchcomplete_bind_widget $widget modify
	done
}

# Given the name of an original widget and args, invoke it, if it exists
_zsh_touchcomplete_invoke_original_widget() {
	# Do nothing unless called with at least one arg
	(( $# )) || return 0

	local original_widget_name="$1"

	shift

	if (( ${+widgets[$original_widget_name]} )); then
		zle $original_widget_name -- $@
	fi
}
