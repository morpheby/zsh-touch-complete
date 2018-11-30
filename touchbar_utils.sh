
_ZSH_FN_KEYS=('^[OP' '^[OQ' '^[OR' '^[OS' '^[[15~' '^[[17~' '^[[18~' '^[[19~' '^[[20~' '^[[21~' '^[[23~' '^[[24~' '^[[1;2P' '^[[1;2Q' '^[[1;2R' '^[[1;2S' '^[[15;2~' '^[[17;2~' '^[[18;2~' '^[[19;2~')

_touchbar_pecho() {
	if [ -n "$TMUX" ]; then
		printf "%s" "\ePtmux;\e$*\e\\"
	else
		printf "%s" "$@"
	fi
}

function _touchbar_setKey(){
	if [[ $4 != -*n* ]]; then
		local escaped=$(printf "%q" "${2}")
		_touchbar_pecho $'\033'"]1337;SetKeyLabel=F${1}=${escaped}"$'\a'
	else
		_touchbar_pecho $'\033'"]1337;SetKeyLabel=F${1}=${2}"$'\a'
	fi
	
	case "$4" in
	-*q*)
		bindkey "$_ZSH_FN_KEYS[$1]" "$3"
		;;
	-*z*)
		bindkey -s "$_ZSH_FN_KEYS[$1]" "$3"
		;;
	*)
		bindkey -s "$_ZSH_FN_KEYS[$1]" "$3\n"
		;;
	esac
}

function _touchbar_clearKey(){
	_touchbar_pecho $'\033'"]1337;SetKeyLabel=F${1}=F${1}"$'\a'
	bindkey -r "$_ZSH_FN_KEYS[$1]"
}

function _touchbar_clearTouchbar() {
	_touchbar_pecho $'\033'"]1337;PopKeyLabels"$'\a'
}

function _touchbar_unbindTouchbar() {
	for fnKey in "$_ZSH_FN_KEYS[@]"; do
		bindkey -r "$fnKey"
	done
}
