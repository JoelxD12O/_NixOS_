#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROFI_THEME="${SCRIPT_DIR}/theme.rasi"

get_volume() {
  pamixer --get-volume 2>/dev/null || echo "0"
}

is_muted() {
  pamixer --get-mute 2>/dev/null || echo "false"
}

get_volume_icon() {
  local vol muted
  vol="$(get_volume)"
  muted="$(is_muted)"

  if [[ "$muted" == "true" ]]; then
    echo "󰝟"
  elif (( vol >= 70 )); then
    echo "󰕾"
  elif (( vol >= 30 )); then
    echo "󰖀"
  else
    echo "󰕿"
  fi
}

get_player_line() {
  local status artist title
  status="$(playerctl status 2>/dev/null || true)"
  artist="$(playerctl metadata artist 2>/dev/null || true)"
  title="$(playerctl metadata title 2>/dev/null || true)"

  if [[ -z "$status" || -z "$title" ]]; then
    echo "Nothing playing"
    return
  fi

  if [[ -n "$artist" ]]; then
    echo "${artist} - ${title}"
  else
    echo "${title}"
  fi
}

build_menu() {
  local vol muted
  vol="$(get_volume)"
  muted="$(is_muted)"

  printf '󰕾  Volume    %s%%\n' "$vol"
  printf '󰝟  Mute      %s\n' "$([[ "$muted" == "true" ]] && echo "On" || echo "Off")"
  printf '󰐊  Play / Pause\n'
  printf '󰒭  Next Track\n'
  printf '󰒮  Previous Track\n'
  printf '󰕿  Volume Up +5%%\n'
  printf '󰖀  Volume Down -5%%\n'
  printf '󰓃  Open Mixer\n'
}

rofi_select() {
  local status_line
  status_line="$(printf 'Now playing: %s\nOutput: %s  %s%%' "$(get_player_line)" "$(get_volume_icon)" "$(get_volume)")"
  build_menu | rofi -dmenu -i -theme "$ROFI_THEME" -p "Audio" -mesg "$status_line"
}

handle_choice() {
  case "$1" in
    "󰝟  Mute      "*)
      pamixer -t
      ;;
    "󰕿  Volume Up +5%")
      pamixer -i 5
      ;;
    "󰖀  Volume Down -5%")
      pamixer -d 5
      ;;
    "󰒭  Next Track")
      playerctl next
      ;;
    "󰒮  Previous Track")
      playerctl previous
      ;;
    "󰐊  Play / Pause")
      playerctl play-pause
      ;;
    "󰓃  Open Mixer")
      pavucontrol >/dev/null 2>&1 &
      ;;
  esac
}

main() {
  local chosen
  chosen="$(rofi_select)"
  [[ -z "${chosen:-}" ]] && exit 0
  handle_choice "$chosen"
}

main "$@"
