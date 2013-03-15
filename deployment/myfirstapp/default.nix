{androidenv, release ? false}:

androidenv.buildApp {
  name = "MyFirstApp";
  src = ../../src/myfirstapp;
  platformVersions = [ "16" ];
  useGoogleAPIs = true;
  
  release = release;
  keyStore = ./keystore;
  keyAlias = "myfirstapp";
  keyStorePassword = "mykeystore";
  keyAliasPassword = "myfirstapp";
}
