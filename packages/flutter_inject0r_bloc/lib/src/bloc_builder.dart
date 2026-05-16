import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inject0r/flutter_inject0r.dart';

class BlocBuilder<TBloc extends StateStreamable<TState>, TState>
    extends StatefulWidget {
  final Widget Function(BuildContext context, TState state) builder;
  final TBloc? bloc;
  final String? blocKey;
  final bool Function(TState previous, TState current)? rebuildWhen;

  const BlocBuilder({
    super.key,
    required this.builder,
    this.bloc,
    this.blocKey,
    this.rebuildWhen,
  }) : assert(
         bloc == null || blocKey == null,
         'You cannot provide both a bloc and a blocKey. Use one or the other.',
       );

  @override
  State<BlocBuilder<TBloc, TState>> createState() =>
      _BlocBuilderState<TBloc, TState>();
}

class _BlocBuilderState<TBloc extends StateStreamable<TState>, TState>
    extends State<BlocBuilder<TBloc, TState>> {
  late TBloc _bloc;
  late TState _state;
  late TState _previousState;
  late StreamSubscription<TState> _subscription;

  @override
  void initState() {
    _bloc = widget.bloc ?? context.get<TBloc>(key: widget.blocKey);
    _state = _bloc.state;
    _previousState = _state;
    _subscribe();
    super.initState();
  }

  @override
  void didUpdateWidget(BlocBuilder<TBloc, TState> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentBloc = widget.bloc ?? context.get<TBloc>(key: widget.blocKey);
    if (_bloc != currentBloc) {
      _subscription.cancel();
      _bloc = currentBloc;
      _previousState = _bloc.state;
      _state = _bloc.state;
      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentBloc = widget.bloc ?? context.get<TBloc>(key: widget.blocKey);
    if (_bloc != currentBloc) {
      _subscription.cancel();
      _bloc = currentBloc;
      _previousState = _bloc.state;
      _state = _bloc.state;
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription = _bloc.stream.listen((data) {
      if (widget.rebuildWhen == null || widget.rebuildWhen!(_previousState, data)) {
        if (mounted) {
          setState(() {
            _state = data;
          });
        }
      }
      _previousState = data;
    });
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
