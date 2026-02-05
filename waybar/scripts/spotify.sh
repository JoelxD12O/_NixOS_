#!/usr/bin/env bash

playerctl -p spotify metadata --format ' {{artist}} - {{title}} ' 2>/dev/null

