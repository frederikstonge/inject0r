import 'package:jaspr/jaspr.dart';
import 'package:jaspr_inject0r/jaspr_inject0r.dart';

extension InheritedContainerScopeExtensions on BuildContext {
  /// Get instance of type [T] from the container scope.
  T get<T>({String? key}) {
    return ContainerScope.get<T>(context: this, key: key);
  }
}
