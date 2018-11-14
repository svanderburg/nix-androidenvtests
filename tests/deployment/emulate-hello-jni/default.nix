{androidenv, hello_jni, platformVersion, abiVersion}:

androidenv.emulateApp {
  name = "emulate-${hello_jni.name}";
  app = hello_jni;
  inherit platformVersion abiVersion;
  package = "com.example.hellojni";
  activity = ".HelloJni";
  systemImageType = "default";

  # API-levels 15 and onwards support GPU acceleration
  enableGPU = (builtins.compareVersions platformVersion "14") == 1; 
}
