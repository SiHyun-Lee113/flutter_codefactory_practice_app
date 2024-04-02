import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_codefactory_practice_app/common/view/root_tab.dart';
import 'package:flutter_codefactory_practice_app/common/view/splash_screen.dart';
import 'package:flutter_codefactory_practice_app/order/view/order_done_screen.dart';
import 'package:flutter_codefactory_practice_app/restaurant/view/basket_screen.dart';
import 'package:flutter_codefactory_practice_app/restaurant/view/restaurant_detail_screen.dart';
import 'package:flutter_codefactory_practice_app/user/model/user_model.dart';
import 'package:flutter_codefactory_practice_app/user/provider/user_me_provider.dart';
import 'package:flutter_codefactory_practice_app/user/view/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(ref: ref);
});

class AuthProvider extends ChangeNotifier {
  final Ref ref;

  AuthProvider({
    required this.ref,
  }) {
    ref.listen<UserModelBase?>(userMeProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });
  }

  List<GoRoute> get routes => [
        GoRoute(
            path: '/',
            name: RootTab.routeName,
            builder: (context, state) => RootTab(),
            routes: [
              GoRoute(
                path: 'restaurant/:rid',
                name: RestaurantDetailScreen.routeName,
                builder: (_, state) => RestaurantDetailScreen(
                  id: state.pathParameters['rid']!,
                ),
              ),
            ]),
        GoRoute(
          path: '/basket',
          name: BasketScreen.routeName,
          builder: (context, state) => BasketScreen(),
        ),
        GoRoute(
          path: '/order_done',
          name: OrderDoneScreen.routeName,
          builder: (context, state) => OrderDoneScreen(),
        ),
        GoRoute(
          path: '/splash',
          name: SplashScreen.routeName,
          builder: (context, state) => SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: LoginScreen.routeName,
          builder: (context, state) => LoginScreen(),
        ),
      ];

  void logout() {
    ref.read(userMeProvider.notifier).logout();
  }

  // SplashScreen
  // 앱을 처음 시작했을 때 토큰이 존재하는지 확인하기 위해
  FutureOr<String?> redirectLogic(BuildContext context, GoRouterState state) {
    final UserModelBase? user = ref.read(userMeProvider);

    final loggingIn = state.uri.toString() == '/login';

    if (user == null) {
      return loggingIn ? null : '/login';
    }

    // user가 Null이 아님

    // UserModel
    // ㅅ용자 정보가 있는 상태면
    // 로그인 중이거나 현재 위치가 SplashScreen이면 홈으로 이동
    if (user is UserModel) {
      return loggingIn || state.uri.toString() == '/splash' ? '/' : null;
    }

    if (user is UserModelError) {
      return !loggingIn ? '/login' : null;
    }

    return null;
  }
}
