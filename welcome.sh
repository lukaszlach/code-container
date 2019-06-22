#!/usr/bin/env bash
. ~/.bash_completion
if [ ! -z "$EDITOR_BANNER" ]; then
    figlet "$EDITOR_BANNER"
fi
cat /tmp/.versions
echo
