import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/live/ring_buffer.dart';

void main() {
  group('RingBuffer', () {
    group('construction', () {
      test('creates buffer with given capacity', () {
        final buffer = RingBuffer<int>(10);
        expect(buffer.capacity, 10);
        expect(buffer.isEmpty, true);
        expect(buffer.length, 0);
      });

      test('throws on zero capacity', () {
        expect(() => RingBuffer<int>(0), throwsA(isA<AssertionError>()));
      });

      test('throws on negative capacity', () {
        expect(() => RingBuffer<int>(-1), throwsA(isA<AssertionError>()));
      });
    });

    group('add', () {
      test('adds items to buffer', () {
        final buffer = RingBuffer<int>(5);
        buffer.add(1);
        buffer.add(2);
        buffer.add(3);

        expect(buffer.length, 3);
        expect(buffer.toList(), [1, 2, 3]);
      });

      test('returns null when not at capacity', () {
        final buffer = RingBuffer<int>(5);
        expect(buffer.add(1), isNull);
        expect(buffer.add(2), isNull);
      });

      test('evicts oldest when at capacity', () {
        final buffer = RingBuffer<int>(3);
        buffer.add(1);
        buffer.add(2);
        buffer.add(3);

        final evicted = buffer.add(4);
        expect(evicted, 1);
        expect(buffer.toList(), [2, 3, 4]);
      });

      test('tracks totalAdded correctly', () {
        final buffer = RingBuffer<int>(3);
        buffer.add(1);
        buffer.add(2);
        buffer.add(3);
        buffer.add(4);

        expect(buffer.totalAdded, 4);
      });

      test('tracks totalEvicted correctly', () {
        final buffer = RingBuffer<int>(3);
        buffer.add(1);
        buffer.add(2);
        buffer.add(3);
        buffer.add(4);
        buffer.add(5);

        expect(buffer.totalEvicted, 2);
      });
    });

    group('addAll', () {
      test('adds multiple items', () {
        final buffer = RingBuffer<int>(10);
        buffer.addAll([1, 2, 3, 4, 5]);

        expect(buffer.length, 5);
        expect(buffer.toList(), [1, 2, 3, 4, 5]);
      });

      test('returns evicted items', () {
        final buffer = RingBuffer<int>(3);
        buffer.add(1);
        buffer.add(2);
        buffer.add(3);

        final evicted = buffer.addAll([4, 5, 6]);
        expect(evicted, [1, 2, 3]);
        expect(buffer.toList(), [4, 5, 6]);
      });
    });

    group('access', () {
      test('operator[] returns correct item', () {
        final buffer = RingBuffer<int>(5);
        buffer.addAll([10, 20, 30, 40, 50]);

        expect(buffer[0], 10);
        expect(buffer[2], 30);
        expect(buffer[4], 50);
      });

      test('operator[] throws on out of bounds', () {
        final buffer = RingBuffer<int>(5);
        buffer.addAll([1, 2, 3]);

        expect(() => buffer[-1], throwsRangeError);
        expect(() => buffer[3], throwsRangeError);
        expect(() => buffer[5], throwsRangeError);
      });

      test('first returns oldest item', () {
        final buffer = RingBuffer<int>(5);
        buffer.addAll([1, 2, 3]);

        expect(buffer.first, 1);
      });

      test('first throws on empty buffer', () {
        final buffer = RingBuffer<int>(5);
        expect(() => buffer.first, throwsStateError);
      });

      test('last returns newest item', () {
        final buffer = RingBuffer<int>(5);
        buffer.addAll([1, 2, 3]);

        expect(buffer.last, 3);
      });

      test('last throws on empty buffer', () {
        final buffer = RingBuffer<int>(5);
        expect(() => buffer.last, throwsStateError);
      });

      test('firstOrNull returns oldest item or null', () {
        final buffer = RingBuffer<int>(5);
        expect(buffer.firstOrNull, isNull);

        buffer.add(1);
        expect(buffer.firstOrNull, 1);
      });

      test('lastOrNull returns newest item or null', () {
        final buffer = RingBuffer<int>(5);
        expect(buffer.lastOrNull, isNull);

        buffer.add(1);
        expect(buffer.lastOrNull, 1);
      });

      test('fromEnd returns item from end', () {
        final buffer = RingBuffer<int>(5);
        buffer.addAll([1, 2, 3, 4, 5]);

        expect(buffer.fromEnd(0), 5);
        expect(buffer.fromEnd(1), 4);
        expect(buffer.fromEnd(4), 1);
        expect(buffer.fromEnd(5), isNull);
      });
    });

    group('getRange', () {
      test('returns range of items', () {
        final buffer = RingBuffer<int>(10);
        buffer.addAll([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

        expect(buffer.getRange(2, 5), [2, 3, 4]);
        expect(buffer.getRange(0, 3), [0, 1, 2]);
        expect(buffer.getRange(7, 10), [7, 8, 9]);
      });

      test('handles bounds clamping', () {
        final buffer = RingBuffer<int>(5);
        buffer.addAll([1, 2, 3, 4, 5]);

        expect(buffer.getRange(-2, 3), [1, 2, 3]);
        expect(buffer.getRange(3, 10), [4, 5]);
      });

      test('returns empty for invalid range', () {
        final buffer = RingBuffer<int>(5);
        buffer.addAll([1, 2, 3]);

        expect(buffer.getRange(5, 10), isEmpty);
        expect(buffer.getRange(3, 1), isEmpty);
      });
    });

    group('lastN and firstN', () {
      test('lastN returns last n items', () {
        final buffer = RingBuffer<int>(10);
        buffer.addAll([1, 2, 3, 4, 5]);

        expect(buffer.lastN(3), [3, 4, 5]);
        expect(buffer.lastN(10), [1, 2, 3, 4, 5]);
        expect(buffer.lastN(0), isEmpty);
      });

      test('firstN returns first n items', () {
        final buffer = RingBuffer<int>(10);
        buffer.addAll([1, 2, 3, 4, 5]);

        expect(buffer.firstN(3), [1, 2, 3]);
        expect(buffer.firstN(10), [1, 2, 3, 4, 5]);
        expect(buffer.firstN(0), isEmpty);
      });
    });

    group('search', () {
      test('indexWhere finds matching item', () {
        final buffer = RingBuffer<int>(10);
        buffer.addAll([1, 2, 3, 4, 5]);

        expect(buffer.indexWhere((x) => x == 3), 2);
        expect(buffer.indexWhere((x) => x > 3), 3);
        expect(buffer.indexWhere((x) => x > 10), -1);
      });

      test('lastIndexWhere finds last matching item', () {
        final buffer = RingBuffer<int>(10);
        buffer.addAll([1, 2, 3, 2, 1]);

        expect(buffer.lastIndexWhere((x) => x == 2), 3);
        expect(buffer.lastIndexWhere((x) => x > 10), -1);
      });

      test('binarySearch finds item in sorted buffer', () {
        final buffer = RingBuffer<int>(10);
        buffer.addAll([10, 20, 30, 40, 50]);

        expect(buffer.binarySearch(30, (a, b) => a.compareTo(b)), 2);
        expect(buffer.binarySearch(10, (a, b) => a.compareTo(b)), 0);
        expect(buffer.binarySearch(50, (a, b) => a.compareTo(b)), 4);
      });

      test('binarySearch returns negative for missing item', () {
        final buffer = RingBuffer<int>(10);
        buffer.addAll([10, 20, 30, 40, 50]);

        final result = buffer.binarySearch(25, (a, b) => a.compareTo(b));
        expect(result, isNegative);
        // Insertion point would be index 2
        expect(-(result + 1), 2);
      });
    });

    group('removal', () {
      test('removeFirst removes oldest item', () {
        final buffer = RingBuffer<int>(5);
        buffer.addAll([1, 2, 3, 4, 5]);

        expect(buffer.removeFirst(), 1);
        expect(buffer.length, 4);
        expect(buffer.toList(), [2, 3, 4, 5]);
      });

      test('removeFirst returns null on empty buffer', () {
        final buffer = RingBuffer<int>(5);
        expect(buffer.removeFirst(), isNull);
      });

      test('removeFirstN removes n oldest items', () {
        final buffer = RingBuffer<int>(10);
        buffer.addAll([1, 2, 3, 4, 5]);

        expect(buffer.removeFirstN(3), 3);
        expect(buffer.length, 2);
        expect(buffer.toList(), [4, 5]);
      });

      test('removeFirstN clamps to length', () {
        final buffer = RingBuffer<int>(10);
        buffer.addAll([1, 2, 3]);

        expect(buffer.removeFirstN(10), 3);
        expect(buffer.isEmpty, true);
      });

      test('removeWhile removes matching items from front', () {
        final buffer = RingBuffer<int>(10);
        buffer.addAll([1, 2, 3, 10, 20, 30]);

        final removed = buffer.removeWhile((x) => x < 5);
        expect(removed, 3);
        expect(buffer.toList(), [10, 20, 30]);
      });

      test('removeWhile stops at first non-matching item', () {
        final buffer = RingBuffer<int>(10);
        buffer.addAll([1, 2, 10, 3, 4]);

        final removed = buffer.removeWhile((x) => x < 5);
        expect(removed, 2);
        expect(buffer.toList(), [10, 3, 4]);
      });

      test('clear removes all items', () {
        final buffer = RingBuffer<int>(10);
        buffer.addAll([1, 2, 3, 4, 5]);

        buffer.clear();
        expect(buffer.isEmpty, true);
        expect(buffer.length, 0);
      });
    });

    group('modification', () {
      test('replaceAt replaces item at index', () {
        final buffer = RingBuffer<int>(5);
        buffer.addAll([1, 2, 3, 4, 5]);

        buffer.replaceAt(2, 100);
        expect(buffer.toList(), [1, 2, 100, 4, 5]);
      });

      test('replaceAt throws on out of bounds', () {
        final buffer = RingBuffer<int>(5);
        buffer.addAll([1, 2, 3]);

        expect(() => buffer.replaceAt(3, 100), throwsRangeError);
      });

      test('replaceLast replaces newest item', () {
        final buffer = RingBuffer<int>(5);
        buffer.addAll([1, 2, 3, 4, 5]);

        buffer.replaceLast(100);
        expect(buffer.toList(), [1, 2, 3, 4, 100]);
      });

      test('replaceLast does nothing on empty buffer', () {
        final buffer = RingBuffer<int>(5);
        buffer.replaceLast(100); // Should not throw
        expect(buffer.isEmpty, true);
      });
    });

    group('iteration', () {
      test('iterator returns items in order', () {
        final buffer = RingBuffer<int>(5);
        buffer.addAll([1, 2, 3, 4, 5]);

        final items = <int>[];
        for (final item in buffer) {
          items.add(item);
        }
        expect(items, [1, 2, 3, 4, 5]);
      });

      test('toList creates copy', () {
        final buffer = RingBuffer<int>(5);
        buffer.addAll([1, 2, 3]);

        final list = buffer.toList();
        list.add(4);

        expect(buffer.length, 3);
        expect(list.length, 4);
      });

      test('asUnmodifiableView returns view', () {
        final buffer = RingBuffer<int>(5);
        buffer.addAll([1, 2, 3]);

        final view = buffer.asUnmodifiableView();
        expect(view.length, 3);
        expect(view[0], 1);

        // Should throw on modification
        expect(() => view.add(4), throwsUnsupportedError);
      });
    });

    group('resize', () {
      test('resized creates new buffer with same items', () {
        final buffer = RingBuffer<int>(5);
        buffer.addAll([1, 2, 3, 4, 5]);

        final newBuffer = buffer.resized(10);
        expect(newBuffer.capacity, 10);
        expect(newBuffer.toList(), [1, 2, 3, 4, 5]);
      });

      test('resized evicts oldest when shrinking', () {
        final buffer = RingBuffer<int>(10);
        buffer.addAll([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

        final newBuffer = buffer.resized(5);
        expect(newBuffer.capacity, 5);
        expect(newBuffer.toList(), [6, 7, 8, 9, 10]);
      });

      test('resized throws on invalid capacity', () {
        final buffer = RingBuffer<int>(5);
        expect(() => buffer.resized(0), throwsArgumentError);
        expect(() => buffer.resized(-1), throwsArgumentError);
      });
    });

    group('circular behavior', () {
      test('maintains order after wrap-around', () {
        final buffer = RingBuffer<int>(3);

        // Fill and overflow
        buffer.add(1);
        buffer.add(2);
        buffer.add(3);
        buffer.add(4); // Evicts 1
        buffer.add(5); // Evicts 2

        expect(buffer.toList(), [3, 4, 5]);
        expect(buffer.first, 3);
        expect(buffer.last, 5);
      });

      test('handles multiple wrap-arounds', () {
        final buffer = RingBuffer<int>(3);

        for (int i = 1; i <= 10; i++) {
          buffer.add(i);
        }

        expect(buffer.toList(), [8, 9, 10]);
      });

      test('access works correctly after wrap-around', () {
        final buffer = RingBuffer<int>(3);
        buffer.addAll([1, 2, 3, 4, 5]);

        expect(buffer[0], 3);
        expect(buffer[1], 4);
        expect(buffer[2], 5);
      });
    });

    group('edge cases', () {
      test('single capacity buffer', () {
        final buffer = RingBuffer<int>(1);

        buffer.add(1);
        expect(buffer.toList(), [1]);

        buffer.add(2);
        expect(buffer.toList(), [2]);

        buffer.add(3);
        expect(buffer.toList(), [3]);
      });

      test('works with nullable types', () {
        final buffer = RingBuffer<int?>(5);
        buffer.add(1);
        buffer.add(null);
        buffer.add(3);

        expect(buffer.toList(), [1, null, 3]);
      });

      test('works with complex objects', () {
        final buffer = RingBuffer<Map<String, int>>(3);
        buffer.add({'a': 1});
        buffer.add({'b': 2});
        buffer.add({'c': 3});

        expect(buffer[1]['b'], 2);
      });
    });
  });
}
