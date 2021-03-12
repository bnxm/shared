extension MapExtensions<K, V> on Map<K, V> {
  V? get(String key) => this[key];
}
