import 'package:flutter/material.dart';

class FadeAnimationPageRoute<T> extends MaterialPageRoute<T> {
  /// FadeAnimationPageRoute initialization
  FadeAnimationPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(
          builder: builder,
          settings: settings,
        );

  /// Build transitions to and from this Route
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
