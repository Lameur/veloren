#!/usr/bin/env -S usage bash
#USAGE flag "-b --build <build>" help="The image to build" {
#USAGE   choices "all" "auth" "server-cli"
#USAGE }

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

if [ -z "$usage_build" ]; then
  BUILD=$(gum choose --no-limit --header="Select build type:" all auth server-cli)
else
  BUILD="$usage_build"
fi
echo "selected build: $BUILD"

#gum spin --title.foreground=${COLORS[Purple]} --title.foreground=${COLORS[Purple]} --spinner.foreground=${COLORS[Orange]} --show-output --show-error --spinner dot --title "Building docker image $BUILD..." --
docker buildx create --driver-opt default-load=true --driver-opt memory=6G --driver-opt memory-swap=10G --driver docker-container --name container --bootstrap --node container --platform linux/amd64,linux/arm64,windows/amd64,windows/arm64
docker bake --builder container --allow=fs=/var/local/buildx-cache --allow=fs.read=.. -f vars.hcl -f docker-bake.hcl "$BUILD" || {
  echo "Failed to build docker image $BUILD"
  exit 1
}

echo "Docker image $BUILD built successfully."
