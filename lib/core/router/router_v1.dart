import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_detail/rick_morty_detail_screen.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_detail/vm/rick_morty_detail_vm.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/rick_morty_list_screen.dart';

import 'fade_animation_page_route.dart';
import 'no_animation_page_route.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

/// Generate Route with Screen for RoutingArguments from Route name
Route<Object> onGenerateRoute(RouteSettings settings) {
  final arguments = settings.name?.routingArguments;

  if (arguments != null) {
    switch (arguments.route) {
      case RickMortyListScreen.route:
        return createRoute((BuildContext context) => const RickMortyListScreen(), settings);
      case RickMortyDetailScreen.route:
        return createRoute(
            (BuildContext context) => BlocProvider(
                  create: (context) => RickMortyDetailVM(),
                  child: RickMortyDetailScreen(),
                ),
            settings);
      default:
        throw Exception('Implement OnGenerateRoute in app');
    }
  }

  throw Exception('Arguments not available');
}

/// Create Route depending on platform for different effects
Route<Object> createRoute(WidgetBuilder builder, RouteSettings settings) {
  if (kIsWeb) {
    return NoAnimationPageRoute(builder: builder, settings: settings);
  } else {
    final arguments = settings.name?.routingArguments;

    if (arguments?['router-no-animation'] != null) {
      return NoAnimationPageRoute<Object>(builder: builder, settings: settings);
    } else if (arguments?['router-fade-animation'] != null) {
      return FadeAnimationPageRoute<Object>(builder: builder, settings: settings);
    } else {
      return MaterialPageRoute<Object>(builder: builder, settings: settings);
    }
  }
}

class RoutingArguments {
  final String? route;

  final Map<String, String>? _query;

  /// RoutingArguments initialization
  RoutingArguments({
    this.route,
    Map<String, String>? query,
  }) : _query = query;

  /// RoutingArguments from current ModalRoute
  static RoutingArguments? of(BuildContext context) {
    return ModalRoute.of(context)?.settings.name?.routingArguments;
  }

  /// Using [] operator gets value from query for key
  String? operator [](String key) => _query?[key];
}

extension StringExtension on String {
  /// Covert String into RoutingArguments
  RoutingArguments? get routingArguments {
    if (this.isEmpty) {
      return null;
    }

    final uri = Uri.parse(this);

    return RoutingArguments(
      route: uri.path,
      query: uri.queryParameters,
    );
  }
}

/// Push named route to stack
Future<T?> pushNamed<T extends Object>(BuildContext context, String routeName, {Map<String, String>? arguments}) {
  if (arguments != null) {
    routeName = Uri(path: routeName, queryParameters: arguments).toString();
  }

  return Navigator.pushNamed(context, routeName);
}

/// Push named route to stack & clear all others
Future<T?> pushNamedNewStack<T extends Object>(
  BuildContext context,
  String routeName, {
  Map<String, String>? arguments,
  RoutePredicate? predicate,
}) {
  if (arguments != null) {
    routeName = Uri(path: routeName, queryParameters: arguments).toString();
  }

  return Navigator.pushNamedAndRemoveUntil(context, routeName, predicate ?? (Route<dynamic> route) => false);
}

/// Pop the route if not yet disposed
void popNotDisposed<T extends Object?>(BuildContext context, bool mounted, [T? result]) {
  if (mounted) {
    Navigator.pop(context, result);
  }
}
