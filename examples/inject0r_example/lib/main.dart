import 'package:flutter/material.dart';
import 'package:inject0r/inject0r.dart';
import 'package:inject0r_example/app.dart';
import 'package:inject0r_example/counter_cubit.dart';

void main() {
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

  runApp(
    ContainerScope.primary(
      serviceProvider: serviceProvider,
      child: const App(),
    ),
  );
}
