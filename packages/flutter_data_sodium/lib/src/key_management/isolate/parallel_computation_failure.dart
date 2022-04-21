// coverage:ignore-file

class ParallelComputationFailure implements Exception {
  final String originalExceptionMessage;

  ParallelComputationFailure(this.originalExceptionMessage);

  @override
  String toString() => originalExceptionMessage;
}
