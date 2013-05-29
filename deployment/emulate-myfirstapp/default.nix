{androidenv, myfirstapp}:

androidenv.emulateApp {
  name = "emulate-${myfirstapp.name}";
  app = myfirstapp;
  platformVersion = "16";
  useGoogleAPIs = true;
  package = "com.example.my.first.app";
  activity = "MainActivity";
}
