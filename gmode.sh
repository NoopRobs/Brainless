game="$MODULE_PKG"

device_config put game_overlay $game mode=2,downscaleFactor=0.3,fps=120

  if [ -z cmd -l | grep -wo "game"]; then
      echo "empty"
  else
      cmd game set --mode 2 --fps 120 -downscale 0.3 --user 0 $game
  fi


# enable VULKAN If possible
# Will be Update further next time
current_apps=$(settings get global updatable_driver_production_opt_in_apps)
IFS=',' read -r -a apps_array <<< "$current_apps"

echo "Apps saat ini: ${apps_array[@]}"

new_package="game"
apps_array+=("$new_package")
updated_apps=$(IFS=','; echo "${apps_array[*]}")

settings put global updatable_driver_production_opt_in_apps "$updated_apps"
echo "Updated apps: $updated_apps"
