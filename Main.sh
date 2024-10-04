game="$MODULE_PKG"
id=($(cmd package dump "$game" | awk '/MAIN/{getline; print $2}'))

compile() {
     cmd package compile -m speed -f "$game" --primary-dex --secondary-dex --include-dependencies --full -p PRIORITY_INTERACTIVE_FAST
}
     
armeabi_v7a() {
    apk_path=$(pm path "$game" | sed 's/package://')
    unzip -l "$apk_path" | grep -q "lib/armeabi-v7a/" && echo "32-bit"
}

ql() {
    # Array of game package name
abi=$(dumpsys package "$game" | grep primaryCpuAbi | cut -d "=" -f2)

case "$abi" in
  "armeabi-v7a")
     abi="32-bit
     abi_flag="--abi ARMEABI-V7A"
  ;;
   "arm64-v8a")
     abi="64-bit"
     abi_flag="
  ;;
 "x86")
     abi="32-bit (x86)"
     abi_flag="--abi x86"
;;
  "x86_64")
     abi="64-bit (x86)"
     abi_flag=""
;;
esac

 # Start the app with flexible flags
am start -S --user 0 "$pkg" \
--ez android.intent.extra.disable_battery_optimization true \
--ez android.intent.extra.enable_gpu_acceleration true \
--ez android.intent.extra.priority true \
--activity-clear-task --no-window-animation \
$abi_flag

# Post notification
cmd notification post -t "Quick Launch" -S inbox \
--line "App Running in $abi" \
--line "Feedback for bugs or errors" \
myTag "Quick Launch - Brainless"
done
}

for pkg in $(pm list packages -U | grep -v $game | cut -f3 -d:); do
    pm trim-caches 99G "$pkg" &
done

cmd shortcut reset-throttling || cmd shortcut reset-all-throttling

sleep 1; ql

if [ -n "$(dumpsys activity top | grep "$game")" ] ; then
   am clear-watch-heap $game
fi
