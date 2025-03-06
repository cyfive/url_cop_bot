#!/usr/bin/env bash

if [ $# -gt 0 ]; then
    $@
    exit $?
fi

${BOT_HOME_DIR}/.venv/bin/python3 -u ${APP_DIR}/join_captcha_bot.py
