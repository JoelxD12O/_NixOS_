#!/usr/bin/env bash

set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/waybar"
STATE_FILE="${STATE_DIR}/current_profile"
DEFAULT_PROFILE="default"
ALT_PROFILE="alt"

mkdir -p "${STATE_DIR}"

current="${DEFAULT_PROFILE}"
if [[ -f "${STATE_FILE}" ]]; then
  current="$(<"${STATE_FILE}")"
fi

if [[ "${current}" == "${ALT_PROFILE}" ]]; then
  next="${DEFAULT_PROFILE}"
else
  next="${ALT_PROFILE}"
fi

exec "${HOME}/.config/waybar/scripts/launch.sh" "${next}"
