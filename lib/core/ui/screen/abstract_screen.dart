import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/auth_provider.dart';
import 'package:rick_and_morty_flutter_proj/core/router/router_v1.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in/google_sign_in_auth_module.dart';

import 'abstract_stateful_screen.dart';

class AbstractScreenStateOptions {
  String screenName;
  String title;
  bool safeArea;

  /// Callback used to preProcess options at the start of each build
  /// May be used to change options based on some conditions
  void Function(BuildContext context)? optionsBuildPreProcessor;
  List<AppBarOption>? appBarOptions;

  /// AbstractScreenStateOptions initialization for default state
  AbstractScreenStateOptions.basic({
    required this.screenName,
    required this.title,
    this.safeArea = true,
  });
}

abstract class AbstractScreen extends AbstractStatefulWidget {
  const AbstractScreen({Key? key}) : super(key: key);
}

abstract class AbstractScreenState<T extends AbstractScreen> extends AbstractStatefulWidgetState<T> with RouteAware {
  @protected
  AbstractScreenStateOptions? options;

  /// Manually dispose of resources
  @override
  void dispose() {
    routeObserver.unsubscribe(this);

    super.dispose();
  }

  /// Run initializations of screen on first build only
  @override
  firstBuildOnly(BuildContext context) {
    super.firstBuildOnly(context);

    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      routeObserver.subscribe(this, modalRoute as PageRoute);
    }
  }

  /// Create view layout from widgets
  @override
  Widget build(BuildContext context) {
    final theOptionsBuildPreProcessor = options?.optionsBuildPreProcessor;

    if (theOptionsBuildPreProcessor != null) {
      theOptionsBuildPreProcessor(context);
    }

    if (widgetState == WidgetState.notInitialized) {
      firstBuildOnly(context);
    }

        Widget theContent = buildContent(context);
        if (options?.safeArea ?? false) {
          theContent = SafeArea(
            top: false,
            child: theContent,
          );
        }else {
          theContent = SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: theContent),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: createAppBar(context),
          body: theContent,
          floatingActionButton: createFloatingActionButton(context),
          floatingActionButtonAnimator: setFloatingActionButtonAnimator(context),
          floatingActionButtonLocation: setFloatingActionButtonLocation(context),
        );
  }

  /// Create default AppBar
  @protected
  PreferredSizeWidget? createAppBar(BuildContext context);

  /// Create floating action button for screen
  @protected
  Widget? createFloatingActionButton(BuildContext context) => null;

  /// Set animator for floating action button
  @protected
  FloatingActionButtonAnimator? setFloatingActionButtonAnimator(BuildContext context) => null;

  /// Set location of floating action button
  @protected
  FloatingActionButtonLocation? setFloatingActionButtonLocation(BuildContext context) => null;

  /// This screen is now the top Route after it has been pushed
  @override
  void didPush() {
    super.didPush();

    onStartResume();
  }

  /// This screen is now the top Route after return back to this Route from next ones
  @override
  void didPopNext() {
    super.didPopNext();

    onStartResume();
    onResume();
  }

  /// This screen is now the top Route
  @protected
  void onStartResume() {}

  /// This screen is now the top Route
  @protected
  void onResume() {}
}

class AppBarOption {
  final Function(BuildContext context) onTap;
  final Widget? icon;
  final Widget? complexIcon;

  /// AppBarOption initialization
  AppBarOption({
    required this.onTap,
    required this.icon,
    this.complexIcon,
  }) : assert(icon != null || complexIcon != null);
}
