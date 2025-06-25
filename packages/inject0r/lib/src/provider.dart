import 'package:flutter/widgets.dart';

import 'provider_type.dart';

/// Represents a provider that creates instances of type [T].
class Provider<T> {
  final T Function(BuildContext context) create;
  final ProviderType providerType;
  final String? key;
  final void Function(T)? dispose;

  const Provider({
    required this.create,
    required this.providerType,
    required this.dispose,
    this.key,
  });
}
