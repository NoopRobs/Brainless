game="$MODULE_PKG"

device_config put game_overlay $game mode=2,downscaleFactor=0.3,fps=120

  if [ -z cmd -l | grep -wo "game"]; then
      echo "empty"
  else
      cmd game set --mode 2 --fps 120 -downscale 0.3 --user 0 $game
  fi
