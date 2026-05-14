import 'package:inject0r/inject0r.dart';
import 'package:test/test.dart';

void main() {
  group('Provider', () {
    test('stores create function and metadata', () {
      final provider = Provider<String, void>(
        create: (_) => 'hello',
        providerType: ProviderType.singleton,
        dispose: null,
        key: 'myKey',
      );

      expect(provider.providerType, ProviderType.singleton);
      expect(provider.key, 'myKey');
      expect(provider.dispose, isNull);
      expect(provider.create(null), 'hello');
    });

    test('create receives context', () {
      final provider = Provider<String, int>(
        create: (ctx) => 'value-$ctx',
        providerType: ProviderType.transient,
        dispose: null,
      );

      expect(provider.create(42), 'value-42');
    });

    test('key defaults to null', () {
      final provider = Provider<String, void>(
        create: (_) => 'hello',
        providerType: ProviderType.scoped,
        dispose: null,
      );

      expect(provider.key, isNull);
    });

    test('dispose callback is stored', () {
      String? disposed;
      final provider = Provider<String, void>(
        create: (_) => 'hello',
        providerType: ProviderType.singleton,
        dispose: (v) => disposed = v,
      );

      provider.dispose!('goodbye');

      expect(disposed, 'goodbye');
    });
  });

  group('ProviderType', () {
    test('has three values', () {
      expect(ProviderType.values, hasLength(3));
    });

    test('contains singleton, scoped, and transient', () {
      expect(ProviderType.values, contains(ProviderType.singleton));
      expect(ProviderType.values, contains(ProviderType.scoped));
      expect(ProviderType.values, contains(ProviderType.transient));
    });
  });
}
