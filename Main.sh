#!/bin/bash

game="$MODULE_PKG"
id=$(dumpsys package "$game" | grep -A 1 "MAIN" | grep "$game/" | awk '{print $2}' | xargs | sed 's/[0-9]*$//')

cmd shortcut reset-throttling && cmd shortcut reset-all-throttling

cmd package compile -m speed-profile -f "$game" --primary-dex --secondary-dex --include-dependencies --full -p PRIORITY_INTERACTIVE_FAST

ql() {
    am start -S --user 0 "${id[0]}" --activity-clear-task --no-window-animation --activity-reorder-to-front \
    --ez android.intent.extra.disable_battery_optimization true \
    --ez android.intent.extra.enable_gpu_acceleration true \
    --ez android.intent.extra.priority true \
    --ez android.intent.extra.ALLOW_IDLE_MODE true \
    --ez android.intent.extra.low_ram true \
    --ez android.intent.extra.allow_background_activity_start false "$@"
}

if ql --abi ARMEABI_V7A; then
  abi_status="32-bit"
else
  ql
  abi_status="64-bit"
fi

cmd notification post -t "Quick Launch - $abi_status" -S inbox \
--line "App Running in $abi_status" \
--line "Feedback for bugs or errors" \
myTag "Quick Launch - Brainless"

dumpsys activity top | grep -q "$game" && am clear-watch-heap $game
