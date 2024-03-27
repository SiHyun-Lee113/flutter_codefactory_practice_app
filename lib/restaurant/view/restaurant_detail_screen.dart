import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_codefactory_practice_app/common/const/data.dart';
import 'package:flutter_codefactory_practice_app/common/dio/dio.dart';
import 'package:flutter_codefactory_practice_app/common/layout/default_layout.dart';
import 'package:flutter_codefactory_practice_app/product/component/product_card.dart';
import 'package:flutter_codefactory_practice_app/restaurant/component/restaurant_card.dart';
import 'package:flutter_codefactory_practice_app/restaurant/model/restaurant_detail_model.dart';
import 'package:flutter_codefactory_practice_app/restaurant/repository/restaurant_repository.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final String id;

  const RestaurantDetailScreen({
    super.key,
    required this.id,
  });

  Future<RestaurantDetailModel> getRestaurantDetail() async {
    final dio = Dio();

    dio.interceptors.add(
      CustomInterceptor(
        storage: storage,
      ),
    );

    final repository =
        RestaurantRepository(dio, baseUrl: 'http://$ip/restaurant');

    return repository.getRestaurantDetail(sid: id);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        title: '불타는 떡볶이',
        child: FutureBuilder<RestaurantDetailModel>(
          future: getRestaurantDetail(),
          builder: (_, AsyncSnapshot<RestaurantDetailModel> snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }

            if (!snapshot.hasData) {
              print(snapshot.error);
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return CustomScrollView(
              slivers: [
                renderTop(
                  model: snapshot.data!,
                ),
                renderLabel(),
                renderProducts(
                  products: snapshot.data!.products,
                ),
              ],
            );
          },
        ));
  }

  SliverPadding renderLabel() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverToBoxAdapter(
        child: Text(
          '메뉴',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  SliverPadding renderProducts({
    required List<RestaurantProductModel> products,
  }) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final model = products[index];

            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ProductCard.fromModel(model: model),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  SliverToBoxAdapter renderTop({required RestaurantDetailModel model}) {
    return SliverToBoxAdapter(
      child: RestaurantCard.fromModel(
        model: model,
        isDetail: true,
      ),
    );
  }
}