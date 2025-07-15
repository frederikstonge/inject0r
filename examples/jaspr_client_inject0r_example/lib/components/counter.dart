import 'package:inject0r_example/inject0r_example.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_inject0r/jaspr_inject0r.dart';
import 'package:jaspr_inject0r_bloc/jaspr_inject0r_bloc.dart';

class Counter extends StatelessComponent {
  const Counter({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'counter', [
      button(
        onClick: () {
          context.get<CounterCubit>().decrement();
        },
        [text('-')],
      ),
      BlocConsumer<CounterCubit, int>(
        listener: (context, state) => print('Counter value: $state'),
        builder: (context, state) sync* {
          yield span([text('$state')]);
        },
      ),
      button(
        onClick: () {
          context.get<CounterCubit>().increment();
        },
        [text('+')],
      ),
    ]);
  }
}
