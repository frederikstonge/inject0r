import 'package:bloc/bloc.dart';
import 'package:jaspr/client.dart';
import 'package:jaspr_inject0r/jaspr_inject0r.dart';

import 'bloc_listener.dart';

class BlocSelector<TBloc extends StateStreamable<TState>, TState, TSelected>
    extends StatefulComponent {
  final Component Function(BuildContext context, TSelected state) builder;
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
    _bloc = component.bloc ?? context.get<TBloc>(key: component.blocKey);
    _state = component.selector(_bloc.state);
    

    super.initState();
  }

  @override
  void didUpdateComponent(BlocSelector<TBloc, TState, TSelected> oldComponent) {
    super.didUpdateComponent(oldComponent);
    final oldBloc = oldComponent.bloc ?? context.get<TBloc>();
    final currentBloc = component.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      _bloc = currentBloc;
      _state = component.selector(_bloc.state);
    } else if (oldComponent.selector != component.selector) {
      _state = component.selector(_bloc.state);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = component.bloc ?? context.get<TBloc>();
    if (_bloc != bloc) {
      _bloc = bloc;
      _state = component.selector(_bloc.state);
    }
  }

  @override
  Component build(BuildContext context) {
     return BlocListener<TBloc, TState>(
      bloc: _bloc,
      listenWhen: component.rebuildWhen,
      listener: (context, state) {
        final selectedState = component.selector(state);
        if (_state != selectedState) setState(() => _state = selectedState);
      },
      child: component.builder(context, _state),
    );
  }
}
