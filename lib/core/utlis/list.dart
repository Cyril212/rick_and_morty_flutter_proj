/// Convenience class for easy autoimport
class ListExtensionDummy {}

extension ListExtension<E> on List<E> {
  /// Returns the first element that satisfies the given predicate or null.
  E? firstWhereOrNull(bool test(E element)) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }

  /// Returns the last element that satisfies the given predicate or null
  E? lastWhereOrNull(bool test(E element)) {
    try {
      late E result;
      bool foundMatching = false;
      for (E element in this) {
        if (test(element)) {
          result = element;
          foundMatching = true;
        }
      }
      if (foundMatching) return result;
      throw new StateError("No element");
    } catch (e) {
      return null;
    }
  }
}
