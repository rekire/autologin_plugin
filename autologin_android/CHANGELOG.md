## 1.0.1

* Add API to delete saved autologin tokens

## 1.0.0

* First official stable version
* Improved documentation to have a full documentation coverage

## 0.1.1

* Extend the documentation

## 0.1.0

* Add Linux support
* Duplicating (test) code
* Use the same method channel structure for all platforms with maps instead of
  JSON
* Setting everything up for publishing on pub.dev

## 0.0.6

* Fix build issues on Android
* Migrate to plugins block

## 0.0.5

* Migrated to federated plugin structure
* Migrated on Android to the CredentialManager API
* Added on Android zero touch login options by using the BlockManager to sync a
  login token across all (Google PlayService compatible) devices of a user
* Add MacOS support
* Use the KeyValueStore to sync login tokens cross iOS and MacOS
* Fixed loading credentials on iOS
* Added tons of tests and CI improvements heavily inspired by
  very_good_flutter_plugin
* Add editor config for better common formatting
