game="$MODULE_PKG"

device_config put game_overlay $game mode=2,downscaleFactor=0.3,fps=120,useAngle=true,LoadingBoost=1


  if [ -z cmd -l | grep -wo "game"]; then
      echo "empty"
  else
      cmd game set --mode 2 --fps 120 -downscale 0.3 --user 0 $game
  fi


a=$(settings get global updatable_driver_production_opt_in_apps)


if [[ ls /system/lib/libvulkan.so ]]; then
   setprop debug.hwui.renderer skiavk
   setprop debug.renderengine.backend skiavkthreaded
   setprop debug.angle.overlay FPS:SkiaVK*PipelineCache*
fi


if [[ "$a" != *"$game"* ]]; then
    settings put global updatable_driver_production_opt_in_apps "$a,com.discord"
fi


dumpsys deviceidle whitelist | grep -p "$game" || dumpsys deviceidle whitelist +"$game"


cmd looper_stats disable
cmd power set-adaptive-power-saver-enabled false
cmd power set-fixed-performance-mode-enabled true
cmd power set-mode 0
cmd thermalservice override-status 0
dumpsys deviceidle enable
dumpsys deviceidle force-idle
dumpsys deviceidle step deep
