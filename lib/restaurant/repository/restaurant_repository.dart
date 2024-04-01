import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_codefactory_practice_app/common/const/data.dart';
import 'package:flutter_codefactory_practice_app/common/dio/dio.dart';
import 'package:flutter_codefactory_practice_app/common/model/cursor_pagination_model.dart';
import 'package:flutter_codefactory_practice_app/common/model/pagination_params.dart';
import 'package:flutter_codefactory_practice_app/common/repository/base_pagination_repositpory.dart';
import 'package:flutter_codefactory_practice_app/restaurant/model/restaurant_detail_model.dart';
import 'package:flutter_codefactory_practice_app/restaurant/model/restaurant_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'restaurant_repository.g.dart';

final restaurantRepositoryProvier = Provider<RestaurantRepository>((ref) {
  final dio = ref.watch(dioProvider);

  final repository = RestaurantRepository(
    dio,
    baseUrl: 'http://$ip/restaurant',
  );

  return repository;
});

@RestApi()
abstract class RestaurantRepository
    implements IBasePaginationRepository<RestaurantModel> {
  // baseUrl = http://$ip/restaurant
  factory RestaurantRepository(Dio dio, {String baseUrl}) =
      _RestaurantRepository;

  @override
  @GET('/')
  @Headers({
    'accessToken': 'true',
  })
  Future<CursorPagination<RestaurantModel>> paginate({
    @Queries() PaginationParams? params = const PaginationParams(),
  });

  @GET('/{id}')
  @Headers({
    'accessToken': 'true',
  })
  Future<RestaurantDetailModel> getRestaurantDetail({
    @Path('id') required String sid,
  });
}
