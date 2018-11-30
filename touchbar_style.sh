
_touchbar_state=''

# Output name of current branch.
_touchbar_git_current_branch() {
	local ref
	ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
	local ret=$?
	if [[ $ret != 0 ]]; then
		[[ $ret == 128 ]] && return  # no git repo.
		ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
	fi
	echo ${ref#refs/heads/}
}

_touchbar_git_status() {
	if [[ -n $(git status -s 2> /dev/null) ]]; then
		echo "❌"
	else
		echo "✅"
	fi
}

function _touchbar_defaultLayout() {
	if [[ ${touchBarState} != '' ]]; then
		_touchbar_clearTouchbar
		_touchbar_state=''
	fi
	_touchbar_unbindTouchbar

	local fnKeyIndex
	fnKeyIndex=1

	# GIT
	# ---
	# Check if the current directory is a git repository and not the .git directory
	if git rev-parse --is-inside-work-tree &>/dev/null &&
		[[ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]]; then

		# Ensure the index is up to date.
		git update-index --really-refresh -q &>/dev/null

		# String of indicators
		local touchbarIndicators

		touchbarIndicators="$(_touchbar_git_status)"
	
		_touchbar_setKey ${fnKeyIndex} "$touchbarIndicators" "git status" '-n'
		fnKeyIndex=$((fnKeyIndex + 1))
	
		_touchbar_setKey ${fnKeyIndex} "🎋 `_touchbar_git_current_branch`" _touchbar_branchesLayout '-nq'
		fnKeyIndex=$((fnKeyIndex + 1))
	fi
  
	# CURRENT_DIR
	# -----------
	_touchbar_setKey ${fnKeyIndex} "👉 $(echo $PWD | awk -F/ '{print $(NF-1)"/"$(NF)}')" _touchbar_pathLayout '-nq'
	fnKeyIndex=$((fnKeyIndex + 1))

	for index in {${fnKeyIndex}..20}; do
		_touchbar_clearKey ${index}
	done
}

_touchbar_gitBranches=()

function _touchbar_branchesLayout() {
	# List of branches for current repo
	_touchbar_gitBranches=($(git branch | sed -E 's/\* /👉/g'))

	if [[ ${touchBarState} != 'branches' ]]; then
		_touchbar_clearTouchbar
		_touchbar_state='branches'
	fi
	_touchbar_unbindTouchbar

	local fnKeysIndex=0
	# for each branch name, bind it to a key
	for branch in "$_touchbar_gitBranches[@]"; do
		fnKeysIndex=$((fnKeysIndex + 1))
		_touchbar_setKey $fnKeysIndex $branch "git checkout $branch"
		
		if (( $fnKeysIndex >= 20 )); then
			break
		fi
	done
}

function _touchbar_pathLayout() {
	if [[ ${touchBarState} != 'path' ]]; then
		_touchbar_clearTouchbar
		_touchbar_state='path'
	fi
	_touchbar_unbindTouchbar
	local directories

	IFS="/" read -rA directories <<< "$PWD"
	local fnKeysIndex=0
	for dir in "${directories[@]:1}"; do
		fnKeysIndex=$((fnKeysIndex + 1))
		_touchbar_setKey $fnKeysIndex "$dir" "cd $(pwd | cut -d'/' -f-$(( $fnKeysIndex + 1 )))"
		
		if (( $fnKeysIndex >= 20 )); then
			break
		fi
	done
}

function _toucbar_autocompleteLayout() {
	_touchbar_state='autocomplete'
}

zle -N _touchbar_defaultLayout
zle -N _touchbar_branchesLayout
zle -N _touchbar_pathLayout

bindkey '^[^[' _touchbar_defaultLayout

_touchbar_precmd_iterm_touchbar() {
	_touchbar_defaultLayout
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _touchbar_precmd_iterm_touchbar
