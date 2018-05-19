{deployAndroidPackage, requireFile, lib, packages, toolsVersion, autopatchelf, makeWrapper, os, pkgs, pkgs_i686, postInstall ? ""}:

if (builtins.substring 0 2 toolsVersion) == "26" then import ./tools/26.nix {
  inherit deployAndroidPackage requireFile lib autopatchelf makeWrapper os pkgs pkgs_i686 postInstall;
} else import ./tools/25.nix {
  inherit deployAndroidPackage lib autopatchelf makeWrapper os pkgs pkgs_i686 postInstall;
  package = packages.tools."${toolsVersion}";
}
