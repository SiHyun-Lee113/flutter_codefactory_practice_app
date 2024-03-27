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
                  final restaurantModel = RestaurantModel.fromJson(
                    json: item,
                  );

                  return RestaurantCard.fromModel(
                    model: restaurantModel,
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
