import 'package:rick_and_morty_flutter_proj/core/dataProvider/main_data_provider.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/main_data_provider/data_request.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/requests/character_list_request.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character_list_response.dart';

class CharacterListSource extends DataSource<CharacterListResponse> {
  CharacterListSource(
      {
      MainDataProviderSource? sourceRegisteredTo,
      MockUpRequestOptions? mockUpRequestOptions,
      required String method,
      required CharacterListResponse? Function(Map<String, dynamic> json) processResponse})
      : super(
            source: MainDataProviderSource.httpClient,
            method: method,
            mockUpRequestOptions: mockUpRequestOptions,
            request: CharacterListRequest(),
            processResponse: processResponse);
}
