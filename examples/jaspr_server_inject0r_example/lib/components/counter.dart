import 'package:inject0r_example/inject0r_example.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_inject0r/jaspr_inject0r.dart';
import 'package:jaspr_inject0r_bloc/jaspr_inject0r_bloc.dart';
import 'package:jaspr_server_inject0r_example/constants/theme.dart';

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

  @css
  static List<StyleRule> get styles => [
    css('.counter', [
      css('&').styles(
        display: Display.flex,
        padding: Padding.symmetric(vertical: 10.px),
        border: Border.symmetric(vertical: BorderSide.solid(color: primaryColor, width: 2.px)),
        alignItems: AlignItems.center,
      ),
      css('button', [
        css('&').styles(
          display: Display.flex,
          width: 2.em,
          height: 2.em, 
          border: Border.unset, 
          radius: BorderRadius.all(Radius.circular(2.em)),
          cursor: Cursor.pointer,
          justifyContent: JustifyContent.center, 
          alignItems: AlignItems.center,
          fontSize: 2.rem,
          backgroundColor: Colors.transparent,
        ),
        css('&:hover').styles(
          backgroundColor: const Color('#0001'),
        ),
      ]),
      css('span').styles(
        minWidth: 2.5.em,
        padding: Padding.symmetric(horizontal: 2.rem),
        boxSizing: BoxSizing.borderBox, 
        color: primaryColor, 
        textAlign: TextAlign.center,
        fontSize: 4.rem,
      ),
    ]),
  ];
}
