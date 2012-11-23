Nix Android tests
=================
This package includes a number of testcases for the `androidenv.buildApp {}`
function that can be used with the [Nix package manager](http://nixos.org/nix),
capable of producing Android APKs from Android source code projects.

This package includes the example application described in the Android tutorial:
[http://developer.android.com/training/basics/firstapp/index.html](http://developer.android.com/training/basics/firstapp/index.html)

According to the content license of the tutorial the example source code is
Apache 2.0 licensed:

    "The documentation content on this site is made available to you as part of
    the Android Open Source Project. This documentation, including any code shown
    in it, is licensed under the Apache 2.0 license, the preferred license for
    all parts of the of the Android Open Source Project."

The remaining content of this package is covered by the MIT license.

Usage
=====
In order to run the examples, you must have the Nix package manager installed
and a copy of [Nixpkgs](http://nixos.org/nixpkgs). Consult the Nix manual for
more details on this.

Then the APK can be built by entering the `deployment/` directory and by
running:

    $ nix-build -A myfirstapp

The above command downloads all required dependencies, including the Android SDK
and the required optional features, and produces the resulting APK in `result/`

We can also automatically start an emulator instance running the app:

    $ nix-build -A emulate_myfirstapp
    $ ./result/run-test-emulator

The above instructions produce a shell script taking care of the starting
process, which is then started from the command-line. The result is an emulator
instance in which the tutorial app is automatically started.
