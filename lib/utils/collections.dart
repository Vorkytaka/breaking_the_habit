extension ListUtils<E> on List<E> {
  E? firstOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
