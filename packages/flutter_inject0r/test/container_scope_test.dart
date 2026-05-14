import 'package:flutter/widgets.dart';
import 'package:flutter_inject0r/flutter_inject0r.dart';
import 'package:flutter_test/flutter_test.dart';

class _DisposableService {
  bool created = false;
  bool disposed = false;

  _DisposableService() {
    created = true;
  }

  void close() => disposed = true;
}

void main() {
  group('ContainerScope', () {
    group('primary', () {
      testWidgets('renders child', (tester) async {
        final sp = ServiceProvider();

        await tester.pumpWidget(
          ContainerScope.primary(serviceProvider: sp, child: const SizedBox()),
        );

        expect(find.byType(SizedBox), findsOneWidget);
      });

      testWidgets('resolves a singleton', (tester) async {
        final sp = ServiceProvider()
          ..registerSingleton<String>(create: (_) => 'hello');

        late String result;
        await tester.pumpWidget(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                result = context.get<String>();
                return const SizedBox();
              },
            ),
          ),
        );

        expect(result, 'hello');
      });

      testWidgets('singleton returns same instance every time', (tester) async {
        var createCount = 0;
        final sp = ServiceProvider()
          ..registerSingleton<_DisposableService>(
            create: (_) {
              createCount++;
              return _DisposableService();
            },
          );

        late _DisposableService first;
        late _DisposableService second;
        await tester.pumpWidget(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                first = context.get<_DisposableService>();
                second = context.get<_DisposableService>();
                return const SizedBox();
              },
            ),
          ),
        );

        expect(identical(first, second), isTrue);
        expect(createCount, 1);
      });

      testWidgets('resolves a transient', (tester) async {
        var createCount = 0;
        final sp = ServiceProvider()
          ..registerTransient<_DisposableService>(
            create: (_) {
              createCount++;
              return _DisposableService();
            },
          );

        late _DisposableService first;
        late _DisposableService second;
        await tester.pumpWidget(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                first = context.get<_DisposableService>();
                second = context.get<_DisposableService>();
                return const SizedBox();
              },
            ),
          ),
        );

        expect(identical(first, second), isFalse);
        expect(createCount, 2);
      });

      testWidgets('resolves with key', (tester) async {
        final sp = ServiceProvider()
          ..registerSingleton<String>(create: (_) => 'default')
          ..registerSingleton<String>(key: 'other', create: (_) => 'keyed');

        late String defaultValue;
        late String keyedValue;
        await tester.pumpWidget(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                defaultValue = context.get<String>();
                keyedValue = context.get<String>(key: 'other');
                return const SizedBox();
              },
            ),
          ),
        );

        expect(defaultValue, 'default');
        expect(keyedValue, 'keyed');
      });
    });

    group('disposal', () {
      testWidgets('disposes singleton instances when scope is removed', (
        tester,
      ) async {
        final service = _DisposableService();
        final sp = ServiceProvider()
          ..registerSingleton<_DisposableService>(
            create: (_) => service,
            dispose: (s) => s.close(),
          );

        await tester.pumpWidget(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                context.get<_DisposableService>();
                return const SizedBox();
              },
            ),
          ),
        );

        expect(service.disposed, isFalse);

        // Remove the scope from the tree
        await tester.pumpWidget(const SizedBox());

        expect(service.disposed, isTrue);
      });

      testWidgets('disposes transient instances when scope is removed', (
        tester,
      ) async {
        final services = <_DisposableService>[];
        final sp = ServiceProvider()
          ..registerTransient<_DisposableService>(
            create: (_) {
              final s = _DisposableService();
              services.add(s);
              return s;
            },
            dispose: (s) => s.close(),
          );

        await tester.pumpWidget(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                context.get<_DisposableService>();
                context.get<_DisposableService>();
                return const SizedBox();
              },
            ),
          ),
        );

        expect(services, hasLength(2));
        expect(services.every((s) => !s.disposed), isTrue);

        await tester.pumpWidget(const SizedBox());

        expect(services.every((s) => s.disposed), isTrue);
      });

      testWidgets('does not dispose instances without dispose callback', (
        tester,
      ) async {
        final sp = ServiceProvider()
          ..registerSingleton<_DisposableService>(
            create: (_) => _DisposableService(),
          );

        await tester.pumpWidget(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                context.get<_DisposableService>();
                return const SizedBox();
              },
            ),
          ),
        );

        // Should not throw when scope is removed
        await tester.pumpWidget(const SizedBox());
      });
    });

    group('createScope', () {
      testWidgets('child scope resolves singletons from root', (tester) async {
        final sp = ServiceProvider()
          ..registerSingleton<String>(create: (_) => 'from-root')
          ..registerScoped<int>(create: (_) => 42);

        late String rootResult;
        late String childResult;
        await tester.pumpWidget(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                rootResult = context.get<String>();
                return ContainerScope.createScope(
                  context: context,
                  child: Builder(
                    builder: (innerContext) {
                      childResult = innerContext.get<String>();
                      return const SizedBox();
                    },
                  ),
                );
              },
            ),
          ),
        );

        expect(rootResult, 'from-root');
        expect(childResult, 'from-root');
      });

      testWidgets('child scope creates its own scoped instances', (
        tester,
      ) async {
        var createCount = 0;
        final sp = ServiceProvider()
          ..registerScoped<int>(
            create: (_) {
              createCount++;
              return createCount;
            },
          );

        late int scopeAValue;
        late int scopeBValue;
        await tester.pumpWidget(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Column(
              children: [
                Builder(
                  builder: (context) {
                    return ContainerScope.createScope(
                      context: context,
                      child: Builder(
                        builder: (ctx) {
                          scopeAValue = ctx.get<int>();
                          return const SizedBox();
                        },
                      ),
                    );
                  },
                ),
                Builder(
                  builder: (context) {
                    return ContainerScope.createScope(
                      context: context,
                      child: Builder(
                        builder: (ctx) {
                          scopeBValue = ctx.get<int>();
                          return const SizedBox();
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );

        expect(scopeAValue, isNot(scopeBValue));
      });

      testWidgets('child scope disposes its instances independently', (
        tester,
      ) async {
        final rootService = _DisposableService();
        final scopedService = _DisposableService();

        final sp = ServiceProvider()
          ..registerSingleton<_DisposableService>(
            create: (_) => rootService,
            dispose: (s) => s.close(),
          )
          ..registerScoped<_DisposableService>(
            key: "scoped",
            create: (_) => scopedService,
            dispose: (s) => s.close(),
          );

        final showScope = ValueNotifier(true);

        await tester.pumpWidget(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                context.get<_DisposableService>();
                return ValueListenableBuilder<bool>(
                  valueListenable: showScope,
                  builder: (context, show, _) {
                    if (!show) return const SizedBox();
                    return ContainerScope.createScope(
                      context: context,
                      child: Builder(
                        builder: (ctx) {
                          ctx.get<_DisposableService>(key: "scoped");
                          return const SizedBox();
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );

        expect(scopedService.created, isTrue);
        expect(scopedService.disposed, isFalse);
        expect(rootService.created, isTrue);
        expect(rootService.disposed, isFalse);

        // Remove child scope
        showScope.value = false;
        await tester.pumpAndSettle();

        expect(scopedService.created, isTrue);
        expect(scopedService.disposed, isTrue);
        expect(rootService.created, isTrue);
        expect(rootService.disposed, isFalse);
      });

      testWidgets('createScope merges scoped service providers', (
        tester,
      ) async {
        final sp = ServiceProvider()
          ..registerSingleton<String>(create: (_) => 'root-singleton')
          ..registerScoped<int>(create: (_) => 42);

        final scopedSp = ServiceProvider()
          ..registerScoped<double>(create: (_) => 3.14);

        late String singletonResult;
        late int intResult;
        late double doubleResult;

        await tester.pumpWidget(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                return ContainerScope.createScope(
                  context: context,
                  serviceProvider: scopedSp,
                  child: Builder(
                    builder: (ctx) {
                      singletonResult = ctx.get<String>();
                      intResult = ctx.get<int>();
                      doubleResult = ctx.get<double>();
                      return const SizedBox();
                    },
                  ),
                );
              },
            ),
          ),
        );

        expect(singletonResult, 'root-singleton');
        expect(intResult, 42);
        expect(doubleResult, 3.14);
      });
    });

    group('BuildContext extensions', () {
      testWidgets('context.get<T>() resolves from nearest scope', (
        tester,
      ) async {
        final sp = ServiceProvider()
          ..registerSingleton<String>(create: (_) => 'hello');

        late String result;
        await tester.pumpWidget(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                result = context.get<String>();
                return const SizedBox();
              },
            ),
          ),
        );

        expect(result, 'hello');
      });

      testWidgets('context.get<T>(key:) resolves keyed instance', (
        tester,
      ) async {
        final sp = ServiceProvider()
          ..registerSingleton<String>(key: 'a', create: (_) => 'alpha')
          ..registerSingleton<String>(key: 'b', create: (_) => 'beta');

        late String a;
        late String b;
        await tester.pumpWidget(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                a = context.get<String>(key: 'a');
                b = context.get<String>(key: 'b');
                return const SizedBox();
              },
            ),
          ),
        );

        expect(a, 'alpha');
        expect(b, 'beta');
      });
    });
  });
}
