#!/usr/bin/env bash

# Check for Nix tools.
command -v nix-shell >/dev/null 2>&1 || {
  nix_profile="$HOME/.nix-profile/etc/profile.d/nix.sh"
  if [ -e "$nix_profile" ]; then
    source "$nix_profile"
  else
    >&2 echo "Failed to find 'nix-shell' on PATH or a Nix profile to load. Have you installed Nix?"
    exit 1  
  fi
}

nix-shell -p jq -p nixops --run "bash $(dirname "$0")/build.sh '$1'"
