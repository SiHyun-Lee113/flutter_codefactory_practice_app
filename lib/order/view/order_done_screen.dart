import 'package:flutter/material.dart';
import 'package:flutter_codefactory_practice_app/common/const/colors.dart';
import 'package:flutter_codefactory_practice_app/common/layout/default_layout.dart';
import 'package:flutter_codefactory_practice_app/common/view/root_tab.dart';
import 'package:go_router/go_router.dart';

class OrderDoneScreen extends StatelessWidget {
  static String get routeName => 'order_done';

  const OrderDoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.thumb_up_alt_outlined,
              color: PRIMARY_COLOR,
              size: 50.0,
            ),
            SizedBox(height: 32.0),
            Text(
              '결제가 완료되었습니다.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: PRIMARY_COLOR,
              ),
              onPressed: () {
                context.goNamed(RootTab.routeName);
              },
              child: Text(
                '홈으로',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
