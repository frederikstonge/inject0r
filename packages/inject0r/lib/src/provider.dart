import 'package:inject0r/inject0r.dart';

/// Represents a provider that creates instances of type [T].
class Provider<T, TContext> {
  final Type type;
  final T Function(TContext context) create;
  final ProviderType providerType;
  final String? key;
  final void Function(T)? dispose;

  const Provider({
    required this.type,
    required this.create,
    required this.providerType,
    required this.dispose,
    this.key,
  });
}
