import 'package:inject0r/inject0r.dart';

/// ServiceProvider is responsible for managing the lifecycle of providers
class ServiceProvider<TContext> {
  ServiceProvider();

  final List<Provider> providers = [];

  /// Register a singleton provider of type [T] with the specified creation function and disposal function.
  void registerSingleton<T>({required T Function(TContext context) create, String? key, void Function(T)? dispose}) {
    providers.add(
      Provider<T, TContext>(
        providerType: ProviderType.singleton,
        create: create,
        key: key,
        dispose: dispose,
      ),
    );
  }

  /// Register a scoped provider of type [T] with the specified creation function and disposal function.
  void registerScoped<T>({ required T Function(TContext context) create, String? key, void Function(T)? dispose}) {
    providers.add(
      Provider<T, TContext>(
        providerType: ProviderType.scoped,
        create: create,
        key: key,
        dispose: dispose,
      ),
    );
  }

  /// Register a transient provider of type [T] with the specified creation function and disposal function.
  void registerTransient<T>({required T Function(TContext context) create, void Function(T)? dispose}) {
    providers.add(
      Provider<T, TContext>(
        providerType: ProviderType.transient,
        create: create,
        dispose: dispose,
      ),
    );
  }
}
