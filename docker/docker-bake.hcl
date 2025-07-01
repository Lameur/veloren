group "all" {
	targets = ["auth","server-cli"]
}

target "docker-metadata-action" {}

target "_common" {
	# Common settings for all targets
	inherits = ["docker-metadata-action"]
	cache-to = ["type=local,dest=/var/local/buildx-cache"]
	cache-from = ["type=local,src=/var/local/buildx-cache"]
}

target "base" {
	context = ".."
	dockerfile = "./docker/base.Dockerfile"
}

target "auth" {
	inherits = ["_common"]
	context = "../auth"
	contexts = {
		"src" = ""
		"base" = "target:base"
	}
	dockerfile = "../docker/auth.Dockerfile"
	tags = ["auth:latest"]
  # platforms = ["linux/amd64", "linux/arm64"]
}


target "server-cli" {
	inherits = ["_common"]
	context = "../veloren"
	contexts = {
		"src" = "../veloren"
		"base" = "target:base"
	}
	dockerfile = "../docker/server-cli.Dockerfile"
	tags = tag("latest")
  # platforms = ["linux/amd64", "linux/arm64"]
  args = {
  	"GIT_DATETIME" = "$(git log -1 --format=%cd)"
  }
}
