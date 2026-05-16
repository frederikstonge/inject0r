import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inject0r/flutter_inject0r.dart';

import 'bloc_listener.dart';

class BlocSelector<TBloc extends StateStreamable<TState>, TState, TSelected>
    extends StatefulWidget {
  final Widget Function(BuildContext context, TSelected state) builder;
  final TSelected Function(TState state) selector;
  final TBloc? bloc;
  final String? blocKey;
  final bool Function(TState previous, TState current)? rebuildWhen;

  const BlocSelector({
    super.key,
    required this.builder,
    required this.selector,
    this.bloc,
    this.blocKey,
    this.rebuildWhen,
  }) : assert(
         bloc == null || blocKey == null,
         'You cannot provide both a bloc and a blocKey. Use one or the other.',
       );

  @override
  State<BlocSelector<TBloc, TState, TSelected>> createState() =>
      _BlocBuilderState<TBloc, TState, TSelected>();
}

class _BlocBuilderState<TBloc extends StateStreamable<TState>, TState, TSelected>
    extends State<BlocSelector<TBloc, TState, TSelected>> {
  late TBloc _bloc;
  late TSelected _state;

  @override
  void initState() {
    _bloc = widget.bloc ?? context.get<TBloc>(key: widget.blocKey);
    _state = widget.selector(_bloc.state);
    

    super.initState();
  }

  @override
  void didUpdateWidget(BlocSelector<TBloc, TState, TSelected> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? context.get<TBloc>();
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      _bloc = currentBloc;
      _state = widget.selector(_bloc.state);
    } else if (oldWidget.selector != widget.selector) {
      _state = widget.selector(_bloc.state);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? context.get<TBloc>();
    if (_bloc != bloc) {
      _bloc = bloc;
      _state = widget.selector(_bloc.state);
    }
  }

  @override
  Widget build(BuildContext context) {
     return BlocListener<TBloc, TState>(
      bloc: _bloc,
      listenWhen: widget.rebuildWhen,
      listener: (context, state) {
        final selectedState = widget.selector(state);
        if (_state != selectedState) setState(() => _state = selectedState);
      },
      child: widget.builder(context, _state),
    );
  }
}
