game="$MODULE_PKG"
a=$(settings get global updatable_driver_production_opt_in_apps)
dscale="0.7"
fps="60"

cmd device_config put game_overlay $game mode=2,downscaleFactor="$dscale",fps="$fps",useAngle=true,LoadingBoost=1

am set-standby-bucket "$game" ACTIVE

if [[ ls /system/lib/libvulkan.so ]]; then
   setprop debug.hwui.renderer skiavk
   setprop debug.renderengine.backend skiavkthreaded
   setprop debug.angle.overlay FPS:SkiaVK*PipelineCache*
fi


if [[ "$a" != *"$game"* ]]; then
    settings put global updatable_driver_production_opt_in_apps "$a,$game"
fi


device_config put activity_manager_native_boot use_freezer true


cmd power set-adaptive-power-saver-enabled false
cmd power set-fixed-performance-mode-enabled true
cmd power set-mode 0
cmd thermalservice override-status 0
cmd looper_stats disable


cmd dropbox remove-low-priority "$game"
