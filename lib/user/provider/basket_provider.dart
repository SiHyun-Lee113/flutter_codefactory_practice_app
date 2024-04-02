import 'package:collection/collection.dart';
import 'package:flutter_codefactory_practice_app/product/model/product_model.dart';
import 'package:flutter_codefactory_practice_app/user/model/basket_item_model.dart';
import 'package:flutter_codefactory_practice_app/user/model/patch_basket_body.dart';
import 'package:flutter_codefactory_practice_app/user/repository/user_me_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final basketProvider =
    StateNotifierProvider<BasketProvider, List<BasketItemModel>>((ref) {
  final repo = ref.watch(userMeRepositoryProvider);

  return BasketProvider(repository: repo);
});

class BasketProvider extends StateNotifier<List<BasketItemModel>> {
  final UserMeRepository repository;

  BasketProvider({required this.repository}) : super([]);

  Future<void> patchBasket() async {
    await repository.patchBasket(
      body: PatchBasketBody(
        basket: state
            .map(
              (e) => PatchBasketBodyBasket(
                productId: e.product.id,
                count: e.count,
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> addToBasket({
    required ProductModel product,
  }) async {
    final exists =
        state.firstWhereOrNull((e) => e.product.id == product.id) != null;

    if (exists) {
      state = state
          .map(
            (e) => e.product.id == product.id
                ? e.copyWith(
                    count: e.count + 1,
                  )
                : e,
          )
          .toList();
    } else {
      state = [
        ...state,
        BasketItemModel(
          product: product,
          count: 1,
        ),
      ];
    }

    patchBasket();
  }

  Future<void> removeFromBasket({
    required ProductModel product,
    // true 시 count와 관계없이 삭제
    bool isDelete = false,
  }) async {
    // 1) 장바구니에 상품이 존재할 때,
    // 1-1) 상품의 카운트가 1보다 크면 -1
    // 1-2) 상품의 카운트가 1이면 삭제
    // 2) 상품이 존재하지 않을 때는 즉시 함수를 반환하고 아무것도 하지 않는다.

    final exists =
        state.firstWhereOrNull((e) => e.product.id == product.id) != null;

    if (!exists) {
      return;
    }

    final existingProduct = state.firstWhere((e) => e.product.id == product.id);

    if (existingProduct.count == 1 || isDelete) {
      state = state
          .where(
            (e) => e.product.id != existingProduct.product.id,
          )
          .toList();
    } else {
      state = state
          .map(
            (e) => e.product.id == product.id
                ? e.copyWith(
                    count: e.count - 1,
                  )
                : e,
          )
          .toList();
    }

    patchBasket();
  }
}
