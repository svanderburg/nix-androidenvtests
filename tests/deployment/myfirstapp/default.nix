{androidenv, release ? false, platformVersion}:

androidenv.buildApp {
  name = "MyFirstApp-${if release then "release" else "debug"}";
  src = ../../src/myfirstapp;
  
  antFlags = "-Dtarget=android-${platformVersion}";
  platformVersions = [ platformVersion ];
  inherit release;
  keyStore = ./keystore;
  keyAlias = "myfirstapp";
  keyStorePassword = "mykeystore";
  keyAliasPassword = "myfirstapp";
}
