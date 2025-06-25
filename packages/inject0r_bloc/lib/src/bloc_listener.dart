import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:inject0r/inject0r.dart';

class BlocListener<TBloc extends StateStreamable<TState>, TState>
    extends StatefulWidget {
  final void Function(BuildContext context, TState state) listener;
  final TBloc? bloc;
  final String? blocKey;
  final bool Function(TState previous, TState current)? listenWhen;
  final Widget child;

  const BlocListener({
    super.key,
    required this.listener,
    required this.child,
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
    _bloc = widget.bloc ?? context.get<TBloc>(key: widget.blocKey);
    _state = _bloc.state;
    _subscription = _bloc.stream.listen((data) {
      if (widget.listenWhen == null || widget.listenWhen!(_state, data)) {
        if (mounted) {
          widget.listener(context, data);
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
    return widget.child;
  }
}
