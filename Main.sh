game="$MODULE_PKG"
id=($(cmd package dump "$game" | awk '/MAIN/{getline; print $2}'))

cmd shortcut reset-throttling || cmd shortcut reset-all-throttling

compile() {
     cmd package compile -m speed-profile -f "$game" --primary-dex --secondary-dex --include-dependencies --full -p PRIORITY_INTERACTIVE_FAST
}
     
compile; sleep 0.5

ql () {
am start -S --user 0 "${id[0]}" --ez --activity-clear-task --no-window-animation \
android.intent.extra.disable_battery_optimization true \
android.intent.extra.enable_gpu_acceleration true \
android.intent.extra.priority true \
--no-window-animation
}

test () {
am start -S --user 0 "${id[0]}"
}

test --abi ARMEABI_V7A
if [ $? -eq 0 ]; then
    cmd notification post -t "Quick Launch" -S inbox \
    --line "App Running in 32-bit" \
    --line "Feedback for bugs or errors" \
    myTag "Quick Launch - Brainless"
else
    test
    cmd notification post -t "Quick Launch" -S inbox \
    --line "App Running in 64-bit" \
    --line "Feedback for bugs or errors" \
    myTag "Quick Launch - Brainless"
fi

if [ -n "$(dumpsys activity top | grep "$game")" ] ; then
   am clear-watch-heap $game
fi
