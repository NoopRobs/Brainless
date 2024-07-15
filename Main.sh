#!/system/bin/sh

cd $(dirname $0)
dos2unix data
source data

found_packages=()
for package in "${pkg[@]}"; do
    if pm list packages | grep -q "$package"; then
        found_packages+=("$package")        
    fi
done

# parameter gathered
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
cmdgame=($(cmd -l | grep "game"))


# Set properties
case "$1" in
    "0.5")
       settings put global downscale 0.5                  
       ;;
   "0.7")
       settings put global downscale 0.7       
       ;;    
   "disable")
       settings put global downscale disable             
       ;;
       *)
       dsempty=("$1")
       ;;
esac


case "$1" in
    "120")
       settings put global fps 120                  
       ;;
   "90")
       settings put global fps 90       
       ;;    
   "60")
       settings put global fps 60             
       ;;
       *)
       fpsempty=("$1")
       ;;
esac


launch_app () {
if ls /sdcard/android/data/$game/files/dragon2017/assets/comlibs/armeabi-v7a; then
   am start -S --user 0 "${id[0]}" --es --windowingMode 1 --no-window-animation --abi ARMEABI-V7A --splashscreen-icon
      if [ $? -eq 0 ]; then
         cmd notification post -S bigtext -t 'MLQL · Laxeron' 'Executed' 'Starting Mobile Legends with Armeabi-v7a !' > /dev/null 2>&1 &
     else         
         am start -S --user 0 "${id[0]}" --es --windowingMode 1 --no-window-animation
             if [ $? -eq 0 ]; then
                 cmd notification post -S bigtext -t 'MLQL · Laxeron' 'Executed' 'Starting APP, Enjoy your games !' > /dev/null 2>&1 &
             else
                 echo "[ Can't start app or Error ! ]"
             fi
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


cmd shortcut reset-all-throttling "$game" > /dev/null
if [ $? -eq 0 ]; then
    echo "[ Reset Throttles for all users ! ]"
else
    echo "[ Failed to reset all App Throttles! ]"
fi

# Clear caches
(for a in $(pm list packages -U|grep -v $game|cut -f3 -d:);do pm trim-caches 99G "$a"&done)>/dev/null 2>&1&

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


 #resolution size screen 
for arg in "$@"; do
    case "$arg" in
        "100")
            wm size reset
            ;;
        "75")
            new_width=$(echo "$sizevalue" | cut -d'x' -f1)
            new_height=$(echo "$sizevalue" | cut -d'x' -f2)
            new_size="${new_width}*0.75x${new_height}*0.75"
            wm size "$new_size"
            ;;
        "50")
            new_width=$(echo "$sizevalue" | cut -d'x' -f1)
            new_height=$(echo "$sizevalue" | cut -d'x' -f2)
            new_size="${new_width}*0.50x${new_height}*0.50"
            wm size "$new_size"
            ;;
        "30")
            new_width=$(echo "$sizevalue" | cut -d'x' -f1)
            new_height=$(echo "$sizevalue" | cut -d'x' -f2)
            new_size="${new_width}*0.30x${new_height}*0.30"
            wm size "$new_size"
            ;;
    esac
done


for arg in "$@"; do
    case "$arg" in 
        "-cmp")
            cmd package compile -m speed -f "$game" -r -secondary-dex > /dev/null
            if [ $? -eq 0 ]; then
                echo "[ App Compiled! ]"
            else
                pm compile -m speed -f "$game" -r -secondary-dex > /dev/null
                if [ $? -eq 0 ]; then
                    echo "[ $game Compiled ! ]"
                else
                    echo "[ Can't Compile App or packagename not found! ]"
                fi
            fi
            ;;
        "-call")
            echo "[ Call Function Now running... Please Wait! ]"
            for pkg in $(cmd package list packages -s | cut -d ":" -f2); do
                pm compile -m space-profile -f $pkg > /dev/null
                    if [ $? -eq 0 ]; then
                        echo "[ Bg App has been Compiled! ]"
                    else
                        echo "[ Can't Compile Bg App! ]"
                    fi
            done
            ;;
        "-dbs")
            for debug in $(getprop | grep -F '[debug.' | cut -f 2 -d [ | cut -f 1 -d ]); do
                setprop "$debug" ""
            done
            if [ $? -eq 0 ]; then
                echo "[ Debug Values Deleted! ]"
            else
                echo "[ Can't delete debug values or error! ]"
            fi              
            ;;
          "-svk")
            if ls /system/lib/libvulkan.so > /dev/null 2>&1; then
                setprop debug.hwui.renderer skiavk
                setprop debug.renderengine.backend skiavkthreaded
            else
                echo "[ Device Not Support Vulkan Render ! ]"
                return 0
            fi   
            ;;
          "-vk")
            if ls /system/lib/libvulkan.so > /dev/null; then
              setprop debug.renderengine.backend vulkan
          	setprop debug.hwui.renderer vulkan
              echo "[ Vulkan Render Applied ! ]"      	
           else
          	echo "[ Device Not Support Vulkan Render ! ]"    
          	return 0
           fi
            ;;
          "-sk")
             echo "[ Skip Quick Launch Option ! ]"
             launch=false
            ;;                        
    esac   
done


if $launch ; then
    results+=($(launch_app))   
fi


# Set system properties for performance
setprop debug.cpurend.vsync false
setprop debug.egl.force_msaa false
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
settings put secure game_auto_tempature 0
settings put secure speed_mode_enable 1
settings put system speed_mode 1
