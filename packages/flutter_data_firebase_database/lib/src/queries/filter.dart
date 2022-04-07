import 'dart:collection';
import 'dart:convert';

import 'package:meta/meta.dart';

/// A helper class to dynamically construct realtime database queries.
///
/// You can use one of the three factory constructors of this class,
/// [Filter.property], [Filter.key] or [Filter.value] to generate a
/// [FilterBuilder]. This will define how elements are order by the server
/// before filters are applied. You can then use the returned builder to apply
/// filters and finally build the actual filter that can be passed to API
/// methods.
///
/// **Important:** This does not affect the ordering of the received data -
/// after filters have been applied, the data can be returned by the server in
/// any order - if you only (or in addition) need to sort returned data, do so
/// on the client side.
class Filter extends UnmodifiableMapBase<String, String> {
  @internal
  static const orderByKey = 'orderBy';

  final Map<String, String> _data;

  Filter._(this._data);

  @override
  Iterable<String> get keys => _data.keys;

  @override
  String? operator [](covariant String key) => _data[key];

  /// Order elements by a certain child value before filtering them.
  ///
  /// When using `orderBy` with the name of a child key, data that contains the
  /// specified child key will be ordered as follows:
  ///
  /// 1. Children with a `null` value for the specified child key come first.
  /// 2. Children with a value of `false` for the specified child key come next.
  /// If multiple children have a value of `false`, they are sorted
  /// lexicographically by key.
  /// 3. Children with a value of `true` for the specified child key come next.
  /// If multiple children have a value of `true`, they are sorted
  /// lexicographically by key.
  /// 4.  Children with a numeric value come next, sorted in ascending order.
  /// If multiple children have the same numerical value for the specified
  /// child node, they are sorted by key.
  /// 5.  Strings come after numbers, and are sorted lexicographically in
  /// ascending order. If multiple children have the same value for the
  /// specified child node, they are ordered lexicographically by key.
  /// 6. Objects come last, and sorted lexicographically by key in ascending
  /// order.
  ///
  /// The filtered results are returned unordered. If the order of your data is
  /// important you should sort the results in your application after they are
  /// returned from Firebase.
  static FilterBuilder<T> property<T>(String property) =>
      FilterBuilder<T>._(property);

  /// Order elements by their key before filtering them.
  ///
  /// When using the `orderBy="$key"` parameter to sort your data, data will be
  /// returned in ascending order by key as follows. Keep in mind that keys can
  /// only be strings.
  ///
  /// 1. Children with a key that can be parsed as a 32-bit integer come first,
  /// sorted in ascending order.
  /// 2. Children with a string value as their key come next, sorted
  /// lexicographically in ascending order.
  static FilterBuilder<String> key() => FilterBuilder<String>._(r'$key');

  /// Order elements by their value before filtering them.
  ///
  /// When using the `orderBy="$value"` parameter to sort your data, children
  /// will be ordered by their value. The ordering criteria is the same as data
  /// ordered by a child key, except the value of the node is used instead of
  /// the value of a specified child key.
  static FilterBuilder<T> value<T>() => FilterBuilder<T>._(r'$value');
}

/// A helper class to build filter queries.
///
/// See [Filter] for more details.
class FilterBuilder<T> {
  final String _orderBy;
  final _queries = <String, String>{};

  FilterBuilder._(this._orderBy);

  /// Limits query results to the first [count] elements
  FilterBuilder<T> limitToFirst(int count) {
    _queries['limitToFirst'] = json.encode(count);
    return this;
  }

  /// Limits query results to the last [count] elements
  FilterBuilder<T> limitToLast(int count) {
    _queries['limitToLast'] = json.encode(count);
    return this;
  }

  /// Only returns results considered greater or equal to [value]
  FilterBuilder<T> startAt(T value) {
    _queries['startAt'] = json.encode(value);
    return this;
  }

  /// Only returns results considered less or equal to [value]
  FilterBuilder<T> endAt(T value) {
    _queries['endAt'] = json.encode(value);
    return this;
  }

  /// Only returns results considered equal to [value]
  FilterBuilder<T> equalTo(T value) {
    _queries['equalTo'] = json.encode(value);
    return this;
  }

  /// Generates the [Filter] that can be passed as params to the repository.
  Filter build() => Filter._(
        Map.unmodifiable(<String, String>{
          Filter.orderByKey: json.encode(_orderBy),
          ..._queries,
        }),
      );
}
