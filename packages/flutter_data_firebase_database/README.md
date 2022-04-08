# flutter_data_firebase_database
An extension package to `flutter_data` that adds a remote adapter to connect with the firebase realtime database.

## Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
  * [1. Let your ApplicationAdapter "extend" the firebase adapter](#1-let-your-applicationadapter-extend-the-firebase-adapter)
  * [2. Adjust your DataModel](#2-adjust-your-datamodel)
- [Documentation](#documentation)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

## Features
- Implements a `RemoteAdapter` that is able to read and write data from and to a firebase realtime database.
  - Adds the background logic needed for the standard findAll/One, save, delete, ...
- Adds new `streamAll` and `streamOne` methods that can be used to stream realtime changes of data on the server
- Adds a new `transaction` method that can be used to run atomic transactions on the server.
- Adds some value classes for server values:
  - `ServerTimestamp`: A wrapper around `DateTime` that can be set to the current server timestamp
  - `ServerIncrementable`: A wrapper around `num` that allows you to specified increments that are applied to the
  current server value.

## Installation
Simply add `flutter_data_firebase_database` to your `pubspec.yaml` and run `dart pub get` (or `flutter pub get`).
You should also add `flutter_data` to your dependencies.

## Usage
Since this is only an extension to flutter_data, you should refer to
[flutter_data quick start guide](https://flutterdata.dev/docs/quickstart/). However, there are a few changes you
need to do in addition to that tutorial in order to connect with the database. The are as follows:

1. [Let your ApplicationAdapter extend the firebase adapter](#1-let-your-applicationadapter-extend-the-firebase-adapter)
2. [Adjust your DataModel](#2-adjust-your-datamodel)

### 1. Let your ApplicationAdapter extend the firebase adapter
In your `ApplicationAdapter`, you must mixin on the `FirebaseDatabaseAdapter` instead of the `RemoteAdapter`. Also,
besides of the `baseUrl`, you must also provide an `idToken`:

```dart
mixin ApplicationAdapter<T extends DataModel<T>> on FirebaseDatabaseAdapter<T> {
  // you can get the base url of your firebase application from the `databaseURL` value in the firebase config
  @override
  String get baseUrl => '<your-firebase-database-url>/path/in/database';

  @override
  String get idToken => '<id-token-of-the-currently-logged-in-user>';
}
```

### 2. Adjust your DataModel
Due to limitations of the dart language, even though your `ApplicationAdapter` is based on the `FirebaseDatabaseAdapter`
it does not get added to the models repository automatically. Instead, you have to specify both. Also, the adapter
requires the `id` of all models to be a string, as the realtime database only works with string keys.

```dart
@JsonSerializable()
// use both adapters
@DataRepository([FirebaseDatabaseAdapter, ApplicationAdapter])
class Task with DataModel<Task> {
  // this must ALWAYS be a String
  @override
  final String? id;

  final String title;
  final bool completed;

  Task({this.id, required this.title, this.completed = false});
}
```

And thats it! You can now use the adapter. If you need to use the added methods like `streamAll` or `transaction`, you
can get a reference to the firebase adapter via `myRepository.firebaseDatabaseAdapter`.

## Documentation
The documentation is available at https://pub.dev/documentation/flutter_data_firebase_database/latest/.
A full example can be found at https://pub.dev/packages/flutter_data_firebase_database/example.
