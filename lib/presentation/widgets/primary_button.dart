import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:rick_and_morty_flutter_proj/constants/theme_constants.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPress;
  final String label;
  const PrimaryButton({Key? key, required this.label, required this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        onPress();
      },
      child: Text(
        label,
        style: kPrimaryTextStyleSize16,
      ),
      style: kPrimaryBtnStyle,
    );
  }
}
