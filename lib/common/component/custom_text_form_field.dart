import 'package:flutter/material.dart';
import 'package:flutter_codefactory_practice_app/common/const/colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  const CustomTextFormField(
      {super.key,
      this.hintText,
      this.errorText,
      this.obscureText = false,
      this.autofocus = false,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
        borderSide: BorderSide(
      color: INPUT_BORDER_COLOR,
      width: 1.0,
    ));

    return TextFormField(
      cursorColor: PRIMARY_COLOR,
      obscureText: obscureText,
      autofocus: autofocus,
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(20),
        hintText: hintText,
        errorText: errorText,
        hintStyle: TextStyle(
          color: BODY_TEXT_COLOR,
          fontSize: 14.0,
        ),
        // fillColor를 통해 텍스트 필드의 배경 색을 채울 때는 filled 속성을 true
        fillColor: INPUT_BG_COLOR,
        filled: true,
        // 모든 Input 상태의 기본 세팅
        border: baseBorder,
        // 선택 시 Input의 세팅
        focusedBorder: baseBorder.copyWith(
          borderSide: baseBorder.borderSide.copyWith(color: PRIMARY_COLOR),
        ),
      ),
    );
  }
}
