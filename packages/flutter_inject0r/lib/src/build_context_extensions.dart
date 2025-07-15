import 'package:flutter/widgets.dart';
import 'container_scope.dart';

extension InheritedContainerScopeExtensions on BuildContext {
  /// Get instance of type [T] from the container scope.
  T get<T>({String? key}) {
    return ContainerScope.get<T>(context: this, key: key);
  }
}
