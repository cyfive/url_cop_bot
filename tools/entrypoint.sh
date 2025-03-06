#!/usr/bin/env bash

if [ $# -gt 0 ]; then
    $@
    exit $?
fi

# Actual script directory path
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Clean old/previous residual captcha images
rm -f $DIR/../src/data/captchas/*

# Launch the Bot
python3 -u $DIR/../src/join_captcha_bot.py
