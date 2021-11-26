import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/base_data_client.dart';

abstract class RequestDataModel {
  String method;
  final Map<String, String>? headers;

  FetchPolicy fetchPolicy;

  RequestDataModel(this.method, this.headers, this.fetchPolicy);

  /// Covert the object into JSON map
  Map<String, dynamic> toJson();

  @protected
  Map<String, dynamic> get resolveQuery;

  bool isRequestEqual(RequestDataModel request) => request.method == method && resolveQuery.toString() == request.resolveQuery.toString();
}
