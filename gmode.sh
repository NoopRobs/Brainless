game="$MODULE_PKG"
a=$(settings get global updatable_driver_production_opt_in_apps)


cmd device_config put game_overlay "$game" mode=2,downscaleFactor="${dscale}",fps="${fps}",useAngle=true,LoadingBoost=1

am set-standby-bucket "$game" ACTIVE

# Check if Vulkan library exists
if [[ -e /system/lib/libvulkan.so ]]; then
   setprop debug.hwui.renderer skiavk
   setprop debug.renderengine.backend skiavkthreaded
   setprop debug.angle.overlay FPS:SkiaVK*PipelineCache*
fi

# Append to updatable driver production opt-in apps if not already included
if [[ "$a" != *"$game"* ]]; then
    settings put global updatable_driver_production_opt_in_apps "$a,$game"
fi

# Additional device configurations
device_config put activity_manager_native_boot use_freezer true

# Power and thermal settings
cmd power set-adaptive-power-saver-enabled false
cmd power set-fixed-performance-mode-enabled true
cmd power set-mode 0
cmd thermalservice override-status 0
cmd looper_stats disable

# Dropbox command (verify syntax with Android documentation)
cmd dropbox remove-low-priority "$game"
