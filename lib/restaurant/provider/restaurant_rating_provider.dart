import 'package:flutter_codefactory_practice_app/common/model/cursor_pagination_model.dart';
import 'package:flutter_codefactory_practice_app/common/provider/pagination_provider.dart';
import 'package:flutter_codefactory_practice_app/rating/model/rating_model.dart';
import 'package:flutter_codefactory_practice_app/restaurant/repository/restaurant_rating_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final restaurantRatingProvider = StateNotifierProvider.family<
    RestaurantRatingStateNotifier, CursorPaginationBase, String>((ref, id) {
  final repo = ref.watch(restaurantRatingRepositoryProvider(id));

  return RestaurantRatingStateNotifier(repository: repo);
});

class RestaurantRatingStateNotifier
    extends PaginationProvider<RatingModel, RestaurantRatingRepository> {
  RestaurantRatingStateNotifier({
    required super.repository,
  });
}
