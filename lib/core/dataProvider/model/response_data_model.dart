import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';

import '../source_exception.dart';
import 'data_model.dart';

class ResponseDataModel extends DataModel {
  ResponseDataModel.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  @override
  Map<String, dynamic> toJson() => {};

  /// Error object to describe negative use cases
  SourceException? error;

  ResponseDataModel.error(this.error) :  super.fromJson({});
}
