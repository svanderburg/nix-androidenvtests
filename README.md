Nix Android tests
=================
This package includes a number of testcases for the `androidenv.buildApp {}`
function that can be used with the [Nix package manager](http://nixos.org/nix),
capable of producing Android APKs from Android source code projects and
`androidenv.emulateApp {}` capable of generating scripts spawning emulator
instances.

This package includes the example application described in the Android tutorial:
[http://developer.android.com/training/basics/firstapp/index.html](http://developer.android.com/training/basics/firstapp/index.html)

According to the content license of the tutorial the example source code is
Apache 2.0 licensed:

    "The documentation content on this site is made available to you as part of
    the Android Open Source Project. This documentation, including any code shown
    in it, is licensed under the Apache 2.0 license, the preferred license for
    all parts of the of the Android Open Source Project."

The remaining content of this package is covered by the MIT license.

Prerequisites
=============
In order to run the examples, you must have the [Nix package manager](http://nixos.org/nix)
installed and a copy of [Nixpkgs](http://nixos.org/nixpkgs). Consult the Nix
manual for more details on this.

Usage
=====
The `default.nix` expression inside the `deployment/` folder contains the
composition expression for the example app. This expression can be used to build
an App for a specific Android revision and to generate scripts spawning emulator
instances.

By default it is configured to only build and emulate for Android API-level 16
(which corresponds to the Android 4.1 platform) using the `armeabi-v7a` ABI which
is most commonly used by Android devices, such as my phone.

Building the example App
------------------------
For example, to build a debug version of the test app APK for API-level 16, we
can run:

    $ nix-build -A myfirstapp_debug.build_16

We can also build a release version of the same APK that is signed with a key.
This repository contains a pre-generated keystore to accomplish that goal:

    $ nix-build -A myfirstapp_release.build_16

If it is desired to replace the pre generated keystore, you can adapt and run the
`generatekeystore.sh` script stored in the `deployment/myfirstapp` folder.

The above commands downloads all required dependencies including the Android SDK
and the required optional features, and produces the resulting APK in `result/`

Emulating the example App
-------------------------
We can also automatically generate a script starting an emulator instance
running the app. The following instruction builds an App for Android API-level 16,
generates a script launching an emulator with a Android API-level 16 system-image
that uses the `armeabi-v7a` ABI:

    $ nix-build -A emulate_myfirstapp_debug.build_16.emulate_16.armeabi-v7a
    $ ./result/run-test-emulator

The generated shell script takes care of performing all steps of the starting
process. The result is an emulator instance in which the tutorial app is
automatically started.

Configuring the compositions
----------------------------
To support more API-levels and ABIs, the parameters of the composition function
must be altered.

The `buildPlatformVersions` parameter is a list of strings which specifies
against which platform API-levels the App has to be built. The
`emulatePlatformVersions` is used to specify for which API-level system images we
want to create emulator instances. The `abiVersions` parameter is used to specify
for which ABIs we want create emulator instances.

The composition expression automatically generates cartesian products for these
values.

For example, by running the following command-line instruction:

    $ nix-build --arg buildPlatformVersions '[ "16" "17" ]' \
      --arg emulatePlatformVersions '[ "16 " 17" ]' \
      --arg abiVersions '[ "armeabi-v7a" "x86" ]' \
      -A emulate_myfirstapp_release.build_16.emulate_17.x86

The cartesian product of build and emulator instances is created taking the three
dimensions into account. This allows us to (for example) build the App against
the API-level 16 platform API, emulate on an API-level 17 system image using the
`x86` ABI, which emulates much more efficiently on `x86` machines, because
hardware virtualisation features (such as [KVM](http://www.linux-kvm.org)) can
be used.

Apart from specifying these dimensions through the command line, the composition
expression can also be used together with [Hydra](http://nixos.org/hydra), the
Nix-based continuous integration server, allowing it to pass these parameters
through its web interface. Hydra will build all the variants inside the
composition automatically.
