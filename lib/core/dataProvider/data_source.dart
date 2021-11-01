import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/abstract_manager.dart';

import 'model/request_data_model.dart';
import 'model/response_data_model.dart';
import 'source_exception.dart';

class DataSource<T extends RequestDataModel, R extends ResponseDataModel> {

  /// The identity of this query within the [Manager]
  final String queryId;

  /// Request of given source
  final T requestDataModel;

  /// Process json to serialize it to object
  final R Function(Map<String, dynamic> json) processResponse;

  /// Response object
  R? response;

  /// Error object to describe negative use cases
  SourceException? error;

  /// Init
  DataSource(this.requestDataModel, this.processResponse, AbstractManager manager, {this.error}) : queryId = manager.generateDataSourceId().toString();
}
