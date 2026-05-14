import 'package:bloc/bloc.dart';
import 'package:inject0r/inject0r.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_inject0r/jaspr_inject0r.dart';
import 'package:jaspr_inject0r_bloc/jaspr_inject0r_bloc.dart';
import 'package:jaspr_test/jaspr_test.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  void increment() => emit(state + 1);
}

/// Helper to wrap a component inside a ContainerScope with a registered cubit.
Component _wrapWithScope({
  required Component child,
  CounterCubit? cubit,
  String? key,
}) {
  final sp = ServiceProvider<BuildContext>();
  if (cubit != null) {
    sp.registerSingleton<CounterCubit>(
      create: (_) => cubit,
      key: key,
      dispose: (c) => c.close(),
    );
  }

  return ContainerScope.primary(
    serviceProvider: sp,
    child: child,
  );
}

void main() {
  group('BlocBuilder', () {
    testComponents('renders initial state', (tester) async {
      final cubit = CounterCubit();

      tester.pumpComponent(
        _wrapWithScope(
          cubit: cubit,
          child: BlocBuilder<CounterCubit, int>(
            builder: (context, state) => span([
              Component.text('$state'),
            ]),
          ),
        ),
      );

      expect(find.text('0'), findsOneComponent);
    });

    testComponents('rebuilds on state change', (tester) async {
      final cubit = CounterCubit();

      tester.pumpComponent(
        _wrapWithScope(
          cubit: cubit,
          child: BlocBuilder<CounterCubit, int>(
            builder: (context, state) => span([
              Component.text('$state'),
            ]),
          ),
        ),
      );

      expect(find.text('0'), findsOneComponent);

      cubit.increment();
      await tester.pump();

      expect(find.text('1'), findsOneComponent);
    });

    testComponents('respects rebuildWhen', (tester) async {
      final cubit = CounterCubit();

      tester.pumpComponent(
        _wrapWithScope(
          cubit: cubit,
          child: BlocBuilder<CounterCubit, int>(
            rebuildWhen: (prev, curr) => curr.isEven,
            builder: (context, state) => span([
              Component.text('$state'),
            ]),
          ),
        ),
      );

      expect(find.text('0'), findsOneComponent);

      cubit.increment(); // 1 — odd, should not rebuild
      await tester.pump();
      expect(find.text('0'), findsOneComponent);

      cubit.increment(); // 2 — even, should rebuild
      await tester.pump();
      expect(find.text('2'), findsOneComponent);
    });

    testComponents('uses provided bloc instance instead of container',
        (tester) async {
      final cubit = CounterCubit();

      tester.pumpComponent(
        _wrapWithScope(
          child: BlocBuilder<CounterCubit, int>(
            bloc: cubit,
            builder: (context, state) => span([
              Component.text('$state'),
            ]),
          ),
        ),
      );

      expect(find.text('0'), findsOneComponent);

      cubit.increment();
      await tester.pump();

      expect(find.text('1'), findsOneComponent);
    });

    testComponents('resolves bloc by key from container', (tester) async {
      final cubit = CounterCubit()..increment(); // start at 1

      tester.pumpComponent(
        _wrapWithScope(
          cubit: cubit,
          key: 'myKey',
          child: BlocBuilder<CounterCubit, int>(
            blocKey: 'myKey',
            builder: (context, state) => span([
              Component.text('$state'),
            ]),
          ),
        ),
      );

      expect(find.text('1'), findsOneComponent);
    });
  });

  group('BlocListener', () {
    testComponents('calls listener on state change', (tester) async {
      final cubit = CounterCubit();
      final states = <int>[];

      tester.pumpComponent(
        _wrapWithScope(
          cubit: cubit,
          child: BlocListener<CounterCubit, int>(
            listener: (context, state) => states.add(state),
            child: div([]),
          ),
        ),
      );

      cubit.increment();
      await tester.pump();

      expect(states, [1]);
    });

    testComponents('does not call listener for initial state', (tester) async {
      final cubit = CounterCubit();
      final states = <int>[];

      tester.pumpComponent(
        _wrapWithScope(
          cubit: cubit,
          child: BlocListener<CounterCubit, int>(
            listener: (context, state) => states.add(state),
            child: div([]),
          ),
        ),
      );

      expect(states, isEmpty);
    });

    testComponents('respects listenWhen', (tester) async {
      final cubit = CounterCubit();
      final states = <int>[];

      tester.pumpComponent(
        _wrapWithScope(
          cubit: cubit,
          child: BlocListener<CounterCubit, int>(
            listenWhen: (prev, curr) => curr.isEven,
            listener: (context, state) => states.add(state),
            child: div([]),
          ),
        ),
      );

      cubit.increment(); // 1 — odd, skip
      await tester.pump();

      cubit.increment(); // 2 — even, listen
      await tester.pump();

      cubit.increment(); // 3 — odd, skip
      await tester.pump();

      expect(states, [2]);
    });

    testComponents('uses provided bloc instance', (tester) async {
      final cubit = CounterCubit();
      final states = <int>[];

      tester.pumpComponent(
        _wrapWithScope(
          child: BlocListener<CounterCubit, int>(
            bloc: cubit,
            listener: (context, state) => states.add(state),
            child: div([]),
          ),
        ),
      );

      cubit.increment();
      await tester.pump();

      expect(states, [1]);
    });

    testComponents('renders child component', (tester) async {
      final cubit = CounterCubit();

      tester.pumpComponent(
        _wrapWithScope(
          cubit: cubit,
          child: BlocListener<CounterCubit, int>(
            listener: (_, _) {},
            child: span([
              Component.text('child'),
            ]),
          ),
        ),
      );

      expect(find.text('child'), findsOneComponent);
    });
  });

  group('BlocConsumer', () {
    testComponents('renders initial state and listens', (tester) async {
      final cubit = CounterCubit();
      final listenedStates = <int>[];

      tester.pumpComponent(
        _wrapWithScope(
          cubit: cubit,
          child: BlocConsumer<CounterCubit, int>(
            listener: (context, state) => listenedStates.add(state),
            builder: (context, state) => span([
              Component.text('$state'),
            ]),
          ),
        ),
      );

      expect(find.text('0'), findsOneComponent);
      expect(listenedStates, isEmpty);

      cubit.increment();
      await tester.pump();

      expect(find.text('1'), findsOneComponent);
      expect(listenedStates, [1]);
    });

    testComponents('respects listenWhen and rebuildWhen independently',
        (tester) async {
      final cubit = CounterCubit();
      final listenedStates = <int>[];

      tester.pumpComponent(
        _wrapWithScope(
          cubit: cubit,
          child: BlocConsumer<CounterCubit, int>(
            listenWhen: (prev, curr) => curr.isOdd,
            rebuildWhen: (prev, curr) => curr.isEven,
            listener: (context, state) => listenedStates.add(state),
            builder: (context, state) => span([
              Component.text('$state'),
            ]),
          ),
        ),
      );

      expect(find.text('0'), findsOneComponent);

      cubit.increment(); // 1 — odd: listen yes, rebuild no
      await tester.pump();
      expect(find.text('0'), findsOneComponent);
      expect(listenedStates, [1]);

      cubit.increment(); // 2 — even: listen no, rebuild yes
      await tester.pump();
      expect(find.text('2'), findsOneComponent);
      expect(listenedStates, [1]);
    });

    testComponents('uses provided bloc instance', (tester) async {
      final cubit = CounterCubit();

      tester.pumpComponent(
        _wrapWithScope(
          child: BlocConsumer<CounterCubit, int>(
            bloc: cubit,
            listener: (_, _) {},
            builder: (context, state) => span([
              Component.text('$state'),
            ]),
          ),
        ),
      );

      cubit.increment();
      await tester.pump();

      expect(find.text('1'), findsOneComponent);
    });
  });
}
