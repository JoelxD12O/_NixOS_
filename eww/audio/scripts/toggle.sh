#!/usr/bin/env bash

set -euo pipefail

CONFIG_DIR="${HOME}/.config/eww/audio"
WINDOW_NAME="audio-panel"
SUBMAP_NAME="audio-panel"

if eww -c "$CONFIG_DIR" active-windows 2>/dev/null | grep -q "$WINDOW_NAME"; then
  eww -c "$CONFIG_DIR" close "$WINDOW_NAME"
  hyprctl dispatch submap reset >/dev/null 2>&1 || true
  exit 0
fi

if ! eww -c "$CONFIG_DIR" active-windows >/dev/null 2>&1; then
  eww -c "$CONFIG_DIR" daemon >/dev/null 2>&1 &
  for _ in $(seq 1 25); do
    if eww -c "$CONFIG_DIR" active-windows >/dev/null 2>&1; then
      break
    fi
    sleep 0.04
  done
fi

eww -c "$CONFIG_DIR" open "$WINDOW_NAME"
hyprctl dispatch submap "$SUBMAP_NAME" >/dev/null 2>&1 || true
