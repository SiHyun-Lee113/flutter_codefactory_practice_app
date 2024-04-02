import 'package:flutter_codefactory_practice_app/common/model/cursor_pagination_model.dart';
import 'package:flutter_codefactory_practice_app/common/provider/pagination_provider.dart';
import 'package:flutter_codefactory_practice_app/order/model/order_model.dart';
import 'package:flutter_codefactory_practice_app/order/model/post_order_body.dart';
import 'package:flutter_codefactory_practice_app/order/repository/order_repository.dart';
import 'package:flutter_codefactory_practice_app/user/provider/basket_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final orderProvider =
    StateNotifierProvider<OrderStateNotifier, CursorPaginationBase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrderStateNotifier(
    ref: ref,
    repository: repository,
  );
});

class OrderStateNotifier
    extends PaginationProvider<OrderModel, OrderRepository> {
  final Ref ref;

  OrderStateNotifier({
    required this.ref,
    required super.repository,
  });

  // Future<void> patchBasket() async {
  //   await repository.patchBasket(
  //     body: PatchBasketBody(
  //       basket: state
  //           .map(
  //             (e) => PatchBasketBodyBasket(
  //               productId: e.product.id,
  //               count: e.count,
  //             ),
  //           )
  //           .toList(),
  //     ),
  //   );
  // }

  Future<bool> postOrder() async {
    try {
      final uuid = Uuid();

      final id = uuid.v4();

      final state = ref.read(basketProvider);

      final resp = await repository.postOrder(
        body: PostOrderBody(
          id: id,
          products: state
              .map(
                (e) => PostOrderBodyProduct(
                  productId: e.product.id,
                  count: e.count,
                ),
              )
              .toList(),
          totalPrice: state.fold(
            0,
            (p, n) => p + (n.count * n.product.price),
          ),
          createdAt: DateTime.now().toString(),
        ),
      );
    } catch (e, stack) {
      print(e);
      print(stack);
      return false;
    }
    return true;
  }
}
