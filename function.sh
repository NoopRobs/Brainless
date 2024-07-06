

launch_app=() {
if ls /sdcard/android/data/$game/files/dragon2017/assets/comlibs/armeabi-v7a; then
   am start -D -N -S --user 0 "${id[0]}" --es --windowingMode 1 --no-window-animation --abi ARMEABI-V7A --splashscreen-icon
      if [ $? -eq 0 ]; then
         cmd notification post -S bigtext -t 'MLQL · Laxeron' 'Executed' 'Starting Mobile Legends with Armeabi-v7a !' > /dev/null 2>&1 &
     else
         echo "[ Can't start app or Error ! ]"
     fi
else
    am start -D -N -S --user 0 "${id[0]}" --es --windowingMode 1 --no-window-animation
       if [ $? -eq 0 ]; then
         cmd notification post -S bigtext -t 'MLQL · Laxeron' 'Executed' 'Starting APP, Enjoy your games !' > /dev/null 2>&1 &
     else
         echo "[ Can't start app or Error ! ]"
     fi
fi
}
launch=true
