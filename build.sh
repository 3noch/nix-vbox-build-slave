#!/usr/bin/env bash

set -e

# Expect a desired path to the conf file to be provided.
conf_file="$1"
conf_dir=$(dirname "$conf_file")

here=$(dirname "$0")

deployment="build-slave-vbox"
machine_name="build-slave"

private_key_file="$conf_dir/nix-${deployment}.ssh-id"

export NIX_PATH=nixpkgs=https://nixos.org/channels/nixos-16.09/nixexprs.tar.xz  # Use stable channel
export NIXOPS_DEPLOYMENT="$deployment"

get_deployment_ip() {
  nixops info --plain --no-eval | cut -s -f6
}

if nixops info --no-eval; then
  # Deployment exists, but reset IP addresses in ~/.ssh/known_hosts: https://github.com/NixOS/nixops/issues/286
  echo "Deployment already created."
  ip="$(get_deployment_ip)"

  # Do a sanity check to make sure the IP is valid before touching ~/.ssh/known_hosts.
  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "Removing old IP $ip from ~/.ssh/known_hosts"
    sed -i "/$ip/d" "$HOME/.ssh/known_hosts"
  fi
else
  echo "****** Deployment does not exist. Creating it now..."
  nixops create "$here/physical-vbox.nix"
fi

echo "****** Deploying build slave."
nixops deploy --check

ip=$(get_deployment_ip)
echo "****** >> Found IP of build slave: $ip"


# Extract the SSH private key from the deployment state.
rm -f "$private_key_file"
nixops export | jq ".[keys[0]].resources.\"$machine_name\".\"virtualbox.clientPrivateKey\"" --raw-output > "$private_key_file"
chmod 400 "$private_key_file"
echo "****** >> Copied private SSH key to build-slave to $private_key_file"

cat <<CONF > "$conf_file"
root@$ip x86_64-linux "$private_key_file" 1 1
CONF

echo "****** >> Wrote remote build configuration to $conf_file"
echo "****** >> export NIX_REMOTE_SYSTEMS=\"$conf_file\""
