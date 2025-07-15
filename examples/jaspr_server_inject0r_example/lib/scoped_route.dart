import 'package:jaspr/jaspr.dart';
import 'package:jaspr_inject0r/jaspr_inject0r.dart';
import 'package:jaspr_router/jaspr_router.dart';

class ScopedRoute extends Route {
  ScopedRoute({
    required super.path,
    required RouterComponentBuilder builder,
    super.name,
    super.title,
    super.routes = const [],
    super.redirect,
    super.settings,
  }) : super(
          builder: (context, state) => ContainerScope.createScope(
            key: ValueKey(state.location),
            context: context,
            children: [
              Builder(builder: (scopedContext) {
                return [builder(scopedContext, state)];
              })
            ],
          ),
        );
}
