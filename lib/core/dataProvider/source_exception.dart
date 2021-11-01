class SourceException {
  final Object? originalException;
  final int? httpStatusCode;

  /// SourceException initialization
  SourceException({
    required this.originalException,
    this.httpStatusCode,
  });
}