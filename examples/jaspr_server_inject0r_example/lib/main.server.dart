/// The entrypoint for the **server** environment.
///
/// The [main] method will only be executed on the server during pre-rendering.
/// To run code on the client, check the `main.client.dart` file.
library;

import 'package:inject0r_shared_example/inject0r_shared_example.dart';
import 'package:jaspr/dom.dart';
// Server-specific Jaspr import.
import 'package:jaspr/server.dart';
import 'package:jaspr_inject0r/jaspr_inject0r.dart';

// Imports the [App] component.
import 'app.dart';

// This file is generated automatically by Jaspr, do not remove or edit.
import 'main.server.options.dart';

void main() {
  // Initializes the server environment with the generated default options.
  Jaspr.initializeApp(
    options: defaultServerOptions,
  );

  final serviceProvider = ServiceProvider();
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

  // Starts the app.
  //
  // [Document] renders the root document structure (<html>, <head> and <body>)
  // with the provided parameters and components.
  runApp(
    ContainerScope.primary(
      serviceProvider: serviceProvider,
      child: Document(
        title: 'jaspr_server_inject0r_example',
        styles: [
          // Special import rule to include to another css file.
          css.import('https://fonts.googleapis.com/css?family=Roboto'),
          // Each style rule takes a valid css selector and a set of styles.
          // Styles are defined using type-safe css bindings and can be freely chained and nested.
          css('html, body').styles(
            width: 100.percent,
            minHeight: 100.vh,
            padding: .zero,
            margin: .zero,
            fontFamily: const .list([FontFamily('Roboto'), FontFamilies.sansSerif]),
          ),
          css('h1').styles(
            margin: .unset,
            fontSize: 4.rem,
          ),
        ],
        body: App(),
      ),
    ),
  );
}
