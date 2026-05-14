import 'package:inject0r/inject0r.dart';
import 'package:test/test.dart';

void main() {
  group('Instance', () {
    test('stores value and metadata', () {
      final instance = Instance<String>(
        value: 'hello',
        providerType: ProviderType.singleton,
        key: 'myKey',
        dispose: null,
      );

      expect(instance.value, 'hello');
      expect(instance.providerType, ProviderType.singleton);
      expect(instance.key, 'myKey');
      expect(instance.dispose, isNull);
    });

    test('stores value with null key', () {
      final instance = Instance<int>(
        value: 42,
        providerType: ProviderType.transient,
        key: null,
        dispose: null,
      );

      expect(instance.value, 42);
      expect(instance.key, isNull);
    });

    test('disposeValue calls dispose callback with value', () {
      String? disposed;
      final instance = Instance<String>(
        value: 'hello',
        providerType: ProviderType.singleton,
        key: null,
        dispose: (v) => disposed = v,
      );

      instance.disposeValue();

      expect(disposed, 'hello');
    });

    test('disposeValue does nothing when dispose is null', () {
      final instance = Instance<String>(
        value: 'hello',
        providerType: ProviderType.singleton,
        key: null,
        dispose: null,
      );

      // Should not throw
      instance.disposeValue();
    });

    test('disposeValue can be called multiple times', () {
      var count = 0;
      final instance = Instance<String>(
        value: 'hello',
        providerType: ProviderType.scoped,
        key: null,
        dispose: (_) => count++,
      );

      instance.disposeValue();
      instance.disposeValue();

      expect(count, 2);
    });
  });
}
