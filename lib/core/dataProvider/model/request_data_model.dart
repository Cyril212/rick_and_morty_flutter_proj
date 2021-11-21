abstract class RequestDataModel {
  String method;
  final Map<String, String>? headers;

  RequestDataModel(this.method, this.headers);
  /// Covert the object into JSON map
  Map<String, dynamic> toJson();
}
