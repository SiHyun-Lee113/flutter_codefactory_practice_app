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
    // 현재까지는 요청을 먼저 보내고 응답이 오면 캐시를 업데이트를 했음.
    // 만약 장바구니 추가 정보를 서버에 보내고 상태를 업데이트하면 await 시간 동안 앱이 멈춰있는 듯한 느낌을 사용자는 받을 수 있다.
    // 그렇다면 사용자가 앱이 빠르다고 느끼게 하기 위해서 상태를 먼저 업데이트 하고 서버 요청을 그 다음 순서로 한다면 사용자는 바로 앱의 변화(장바구나에 물건이 들어갔구나)를 바로 느낄 수 있어 앱이 빠르다고 느낄 수 있다.
    // 이제 기능적인 측면에서 고려해 보아야 하는 것이 만약 상태를 바꿨는데 서버 요청에서 에러가 나서 장바구니에 추가가 안됬다고 가정하면,
    // 서버에 문제가 있지 않는 이상 그럴 경우는 없지만 만약 그런 일이 발생한다 하더라도 사용자는 결제 창에서 한번더
    // 장바구니 목록을 확인하기 때문에 문제가 생기더라도 큰 문제가 아닐 수 있다.
    // 이를 Optimistic Reponse라고 한다. 응답이 성공할 것이라고 가정하고 상태를 먼저 업데이트함으로써 UX를 향상 시키는 방법이다.
    // 1) 아직 장바구니에 해당되는 상품이 없다면 장바구니에 상품을 추가.
    // 2) 이미 들어있다면 장바구니에 있는 값에 + 1

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
