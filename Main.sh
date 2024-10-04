game="$MODULE_PKG"
id=($(cmd package dump "$game" | awk '/MAIN/{getline; print $2}'))

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

ql () {
    abi=($(armeabi_v7a))

    if [ ${#abi[@]} -gt 0 ]; then
        am start -S --user 0 "${id[0]}" --ez --activity-clear-task --no-window-animation \
        android.intent.extra.disable_battery_optimization true \
        android.intent.extra.enable_gpu_acceleration true \
        android.intent.extra.priority true \
    --no-window-animation --abi ARMEABI-V7A
        if [ $? -eq 0 ]; then
            cmd notification post -t "Quick Launch" -S inbox \
            --line "App Running in 32-bit" \
            --line "Feedback for bugs or errors" \
            myTag "Quick Launch - Brainless"
        else
            am start -S --user 0 "${id[0]}" --ez --activity-clear-task --no-window-animation \
            android.intent.extra.disable_battery_optimization true \
            android.intent.extra.enable_gpu_acceleration true \
            android.intent.extra.priority true \
            --no-window-animation
                if [ $? -eq 0 ]; then
                    cmd notification post -t "Quick Launch" -S inbox \
                    --line "App Running in 64-bit" \
                    --line "Feedback for bugs or errors" \
                    myTag "Quick Launch - Brainless"
                fi
        fi
    else
        am start -S --user 0 "${id[0]}" --ez --activity-clear-task --no-window-animation \
        android.intent.extra.disable_battery_optimization true \
        android.intent.extra.enable_gpu_acceleration true \
        android.intent.extra.priority true \
        --no-window-animation
            if [ $? -eq 0 ]; then
                cmd notification post -t "Quick Launch" -S inbox \
                --line "App Running in 64-bit" \
                --line "Feedback for bugs or errors" \
                myTag "Quick Launch - Brainless"
            fi
    fi
}

for pkg in $(pm list packages -U | grep -v $game | cut -f3 -d:); do
    pm trim-caches 99G "$pkg" &
done

cmd shortcut reset-throttling || cmd shortcut reset-all-throttling

sleep 1; ql

if [ -n "$(dumpsys activity top | grep "$game")" ] ; then
   am clear-watch-heap $game
fi
