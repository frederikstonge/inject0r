import 'package:flutter/material.dart';
import 'package:inject0r/inject0r.dart';
import 'package:inject0r_bloc/inject0r_bloc.dart';
import 'package:inject0r_example/counter_cubit.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final message = context.get<String>();
    final number = context.get<int>();
    final pi = context.get<double>();

    return BlocConsumer<CounterCubit, int>(
      blocKey: 'test',
      listener: (context, state) => print('Cubit value: $state'),
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Inject0r Example')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(message),
                Text('Number: $number'),
                Text('Pi: $pi'),
                Text('Counter: $state'),
                ElevatedButton(
                  onPressed: () {
                    context.get<CounterCubit>(key: 'test').increment();
                  },
                  child: const Text('Increment Counter'),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.get<CounterCubit>(key: 'test').decrement();
                  },
                  child: const Text('Decrement Counter'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
