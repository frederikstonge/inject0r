import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:inject0r/inject0r.dart';

class BlocConsumer<TBloc extends StateStreamable<TState>, TState>
    extends StatefulWidget {
  final void Function(BuildContext context, TState state) listener;
  final Widget Function(BuildContext context, TState state) builder;
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
    _bloc = widget.bloc ?? context.get<TBloc>(key: widget.blocKey);
    _state = _bloc.state;
    _subscription = _bloc.stream.listen((data) {
      if (widget.listenWhen == null || widget.listenWhen!(_state, data)) {
        if (mounted) {
          widget.listener(context, data);
        }
      }

      if (widget.rebuildWhen == null || widget.rebuildWhen!(_state, data)) {
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
  Widget build(BuildContext context) {
    return widget.builder(context, _state);
  }
}
