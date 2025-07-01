variable "BASE_IMAGE" {
	default = "nixos/nix"


  # First validation block: Ensure the variable is not empty
  validation {
    condition = BASE_IMAGE != ""
    error_message = "The variable 'BASE_IMAGE' must not be empty."
  }

	# Second validation block: Ensure the value contains only alphanumeric characters
  validation {
    # BASE_IMAGE and the regex match must be identical:
    condition = BASE_IMAGE == regex("[a-z]+[/][a-z]+", BASE_IMAGE)
    error_message = "The variable 'BASE_IMAGE' can only contain letters and numbers."
  }
}

variable "BASE_VERSION" {
  default = "latest"
  # First validation block: Ensure the variable is not empty
  validation {
    condition = BASE_IMAGE != ""
    error_message = "The variable 'BASE_VERSION' must not be empty."
  }
  validation {
    # BASE_VERSION and the regex match must be identical:
    condition = BASE_VERSION == regex("[a-zA-Z0-9]+", BASE_VERSION)
    error_message = "The variable 'BASE_VERSION' can only contain letters and numbers."
  }
}


variable "TAG" {
  default = "latest"
  # First validation block: Ensure the variable is not empty
  validation {
    condition = TAG != ""
    error_message = "The variable 'TAG' must not be empty."
  }
  validation {
    # TAG and the regex match must be identical:
    condition = TAG == regex("[a-zA-Z0-9]+", TAG)
    error_message = "The variable 'TAG' can only contain letters and numbers."
  }
}

variable "REPO" {
	default = "lameur/veloren"
}

function "tag" {
	params = [tag]
	result = ["${REPO}:${tag}"]
}