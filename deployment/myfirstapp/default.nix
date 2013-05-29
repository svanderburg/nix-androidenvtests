{androidenv, release ? false}:

androidenv.buildApp {
  name = "MyFirstApp-${if release then "release" else "debug"}";
  src = ../../src/myfirstapp;
  platformVersions = [ "16" ];
  useGoogleAPIs = true;
  
  release = release;
  keyStore = ./keystore;
  keyAlias = "myfirstapp";
  keyStorePassword = "mykeystore";
  keyAliasPassword = "myfirstapp";
}
