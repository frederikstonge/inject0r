import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inject0r/flutter_inject0r.dart';
import 'package:flutter_inject0r_bloc/flutter_inject0r_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inject0r/inject0r.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  void increment() => emit(state + 1);
}

/// Helper to wrap a widget inside a ContainerScope with a registered cubit.
Widget _wrapWithScope({
  required Widget child,
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
    testWidgets('renders initial state', (tester) async {
      final cubit = CounterCubit();

      await tester.pumpWidget(
        _wrapWithScope(
          cubit: cubit,
          child: BlocBuilder<CounterCubit, int>(
            builder: (context, state) => Text(
              '$state',
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('rebuilds on state change', (tester) async {
      final cubit = CounterCubit();

      await tester.pumpWidget(
        _wrapWithScope(
          cubit: cubit,
          child: BlocBuilder<CounterCubit, int>(
            builder: (context, state) => Text(
              '$state',
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      cubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('respects rebuildWhen', (tester) async {
      final cubit = CounterCubit();

      await tester.pumpWidget(
        _wrapWithScope(
          cubit: cubit,
          child: BlocBuilder<CounterCubit, int>(
            rebuildWhen: (prev, curr) => curr.isEven,
            builder: (context, state) => Text(
              '$state',
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      cubit.increment(); // 1 — odd, should not rebuild
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);

      cubit.increment(); // 2 — even, should rebuild
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('uses provided bloc instance instead of container',
        (tester) async {
      final cubit = CounterCubit();

      await tester.pumpWidget(
        _wrapWithScope(
          child: BlocBuilder<CounterCubit, int>(
            bloc: cubit,
            builder: (context, state) => Text(
              '$state',
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      cubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('resolves bloc by key from container', (tester) async {
      final cubit = CounterCubit()..increment(); // start at 1

      await tester.pumpWidget(
        _wrapWithScope(
          cubit: cubit,
          key: 'myKey',
          child: BlocBuilder<CounterCubit, int>(
            blocKey: 'myKey',
            builder: (context, state) => Text(
              '$state',
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('cancels subscription on dispose', (tester) async {
      final cubit = CounterCubit();

      await tester.pumpWidget(
        _wrapWithScope(
          cubit: cubit,
          child: BlocBuilder<CounterCubit, int>(
            builder: (context, state) => Text(
              '$state',
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      );

      // Remove from tree
      await tester.pumpWidget(
        _wrapWithScope(child: const SizedBox()),
      );

      // Emitting after dispose should not cause errors
      cubit.increment();
      await tester.pumpAndSettle();
    });
  });

  group('BlocListener', () {
    testWidgets('calls listener on state change', (tester) async {
      final cubit = CounterCubit();
      final states = <int>[];

      await tester.pumpWidget(
        _wrapWithScope(
          cubit: cubit,
          child: BlocListener<CounterCubit, int>(
            listener: (context, state) => states.add(state),
            child: const SizedBox(),
          ),
        ),
      );

      cubit.increment();
      await tester.pumpAndSettle();

      expect(states, [1]);
    });

    testWidgets('does not call listener for initial state', (tester) async {
      final cubit = CounterCubit();
      final states = <int>[];

      await tester.pumpWidget(
        _wrapWithScope(
          cubit: cubit,
          child: BlocListener<CounterCubit, int>(
            listener: (context, state) => states.add(state),
            child: const SizedBox(),
          ),
        ),
      );

      expect(states, isEmpty);
    });

    testWidgets('respects listenWhen', (tester) async {
      final cubit = CounterCubit();
      final states = <int>[];

      await tester.pumpWidget(
        _wrapWithScope(
          cubit: cubit,
          child: BlocListener<CounterCubit, int>(
            listenWhen: (prev, curr) => curr.isEven,
            listener: (context, state) => states.add(state),
            child: const SizedBox(),
          ),
        ),
      );

      cubit.increment(); // 1 — odd, skip
      await tester.pumpAndSettle();

      cubit.increment(); // 2 — even, listen
      await tester.pumpAndSettle();

      cubit.increment(); // 3 — odd, skip
      await tester.pumpAndSettle();

      expect(states, [2]);
    });

    testWidgets('uses provided bloc instance', (tester) async {
      final cubit = CounterCubit();
      final states = <int>[];

      await tester.pumpWidget(
        _wrapWithScope(
          child: BlocListener<CounterCubit, int>(
            bloc: cubit,
            listener: (context, state) => states.add(state),
            child: const SizedBox(),
          ),
        ),
      );

      cubit.increment();
      await tester.pumpAndSettle();

      expect(states, [1]);
    });

    testWidgets('renders child widget', (tester) async {
      final cubit = CounterCubit();

      await tester.pumpWidget(
        _wrapWithScope(
          cubit: cubit,
          child: BlocListener<CounterCubit, int>(
            listener: (_, __) {},
            child: const Text('child', textDirection: TextDirection.ltr),
          ),
        ),
      );

      expect(find.text('child'), findsOneWidget);
    });

    testWidgets('cancels subscription on dispose', (tester) async {
      final cubit = CounterCubit();
      final states = <int>[];

      await tester.pumpWidget(
        _wrapWithScope(
          cubit: cubit,
          child: BlocListener<CounterCubit, int>(
            listener: (context, state) => states.add(state),
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pumpWidget(
        _wrapWithScope(child: const SizedBox()),
      );

      cubit.increment();
      await tester.pumpAndSettle();

      expect(states, isEmpty);
    });
  });

  group('BlocConsumer', () {
    testWidgets('renders initial state and listens', (tester) async {
      final cubit = CounterCubit();
      final listenedStates = <int>[];

      await tester.pumpWidget(
        _wrapWithScope(
          cubit: cubit,
          child: BlocConsumer<CounterCubit, int>(
            listener: (context, state) => listenedStates.add(state),
            builder: (context, state) => Text(
              '$state',
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
      expect(listenedStates, isEmpty);

      cubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(listenedStates, [1]);
    });

    testWidgets('respects listenWhen and rebuildWhen independently',
        (tester) async {
      final cubit = CounterCubit();
      final listenedStates = <int>[];

      await tester.pumpWidget(
        _wrapWithScope(
          cubit: cubit,
          child: BlocConsumer<CounterCubit, int>(
            listenWhen: (prev, curr) => curr.isOdd,
            rebuildWhen: (prev, curr) => curr.isEven,
            listener: (context, state) => listenedStates.add(state),
            builder: (context, state) => Text(
              '$state',
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      cubit.increment(); // 1 — odd: listen yes, rebuild no
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget); // no rebuild
      expect(listenedStates, [1]);

      cubit.increment(); // 2 — even: listen no, rebuild yes
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
      expect(listenedStates, [1]); // no new listen
    });

    testWidgets('uses provided bloc instance', (tester) async {
      final cubit = CounterCubit();

      await tester.pumpWidget(
        _wrapWithScope(
          child: BlocConsumer<CounterCubit, int>(
            bloc: cubit,
            listener: (_, __) {},
            builder: (context, state) => Text(
              '$state',
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      );

      cubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('cancels subscription on dispose', (tester) async {
      final cubit = CounterCubit();
      final listenedStates = <int>[];

      await tester.pumpWidget(
        _wrapWithScope(
          cubit: cubit,
          child: BlocConsumer<CounterCubit, int>(
            listener: (context, state) => listenedStates.add(state),
            builder: (context, state) => Text(
              '$state',
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        _wrapWithScope(child: const SizedBox()),
      );

      cubit.increment();
      await tester.pumpAndSettle();

      expect(listenedStates, isEmpty);
    });
  });
}
