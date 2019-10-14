{deployAndroidPackage, lib, package, os, type}:

deployAndroidPackage {
  inherit os package;

  # Patch 'google_apis' system images so they're recognized by the sdk.
  # Without this, `android list targets` shows 'Tag/ABIs : no ABIs' instead
  # of 'Tag/ABIs : google_apis*/*' and the emulator fails with an ABI-related
  # error.
  patchInstructions = lib.optionalString (lib.hasPrefix "google_apis" type) ''
    sed -i '/^Addon.Vendor/d' source.properties
  '';
}
