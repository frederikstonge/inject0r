// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_static_inject0r_example/components/counter.dart'
    as prefix0;
import 'package:jaspr_static_inject0r_example/components/header.dart'
    as prefix1;
import 'package:jaspr_static_inject0r_example/pages/about.dart' as prefix2;
import 'package:jaspr_static_inject0r_example/app.dart' as prefix3;

/// Default [JasprOptions] for use with your jaspr project.
///
/// Use this to initialize jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'jaspr_options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultJasprOptions,
///   );
///
///   runApp(...);
/// }
/// ```
JasprOptions get defaultJasprOptions => JasprOptions(
  clients: {prefix3.App: ClientTarget<prefix3.App>('app')},
  styles: () => [
    ...prefix0.Counter.styles,
    ...prefix1.Header.styles,
    ...prefix2.About.styles,
    ...prefix3.AppState.styles,
  ],
);
