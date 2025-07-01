#!/bin/bash

# simple script that pass execution to the build.sh inside the docker folder, also block execution if `usage` is not present

ARGS=("$@")

# Color table
declare -A COLORS=(
  [Red]="#FF0000"
  [Blue]="#0000FF"
  [Green]="#00FF00"
  [Yellow]="#FFFF00"
  [Orange]="#FFA500"
  [Purple]="#800080"
  [Pink]="#FF00FF"
)

# Auto-install mise si absent
if ! command -v mise >/dev/null 2>&1; then
  echo "Downloading mise..."
  curl https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

if command -v usage >/dev/null 2>&1; then
  pushd docker || return
  ./build.sh "${ARGS[@]}"
  popd || return
else
  gum log --prefix.foreground="${COLORS[Red]}" -f --prefix="Error" "'usage' is not available in \$PATH. Please put it in your PATH or use \`mise i\` to setup everything directly"
  exit 1
fi