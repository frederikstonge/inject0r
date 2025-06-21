import 'package:flutter/widgets.dart';

import 'provider.dart';
import 'provider_type.dart';

/// ServiceProvider is responsible for managing the lifecycle of providers
class ServiceProvider {
  ServiceProvider();

  final List<Provider> providers = [];

  /// Register a singleton provider of type [T] with the specified creation function and disposal function.
  void registerSingleton<T>({required T Function(BuildContext context) create, void Function(T)? dispose}) {
    providers.add(
      Provider<T>(
        providerType: ProviderType.singleton,
        create: create,
        dispose: dispose,
      ),
    );
  }

  /// Register a scoped provider of type [T] with the specified creation function and disposal function.
  void registerScoped<T>({ required T Function(BuildContext context) create, void Function(T)? dispose}) {
    providers.add(
      Provider<T>(
        providerType: ProviderType.scoped,
        create: create,
        dispose: dispose,
      ),
    );
  }

  /// Register a transient provider of type [T] with the specified creation function and disposal function.
  void registerTransient<T>({required T Function(BuildContext context) create, void Function(T)? dispose}) {
    providers.add(
      Provider<T>(
        providerType: ProviderType.transient,
        create: create,
        dispose: dispose,
      ),
    );
  }
}
