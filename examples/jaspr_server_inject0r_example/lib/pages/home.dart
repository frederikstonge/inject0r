import 'package:jaspr/jaspr.dart';
import 'package:jaspr_inject0r/jaspr_inject0r.dart';

import '../components/counter.dart';

class Home extends StatelessComponent {
  const Home({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
   final message = context.get<String>();
    final number = context.get<int>();
    final pi = context.get<double>();
    yield section([
      img(src: 'images/logo.svg', width: 80),
      h1([text('Welcome')]),
      p([text('You successfully create a new Jaspr site.')]),
      p([text(message)]),
      p([text('Number: $number')]),
      p([text('Pi: $pi')]),
      div(styles: Styles(height: 100.px), []),
      const Counter(),
    ]);
  }
}
