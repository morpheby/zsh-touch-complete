
_TOUCHCOMPLETE_ROOT_SOURCE_PATH="${(%):-%N}"

if [[ "${_TOUCHCOMPLETE_ROOT_SOURCE_PATH}" = /* ]]; then
	_TOUCHCOMPLETE_ROOT_SOURCE_DIR="$(dirname ${_TOUCHCOMPLETE_ROOT_SOURCE_PATH})"
else
	_TOUCHCOMPLETE_ROOT_SOURCE_DIR="$(pwd)/$(dirname ${_TOUCHCOMPLETE_ROOT_SOURCE_PATH})"
fi

# Init common vars
source ${_TOUCHCOMPLETE_ROOT_SOURCE_DIR}/vars.sh

# Init touchbar
source ${_TOUCHCOMPLETE_ROOT_SOURCE_DIR}/touchbar_utils.sh
source ${_TOUCHCOMPLETE_ROOT_SOURCE_DIR}/touchbar_style.sh

# Init touchcomplete
source ${_TOUCHCOMPLETE_ROOT_SOURCE_DIR}/touchcomplete_boot.sh

# Init async
source ${_TOUCHCOMPLETE_ROOT_SOURCE_DIR}/async_client.sh

# Init suggestions
source ${_TOUCHCOMPLETE_ROOT_SOURCE_DIR}/suggest.sh
source ${_TOUCHCOMPLETE_ROOT_SOURCE_DIR}/buffer.sh
source ${_TOUCHCOMPLETE_ROOT_SOURCE_DIR}/widget_helpers.sh

# Run necessary initialization procedures
_zsh_touchcomplete_start
