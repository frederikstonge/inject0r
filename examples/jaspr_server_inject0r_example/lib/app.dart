import 'package:inject0r/inject0r.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_inject0r/jaspr_inject0r.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_server_inject0r_example/counter_cubit.dart';
import 'package:jaspr_server_inject0r_example/scoped_route.dart';

import 'components/header.dart';
import 'pages/about.dart';
import 'pages/home.dart';

// The main component of your application.
//
// By using the @client annotation this component will be automatically compiled to javascript and mounted
// on the client. Therefore:
// - this file and any imported file must be compilable for both server and client environments.
// - this component and any child components will be built once on the server during pre-rendering and then
//   again on the client during normal rendering.
@client
class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    // Run code depending on the rendering environment.
    if (kIsWeb) {
      print("Hello client");
      // When using @client components there is no default `main()` function on the client where you would normally
      // run any client-side initialization logic. Instead you can put it here, considering this component is only
      // mounted once at the root of your client-side component tree.
    } else {
      print("Hello server");
    }
  }

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

  // Defines the css styles for elements of this component.
  //
  // By using the @css annotation, these will be rendered automatically to css inside the <head> of your page.
  // Must be a variable or getter of type [List<StyleRule>].
  @css
  static List<StyleRule> get styles => [
        css('.main', [
          // The '&' refers to the parent selector of a nested style rules.
          css('&').styles(
            display: Display.flex,
            height: 100.vh,
            flexDirection: FlexDirection.column,
            flexWrap: FlexWrap.wrap,
          ),
          css('section').styles(
            display: Display.flex,
            flexDirection: FlexDirection.column,
            justifyContent: JustifyContent.center,
            alignItems: AlignItems.center,
            flex: Flex(grow: 1),
          ),
        ]),
      ];
}
