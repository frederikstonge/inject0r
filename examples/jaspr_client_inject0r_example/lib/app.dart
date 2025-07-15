import 'package:inject0r/inject0r.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_inject0r/jaspr_inject0r.dart';
import 'package:jaspr_client_inject0r_example/scoped_route.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/header.dart';
import 'counter_cubit.dart';
import 'pages/about.dart';
import 'pages/home.dart';

// The main component of your application.
class App extends StatelessComponent {
  const App({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    // This method is rerun every time the component is rebuilt.
    //
    // Each build method can return multiple child components as an [Iterable]. The recommended approach
    // is using the [sync* / yield] syntax for a streamlined control flow, but its also possible to simply
    // create and return a [List] here.

    // Renders a <div class="main"> html element with children.
    final serviceProvider = ServiceProvider<BuildContext>();
    serviceProvider.registerSingleton<String>(
      create: (context) {
        final value = 'Hello, Inject0r!';
        print('Creating singleton value: $value');
        return value;
      },
      dispose: (value) {
        print('Disposing singleton value: $value');
      },
    );

    serviceProvider.registerScoped<int>(
      create: (context) {
        final value = 42;
        print('Creating scoped value: $value');
        return value;
      },
      dispose: (value) {
        print('Disposing scoped value: $value');
      },
    );

    serviceProvider.registerTransient<double>(
      create: (context) {
        final value = 3.14;
        print('Creating transient value: $value');
        return value;
      },
      dispose: (value) {
        print('Disposing transient value: $value');
      },
    );

    serviceProvider.registerScoped<CounterCubit>(
      create: (context) {
        print('Creating scoped CounterCubit');
        return CounterCubit();
      },
      dispose: (cubit) {
        print('Disposing scoped CounterCubit');
        cubit.close();
      },
    );

    serviceProvider.registerScoped<CounterCubit>(
      key: 'test',
      create: (context) {
        print('Creating scoped test CounterCubit');
        return CounterCubit();
      },
      dispose: (cubit) {
        print('Disposing scoped test CounterCubit');
        cubit.close();
      },
    );

    yield div(classes: 'main', [
      ContainerScope.primary(serviceProvider: serviceProvider, children: [
        Router(routes: [
          ShellRoute(
            builder: (context, state, child) => Fragment(children: [
              const Header(),
              child,
            ]),
            routes: [
              ScopedRoute(
                  path: '/',
                  title: 'Home',
                  builder: (context, state) => const Home()),
              ScopedRoute(
                  path: '/about',
                  title: 'About',
                  builder: (context, state) => const About()),
            ],
          ),
        ]),
      ]),
    ]);
  }
}
