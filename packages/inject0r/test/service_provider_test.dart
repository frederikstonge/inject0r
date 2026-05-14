import 'package:inject0r/inject0r.dart';
import 'package:test/test.dart';

void main() {
  group('ServiceProvider', () {
    late ServiceProviderBase<String> serviceProvider;

    setUp(() {
      serviceProvider = ServiceProviderBase<String>();
    });

    test('starts with empty providers list', () {
      expect(serviceProvider.providers, isEmpty);
    });

    group('registerSingleton', () {
      test('adds a singleton provider', () {
        serviceProvider.registerSingleton<int>(create: (_) => 42);

        expect(serviceProvider.providers, hasLength(1));

        final provider = serviceProvider.providers.first;
        expect(provider.providerType, ProviderType.singleton);
      });

      test('adds a singleton provider with correct type', () {
        serviceProvider.registerSingleton<int>(create: (_) => 42);

        final provider =
            serviceProvider.providers.first as Provider<int, String>;
        expect(provider.create('ctx'), 42);
      });

      test('adds a singleton provider with key', () {
        serviceProvider.registerSingleton<int>(create: (_) => 42, key: 'myKey');

        expect(serviceProvider.providers.first.key, 'myKey');
      });

      test('adds a singleton provider with dispose', () {
        int? disposed;
        serviceProvider.registerSingleton<int>(
          create: (_) => 42,
          dispose: (v) => disposed = v,
        );

        final provider =
            serviceProvider.providers.first as Provider<int, String>;
        provider.dispose!(99);
        expect(disposed, 99);
      });

      test('key defaults to null', () {
        serviceProvider.registerSingleton<int>(create: (_) => 42);

        expect(serviceProvider.providers.first.key, isNull);
      });

      test('dispose defaults to null', () {
        serviceProvider.registerSingleton<int>(create: (_) => 42);

        expect(serviceProvider.providers.first.dispose, isNull);
      });
    });

    group('registerScoped', () {
      test('adds a scoped provider', () {
        serviceProvider.registerScoped<int>(create: (_) => 42);

        expect(serviceProvider.providers, hasLength(1));
        expect(
          serviceProvider.providers.first.providerType,
          ProviderType.scoped,
        );
      });

      test('adds a scoped provider with key', () {
        serviceProvider.registerScoped<int>(
          create: (_) => 42,
          key: 'scopedKey',
        );

        expect(serviceProvider.providers.first.key, 'scopedKey');
      });

      test('adds a scoped provider with dispose', () {
        int? disposed;
        serviceProvider.registerScoped<int>(
          create: (_) => 42,
          dispose: (v) => disposed = v,
        );

        final provider =
            serviceProvider.providers.first as Provider<int, String>;
        provider.dispose!(10);
        expect(disposed, 10);
      });
    });

    group('registerTransient', () {
      test('adds a transient provider', () {
        serviceProvider.registerTransient<int>(create: (_) => 42);

        expect(serviceProvider.providers, hasLength(1));
        expect(
          serviceProvider.providers.first.providerType,
          ProviderType.transient,
        );
      });

      test('transient provider has null key', () {
        serviceProvider.registerTransient<int>(create: (_) => 42);

        expect(serviceProvider.providers.first.key, isNull);
      });

      test('adds a transient provider with dispose', () {
        int? disposed;
        serviceProvider.registerTransient<int>(
          create: (_) => 42,
          dispose: (v) => disposed = v,
        );

        final provider =
            serviceProvider.providers.first as Provider<int, String>;
        provider.dispose!(5);
        expect(disposed, 5);
      });
    });

    group('multiple registrations', () {
      test('can register multiple providers of different types', () {
        serviceProvider.registerSingleton<int>(create: (_) => 1);
        serviceProvider.registerScoped<String>(create: (_) => 'hello');
        serviceProvider.registerTransient<double>(create: (_) => 3.14);

        expect(serviceProvider.providers, hasLength(3));
        expect(
          serviceProvider.providers[0].providerType,
          ProviderType.singleton,
        );
        expect(serviceProvider.providers[1].providerType, ProviderType.scoped);
        expect(
          serviceProvider.providers[2].providerType,
          ProviderType.transient,
        );
      });

      test(
        'can register multiple providers of the same type with different keys',
        () {
          serviceProvider.registerScoped<int>(create: (_) => 1, key: 'first');
          serviceProvider.registerScoped<int>(create: (_) => 2, key: 'second');

          expect(serviceProvider.providers, hasLength(2));
          expect(serviceProvider.providers[0].key, 'first');
          expect(serviceProvider.providers[1].key, 'second');
        },
      );

      test('create function receives context', () {
        serviceProvider.registerSingleton<String>(
          create: (ctx) => 'value-$ctx',
        );

        final provider =
            serviceProvider.providers.first as Provider<String, String>;
        expect(provider.create('context'), 'value-context');
      });
    });
  });
}
