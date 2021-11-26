import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/base_data_client.dart';

abstract class RequestDataModel {
  String method;
  final Map<String, String>? headers;

  FetchPolicy fetchPolicy;

  RequestDataModel(this.method, this.headers,this.fetchPolicy);
  /// Covert the object into JSON map
  Map<String, dynamic> toJson();
}
