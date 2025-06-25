import 'provider_type.dart';

/// Represents an instance of a dependency with its type and disposal function.
class Instance<T> {
  final T value;
  final ProviderType providerType;
  final String? key;
  final void Function(T)? dispose;

  Instance({required this.value, required this.providerType, required this.key, required this.dispose});

  void disposeValue() {
    if (dispose != null) {
      dispose!(value);
    }
  }
}
