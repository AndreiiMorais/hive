part of hive_flutter;

/// Flutter extensions for boxes.
extension BoxX<T> on Box<T> {
  /// Returns a [ValueListenable] which notifies its listeners when an entry
  /// in the box changes.
  ///
  /// If [keys] filter is provided, only changes to entries with the
  /// specified keys notify the listeners.
  ValueListenable<Box<T>> listenable({List<dynamic>? keys}) =>
      _BoxListenable(this, keys?.toSet());

  Future<List<String>> getAllKeys() async {
    return keys
        .cast<String>()
        .map((key) => key)
        .map(Uri.decodeComponent)
        .toList();
  }

  Future<Map<String, T>> getAllValues() async {
    return toMap()
        .map((k, v) => MapEntry(Uri.decodeComponent(k.toString()), v));
  }

  Future<List<T?>> getAll(
    List<String> keys,
  ) async {
    final values = <T?>[];
    for (var key in keys) {
      values.add(get(key));
    }
    return values;
  }
}

/// Flutter extensions for lazy boxes.
extension LazyBoxX<T> on LazyBox<T> {
  /// Returns a [ValueListenable] which notifies its listeners when an entry
  /// in the box changes.
  ///
  /// If [keys] filter is provided, only changes to entries with the
  /// specified keys notify the listeners.
  ValueListenable<LazyBox<T>> listenable({List<dynamic>? keys}) =>
      _BoxListenable(this, keys?.toSet());

  Future<List<String>> getAllKeys() async {
    return keys
        .cast<String>()
        .map((key) => key)
        .map(Uri.decodeComponent)
        .toList();
  }

  Future<List<T?>> getAll(
    List<String> keys,
  ) async {
    final values = <T?>[];
    for (var key in keys) {
      values.add(await get(key));
    }
    return values;
  }
}

class _BoxListenable<T, B extends BoxBase<T>> extends ValueListenable<B> {
  final B box;

  final Set<dynamic>? keys;

  final List<VoidCallback> _listeners = [];

  StreamSubscription? _subscription;

  _BoxListenable(this.box, this.keys);

  @override
  void addListener(VoidCallback listener) {
    if (_listeners.isEmpty) {
      if (keys != null) {
        _subscription = box.watch().listen((event) {
          if (keys!.contains(event.key)) {
            for (var listener in _listeners) {
              listener();
            }
          }
        });
      } else {
        _subscription = box.watch().listen((_) {
          for (var listener in _listeners) {
            listener();
          }
        });
      }
    }

    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);

    if (_listeners.isEmpty) {
      _subscription?.cancel();
      _subscription = null;
    }
  }

  @override
  B get value => box;
}
