game="$MODULE_PKG"
numz="$ds"
a=$(settings get global updatable_driver_production_opt_in_apps)

device_config put game_overlay $game mode=2,downscaleFactor="$numz",fps=120,useAngle=true,LoadingBoost=1


  if [ -z cmd -l | grep -wo "game"]; then
      echo "empty"
  else
      cmd game set --mode 2 --fps 120 -downscale "$numz" --user 0 $game
  fi


if [[ ls /system/lib/libvulkan.so ]]; then
   setprop debug.hwui.renderer skiavk
   setprop debug.renderengine.backend skiavkthreaded
   setprop debug.angle.overlay FPS:SkiaVK*PipelineCache*
fi


if [[ "$a" != *"$game"* ]]; then
    settings put global updatable_driver_production_opt_in_apps "$a,com.discord"
fi


dumpsys deviceidle whitelist | grep -p "$game" || dumpsys deviceidle whitelist +"$game"


cmd looper_stats | grep -q "Looper stats disabled" || { echo "Disabling looper stats..."; cmd looper_stats disable; }
cmd power get-adaptive-power-saver-enabled | grep -q "false" || { echo "Setting adaptive power saver to false..."; cmd power set-adaptive-power-saver-enabled false; }
cmd power get-fixed-performance-mode-enabled | grep -q "true" || { echo "Enabling fixed performance mode..."; cmd power set-fixed-performance-mode-enabled true; }
cmd power get-mode | grep -q "0" || { echo "Setting power mode to 0..."; cmd power set-mode 0; }
cmd thermalservice get-override-status | grep -q "0" || { echo "Overriding thermal status to 0..."; cmd thermalservice override-status 0; }


dumpsys deviceidle | grep -q "mLightEnabled=true" || { echo "Enabling device idle..."; dumpsys deviceidle enable; }
dumpsys deviceidle | grep -q "mForceIdle=true" || { echo "Activating forced idle mode..."; dumpsys deviceidle force-idle; }
dumpsys deviceidle step | grep -q "Light" || { echo "Stepping into light state..."; dumpsys deviceidle step d; }
