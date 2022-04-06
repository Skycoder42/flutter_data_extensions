// coverage:ignore-file

class TransactionRejected implements Exception {
  final Object id;

  final String _message;

  TransactionRejected._(this.id, this._message);

  TransactionRejected.remote(Object id)
      : this._(
          id,
          'Transaction on data with id "$id" was rejected by the server.',
        );

  TransactionRejected.invalidId(Object id)
      : this._(
          id,
          'The updated data must have the same id as the transaction ($id).',
        );

  @override
  String toString() => _message;
}
