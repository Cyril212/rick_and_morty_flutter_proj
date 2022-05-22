import 'package:dio/dio.dart';
import 'package:rick_and_morty_flutter_proj/mock/configs/base_mock_response_config.dart';

class MockInterceptor extends Interceptor {
  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) =>
      BaseMockResponseConfig.generate(url: options.uri)
          .dispatch()
          .then((response) => handler.resolve(response));
}
