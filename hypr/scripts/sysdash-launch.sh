#!/usr/bin/env bash

set -euo pipefail

WIDTH=1180
HEIGHT=760
RIGHT_MARGIN=18
TOP_MARGIN=56

if pgrep -f "kitty.*--class sysdash" >/dev/null 2>&1; then
  pkill -f "kitty.*--class sysdash" || true
  exit 0
fi

kitty --class sysdash --title sysdash -e python3 "$HOME/.config/hypr/scripts/sysdash.py" >/dev/null 2>&1 &

for _ in $(seq 1 30); do
  address="$(hyprctl clients -j 2>/dev/null | jq -r '.[] | select(.class=="sysdash") | .address' | head -n1)"
  if [[ -n "${address}" && "${address}" != "null" ]]; then
    break
  fi
  sleep 0.1
done

if [[ -z "${address:-}" || "${address}" == "null" ]]; then
  exit 0
fi

read -r mon_x mon_y mon_w <<< "$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused == true) | "\(.x) \(.y) \(.width)"' | head -n1)"

if [[ -z "${mon_x:-}" || -z "${mon_y:-}" || -z "${mon_w:-}" ]]; then
  exit 0
fi

target_x=$((mon_x + mon_w - WIDTH - RIGHT_MARGIN))
target_y=$((mon_y + TOP_MARGIN))

hyprctl dispatch resizewindowpixel exact "${WIDTH}" "${HEIGHT},address:${address}" >/dev/null 2>&1 || true
hyprctl dispatch movewindowpixel exact "${target_x}" "${target_y},address:${address}" >/dev/null 2>&1 || true
