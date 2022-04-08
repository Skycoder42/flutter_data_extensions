// coverage:ignore-file

/// A base class for [Exception]s that can be thrown when committing a
/// transaction.
abstract class TransactionException implements Exception {
  /// The id of the dataset for which the transaction failed.
  final String id;

  /// The error message of this exception.
  final String message;

  TransactionException._(this.id, this.message);

  @override
  String toString() => message;
}

/// An [Exception] thrown if a transaction failed to commit because the data has
/// been changed on the server since the beginning of the transaction and was
/// thus rejected.
class TransactionRejected extends TransactionException {
  /// Default Constructor.
  TransactionRejected(String id)
      : super._(
          id,
          'Transaction on data with id "$id" was rejected by the server.',
        );
}

/// An [Exception] thrown if a transaction failed to commit because the data
/// returned by the transaction function is invalid. This can for example
/// happen, if the id of the returned data does not match the transaction id.
class TransactionInvalid extends TransactionException {
  /// Creates an [TransactionInvalid] exception for transaction with invalid id.
  TransactionInvalid.invalidId(String id)
      : super._(
          id,
          'The updated data must have the same id as the transaction ($id).',
        );
}
