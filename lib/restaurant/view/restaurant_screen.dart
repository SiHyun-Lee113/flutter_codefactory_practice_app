import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_codefactory_practice_app/common/const/data.dart';
import 'package:flutter_codefactory_practice_app/restaurant/component/restaurant_card.dart';
import 'package:flutter_codefactory_practice_app/restaurant/model/restaurant_model.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key});

  Future<List> paginateRestaurant() async {
    final dio = Dio();

    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    var response = await dio.get(
      'http://$ip/restaurant',
      options: Options(headers: {
        'authorization': 'Bearer $accessToken',
      }),
    );

    return response.data['data'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: FutureBuilder<List>(
            future: paginateRestaurant(),
            builder: (context, AsyncSnapshot<List> snapshot) {
              if (!snapshot.hasData) {
                return const Placeholder();
              }

              return ListView.separated(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) {
                  final item = snapshot.data![index];
                  final pItem = RestaurantModel(
                    id: item['id'],
                    name: item['name'],
                    thumbUrl: item['thumbUrl'],
                    tags: List<String>.from(item['tags']),
                    priceRange: RestaurantPriceRange.values.firstWhere(
                      (element) => element.name == item['priceRange'],
                    ),
                    ratings: item['ratings'],
                    ratingsCount: item['ratingsCount'],
                    deliveryTime: item['deliveryTime'],
                    deliveryFee: item['deliveryFee'],
                  );

                  return RestaurantCard(
                    // image: Image.asset(
                    //   'asset/img/food/ddeok_bok_gi.jpg',
                    //   fit: BoxFit.cover,
                    // ),
                    image: Image.network(
                      'http://$ip${pItem.thumbUrl}',
                      fit: BoxFit.cover,
                    ),
                    name: pItem.name,
                    tags: pItem.tags,
                    ratingsCount: pItem.ratingsCount,
                    deliveryTime: pItem.deliveryTime,
                    deliveryFee: pItem.deliveryFee,
                    ratings: pItem.ratings,
                  );
                },
                separatorBuilder: (_, index) {
                  return const SizedBox(height: 16);
                },
              );
            },
          )),
    ));
  }
}
