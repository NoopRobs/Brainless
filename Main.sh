source run.sh
pkg=$(declare -p pkg | grep -oP 'pkg=(k[^)]+')

found_packages=()
for package in "${pkg[@]}"; do
    if pm list packages | grep -q "$package"; then
        found_packages+=("$package")        
    fi
done


game="${found_packages[0]}"
id=($(cmd package dump "$game" | awk '/MAIN/{getline; print $2}'))
status=$(am get-standby-bucket "$game")


fps=($(settings get global fps))
downscale=($(settings get global downscale))

renderer=$(getprop debug.hwui.renderer)
renderengine=$(getprop debug.renderengine.backend)

size=$(wm size)
density=$(wm density)


width=$(echo $size | cut -d 'x' -f 1)
height=$(echo $size | cut -d 'x' -f 2)


launch_app () {
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

echo "[ Game Discovered as > $game ]"
echo ""

if [ ${#dsempty[@]} -ne 0 ]; then
    echo "[ No Downscale in argument !, now using saved Value ! ]"
else
    echo "[ Downscale value was added with Argument ! ]"
fi

echo ""

if [ ${#fps[@]} -ne 0 ]; then
    echo "[ No Fps in argument !, now using saved Value ! ]"
else
    echo "[ Fps value was added with Argument ! ]"
fi

echo ""

echo "[ Current renderer > $renderer ! ]"
echo "[ Current Render Engine > $renderengine ! ]"
echo "• You can change render by using Render Option !"
echo ""


if  [ -z $downscale ]; then
    echo "[ There is no saved value, Please add value on next Argument ! ]"
    echo ""
else
     echo "[ Downscale set with > $downscale ! ]"
     echo ""
fi

if [ -z "$fps" ]; then
    echo "[ Fps Value is Empety ! ]"
    echo ""
else
    echo "[ Fps set with > $fps ! ]"
    echo ""
fi


# Reset app throttling
cmd shortcut reset-throttling "$game" > /dev/null
if [ $? -eq 0 ]; then
    echo "[ Reset Throttle for app and users ! ]"
else
    echo "[ Failed to reset App Throttle ! ]"
fi

sleep 1

cmd shortcut reset-all-throttling "$game" > /dev/null
if [ $? -eq 0 ]; then
    echo "[ Reset Throttles for all users ! ]"
else
    echo "[ Failed to reset all App Throttles! ]"
fi

# Clear caches
pm trim-caches 999G &

# Set device to idle
{
    dumpsys deviceidle enable
    dumpsys deviceidle force-idle
    dumpsys deviceidle step deep
} > /dev/null

# Check and add game to whitelist if necessary
if dumpsys deviceidle | grep -q "$game"; then
    echo "[ $game already in whitelist ]"
else
    echo "[ $game is not listed ]"
    sleep 1
    cmd deviceidle whitelist +$game > /dev/null
    echo "[ $game Added to Whitelist. ]"
fi

                  
# Compile system ui
cmd package compile -m quicken -f com.android.systemui > /dev/null
    if [ $? -eq 0 ]; then
        echo "[ $game is Compiled ! ]"
    else
        pm compile -m quicken -f com.android.systemui > /dev/null
        if [ $? -eq 0 ]; then
            echo "[ SystemUi is Compiled ! ]"
        else
            echo "[ Can't Compile App or packagename not found! ]"
        fi
    fi


# Apply device config
device_config delete game_overlay "$game" > /dev/null
  if [ $? -eq 0 ]; then  
     device_config put game_overlay "$game" mode=2,fps="$fps",downscaleFactor="$downscale"
  else
     echo "[ Can't Apply game_overlay or Error ! ]"
     echo ""
  fi
    

# Set game mode and performance settings
if [ -z "$cmdgame" ]; then
     echo "[ Cmd Game not supported on this Device! ]"
else
     cmd game set --mode performance --downscale "$downscale" --fps "$fps" --user 0 "$game" > /dev/null
          if [ $? -eq 0 ]; then
               echo "[ Cmd Game Applied! ]"
          else
               echo "[ Cmd Game not supported on this Device! ]"
          fi
fi


# Set standby mode
if [ "$status" -ne 10 ]; then
    am set-standby-bucket "$game" 10
    if [ $? -eq 0 ]; then
        echo "[ $game now in High Standby Mode ]"
    else
        echo "[ Failed to set $game in Standby Mode! ]"
    fi
else
    echo "[ $game is already in Standby Mode! ]"
fi


am send-trim-memory --user 0 com.android.systemui RUNNING_CRITICAL
 if [ "$?" -eq "0" ]; then
   echo "[ SytemUi Optimized ! ]" 
 else
   echo "[ Error Optimize SystemUi ! ]"
 fi


# Set system properties for performance
setprop debug.sf.hw 1
setprop debug.egl.hw 1
setprop debug.egl.sync 0
setprop debug.composition.type gpu
device_config put activity_manager_native_boot use_freezer true
settings put global cached_apps_freezer 1
settings delete system thermal_limit_refresh_rate > /dev/null
settings put system peak_refresh_rate 1
settings put system user_refresh_rate 1
cmd power set-adaptive-power-saver-enabled false
cmd power set-fixed-performance-mode-enabled true
cmd power set-mode 0
cmd thermalservice override-status 0
cmd looper_stats disable


if pgrep -f "$game" > /dev/null;then
   am clear-watch-heap $game 
       if [ $? -eq 0 ]; then
           echo "[ $game heap cleared ! ]"
       else
           echo "[ Can't clear $game heap ]"
       fi
fi

