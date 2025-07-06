#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"

# Run AppleScript in the background
osascript "$DIR/install.applescript" &
PID=$!

# Spinner
i=0
sp='|/-\'
while kill -0 $PID 2>/dev/null; do
    printf "\rInstalling SafeSound... %c" "${sp:$((i++ % 4)):1}"
    sleep 0.1
done

wait $PID
echo -e "\rInstall complete!        "
