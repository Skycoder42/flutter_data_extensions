# flutter_data_sodium
[![CI/CD for flutter_data_sodium](https://github.com/Skycoder42/flutter_data_extensions/actions/workflows/flutter_data_sodium.yaml/badge.svg)](https://github.com/Skycoder42/flutter_data_extensions/actions/workflows/flutter_data_sodium.yaml)
[![Pub Version](https://img.shields.io/pub/v/flutter_data_sodium)](https://pub.dev/packages/flutter_data_sodium)

An extension package to `flutter_data` that adds End-To-End-Encryption to all requests.

## Table of Contents

## Features
- Implements a `RemoteAdapter` that encrypts all request data and decrypts all response data
  - Uses [libsodium](https://libsodium.gitbook.io/doc/) with the [sodium](https://pub.dev/packages/sodium) package under the hood
  - Data is encrypted with unique keys for each repository that are automatically rotated every 30 days
  - Uses Authenticated symmetric encryption to prevent modification of data
- All encryption is based on a single master key that is unique per user
- Also providers methods to use sodium for encrypting the local hive boxes

## Installation
Simply add `flutter_data_sodium` to your `pubspec.yaml` and run `dart pub get` (or `flutter pub get`).
You should also add `flutter_data` to your dependencies. If you are build a flutter app, you should add `sodium_libs` as
well, or `sodium` for plain dart applications.

## Usage
Since this is only an extension to flutter_data, you should refer to
[flutter_data quick start guide](https://flutterdata.dev/docs/quickstart/).

After finishing that guide, you can start with encryption by following the next steps.

First, you need to create your own key manager. The easiest way is to use the `PassphraseBasedKeyManager` together with
the `ParallelMasterKeyComputation` mixin to get a smooth user experience.

```dart
import 'package:flutter/foundation.dart' as ff;
import 'package:sodium_libs/sodium_libs.dart';

class MyKeyManager extends PassphraseBasedKeyManager
    with ParallelMasterKeyComputation {
  MyKeyManager(Sodium sodium) : super(sodium: sodium);

  @override
  CreateSodiumFn get sodiumFactory => SodiumInit.init;

  @override
  Future<R> compute<Q, R>(ComputeCallback<Q, R> callback, Q message) =>
      ff.compute(
        callback,
        message,
        debugLabel: '$MyKeyManager.compute',
      );

  @override
  FutureOr<MasterKeyComponents> loadMasterKeyComponents(int saltBytes) {
    final password = await letUserInputPassword();
    final salt = await generateSaltForUser(saltBytes);
    return MasterKeyComponents(
      password: password,
      salt: salt
    );
  }
}
```

The `letUserInputPassword` and `generateSaltForUser` methods are dummy methods. Here you will have to implement your own
logic to get both, a passphrase of the user and some kind of salt that is unique for the user (but must never change).

To now add the encryption, you need to let your `ApplicationAdapter` be a mixin on the `SodiumRemoteAdapter`. The
following sample assumes you are build a flutter app and have already add the `sodium_libs` package as dependency.

```dart
import 'package:sodium_libs/sodium_libs.dart';

mixin ApplicationAdapter<T extends DataModel<T>> on SodiumRemoteAdapter<T> {
  @override
  String get baseUrl => 'https://my-json-server.typicode.com/flutterdata/demo/';

  @override
  late final Sodium sodium;

  @override
  late final keyManager = KeyManager(sodium);

  @override
  @mustCallSuper
  Future<void> onInitialized() async {
    await super.onInitialized();
    sodium = await SodiumInit.init();
  }
}
```

And thats it! With that, all your data will get encrypted. The data can also
be synced between different devices, as long as they all use the same master
key (in this example: The same passphrase and salt).

## Documentation
The documentation is available at https://pub.dev/documentation/flutter_data_sodium/latest/.
A full example can be found at https://pub.dev/packages/flutter_data_sodium/example.
