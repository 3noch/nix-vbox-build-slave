let
  pkgsNative = import <nixpkgs> { system = builtins.currentSystem; };
  unpackImage = name: sha256:
    pkgsNative.runCommand
      "virtualbox-nixops-${name}.vmdk"
      { preferLocalBuild = true; allowSubstitutes = false; }
      ''
        xz -d < ${pkgsNative.fetchurl {
          url = "http://nixos.org/releases/nixos/virtualbox-nixops-images/virtualbox-nixops-${name}.vmdk.xz";
          inherit sha256;
        }} > $out
      '';

  baseImage = unpackImage
    "16.09.877.5b08a40"
    "c20ee9ff0f58b10cd2b1e52411a56a862c8eaecddbbddd337ae0cca888f6727f";

  machineTemplate = memoryGb: {
    deployment.targetEnv = "virtualbox";
    deployment.virtualbox = {
      memorySize = 1024 * memoryGb;
      disks.disk1.baseImage = baseImage;
    };
  };
in {
  build-slave = machineTemplate 1;
}
