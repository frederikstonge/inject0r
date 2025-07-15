import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_inject0r/jaspr_inject0r.dart';

class BlocListener<TBloc extends StateStreamable<TState>, TState>
    extends StatefulComponent {
  final void Function(BuildContext context, TState state) listener;
  final TBloc? bloc;
  final String? blocKey;
  final bool Function(TState previous, TState current)? listenWhen;
  final Iterable<Component> children;

  const BlocListener({
    super.key,
    required this.listener,
    required this.children,
    this.bloc,
    this.blocKey,
    this.listenWhen,
  }) : assert(
         bloc == null || blocKey == null,
         'You cannot provide both a bloc and a blocKey. Use one or the other.',
       );

  @override
  State<BlocListener<TBloc, TState>> createState() =>
      _BlocListenerState<TBloc, TState>();
}

class _BlocListenerState<TBloc extends StateStreamable<TState>, TState>
    extends State<BlocListener<TBloc, TState>> {
  late TBloc _bloc;
  late TState _state;
  late StreamSubscription<TState> _subscription;

  @override
  void initState() {
    _bloc = component.bloc ?? context.get<TBloc>(key: component.blocKey);
    _state = _bloc.state;
    _subscription = _bloc.stream.listen((data) {
      if (component.listenWhen == null || component.listenWhen!(_state, data)) {
        if (mounted) {
          component.listener(context, data);
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Iterable<Component> build(BuildContext context) {
    return component.children;
  }
}
