# This expression is used to produce the release artifacts.
# To build for a particular board, please refer to `default.nix` instead.

# This is a "clean" Nixpkgs. No overlays have been applied yet.
{ pkgs ? import ./nixpkgs.nix {} }:

let
  inherit (pkgs.lib)
    concatStringsSep
    filter
  ;

  # We're slightly cheating here
  version =
    let info = (import ./modules/tow-boot/identity.nix).Tow-Boot; in
    "${info.releaseNumber}${info.releaseIdentifier}"
  ;

  release-tools = import ./support/nix/release-tools.nix { inherit pkgs; };
in
  pkgs.runCommandNoCC "Tow-Boot.release.${version}" {
    inherit version;
  } ''
    mkdir -p $out
    PS4=" $ "

    ${concatStringsSep "\n" (builtins.map (eval: ''
      (
      echo " :: Packaging ${eval.config.device.identifier}"
      cp ${eval.build.archive} $out/${eval.build.archive.name}
      )
    '') release-tools.releasedDevicesEvaluations)}
  ''
