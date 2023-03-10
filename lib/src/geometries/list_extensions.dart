import 'dart:typed_data';

extension ListExtension<T> on List<T> {
  void forEachIndexed<R>(void Function(T element, int index) action) {
    var index = 0;
    for (final element in this) {
      action(element, index++);
    }
  }

  List<R> mapIndexed<R>(R Function(T element, int index) toElement) {
    var index = 0, elements = <R>[];
    for (final element in this) {
      elements.add(toElement(element, index++));
    }
    return elements;
  }
}

extension Uint8ListExtension on Uint8List {
  Uint8List concat(Uint8List other) {
    var builder = BytesBuilder()
      ..add(this)
      ..add(other);
    return builder.takeBytes();
  }
}
