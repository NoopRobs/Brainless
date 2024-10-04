game="$MODULE_PKG"
id=($(cmd package dump "$game" | awk '/MAIN/{getline; print $2}'))

cmd shortcut reset-throttling || cmd shortcut reset-all-throttling

compile() {
     cmd package compile -m speed -f "$game" --primary-dex --secondary-dex --include-dependencies --full -p PRIORITY_INTERACTIVE_FAST
}
     
armeabi_v7a () {
    apk_path=$(pm path $game | sed 's/package://g')
    armeabi_v7a_apps=()

    if [ -n "$apk_path" ]; then
        if unzip -l "$apk_path" | grep -q "lib/armeabi-v7a/"; then
            armeabi_v7a_apps+=("$game")
        fi
    fi

    echo "${armeabi_v7a_apps[@]}"
}
abi=($(armeabi_v7a))

launch_app() {
    am start -S --user 0 "${id[0]}" --ez --activity-clear-task --no-window-animation \
        android.intent.extra.disable_battery_optimization true \
        android.intent.extra.enable_gpu_acceleration true \
        android.intent.extra.priority true \
        --no-window-animation "$@"
}

# Inside ql function
if [ ${#abi[@]} -gt 0 ]; then
    launch_app --abi ARMEABI-V7A
    cmd notification post -t "Quick Launch" -S inbox \
    --line "App Running in 32-bit" \
    --line "Feedback for bugs or errors" \
    myTag "Quick Launch - Brainless"
else
    launch_app
    cmd notification post -t "Quick Launch" -S inbox \
    --line "App Running in 64-bit" \
    --line "Feedback for bugs or errors" \
    myTag "Quick Launch - Brainless"
fi

if [ -n "$(dumpsys activity top | grep "$game")" ] ; then
   am clear-watch-heap $game
fi
