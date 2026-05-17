#!/usr/bin/env bash

set -euo pipefail

CACHE_DIR="/tmp/eww-audio"
COVER_FILE="${CACHE_DIR}/cover"
COVER_URL_FILE="${CACHE_DIR}/cover.url"
FALLBACK_COVER="${HOME}/.config/rofi/images/gradient.png"

mkdir -p "$CACHE_DIR"

trim_line() {
  local text="${1:-}"
  text="${text//$'\n'/ }"
  printf '%s' "$text"
}

decode_file_url() {
  local raw="${1#file://}"
  python3 - <<'PY' "$raw"
import sys
from urllib.parse import unquote
print(unquote(sys.argv[1]))
PY
}

player_status() {
  playerctl status 2>/dev/null || true
}

case "${1:-}" in
  volume)
    pamixer --get-volume 2>/dev/null || echo "0"
    ;;
  mute-label)
    if [[ "$(pamixer --get-mute 2>/dev/null || echo false)" == "true" ]]; then
      echo "Unmute"
    else
      echo "Mute"
    fi
    ;;
  title)
    title="$(playerctl metadata --format '{{ title }}' 2>/dev/null || true)"
    title="$(trim_line "$title")"
    if [[ -n "$title" ]]; then
      echo "$title"
    else
      echo "Nothing playing"
    fi
    ;;
  artist)
    artist="$(playerctl metadata --format '{{ artist }}' 2>/dev/null || true)"
    artist="$(trim_line "$artist")"
    if [[ -n "$artist" ]]; then
      echo "$artist"
    else
      echo "Waiting for a player"
    fi
    ;;
  play-icon)
    if [[ "$(player_status)" == "Playing" ]]; then
      echo "󰏤"
    else
      echo "󰐊"
    fi
    ;;
  progress)
    length_us="$(playerctl metadata mpris:length 2>/dev/null || echo 0)"
    position_s="$(playerctl position 2>/dev/null || echo 0)"
    if [[ "$length_us" =~ ^[0-9]+$ ]] && (( length_us > 0 )); then
      python3 - <<'PY' "$length_us" "$position_s"
import sys
length_us = int(sys.argv[1])
position_s = float(sys.argv[2])
value = max(0.0, min(100.0, (position_s * 1_000_000 / length_us) * 100.0))
print(f"{value:.0f}")
PY
    else
      echo "0"
    fi
    ;;
  cover)
    art_url="$(playerctl metadata mpris:artUrl 2>/dev/null || true)"
    if [[ -z "$art_url" ]]; then
      echo "$FALLBACK_COVER"
      exit 0
    fi

    if [[ "$art_url" == file://* ]]; then
      decoded="$(decode_file_url "$art_url")"
      if [[ -f "$decoded" ]]; then
        echo "$decoded"
        exit 0
      fi
      echo "$FALLBACK_COVER"
      exit 0
    fi

    if [[ "$art_url" =~ ^https?:// ]]; then
      if [[ ! -f "$COVER_URL_FILE" ]] || [[ "$(cat "$COVER_URL_FILE" 2>/dev/null)" != "$art_url" ]] || [[ ! -s "$COVER_FILE" ]]; then
        printf '%s' "$art_url" > "$COVER_URL_FILE"
        curl -L --silent --show-error --max-time 3 "$art_url" -o "$COVER_FILE" >/dev/null 2>&1 || true
      fi

      if [[ -s "$COVER_FILE" ]]; then
        echo "$COVER_FILE"
      else
        echo "$FALLBACK_COVER"
      fi
      exit 0
    fi

    echo "$FALLBACK_COVER"
    ;;
  *)
    exit 1
    ;;
esac
