#!/usr/bin/env bash
# DND toggle for swaync (uses swaync itself). Prints "true"/"false".
set -u
swaync-client -d -sw >/dev/null 2>&1
swaync-client -D -sw 2>/dev/null
