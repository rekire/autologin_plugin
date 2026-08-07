#!/bin/bash
cd ../autologin
echo autologin:
dart pub get
cd ../autologin_android
echo autologin_android:
dart pub get
cd ../autologin_darwin
echo autologin_darwin:
dart pub get
cd ../autologin_linux
echo autologin_linux:
dart pub get
cd ../autologin_platform_interface
echo autologin_platform_interface:
dart pub get
cd ../autologin_test_utils
echo autologin_test_utils:
dart pub get
cd ../autologin_web
echo autologin_web:
dart pub get
cd ../autologin_windows
echo autologin_windows:
dart pub get
