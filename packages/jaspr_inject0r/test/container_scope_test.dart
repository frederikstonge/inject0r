import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_inject0r/jaspr_inject0r.dart';
import 'package:jaspr_test/jaspr_test.dart';

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
      testComponents('renders child', (tester) async {
        final sp = ServiceProvider();

        tester.pumpComponent(
          ContainerScope.primary(serviceProvider: sp, child: div([])),
        );

        expect(find.tag('div'), findsOneComponent);
      });

      testComponents('resolves a singleton', (tester) async {
        final sp = ServiceProvider()
          ..registerSingleton<String>(create: (_) => 'hello');

        late String result;
        tester.pumpComponent(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                result = context.get<String>();
                return div([]);
              },
            ),
          ),
        );

        expect(result, 'hello');
      });

      testComponents('singleton returns same instance every time', (
        tester,
      ) async {
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
        tester.pumpComponent(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                first = context.get<_DisposableService>();
                second = context.get<_DisposableService>();
                return div([]);
              },
            ),
          ),
        );

        expect(identical(first, second), isTrue);
        expect(createCount, 1);
      });

      testComponents('resolves a transient', (tester) async {
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
        tester.pumpComponent(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                first = context.get<_DisposableService>();
                second = context.get<_DisposableService>();
                return div([]);
              },
            ),
          ),
        );

        expect(identical(first, second), isFalse);
        expect(createCount, 2);
      });

      testComponents('resolves with key', (tester) async {
        final sp = ServiceProvider()
          ..registerSingleton<String>(create: (_) => 'default')
          ..registerSingleton<String>(key: 'other', create: (_) => 'keyed');

        late String defaultValue;
        late String keyedValue;
        tester.pumpComponent(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                defaultValue = context.get<String>();
                keyedValue = context.get<String>(key: 'other');
                return div([]);
              },
            ),
          ),
        );

        expect(defaultValue, 'default');
        expect(keyedValue, 'keyed');
      });
    });

    group('createScope', () {
      testComponents('child scope resolves singletons from root', (
        tester,
      ) async {
        final sp = ServiceProvider()
          ..registerSingleton<String>(create: (_) => 'from-root')
          ..registerScoped<int>(create: (_) => 42);

        late String rootResult;
        late String childResult;
        tester.pumpComponent(
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
                      return div([]);
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

      testComponents('child scope creates its own scoped instances', (
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
        tester.pumpComponent(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (outerContext) {
                return Component.fragment([
                  ContainerScope.createScope(
                    context: outerContext,
                    child: Builder(
                      builder: (ctx) {
                        scopeAValue = ctx.get<int>();
                        return div([]);
                      },
                    ),
                  ),
                  ContainerScope.createScope(
                    context: outerContext,
                    child: Builder(
                      builder: (ctx) {
                        scopeBValue = ctx.get<int>();
                        return span([]);
                      },
                    ),
                  ),
                ]);
              },
            ),
          ),
        );

        expect(scopeAValue, isNot(scopeBValue));
      });

      testComponents('child scope disposes its instances independently', (
        tester,
      ) async {
        final rootService = _DisposableService();
        final scopedService = _DisposableService();

        final sp = ServiceProvider()
          ..registerSingleton<_DisposableService>(
            create: (_) => rootService,
            dispose: (service) => service.close(),
          )
          ..registerScoped<_DisposableService>(
            key: "scoped",
            create: (_) => scopedService,
            dispose: (service) => service.close(),
          );

        final showScope = ValueNotifier(true);

        tester.pumpComponent(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                context.get<_DisposableService>();
                return ValueListenableBuilder<bool>(
                  listenable: showScope,
                  builder: (context, show) {
                    if (!show) return const div([]);
                    return ContainerScope.createScope(
                      context: context,
                      child: Builder(
                        builder: (ctx) {
                          ctx.get<_DisposableService>(key: "scoped");
                          return const div([]);
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
        await tester.pump();

        expect(scopedService.created, isTrue);
        expect(scopedService.disposed, isTrue);
        expect(rootService.created, isTrue);
        expect(rootService.disposed, isFalse);
      });

      testComponents('createScope merges scoped service providers', (
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

        tester.pumpComponent(
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
                      return div([]);
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
      testComponents('context.get<T>() resolves from nearest scope', (
        tester,
      ) async {
        final sp = ServiceProvider()
          ..registerSingleton<String>(create: (_) => 'hello');

        late String result;
        tester.pumpComponent(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                result = context.get<String>();
                return div([]);
              },
            ),
          ),
        );

        expect(result, 'hello');
      });

      testComponents('context.get<T>(key:) resolves keyed instance', (
        tester,
      ) async {
        final sp = ServiceProvider()
          ..registerSingleton<String>(key: 'a', create: (_) => 'alpha')
          ..registerSingleton<String>(key: 'b', create: (_) => 'beta');

        late String a;
        late String b;
        tester.pumpComponent(
          ContainerScope.primary(
            serviceProvider: sp,
            child: Builder(
              builder: (context) {
                a = context.get<String>(key: 'a');
                b = context.get<String>(key: 'b');
                return div([]);
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
