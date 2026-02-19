import 'dart:collection';

/// Efficient circular buffer for live data storage.
///
/// O(1) insert, O(1) access, fixed memory footprint.
/// Thread-safe for single-writer, multiple-reader pattern.
///
/// Example:
/// ```dart
/// final buffer = RingBuffer<int>(5);
/// buffer.add(1);
/// buffer.add(2);
/// buffer.add(3);
/// print(buffer.toList()); // [1, 2, 3]
///
/// // When full, oldest items are evicted
/// buffer.addAll([4, 5, 6, 7]);
/// print(buffer.toList()); // [3, 4, 5, 6, 7]
/// ```
class RingBuffer<T> extends IterableBase<T> {
  /// Creates a ring buffer with the given [capacity].
  ///
  /// [capacity] must be greater than 0.
  RingBuffer(this.capacity)
    : assert(capacity > 0, 'Capacity must be positive'),
      _buffer = List<T?>.filled(capacity, null);

  /// The maximum number of items this buffer can hold.
  final int capacity;

  final List<T?> _buffer;
  int _head = 0; // Index of oldest element
  int _tail = 0; // Index where next element will be written
  int _count = 0;
  int _totalAdded = 0;
  int _totalEvicted = 0;

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  @override
  int get length => _count;

  @override
  bool get isEmpty => _count == 0;

  @override
  bool get isNotEmpty => _count > 0;

  /// Whether the buffer is at capacity.
  bool get isFull => _count == capacity;

  /// Total number of items added since creation.
  int get totalAdded => _totalAdded;

  /// Total number of items evicted due to capacity since creation.
  int get totalEvicted => _totalEvicted;

  /// Number of available slots before eviction occurs.
  int get available => capacity - _count;

  // ---------------------------------------------------------------------------
  // Add operations
  // ---------------------------------------------------------------------------

  /// Add item, evicting oldest if at capacity.
  ///
  /// Returns the evicted item, or null if no eviction occurred.
  T? add(T item) {
    T? evicted;

    if (_count == capacity) {
      evicted = _buffer[_head];
      _head = (_head + 1) % capacity;
      _totalEvicted++;
    } else {
      _count++;
    }

    _buffer[_tail] = item;
    _tail = (_tail + 1) % capacity;
    _totalAdded++;

    return evicted;
  }

  /// Add multiple items efficiently.
  ///
  /// Returns list of evicted items.
  List<T> addAll(Iterable<T> items) {
    final evicted = <T>[];
    for (final item in items) {
      final e = add(item);
      if (e != null) evicted.add(e);
    }
    return evicted;
  }

  // ---------------------------------------------------------------------------
  // Access operations
  // ---------------------------------------------------------------------------

  /// Get item at logical index (0 = oldest, length-1 = newest).
  ///
  /// Throws [RangeError] if index is out of bounds.
  T operator [](int index) {
    if (index < 0 || index >= _count) {
      throw RangeError.index(index, this, 'index', null, _count);
    }
    return _buffer[(_head + index) % capacity] as T;
  }

  /// Get oldest item.
  ///
  /// Throws [StateError] if buffer is empty.
  @override
  T get first {
    if (isEmpty) throw StateError('No element');
    return this[0];
  }

  /// Get newest item.
  ///
  /// Throws [StateError] if buffer is empty.
  @override
  T get last {
    if (isEmpty) throw StateError('No element');
    return this[_count - 1];
  }

  /// Get oldest item, or null if empty.
  T? get firstOrNull => isEmpty ? null : this[0];

  /// Get newest item, or null if empty.
  T? get lastOrNull => isEmpty ? null : this[_count - 1];

  /// Get item at index from the end (0 = newest, 1 = second newest).
  ///
  /// Returns null if index is out of bounds.
  T? fromEnd(int index) {
    if (index < 0 || index >= _count) return null;
    return this[_count - 1 - index];
  }

  /// Get a range of items [start, end).
  ///
  /// Returns an empty list if range is invalid.
  List<T> getRange(int start, int end) {
    final effectiveStart = start < 0 ? 0 : start;
    final effectiveEnd = end > _count ? _count : end;
    if (effectiveStart >= effectiveEnd) return [];

    return List<T>.generate(
      effectiveEnd - effectiveStart,
      (i) => this[effectiveStart + i],
    );
  }

  /// Get the last [count] items (newest).
  ///
  /// Returns all items if count exceeds length.
  List<T> lastN(int count) {
    if (count <= 0) return [];
    if (count >= _count) return toList();
    return getRange(_count - count, _count);
  }

  /// Get the first [count] items (oldest).
  ///
  /// Returns all items if count exceeds length.
  List<T> firstN(int count) {
    if (count <= 0) return [];
    if (count >= _count) return toList();
    return getRange(0, count);
  }

  // ---------------------------------------------------------------------------
  // Search operations
  // ---------------------------------------------------------------------------

  /// Find index of first item matching predicate, or -1 if not found.
  int indexWhere(bool Function(T) test) {
    for (int i = 0; i < _count; i++) {
      if (test(this[i])) return i;
    }
    return -1;
  }

  /// Find index of last item matching predicate, or -1 if not found.
  int lastIndexWhere(bool Function(T) test) {
    for (int i = _count - 1; i >= 0; i--) {
      if (test(this[i])) return i;
    }
    return -1;
  }

  /// Binary search for sorted data.
  ///
  /// Returns index of item, or negative value indicating insertion point.
  /// The insertion point is `-(returnValue + 1)`.
  ///
  /// Assumes buffer is sorted according to [compare].
  int binarySearch(T item, int Function(T a, T b) compare) {
    int low = 0;
    int high = _count - 1;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final cmp = compare(this[mid], item);

      if (cmp < 0) {
        low = mid + 1;
      } else if (cmp > 0) {
        high = mid - 1;
      } else {
        return mid;
      }
    }

    return -(low + 1);
  }

  /// Find the insertion point for [item] in a sorted buffer.
  ///
  /// Returns the index where [item] should be inserted to maintain sort order.
  int lowerBound(T item, int Function(T a, T b) compare) {
    final index = binarySearch(item, compare);
    return index >= 0 ? index : -(index + 1);
  }

  // ---------------------------------------------------------------------------
  // Removal operations
  // ---------------------------------------------------------------------------

  /// Remove and return the oldest item, or null if empty.
  T? removeFirst() {
    if (isEmpty) return null;

    final item = _buffer[_head] as T;
    _buffer[_head] = null;
    _head = (_head + 1) % capacity;
    _count--;

    return item;
  }

  /// Remove the first [count] items (oldest).
  ///
  /// Returns actual number of items removed.
  int removeFirstN(int count) {
    if (count <= 0) return 0;

    final toRemove = count.clamp(0, _count);

    for (int i = 0; i < toRemove; i++) {
      _buffer[_head] = null;
      _head = (_head + 1) % capacity;
    }

    _count -= toRemove;
    return toRemove;
  }

  /// Remove items matching predicate from the front (oldest).
  ///
  /// Stops at first non-matching item.
  /// Returns number of items removed.
  int removeWhile(bool Function(T) test) {
    int removed = 0;

    while (isNotEmpty && test(first)) {
      removeFirst();
      removed++;
    }

    return removed;
  }

  /// Clear all items.
  void clear() {
    for (int i = 0; i < capacity; i++) {
      _buffer[i] = null;
    }
    _head = 0;
    _tail = 0;
    _count = 0;
  }

  // ---------------------------------------------------------------------------
  // Modification operations
  // ---------------------------------------------------------------------------

  /// Replace item at logical index.
  ///
  /// Throws [RangeError] if index is out of bounds.
  void replaceAt(int index, T item) {
    if (index < 0 || index >= _count) {
      throw RangeError.index(index, this, 'index', null, _count);
    }
    _buffer[(_head + index) % capacity] = item;
  }

  /// Replace the newest item (last).
  ///
  /// Does nothing if buffer is empty.
  void replaceLast(T item) {
    if (isEmpty) return;
    _buffer[(_tail - 1 + capacity) % capacity] = item;
  }

  // ---------------------------------------------------------------------------
  // Conversion
  // ---------------------------------------------------------------------------

  /// Convert to list (creates copy).
  @override
  List<T> toList({bool growable = true}) {
    if (isEmpty) return growable ? <T>[] : List<T>.empty();

    final list = List<T>.generate(_count, (i) => this[i], growable: growable);
    return list;
  }

  /// Create unmodifiable view (no copy, wraps buffer).
  List<T> asUnmodifiableView() => _RingBufferListView(this);

  @override
  Iterator<T> get iterator => _RingBufferIterator(this);

  // ---------------------------------------------------------------------------
  // Resize
  // ---------------------------------------------------------------------------

  /// Resize buffer capacity.
  ///
  /// If shrinking, oldest items are evicted.
  /// Returns list of evicted items.
  RingBuffer<T> resized(int newCapacity) {
    if (newCapacity <= 0) {
      throw ArgumentError.value(newCapacity, 'newCapacity', 'must be positive');
    }

    final newBuffer = RingBuffer<T>(newCapacity);

    // If shrinking, only copy the newest items that fit
    if (_count > newCapacity) {
      final startIndex = _count - newCapacity;
      for (int i = startIndex; i < _count; i++) {
        newBuffer.add(this[i]);
      }
    } else {
      // Copy all items
      for (int i = 0; i < _count; i++) {
        newBuffer.add(this[i]);
      }
    }

    // Preserve statistics
    newBuffer._totalAdded = _totalAdded;
    newBuffer._totalEvicted =
        _totalEvicted + (_count > newCapacity ? _count - newCapacity : 0);

    return newBuffer;
  }

  // ---------------------------------------------------------------------------
  // Debug
  // ---------------------------------------------------------------------------

  @override
  String toString() {
    return 'RingBuffer(capacity: $capacity, length: $_count, items: ${toList()})';
  }
}

class _RingBufferIterator<T> implements Iterator<T> {
  _RingBufferIterator(this._buffer);

  final RingBuffer<T> _buffer;
  int _index = -1;

  @override
  T get current {
    if (_index < 0 || _index >= _buffer.length) {
      throw StateError('No current element');
    }
    return _buffer[_index];
  }

  @override
  bool moveNext() {
    _index++;
    return _index < _buffer.length;
  }
}

class _RingBufferListView<T> extends ListBase<T> {
  _RingBufferListView(this._buffer);

  final RingBuffer<T> _buffer;

  @override
  int get length => _buffer.length;

  @override
  set length(int newLength) =>
      throw UnsupportedError('Cannot resize unmodifiable view');

  @override
  T operator [](int index) => _buffer[index];

  @override
  void operator []=(int index, T value) =>
      throw UnsupportedError('Cannot modify unmodifiable view');
}
