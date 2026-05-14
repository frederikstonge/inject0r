import 'package:inject0r/inject0r.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_inject0r/src/service_provider.dart';

/// A component that provides a container scope for dependency injection.
class ContainerScope extends StatefulComponent {
  final bool primary;
  final ServiceProvider serviceProvider;
  final Component child;

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
    required Component child,
  }) : this._(
         key: key,
         primary: true,
         serviceProvider: serviceProvider,
         child: child,
       );

  /// Get an instance of type [T] from the container scope.
  static T get<T>({required BuildContext context, String? key}) {
    final state = context.findAncestorStateOfType<_ContainerScopeState>();
    assert(
      state != null,
      'No ContainerScope found in the context. Make sure to wrap your component tree with a ContainerScope.',
    );

    return state!.get<T>(key: key);
  }

  /// Creates a new container scope from the current context.
  ///
  /// If [serviceProvider] is provided, it must only contain scoped providers.
  /// These will be merged with the primary container's providers.
  static ContainerScope createScope({
    Key? key,
    required BuildContext context,
    required Component child,
    ServiceProvider? serviceProvider,
  }) {
    final state = context.findAncestorStateOfType<_ContainerScopeState>();
    assert(
      state != null,
      'No ContainerScope found in the context. Make sure to wrap your component tree with a ContainerScope.',
    );

    return state!.createScope(key, child, serviceProvider);
  }

  @override
  State<ContainerScope> createState() => _ContainerScopeState();
}

class _ContainerScopeState extends State<ContainerScope> {
  late final _ContainerScopeState? _root = _getRoot();
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
    final provider = component.serviceProvider.getProvider<T>(key: key);

    assert(
      provider != null,
      'No provider found for type $T${key != null ? ' with key $key' : ''}.',
    );

    assert(
      !(provider!.providerType == ProviderType.scoped && component.primary),
      'Cannot get a scoped instance from a primary container.',
    );

    // If the provider is a singleton, get it from the root container
    if (provider!.providerType == ProviderType.singleton &&
        !component.primary) {
      if (_root != null) {
        return _root.get<T>(key: key);
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
  ContainerScope createScope(
    Key? key,
    Component child,
    ServiceProvider? scopedServiceProvider,
  ) {
    assert(
      scopedServiceProvider == null ||
          scopedServiceProvider.providers.every(
            (p) => p.providerType == ProviderType.scoped,
          ),
      'A scoped service provider should only contain scoped providers.',
    );

    final mergedServiceProvider = ServiceProvider()
      ..addAll(component.serviceProvider.providers)
      ..addAll(scopedServiceProvider?.providers ?? []);

    return ContainerScope._(
      key: key,
      primary: false,
      serviceProvider: mergedServiceProvider,
      child: child,
    );
  }

  /// Get the root container scope state.
  _ContainerScopeState? _getRoot() {
    _ContainerScopeState? root;
    context.visitAncestorElements((element) {
      if (element is StatefulElement && element.state is _ContainerScopeState) {
        root = element.state as _ContainerScopeState;
      }

      return true;
    });

    return root;
  }

  @override
  Component build(BuildContext context) => component.child;
}
