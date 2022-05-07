import 'package:quiver/collection.dart';

TreeSet<T> singleTreeSet<T>(T item) => doubleTreeSet(item, item);

TreeSet<T> doubleTreeSet<T>(T item1, T item2) {
  TreeSet<T> t = TreeSet();
  t.addAll([item1, item2]);
  return t;
}