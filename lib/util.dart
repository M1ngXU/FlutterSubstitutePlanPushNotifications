import 'package:quiver/collection.dart';

typedef JsonObject = Map<String, dynamic>;
typedef JsonArray = List<JsonObject>;

TreeSet<T> singleTreeSet<T>(T item) => doubleTreeSet(item, item);
TreeSet<T> doubleTreeSet<T>(T item1, T item2) {
  TreeSet<T> t = TreeSet();
  t.addAll([item1, item2]);
  return t;
}

bool deepEqualSet<T>(Set<T> set1, Set<T> set2) => set1.length == set2.length && set1.difference(set2).isEmpty;

List<T> castListOr<T>(Object? t, List<T> def) => t is List<dynamic> && !t.any((e) => e is! T) ? t.cast<T>() : def;
JsonArray castToJsonArray(Object? t) => castListOr(t, []);
/// casts `t` to `T` if it is possible, otherwise returns `def`
T castOr<T>(Object? t, T def) => t is T ? t : def;
JsonObject? getKey(JsonObject? json, String key) => castOr(json?[key], null);