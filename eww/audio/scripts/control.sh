#!/usr/bin/env bash

set -euo pipefail

action="${1:-}"

case "$action" in
  set-volume)
    value="${2:-0}"
    value="${value%.*}"
    pamixer --set-volume "$value"
    ;;
  volume-up)
    pamixer -i 5
    ;;
  volume-down)
    pamixer -d 5
    ;;
  toggle-mute)
    pamixer -t
    ;;
  play-pause)
    playerctl play-pause
    ;;
  next)
    playerctl next
    ;;
  previous)
    playerctl previous
    ;;
  *)
    exit 1
    ;;
esac
