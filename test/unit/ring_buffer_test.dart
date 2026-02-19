import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/live/ring_buffer.dart';

void main() {
  // ===========================================================================
  // RING BUFFER - CONSTRUCTION
  // ===========================================================================
  group('RingBuffer - Construction', () {
    test('creates with given capacity', () {
      final buffer = RingBuffer<int>(10);

      expect(buffer.capacity, 10);
      expect(buffer.length, 0);
      expect(buffer.isEmpty, isTrue);
    });

    test('creates empty buffer', () {
      final buffer = RingBuffer<int>(5);

      expect(buffer.isEmpty, isTrue);
      expect(buffer.isNotEmpty, isFalse);
      expect(buffer.isFull, isFalse);
    });
  });

  // ===========================================================================
  // PROPERTIES
  // ===========================================================================
  group('RingBuffer - Properties', () {
    test('length returns current count', () {
      final buffer = RingBuffer<int>(5);

      buffer.add(1);
      expect(buffer.length, 1);

      buffer.add(2);
      buffer.add(3);
      expect(buffer.length, 3);
    });

    test('isEmpty returns true when empty', () {
      final buffer = RingBuffer<int>(5);
      expect(buffer.isEmpty, isTrue);

      buffer.add(1);
      expect(buffer.isEmpty, isFalse);
    });

    test('isNotEmpty returns true when has items', () {
      final buffer = RingBuffer<int>(5);
      expect(buffer.isNotEmpty, isFalse);

      buffer.add(1);
      expect(buffer.isNotEmpty, isTrue);
    });

    test('isFull returns true at capacity', () {
      final buffer = RingBuffer<int>(3);

      buffer.add(1);
      buffer.add(2);
      expect(buffer.isFull, isFalse);

      buffer.add(3);
      expect(buffer.isFull, isTrue);
    });

    test('totalAdded tracks all additions', () {
      final buffer = RingBuffer<int>(3);

      buffer.add(1);
      buffer.add(2);
      buffer.add(3);
      buffer.add(4);
      buffer.add(5);

      expect(buffer.totalAdded, 5);
    });

    test('totalEvicted tracks evictions', () {
      final buffer = RingBuffer<int>(3);

      buffer.add(1);
      buffer.add(2);
      buffer.add(3);
      expect(buffer.totalEvicted, 0);

      buffer.add(4);
      expect(buffer.totalEvicted, 1);

      buffer.add(5);
      expect(buffer.totalEvicted, 2);
    });

    test('available returns remaining slots', () {
      final buffer = RingBuffer<int>(5);

      expect(buffer.available, 5);

      buffer.add(1);
      buffer.add(2);
      expect(buffer.available, 3);

      buffer.add(3);
      buffer.add(4);
      buffer.add(5);
      expect(buffer.available, 0);
    });
  });

  // ===========================================================================
  // ADD OPERATIONS
  // ===========================================================================
  group('RingBuffer - Add Operations', () {
    test('add returns null when not evicting', () {
      final buffer = RingBuffer<int>(5);

      final evicted = buffer.add(1);

      expect(evicted, isNull);
    });

    test('add returns evicted item when at capacity', () {
      final buffer = RingBuffer<int>(3);

      buffer.add(1);
      buffer.add(2);
      buffer.add(3);

      final evicted = buffer.add(4);

      expect(evicted, 1);
      expect(buffer.toList(), [2, 3, 4]);
    });

    test('addAll adds multiple items', () {
      final buffer = RingBuffer<int>(5);

      buffer.addAll([1, 2, 3]);

      expect(buffer.toList(), [1, 2, 3]);
    });

    test('addAll returns evicted items', () {
      final buffer = RingBuffer<int>(3);

      buffer.add(1);
      buffer.add(2);
      buffer.add(3);

      final evicted = buffer.addAll([4, 5]);

      expect(evicted, [1, 2]);
      expect(buffer.toList(), [3, 4, 5]);
    });
  });

  // ===========================================================================
  // ACCESS OPERATIONS
  // ===========================================================================
  group('RingBuffer - Access Operations', () {
    test('operator[] returns item at logical index', () {
      final buffer = RingBuffer<int>(5);

      buffer.addAll([10, 20, 30, 40]);

      expect(buffer[0], 10);
      expect(buffer[1], 20);
      expect(buffer[2], 30);
      expect(buffer[3], 40);
    });

    test('operator[] throws RangeError for invalid index', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([1, 2, 3]);

      expect(() => buffer[-1], throwsRangeError);
      expect(() => buffer[3], throwsRangeError);
    });

    test('first returns oldest item', () {
      final buffer = RingBuffer<int>(5);

      buffer.addAll([10, 20, 30]);

      expect(buffer.first, 10);
    });

    test('first throws StateError when empty', () {
      final buffer = RingBuffer<int>(5);

      expect(() => buffer.first, throwsStateError);
    });

    test('last returns newest item', () {
      final buffer = RingBuffer<int>(5);

      buffer.addAll([10, 20, 30]);

      expect(buffer.last, 30);
    });

    test('last throws StateError when empty', () {
      final buffer = RingBuffer<int>(5);

      expect(() => buffer.last, throwsStateError);
    });

    test('firstOrNull returns oldest item or null', () {
      final buffer = RingBuffer<int>(5);

      expect(buffer.firstOrNull, isNull);

      buffer.add(10);
      expect(buffer.firstOrNull, 10);
    });

    test('lastOrNull returns newest item or null', () {
      final buffer = RingBuffer<int>(5);

      expect(buffer.lastOrNull, isNull);

      buffer.add(10);
      expect(buffer.lastOrNull, 10);
    });

    test('fromEnd returns item from end', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30, 40]);

      expect(buffer.fromEnd(0), 40);
      expect(buffer.fromEnd(1), 30);
      expect(buffer.fromEnd(2), 20);
      expect(buffer.fromEnd(3), 10);
    });

    test('fromEnd returns null for invalid index', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([1, 2, 3]);

      expect(buffer.fromEnd(-1), isNull);
      expect(buffer.fromEnd(3), isNull);
    });

    test('getRange returns range of items', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30, 40, 50]);

      expect(buffer.getRange(1, 4), [20, 30, 40]);
    });

    test('getRange handles invalid ranges', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30]);

      expect(buffer.getRange(-1, 2), [10, 20]);
      expect(buffer.getRange(1, 10), [20, 30]);
      expect(buffer.getRange(3, 2), <int>[]);
    });

    test('lastN returns newest items', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30, 40, 50]);

      expect(buffer.lastN(3), [30, 40, 50]);
    });

    test('lastN handles edge cases', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30]);

      expect(buffer.lastN(0), <int>[]);
      expect(buffer.lastN(10), [10, 20, 30]);
    });

    test('firstN returns oldest items', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30, 40, 50]);

      expect(buffer.firstN(3), [10, 20, 30]);
    });

    test('firstN handles edge cases', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30]);

      expect(buffer.firstN(0), <int>[]);
      expect(buffer.firstN(10), [10, 20, 30]);
    });
  });

  // ===========================================================================
  // SEARCH OPERATIONS
  // ===========================================================================
  group('RingBuffer - Search Operations', () {
    test('indexWhere finds first matching item', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30, 20, 50]);

      expect(buffer.indexWhere((x) => x == 20), 1);
    });

    test('indexWhere returns -1 when not found', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30]);

      expect(buffer.indexWhere((x) => x == 100), -1);
    });

    test('lastIndexWhere finds last matching item', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30, 20, 50]);

      expect(buffer.lastIndexWhere((x) => x == 20), 3);
    });

    test('lastIndexWhere returns -1 when not found', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30]);

      expect(buffer.lastIndexWhere((x) => x == 100), -1);
    });

    test('binarySearch finds item in sorted buffer', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30, 40, 50]);

      expect(buffer.binarySearch(30, (a, b) => a.compareTo(b)), 2);
    });

    test('binarySearch returns negative for missing item', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 40, 50]);

      final index = buffer.binarySearch(30, (a, b) => a.compareTo(b));

      expect(index, lessThan(0));
      expect(-(index + 1), 2); // Insertion point
    });

    test('lowerBound finds insertion point', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 40, 50]);

      expect(buffer.lowerBound(30, (a, b) => a.compareTo(b)), 2);
      expect(buffer.lowerBound(20, (a, b) => a.compareTo(b)), 1);
    });
  });

  // ===========================================================================
  // REMOVAL OPERATIONS
  // ===========================================================================
  group('RingBuffer - Removal Operations', () {
    test('removeFirst removes and returns oldest item', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30]);

      final removed = buffer.removeFirst();

      expect(removed, 10);
      expect(buffer.toList(), [20, 30]);
    });

    test('removeFirst returns null when empty', () {
      final buffer = RingBuffer<int>(5);

      final removed = buffer.removeFirst();

      expect(removed, isNull);
    });

    test('removeFirstN removes multiple oldest items', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30, 40, 50]);

      final count = buffer.removeFirstN(3);

      expect(count, 3);
      expect(buffer.toList(), [40, 50]);
    });

    test('removeFirstN handles edge cases', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30]);

      expect(buffer.removeFirstN(0), 0);
      expect(buffer.removeFirstN(10), 3);
      expect(buffer.isEmpty, isTrue);
    });

    test('removeWhile removes matching items from front', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30, 40, 50]);

      final count = buffer.removeWhile((x) => x < 35);

      expect(count, 3);
      expect(buffer.toList(), [40, 50]);
    });

    test('removeWhile stops at first non-match', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30, 10, 50]);

      final count = buffer.removeWhile((x) => x < 25);

      expect(count, 2);
      expect(buffer.toList(), [30, 10, 50]);
    });

    test('clear removes all items', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30]);

      buffer.clear();

      expect(buffer.isEmpty, isTrue);
      expect(buffer.length, 0);
    });
  });

  // ===========================================================================
  // MODIFICATION OPERATIONS
  // ===========================================================================
  group('RingBuffer - Modification Operations', () {
    test('replaceAt replaces item at index', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30]);

      buffer.replaceAt(1, 25);

      expect(buffer.toList(), [10, 25, 30]);
    });

    test('replaceAt throws RangeError for invalid index', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30]);

      expect(() => buffer.replaceAt(-1, 99), throwsRangeError);
      expect(() => buffer.replaceAt(3, 99), throwsRangeError);
    });

    test('replaceLast replaces newest item', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30]);

      buffer.replaceLast(35);

      expect(buffer.toList(), [10, 20, 35]);
    });

    test('replaceLast does nothing when empty', () {
      final buffer = RingBuffer<int>(5);

      buffer.replaceLast(99);

      expect(buffer.isEmpty, isTrue);
    });
  });

  // ===========================================================================
  // CONVERSION
  // ===========================================================================
  group('RingBuffer - Conversion', () {
    test('toList returns copy of items', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30]);

      final list = buffer.toList();

      expect(list, [10, 20, 30]);

      // Modify list doesn't affect buffer
      list[0] = 99;
      expect(buffer[0], 10);
    });

    test('toList returns empty list when empty', () {
      final buffer = RingBuffer<int>(5);

      expect(buffer.toList(), isEmpty);
    });

    test('toList with growable parameter', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30]);

      final growable = buffer.toList(growable: true);
      final fixed = buffer.toList(growable: false);

      growable.add(40); // Should work
      expect(() => fixed.add(40), throwsUnsupportedError);
    });

    test('asUnmodifiableView returns view without copy', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30]);

      final view = buffer.asUnmodifiableView();

      expect(view.length, 3);
      expect(view[0], 10);
      expect(view[1], 20);
      expect(view[2], 30);
    });

    test('asUnmodifiableView is unmodifiable', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30]);

      final view = buffer.asUnmodifiableView();

      expect(() => view[0] = 99, throwsUnsupportedError);
      expect(() => view.length = 5, throwsUnsupportedError);
    });

    test('iterator iterates in order', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30]);

      final items = <int>[];
      for (final item in buffer) {
        items.add(item);
      }

      expect(items, [10, 20, 30]);
    });
  });

  // ===========================================================================
  // RESIZE
  // ===========================================================================
  group('RingBuffer - Resize', () {
    test('resized creates buffer with new capacity', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30]);

      final resized = buffer.resized(10);

      expect(resized.capacity, 10);
      expect(resized.toList(), [10, 20, 30]);
    });

    test('resized keeps newest items when shrinking', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30, 40, 50]);

      final resized = buffer.resized(3);

      expect(resized.capacity, 3);
      expect(resized.toList(), [30, 40, 50]);
    });

    test('resized preserves statistics', () {
      final buffer = RingBuffer<int>(3);
      buffer.addAll([10, 20, 30, 40, 50]);

      final resized = buffer.resized(5);

      expect(resized.totalAdded, buffer.totalAdded);
      expect(resized.totalEvicted, buffer.totalEvicted);
    });

    test('resized throws for invalid capacity', () {
      final buffer = RingBuffer<int>(5);

      expect(() => buffer.resized(0), throwsArgumentError);
      expect(() => buffer.resized(-1), throwsArgumentError);
    });
  });

  // ===========================================================================
  // CIRCULAR BEHAVIOR
  // ===========================================================================
  group('RingBuffer - Circular Behavior', () {
    test('wraps around correctly', () {
      final buffer = RingBuffer<int>(3);

      buffer.add(1);
      buffer.add(2);
      buffer.add(3);
      expect(buffer.toList(), [1, 2, 3]);

      buffer.add(4);
      expect(buffer.toList(), [2, 3, 4]);

      buffer.add(5);
      expect(buffer.toList(), [3, 4, 5]);

      buffer.add(6);
      expect(buffer.toList(), [4, 5, 6]);
    });

    test('maintains FIFO order after wrap', () {
      final buffer = RingBuffer<int>(3);
      buffer.addAll([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

      expect(buffer.first, 8);
      expect(buffer.last, 10);
      expect(buffer.toList(), [8, 9, 10]);
    });

    test('access works after multiple wraps', () {
      final buffer = RingBuffer<int>(3);

      for (int i = 1; i <= 100; i++) {
        buffer.add(i);
      }

      expect(buffer[0], 98);
      expect(buffer[1], 99);
      expect(buffer[2], 100);
    });
  });

  // ===========================================================================
  // TO STRING
  // ===========================================================================
  group('RingBuffer - toString', () {
    test('toString returns descriptive string', () {
      final buffer = RingBuffer<int>(5);
      buffer.addAll([10, 20, 30]);

      final str = buffer.toString();

      expect(str, contains('RingBuffer'));
      expect(str, contains('capacity: 5'));
      expect(str, contains('length: 3'));
    });
  });

  // ===========================================================================
  // ITERATOR EDGE CASES
  // ===========================================================================
  group('RingBuffer - Iterator Edge Cases', () {
    test('iterator current throws before moveNext', () {
      final buffer = RingBuffer<int>(5);
      buffer.add(1);

      final iterator = buffer.iterator;

      expect(() => iterator.current, throwsStateError);
    });

    test('iterator current throws after exhaustion', () {
      final buffer = RingBuffer<int>(5);
      buffer.add(1);

      final iterator = buffer.iterator;
      iterator.moveNext();
      iterator.moveNext(); // Past end

      expect(() => iterator.current, throwsStateError);
    });
  });
}
