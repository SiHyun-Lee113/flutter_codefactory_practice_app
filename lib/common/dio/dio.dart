import 'package:dio/dio.dart';
import 'package:flutter_codefactory_practice_app/common/const/data.dart';
import 'package:flutter_codefactory_practice_app/common/sercure_storage/secure_stroage.dart';
import 'package:flutter_codefactory_practice_app/user/provider/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  final storage = ref.watch(secureStorageProvider);

  dio.interceptors.add(CustomInterceptor(
    storage: storage,
    ref: ref,
  ));

  return dio;
});

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final Ref ref;

  CustomInterceptor({
    required this.storage,
    required this.ref,
  });

  // 1) 요청을 보낼떄
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print('[RES] [${options.method}] ${options.uri}');
    if (options.headers['accessToken'] == 'true') {
      options.headers.remove('accessToken');

      final token = await storage.read(key: ACCESS_TOKEN_KEY);

      options.headers.addAll({
        'authorization': 'Bearer $token',
      });
    }

    if (options.headers['refreshToken'] == 'true') {
      options.headers.remove('refreshToken');

      final token = await storage.read(key: REFRESH_TOKEN_KEY);

      options.headers.addAll({
        'authorization': 'Bearer $token',
      });
    }

    super.onRequest(options, handler);
  }

  // 2) 응답을 받을때
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        '[REP] [${response.requestOptions.method}] ${response.requestOptions.uri}');
    return super.onResponse(response, handler);
  }

  // 3) 에러가 났을떄
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri}');

    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    if (refreshToken == null) {
      return handler.reject(err);
    }

    final isStatus401 = err.response?.statusCode == 401;
    final isPathRefresh = err.requestOptions.path == '/auth/token';

    try {
      if (isStatus401 && !isPathRefresh) {
        final dio = Dio();

        final resp = await dio.post('http://$ip/auth/token',
            options: Options(headers: {
              'authorization': 'Bearer $refreshToken',
            }));

        final accessToken = resp.data['accessToken'];
        final options = err.requestOptions;

        options.headers.addAll({
          'authorization': 'Bearer $accessToken',
        });

        await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);
        final response = await dio.fetch(options);

        return handler.resolve(response);
      }
    } on DioException catch (e) {
      // CircularDependencyError
      // A, B
      // A -> B의 친구, B -> A의 친구 => A-> B -> A -> B -> ...
      // ref.read(userMeProvider.notifier).logout();
      ref.read(authProvider.notifier).logout();

      return handler.reject(e);
    }

    return handler.reject(err);
  }
}
