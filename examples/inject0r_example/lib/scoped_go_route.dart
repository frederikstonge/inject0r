import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:inject0r/inject0r.dart';

class ScopedGoRoute extends GoRoute {
  ScopedGoRoute({
    required super.path,
    required Widget Function(BuildContext context, GoRouterState state) builder,
    super.name,
    super.routes,
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.caseSensitive,
  }) : super(
         builder: (context, state) => ContainerScope.createScope(
           context: context,
           child: Builder(builder: (context) => builder(context, state)),
         ),
       );
}
