import 'package:collection/collection.dart';
import 'package:inject0r/inject0r.dart';

/// ServiceProvider is responsible for managing the lifecycle of providers
class ServiceProviderBase<TContext> {
  final List<Provider> _providers = [];
  ServiceProviderBase();

  List<Provider> get providers => List.unmodifiable(_providers);

  void addAll(List<Provider> providers) {
    for (var provider in providers) {
      final otherProviders = providers.where((p) => p != provider).toList();
      assert(
        otherProviders.where((p) => p.key == provider.key && p.type == provider.type).isEmpty,
        'A provider with the same type and key already exists.',
      );

      assert(
        _providers.where((p) => p.key == provider.key && p.type == provider.type).isEmpty,
        'A provider with the same type and key already exists.',
      );
    }
    
    _providers.addAll(providers);
  }

  /// Register a singleton provider of type [T] with the specified creation function and disposal function.
  void registerSingleton<T>({
    required T Function(TContext context) create,
    String? key,
    void Function(T)? dispose,
  }) {
    assert(
      providers.where((p) => p.key == key && p.type == T).isEmpty,
      'A provider with the same type and key already exists.',
    );

    providers.add(
      Provider<T, TContext>(
        type: T,
        providerType: ProviderType.singleton,
        create: create,
        key: key,
        dispose: dispose,
      ),
    );
  }

  /// Register a scoped provider of type [T] with the specified creation function and disposal function.
  void registerScoped<T>({
    required T Function(TContext context) create,
    String? key,
    void Function(T)? dispose,
  }) {
    assert(
      providers.where((p) => p.key == key && p.type == T).isEmpty,
      'A provider with the same type and key already exists.',
    );
    
    providers.add(
      Provider<T, TContext>(
        type: T,
        providerType: ProviderType.scoped,
        create: create,
        key: key,
        dispose: dispose,
      ),
    );
  }

  /// Register a transient provider of type [T] with the specified creation function and disposal function.
  void registerTransient<T>({
    required T Function(TContext context) create,
    String? key,
    void Function(T)? dispose,
  }) {
    assert(
      providers.where((p) => p.key == key && p.type == T).isEmpty,
      'A provider with the same type and key already exists.',
    );

    providers.add(
      Provider<T, TContext>(
        type: T,
        providerType: ProviderType.transient,
        create: create,
        key: key,
        dispose: dispose,
      ),
    );
  }

  Provider<T, TContext>? getProvider<T>({
    required String? key,
  }) {
    return providers
        .whereType<Provider<T, TContext>>()
        .firstWhereOrNull((p) => p.key == key);
  }
}
