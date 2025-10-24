import 'package:flutter/material.dart';

import 'dart:math' as math;

import '../../data/fusion_data_point.dart';
import '../fusion_coordinate_system.dart';

/// QuadTree spatial index for O(log n) point queries.
///
/// **Problem:** Linear search for nearest point is O(n):
/// ```dart
/// // Bad: O(n) - slow for 1000+ points
/// for (final point in allPoints) {
///   if (distance(tapPosition, point) < minDistance) {
///     nearest = point;
///   }
/// }
/// ```
///
/// **Solution:** QuadTree reduces search to O(log n)
///
/// ## Performance Comparison
///
/// | Points | Linear Search | QuadTree | Speedup |
/// |--------|--------------|----------|---------|
/// | 100    | 100 ops      | 7 ops    | 14x     |
/// | 1,000  | 1,000 ops    | 10 ops   | 100x    |
/// | 10,000 | 10,000 ops   | 13 ops   | 769x    |
///
/// ## Example
///
/// ```dart
/// // Build index from data points
/// final index = FusionSpatialIndex(dataPoints, coordSystem);
///
/// // Find nearest point to tap position
/// final nearest = index.findNearest(tapPosition, maxDistance: 30.0);
///
/// // Find all points in radius
/// final nearby = index.findInRadius(tapPosition, radius: 50.0);
/// ```
class FusionSpatialIndex {
  FusionSpatialIndex({
    required List<FusionDataPoint> dataPoints,
    required this.coordSystem,
    this.maxPointsPerNode = 4,
    this.maxDepth = 8,
  }) {
    // Build QuadTree from data points
    final bounds = coordSystem.chartArea;
    _root = _QuadTreeNode(bounds, 0, maxPointsPerNode, maxDepth);

    // Insert all points
    for (final point in dataPoints) {
      final screenPos = coordSystem.dataToScreen(point);
      _root!.insert(_IndexedPoint(point, screenPos));
    }
  }

  final FusionCoordinateSystem coordSystem;
  final int maxPointsPerNode;
  final int maxDepth;

  _QuadTreeNode? _root;

  // ==========================================================================
  // QUERY OPERATIONS
  // ==========================================================================

  /// Finds the nearest point to a screen position.
  ///
  /// Returns null if no point within maxDistance.
  FusionDataPoint? findNearest(Offset screenPosition, {double maxDistance = double.infinity}) {
    if (_root == null) return null;

    final candidates = _root!.query(
      Rect.fromCenter(center: screenPosition, width: maxDistance * 2, height: maxDistance * 2),
    );

    if (candidates.isEmpty) return null;

    FusionDataPoint? nearest;
    double minDist = maxDistance;

    for (final candidate in candidates) {
      final dist = (candidate.screenPosition - screenPosition).distance;
      if (dist < minDist) {
        minDist = dist;
        nearest = candidate.dataPoint;
      }
    }

    return nearest;
  }

  /// Finds all points within a radius.
  List<FusionDataPoint> findInRadius(Offset screenPosition, {required double radius}) {
    if (_root == null) return [];

    final candidates = _root!.query(
      Rect.fromCenter(center: screenPosition, width: radius * 2, height: radius * 2),
    );

    final result = <FusionDataPoint>[];
    final radiusSq = radius * radius;

    for (final candidate in candidates) {
      final distSq = (candidate.screenPosition - screenPosition).distanceSquared;
      if (distSq <= radiusSq) {
        result.add(candidate.dataPoint);
      }
    }

    return result;
  }

  /// Finds all points in a rectangle.
  List<FusionDataPoint> findInRect(Rect rect) {
    if (_root == null) return [];

    final candidates = _root!.query(rect);
    return candidates.map((p) => p.dataPoint).toList();
  }

  /// Finds points along a line with tolerance.
  List<FusionDataPoint> findAlongLine(Offset start, Offset end, {double tolerance = 10.0}) {
    if (_root == null) return [];

    // Create bounding box for line
    final minX = math.min(start.dx, end.dx) - tolerance;
    final maxX = math.max(start.dx, end.dx) + tolerance;
    final minY = math.min(start.dy, end.dy) - tolerance;
    final maxY = math.max(start.dy, end.dy) + tolerance;

    final bounds = Rect.fromLTRB(minX, minY, maxX, maxY);
    final candidates = _root!.query(bounds);

    // Filter by distance to line
    final result = <FusionDataPoint>[];

    for (final candidate in candidates) {
      final dist = _distanceToLineSegment(candidate.screenPosition, start, end);
      if (dist <= tolerance) {
        result.add(candidate.dataPoint);
      }
    }

    return result;
  }

  /// Finds the closest point on a line segment to a point.
  double _distanceToLineSegment(Offset point, Offset lineStart, Offset lineEnd) {
    final dx = lineEnd.dx - lineStart.dx;
    final dy = lineEnd.dy - lineStart.dy;

    if (dx == 0 && dy == 0) {
      return (point - lineStart).distance;
    }

    final t =
        ((point.dx - lineStart.dx) * dx + (point.dy - lineStart.dy) * dy) / (dx * dx + dy * dy);

    final clampedT = t.clamp(0.0, 1.0);
    final closestPoint = Offset(lineStart.dx + clampedT * dx, lineStart.dy + clampedT * dy);

    return (point - closestPoint).distance;
  }

  // ==========================================================================
  // INDEX MANAGEMENT
  // ==========================================================================

  /// Rebuilds the index.
  void rebuild(List<FusionDataPoint> dataPoints) {
    _root = null;

    final bounds = coordSystem.chartArea;
    _root = _QuadTreeNode(bounds, 0, maxPointsPerNode, maxDepth);

    for (final point in dataPoints) {
      final screenPos = coordSystem.dataToScreen(point);
      _root!.insert(_IndexedPoint(point, screenPos));
    }
  }

  /// Clears the index.
  void clear() {
    _root = null;
  }

  // ==========================================================================
  // STATISTICS
  // ==========================================================================

  /// Gets statistics about the QuadTree.
  QuadTreeStatistics get statistics {
    if (_root == null) {
      return QuadTreeStatistics(totalPoints: 0, nodeCount: 0, maxDepth: 0, avgPointsPerLeaf: 0);
    }

    int nodeCount = 0;
    int leafCount = 0;
    int totalPointsInLeaves = 0;
    int maxDepthFound = 0;

    void traverse(_QuadTreeNode node, int depth) {
      nodeCount++;
      maxDepthFound = math.max(maxDepthFound, depth);

      if (node.isLeaf) {
        leafCount++;
        totalPointsInLeaves += node.points.length;
      } else {
        if (node.topLeft != null) traverse(node.topLeft!, depth + 1);
        if (node.topRight != null) traverse(node.topRight!, depth + 1);
        if (node.bottomLeft != null) traverse(node.bottomLeft!, depth + 1);
        if (node.bottomRight != null) traverse(node.bottomRight!, depth + 1);
      }
    }

    traverse(_root!, 0);

    return QuadTreeStatistics(
      totalPoints: totalPointsInLeaves,
      nodeCount: nodeCount,
      maxDepth: maxDepthFound,
      avgPointsPerLeaf: leafCount > 0 ? totalPointsInLeaves / leafCount : 0,
    );
  }

  @override
  String toString() {
    final stats = statistics;
    return 'FusionSpatialIndex('
        'points: ${stats.totalPoints}, '
        'nodes: ${stats.nodeCount}, '
        'depth: ${stats.maxDepth}'
        ')';
  }
}

// ==========================================================================
// QUADTREE NODE
// ==========================================================================

class _QuadTreeNode {
  _QuadTreeNode(this.bounds, this.depth, this.maxPointsPerNode, this.maxDepth);

  final Rect bounds;
  final int depth;
  final int maxPointsPerNode;
  final int maxDepth;

  final List<_IndexedPoint> points = [];

  _QuadTreeNode? topLeft;
  _QuadTreeNode? topRight;
  _QuadTreeNode? bottomLeft;
  _QuadTreeNode? bottomRight;

  bool get isLeaf => topLeft == null;

  /// Inserts a point into the tree.
  bool insert(_IndexedPoint point) {
    // Check if point is within bounds
    if (!bounds.contains(point.screenPosition)) {
      return false;
    }

    // If leaf and has capacity, add here
    if (isLeaf && points.length < maxPointsPerNode) {
      points.add(point);
      return true;
    }

    // If at max depth, force add here
    if (depth >= maxDepth) {
      points.add(point);
      return true;
    }

    // Subdivide if needed
    if (isLeaf) {
      _subdivide();
    }

    // Insert into appropriate child
    if (topLeft!.insert(point)) return true;
    if (topRight!.insert(point)) return true;
    if (bottomLeft!.insert(point)) return true;
    if (bottomRight!.insert(point)) return true;

    // Fallback: shouldn't happen
    points.add(point);
    return true;
  }

  /// Subdivides this node into 4 children.
  void _subdivide() {
    final midX = (bounds.left + bounds.right) / 2;
    final midY = (bounds.top + bounds.bottom) / 2;

    topLeft = _QuadTreeNode(
      Rect.fromLTRB(bounds.left, bounds.top, midX, midY),
      depth + 1,
      maxPointsPerNode,
      maxDepth,
    );

    topRight = _QuadTreeNode(
      Rect.fromLTRB(midX, bounds.top, bounds.right, midY),
      depth + 1,
      maxPointsPerNode,
      maxDepth,
    );

    bottomLeft = _QuadTreeNode(
      Rect.fromLTRB(bounds.left, midY, midX, bounds.bottom),
      depth + 1,
      maxPointsPerNode,
      maxDepth,
    );

    bottomRight = _QuadTreeNode(
      Rect.fromLTRB(midX, midY, bounds.right, bounds.bottom),
      depth + 1,
      maxPointsPerNode,
      maxDepth,
    );

    // Redistribute points to children
    final pointsToRedistribute = List<_IndexedPoint>.from(points);
    points.clear();

    for (final point in pointsToRedistribute) {
      if (!topLeft!.insert(point)) {
        if (!topRight!.insert(point)) {
          if (!bottomLeft!.insert(point)) {
            if (!bottomRight!.insert(point)) {
              points.add(point); // Fallback
            }
          }
        }
      }
    }
  }

  /// Queries all points within a rectangle.
  List<_IndexedPoint> query(Rect queryBounds) {
    final result = <_IndexedPoint>[];

    // No intersection
    if (!bounds.overlaps(queryBounds)) {
      return result;
    }

    // If leaf, check all points
    if (isLeaf) {
      for (final point in points) {
        if (queryBounds.contains(point.screenPosition)) {
          result.add(point);
        }
      }
      return result;
    }

    // Query children
    if (topLeft != null) result.addAll(topLeft!.query(queryBounds));
    if (topRight != null) result.addAll(topRight!.query(queryBounds));
    if (bottomLeft != null) result.addAll(bottomLeft!.query(queryBounds));
    if (bottomRight != null) result.addAll(bottomRight!.query(queryBounds));

    // Add any points stored in this non-leaf node (edge case)
    for (final point in points) {
      if (queryBounds.contains(point.screenPosition)) {
        result.add(point);
      }
    }

    return result;
  }
}

// ==========================================================================
// INDEXED POINT
// ==========================================================================

class _IndexedPoint {
  const _IndexedPoint(this.dataPoint, this.screenPosition);

  final FusionDataPoint dataPoint;
  final Offset screenPosition;
}

// ==========================================================================
// QUADTREE STATISTICS
// ==========================================================================

class QuadTreeStatistics {
  const QuadTreeStatistics({
    required this.totalPoints,
    required this.nodeCount,
    required this.maxDepth,
    required this.avgPointsPerLeaf,
  });

  final int totalPoints;
  final int nodeCount;
  final int maxDepth;
  final double avgPointsPerLeaf;

  @override
  String toString() {
    return 'QuadTreeStatistics('
        'points: $totalPoints, '
        'nodes: $nodeCount, '
        'depth: $maxDepth, '
        'avgPerLeaf: ${avgPointsPerLeaf.toStringAsFixed(1)}'
        ')';
  }
}
