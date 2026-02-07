#!/usr/bin/env bash
# ============================================
# Spotify - Muestra la canción actual
# ============================================
# Obtiene el artista y título de la canción que se está reproduciendo
# Usado en el módulo de música de waybar

playerctl -p spotify metadata --format '<span foreground="#1db954"></span> <span foreground="#89b4fa"> {{artist}} - {{title}}</span> ' 2>/dev/null

