#!/bin/bash
# ============================================
# Check Updates - Verifica actualizaciones disponibles
# ============================================
# Cuenta el número de paquetes con actualizaciones pendientes
# Usado en el módulo de actualizaciones de waybar

i="$(checkupdates)"
printf "%b%b" "$i" "${i:+\n}" |wc -l; echo "$i" |column -t
