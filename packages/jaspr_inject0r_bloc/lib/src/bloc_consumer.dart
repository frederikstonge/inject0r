import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_inject0r/jaspr_inject0r.dart';

class BlocConsumer<TBloc extends StateStreamable<TState>, TState>
    extends StatefulComponent {
  final void Function(BuildContext context, TState state) listener;
  final Component Function(BuildContext context, TState state) builder;
  final TBloc? bloc;
  final String? blocKey;
  final bool Function(TState previous, TState current)? listenWhen;
  final bool Function(TState previous, TState current)? rebuildWhen;

  const BlocConsumer({
    super.key,
    required this.listener,
    required this.builder,
    this.bloc,
    this.blocKey,
    this.listenWhen,
    this.rebuildWhen,
  }) : assert(
         bloc == null || blocKey == null,
         'You cannot provide both a bloc and a blocKey. Use one or the other.',
       );

  @override
  State<BlocConsumer<TBloc, TState>> createState() =>
      _BlocConsumerState<TBloc, TState>();
}

class _BlocConsumerState<TBloc extends StateStreamable<TState>, TState>
    extends State<BlocConsumer<TBloc, TState>> {
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

      if (component.rebuildWhen == null ||
          component.rebuildWhen!(_state, data)) {
        if (mounted) {
          setState(() {
            _state = data;
          });
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
  Component build(BuildContext context) {
    return component.builder(context, _state);
  }
}
