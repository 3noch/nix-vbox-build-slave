Quickly Create a VirtualBox Build-Slave for Nix
===============================================

This repository provides a script that can be used to very easily create a [NixOS](https://nixos.org/) build slave for your needs. This is extremely useful where you're trying to deploy to a NixOS system from a non-NixOS host (e.g. using [NixOps](https://nixos.org/nixops/) on macOS).

**Prerequisites:** You are not running on Windows and have [VirtualBox](https://www.virtualbox.org/) installed.

Run `. ./setup` to setup your current shell. This will do the following:

  1. Create a `nixops` VirtualBox deployment for the build-slave.
  2. Deploy the build-slave.
  3. Create a `remote-systems.conf` file that tells nix how to SSH into this machine.
  4. Configure `NIX_REMOTE_SYSTEMS` to use this `remote-systems.conf`.

After running this, you should be able to use `nixops` as normal and it will use your build slave.

To shut-down the build-slave, run `. ./shutdown` which will turn off the VM and unset the environment variables.
