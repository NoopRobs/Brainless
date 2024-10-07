game="$MODULE_PKG"

device_config put game_overlay $game mode=2,downscaleFactor=0.3,fps=120,useAngle=true,LoadingBoost=1

  if [ -z cmd -l | grep -wo "game"]; then
      echo "empty"
  else
      cmd game set --mode 2 --fps 120 -downscale 0.3 --user 0 $game
  fi


# enable VULKAN If possible
# Will be Update further next time
a=$(settings get global updatable_driver_production_opt_in_apps)

# Menambahkan com.discord ke dalam daftar aplikasi, jika belum ada
if [[ "$a" != *"$game"* ]]; then
    settings put global updatable_driver_production_opt_in_apps "$a,com.discord"
fi
