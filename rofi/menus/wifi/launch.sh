#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROFI_THEME="${SCRIPT_DIR}/theme.rasi"

toggle_wifi() {
  local state
  state="$(nmcli -fields WIFI g 2>/dev/null | tr -d '[:space:]')"
  if [[ "$state" == "enabled" ]]; then
    nmcli radio wifi off
    notify-send "Wi-Fi" "Wi-Fi desactivado"
  else
    nmcli radio wifi on
    notify-send "Wi-Fi" "Wi-Fi activado"
  fi
}

wifi_enabled() {
  [[ "$(nmcli -fields WIFI g 2>/dev/null | tr -d '[:space:]')" == "enabled" ]]
}

build_menu() {
  local toggle_label rescan_label
  if wifi_enabled; then
    toggle_label="󰖪  Disable Wi-Fi"
  else
    toggle_label="󰖩  Enable Wi-Fi"
  fi
  rescan_label="󰑐  Manual Rescan"

  printf '%s\n' "$toggle_label"
  printf '%s\n' "$rescan_label"

  nmcli -t -f IN-USE,SECURITY,SIGNAL,SSID device wifi list --rescan no 2>/dev/null | while IFS=: read -r in_use security signal ssid; do
    [[ -z "${ssid// }" ]] && continue

    local state_icon lock_icon
    state_icon="○"
    [[ "$in_use" == "*" ]] && state_icon="󰄬"

    if [[ -n "${security// }" && "$security" != "--" ]]; then
      lock_icon="󰌾"
    else
      lock_icon="󰤨"
    fi

    printf '%s  %s  %-28s  %3s%%\n' "$state_icon" "$lock_icon" "$ssid" "$signal"
  done
}

prompt_password() {
  rofi -dmenu \
    -theme "$ROFI_THEME" \
    -theme-str 'listview { lines: 0; } entry { placeholder: "Password"; }' \
    -password \
    -p "Wi-Fi Password"
}

connect_network() {
  local chosen="$1"
  local ssid success_message saved_connections wifi_password=""

  ssid="$(printf '%s\n' "$chosen" | sed -E 's/^[^ ]+ +[^ ]+ +//; s/ +[0-9]{1,3}%$//')"
  ssid="$(printf '%s' "$ssid" | sed -E 's/[[:space:]]+$//')"

  [[ -z "$ssid" ]] && exit 0

  success_message="Connected to \"$ssid\"."
  saved_connections="$(nmcli -g NAME connection 2>/dev/null || true)"

  if printf '%s\n' "$saved_connections" | grep -Fxq "$ssid"; then
    nmcli connection up id "$ssid" | grep -qi "success" && notify-send "Wi-Fi" "$success_message"
    exit 0
  fi

  if [[ "$chosen" == *"󰌾"* ]]; then
    wifi_password="$(prompt_password)"
    [[ -z "$wifi_password" ]] && exit 0
    nmcli device wifi connect "$ssid" password "$wifi_password" | grep -qi "success" && notify-send "Wi-Fi" "$success_message"
  else
    nmcli device wifi connect "$ssid" | grep -qi "success" && notify-send "Wi-Fi" "$success_message"
  fi
}

main() {
  local chosen
  chosen="$(build_menu | rofi -dmenu -i -markup-rows -theme "$ROFI_THEME" -p "Wi-Fi")"

  [[ -z "${chosen:-}" ]] && exit 0

  case "$chosen" in
    "󰖩  Enable Wi-Fi"|"󰖪  Disable Wi-Fi")
      toggle_wifi
      ;;
    "󰑐  Manual Rescan")
      notify-send "Wi-Fi" "Rescanning networks..."
      nmcli device wifi list --rescan yes >/dev/null 2>&1 || true
      exec "$0"
      ;;
    *)
      connect_network "$chosen"
      ;;
  esac
}

main "$@"
