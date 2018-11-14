{androidenv, release ? false, platformVersion}:

androidenv.buildApp {
  name = "hello-jni-${if release then "release" else "debug"}";
  src = ../../src/hello-jni;

  antFlags = "-Dtarget=android-${platformVersion}";
  inherit release;
  keyStore = ./keystore;
  keyAlias = "myfirstapp";
  keyStorePassword = "mykeystore";
  keyAliasPassword = "myfirstapp";

  platformVersions = [ platformVersion ];
  includeNDK = true;
}
