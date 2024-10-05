game="$MODULE_PKG"
id=($(cmd package dump "$game" | awk '/MAIN/{getline; print $2}'))

cmd shortcut reset-throttling || cmd shortcut reset-all-throttling

compile() {
     cmd package compile -m speed-profile -f "$game" --primary-dex --secondary-dex --include-dependencies --full -p PRIORITY_INTERACTIVE_FAST
}

compile, sleep 0.5    

armeabi_v7a() {
    apk_path=$(pm path "$game" | sed 's/package://')
    unzip -l "$apk_path" | grep -q "lib/armeabi-v7a/" &> /dev/null && echo "32-bit"
}

ql() {
    abi=$(armeabi_v7a || echo "64-bit")
    abi_flag=$([ "$abi" = "32-bit" ] && echo "--abi ARMEABI-V7A")

    am start -S --user 0 "${id[0]}" --activity-clear-task --no-window-animation \
    --ez android.intent.extra.disable_battery_optimization true \
    --ez android.intent.extra.enable_gpu_acceleration true \
    --ez android.intent.extra.priority true $abi_flag

    cmd notification post -t "Quick Launch" -S inbox \
    --line "App Running in $abi" \
    --line "Feedback for bugs or errors" \
    myTag "Quick Launch - Brainless"
}

if [ -n "$(dumpsys activity top | grep "$game")" ] ; then
   am clear-watch-heap $game
fi
