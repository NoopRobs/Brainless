#!/bin/bash

game="$MODULE_PKG"
id=($(pm dump $game | grep -o "$game/[^ ]*" | grep -i "main" | sort -u | head -n 1))

cmd shortcut reset-throttling && cmd shortcut reset-all-throttling

compile() {
     cmd package compile -m speed-profile -f "$game" --primary-dex --secondary-dex --include-dependencies --full -p PRIORITY_INTERACTIVE_FAST
}

compile
sleep 0.5

ql() {
    am start -S --user 0 "${id[0]}" --activity-clear-task --no-window-animation \
    --ez android.intent.extra.disable_battery_optimization true \
    --ez android.intent.extra.enable_gpu_acceleration true \
    --ez android.intent.extra.priority true
}

ql --abi ARMEABI_V7A && abi_status="32-bit" || abi_status="64-bit" ql

cmd notification post -t "Quick Launch - $abi_status" -S inbox \
--line "App Running in $abi_status" \
--line "Feedback for bugs or errors" \
myTag "Quick Launch - Brainless"

if [[ dumpsys activity top | grep -q "$game" ]]; then
   am clear-watch-heap $game
fi
