################################################################################
##
## Alces Flight Compatibility Layer
## Copyright (c) 2020-present Alces Flight Ltd
##
################################################################################
alces() {
  case $1 in
    s|se|ses|sess|sessi|session)
      flight desktop "${@:2}"
      ;;
    gr|gri|grid|gridw|gridwa|gridwar|gridware)
      if type -t gridware &>/dev/null; then
        gridware "${@:2}"
      else
        echo "alces: gridware not available; try 'flight env activate gridware' first?"
      fi
      ;;
    *)
      flight "$@"
  esac
}

al() {
  alces "$@"
}

export -f alces al
