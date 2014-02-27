{androidenv, myfirstapp, platformVersion, abiVersion}:

androidenv.emulateApp {
  name = "emulate-${myfirstapp.name}";
  app = myfirstapp;
  inherit platformVersion abiVersion;
  package = "com.example.my.first.app";
  activity = ".MainActivity";
  
  # API-levels 15 and onwards support GPU acceleration
  enableGPU = (builtins.compareVersions platformVersion "14") == 1; 
}
