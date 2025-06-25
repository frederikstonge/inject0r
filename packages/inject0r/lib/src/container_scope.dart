import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import 'instance.dart';
import 'provider.dart';
import 'service_provider.dart';
import 'provider_type.dart';

/// A widget that provides a container scope for dependency injection.
class ContainerScope extends StatefulWidget {
  final bool primary;
  final ServiceProvider serviceProvider;
  final Widget child;

  const ContainerScope._({
    super.key,
    required this.primary,
    required this.serviceProvider,
    required this.child,
  });

  /// Creates a primary container scope.
  const ContainerScope.primary({
    Key? key,
    required ServiceProvider serviceProvider,
    required Widget child,
  }) : this._(
         key: key,
         primary: true,
         serviceProvider: serviceProvider,
         child: child,
       );

  /// Get an instance of type [T] from the container scope.
  static T get<T>({required BuildContext context, String? key}) =>
      context.findAncestorStateOfType<_ContainerScopeState>()!.get<T>(key: key);

  /// Creates a new container scope from the current context.
  static ContainerScope createScope({
    required BuildContext context,
    required Widget child,
  }) => context.findAncestorStateOfType<_ContainerScopeState>()!.createScope(
    child,
  );

  @override
  State<ContainerScope> createState() => _ContainerScopeState();
}

class _ContainerScopeState extends State<ContainerScope> {
  final List<Instance> _instances = [];

  /// Dispose all instances in the container scope.
  @override
  void dispose() {
    for (final instance in _instances) {
      instance.disposeValue();
    }

    super.dispose();
  }

  /// Get an instance of type [T] from the container scope.
  T get<T>({required String? key}) {
    final provider = widget.serviceProvider.providers
        .whereType<Provider<T>>()
        .firstWhereOrNull((p) => p.key == key);

    assert(provider != null, 'No provider found for type $T${key != null ? ' with key $key' : ''}.');

    assert(
      !(provider!.providerType == ProviderType.scoped && widget.primary),
      'Cannot get a scoped instance from a primary container.',
    );

    // If the provider is a singleton, get it from the root container
    if (provider!.providerType == ProviderType.singleton && !widget.primary) {
      final root = getRoot();
      if (root != null) {
        return getRoot()!.get<T>(key: key);
      }
    }

    final instance = _instances.whereType<Instance<T>>().firstWhere(
      // Create a new instance all the time of transient providers
      (i) => i.providerType != ProviderType.transient && i.key == key,
      orElse: () {
        final i = Instance<T>(
          value: provider.create(context),
          providerType: provider.providerType,
          key: key,
          dispose: provider.dispose,
        );
        _instances.add(i);
        return i;
      },
    );

    return instance.value;
  }

  /// Creates a new container scope with the current service provider.
  ContainerScope createScope(Widget child) {
    return ContainerScope._(
      primary: false,
      serviceProvider: widget.serviceProvider,
      child: child,
    );
  }

  /// Get the root container scope state.
  _ContainerScopeState? getRoot() =>
      context.findRootAncestorStateOfType<_ContainerScopeState>();

  @override
  Widget build(BuildContext context) => widget.child;
}
