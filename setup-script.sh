#!/usr/bin/env sh

here=$(dirname "$0")

deployment="build-slave-vbox"
machine_name="build-slave"

get_abs_filename() {
  # $1 : relative filename
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}


if ! nixops info --no-eval -d "$deployment"; then
  echo "****** Deployment does not exist. Creating it now..."
  nixops create -d "$deployment" "$here/physical-vbox.nix"
fi

machine_state=$(nixops info --plain --no-eval -d "$deployment" | cut -s -f2)

if [ "$machine_state" == "up-to-date" ]; then
  echo "****** Build slave already up-to-date."
  nixops start -d "$deployment"  # just in case it's not running
else
  echo "****** Deploying build slave."
  nixops deploy -d "$deployment" --check
fi

ip=$(nixops info --plain --no-eval -d "$deployment" | cut -s -f6)
echo "****** >> Found IP of build slave: $ip"

private_key_file=$(get_abs_filename "${deployment}.id_rsa")

rm -f "$private_key_file" 
nixops export -d "$deployment" | jq ".[keys[0]].resources.\"$machine_name\".\"virtualbox.clientPrivateKey\"" --raw-output > "$private_key_file"
chmod 0400 "$private_key_file"
echo "****** >> Copied private SSH key to build-slave to $private_key_file"

conf_file=$(get_abs_filename "remote-systems.conf")
cat <<CONF > "$conf_file"
root@$ip x86_64-linux "$private_key_file" 1 1
CONF

echo "****** >> Wrote remote build configuration to $conf_file"
echo "****** >> export NIX_REMOTE_SYSTEMS=\"$conf_file\""
