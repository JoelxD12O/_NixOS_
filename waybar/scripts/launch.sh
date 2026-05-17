#!/usr/bin/env bash

set -euo pipefail

WAYBAR_DIR="${HOME}/.config/waybar"
PROFILES_DIR="${WAYBAR_DIR}/profiles"
STATE_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/waybar"
STATE_FILE="${STATE_DIR}/current_profile"
DEFAULT_PROFILE="default"

mkdir -p "${STATE_DIR}"

profile="${1:-}"
if [[ -z "${profile}" ]]; then
  if [[ -f "${STATE_FILE}" ]]; then
    profile="$(<"${STATE_FILE}")"
  else
    profile="${DEFAULT_PROFILE}"
  fi
fi

config_path="${PROFILES_DIR}/${profile}/config.jsonc"
style_path="${PROFILES_DIR}/${profile}/style.css"

if [[ ! -f "${config_path}" || ! -f "${style_path}" ]]; then
  profile="${DEFAULT_PROFILE}"
  config_path="${PROFILES_DIR}/${profile}/config.jsonc"
  style_path="${PROFILES_DIR}/${profile}/style.css"
fi

printf '%s\n' "${profile}" > "${STATE_FILE}"

pkill waybar >/dev/null 2>&1 || true
exec waybar -c "${config_path}" -s "${style_path}" >/dev/null 2>&1 &
