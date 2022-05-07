import 'package:quiver/collection.dart';

typedef JSONObject = Map<String, dynamic>;
typedef JSONArray = List<JSONObject>;

TreeSet<T> singleTreeSet<T>(T item) => doubleTreeSet(item, item);

TreeSet<T> doubleTreeSet<T>(T item1, T item2) {
  TreeSet<T> t = TreeSet();
  t.addAll([item1, item2]);
  return t;
}

bool deepEqualSet<T>(Set<T> set1, Set<T> set2) => set1.length == set2.length && set1.difference(set2).isEmpty;