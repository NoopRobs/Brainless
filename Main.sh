game="$MODULE_PKG"
id=($(cmd package dump "$game" | awk '/MAIN/{getline; print $2}'))

compile() {
     cmd package compile -m speed -f "$game" --primary-dex --secondary-dex --include-dependencies --full -p PRIORITY_INTERACTIVE_FAST
}
     
ql() {
    abi=$(armeabi_v7a || echo "64-bit")
    abi_flag=$([ "$abi" = "32-bit" ] && echo "--abi ARMEABI-V7A")

    am start -S --user 0 "${id[0]}" --ez --activity-clear-task --no-window-animation \
    android.intent.extra.disable_battery_optimization true \
    android.intent.extra.enable_gpu_acceleration true \
    android.intent.extra.priority true \
    --no-window-animation $abi_flag

    cmd notification post -t "Quick Launch" -S inbox \
    --line "App Running in $abi" \
    --line "Feedback for bugs or errors" \
    myTag "Quick Launch - Brainless"
}



buat agar string ini lebih fleksible pada device" lain

for pkg in $(pm list packages -U | grep -v $game | cut -f3 -d:); do
    pm trim-caches 99G "$pkg" &
done

cmd shortcut reset-throttling || cmd shortcut reset-all-throttling

sleep 1; ql

if [ -n "$(dumpsys activity top | grep "$game")" ] ; then
   am clear-watch-heap $game
fi
