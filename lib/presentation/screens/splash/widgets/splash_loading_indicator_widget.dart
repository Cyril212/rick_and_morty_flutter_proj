import 'package:flutter/material.dart';

class SplashLoadingIndicatorWidget extends StatelessWidget {
  const SplashLoadingIndicatorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.only(top: 180.0),
      child: const CircularProgressIndicator(),
    );
  }
}
