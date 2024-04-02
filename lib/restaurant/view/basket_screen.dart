import 'package:flutter/material.dart';
import 'package:flutter_codefactory_practice_app/common/const/colors.dart';
import 'package:flutter_codefactory_practice_app/common/layout/default_layout.dart';
import 'package:flutter_codefactory_practice_app/order/provider/order_provider.dart';
import 'package:flutter_codefactory_practice_app/order/view/order_done_screen.dart';
import 'package:flutter_codefactory_practice_app/product/component/product_card.dart';
import 'package:flutter_codefactory_practice_app/user/provider/basket_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BasketScreen extends ConsumerWidget {
  static String get routeName => 'basket';

  const BasketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basket = ref.watch(basketProvider);

    if (basket.isEmpty) {
      return DefaultLayout(
        title: '장바구니',
        child: Center(
          child: Text(
            '장바구니가 비어있습니다.',
          ),
        ),
      );
    }

    final int productsPrice = basket.fold(
      0,
      (p, n) => p + (n.product.price * n.count),
    );
    final int deliverPee = basket.first.product.restaurant.deliveryFee;
    final int totalPrice = productsPrice + deliverPee;
    return DefaultLayout(
      title: '장바구니',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (_, index) {
                    return const Divider(height: 32.0);
                  },
                  itemBuilder: (_, index) {
                    final model = basket[index];
                    return ProductCard.fromProductModel(
                      model: model.product,
                      onAdd: () {
                        ref.read(basketProvider.notifier).addToBasket(
                              product: model.product,
                            );
                      },
                      onSubtract: () {
                        ref.read(basketProvider.notifier).removeFromBasket(
                              product: model.product,
                            );
                      },
                    );
                  },
                  itemCount: basket.length,
                ),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '장바구니 금액',
                        style: TextStyle(
                          color: BODY_TEXT_COLOR,
                        ),
                      ),
                      Text(
                        '₩$productsPrice',
                      ),
                    ],
                  ),
                  if (basket.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '배달비',
                          style: TextStyle(
                            color: BODY_TEXT_COLOR,
                          ),
                        ),
                        Text(
                          '₩$deliverPee',
                        )
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '총액',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '₩$totalPrice',
                      )
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final resp =
                            await ref.read(orderProvider.notifier).postOrder();
                        if (resp) {
                          await ref.read(orderProvider.notifier).paginate(
                                forceRefetch: true,
                              );
                          context.goNamed(OrderDoneScreen.routeName);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('결제 실패!'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: PRIMARY_COLOR,
                      ),
                      child: const Text(
                        '결제하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
