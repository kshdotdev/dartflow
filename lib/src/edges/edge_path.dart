import 'dart:math' as math;
import 'dart:ui';

import '../models/flow_port.dart';
import 'path_segments.dart';

/// Default curvature used by [FlowEdgeStyle.bezier].
const double kDefaultEdgeCurvature = 0.5;

/// Default minimum extension out of a port before a wire may bend.
const double kDefaultPortExtension = 20;

/// Default rounded-corner radius for smoothstep edges.
const double kDefaultCornerRadius = 8;

/// Pure geometry helpers for building connection paths, hit-test rectangles,
/// and waypoint routing. All methods are coordinate-space agnostic: pass screen
/// or graph [Offset]s and the results come back in the same space.
abstract final class EdgePathMath {
  /// Whether [side] runs along the horizontal axis (left/right).
  static bool isHorizontal(PortSide side) =>
      side == PortSide.left || side == PortSide.right;

  /// Gets the extended point from a port in its facing direction.
  ///
  /// This ensures connections always start by moving OUTWARD from the port.
  static Offset getExtendedPoint(
    Offset point,
    PortSide position,
    double offset,
  ) {
    return switch (position) {
      PortSide.right => Offset(point.dx + offset, point.dy),
      PortSide.left => Offset(point.dx - offset, point.dy),
      PortSide.top => Offset(point.dx, point.dy - offset),
      PortSide.bottom => Offset(point.dx, point.dy + offset),
    };
  }

  // ===========================================================================
  // Bezier
  // ===========================================================================

  /// Creates a single cubic bezier segment for a forward connection.
  static CubicSegment createBezierSegment({
    required Offset start,
    required Offset end,
    required PortSide sourcePosition,
    required PortSide targetPosition,
    required double curvature,
    required double portExtension,
    double? sourceExtension,
    double? targetExtension,
  }) {
    final effectiveSourceExtension = sourceExtension ?? portExtension;
    final effectiveTargetExtension = targetExtension ?? portExtension;

    final cp1 = _calculateBezierControlPoint(
      anchor: start,
      target: end,
      position: sourcePosition,
      curvature: curvature,
      portExtension: effectiveSourceExtension,
    );

    final cp2 = _calculateBezierControlPoint(
      anchor: end,
      target: start,
      position: targetPosition,
      curvature: curvature,
      portExtension: effectiveTargetExtension,
    );

    return CubicSegment(
      controlPoint1: cp1,
      controlPoint2: cp2,
      end: end,
      curvature: curvature,
    );
  }

  /// Matches React Flow's bezier calculation:
  /// `offset = max(portExtension, |distance| * curvature)`.
  static Offset _calculateBezierControlPoint({
    required Offset anchor,
    required Offset target,
    required PortSide position,
    required double curvature,
    required double portExtension,
  }) {
    switch (position) {
      case PortSide.right:
        final offset = math.max(
          portExtension,
          (target.dx - anchor.dx).abs() * curvature,
        );
        return Offset(anchor.dx + offset, anchor.dy);

      case PortSide.left:
        final offset = math.max(
          portExtension,
          (target.dx - anchor.dx).abs() * curvature,
        );
        return Offset(anchor.dx - offset, anchor.dy);

      case PortSide.bottom:
        final offset = math.max(
          portExtension,
          (target.dy - anchor.dy).abs() * curvature,
        );
        return Offset(anchor.dx, anchor.dy + offset);

      case PortSide.top:
        final offset = math.max(
          portExtension,
          (target.dy - anchor.dy).abs() * curvature,
        );
        return Offset(anchor.dx, anchor.dy - offset);
    }
  }

  /// Builds the segments for a forward bezier connection (single cubic).
  static List<PathSegment> bezierSegments({
    required Offset start,
    required Offset end,
    required PortSide sourceSide,
    required PortSide targetSide,
    double curvature = kDefaultEdgeCurvature,
    double portExtension = kDefaultPortExtension,
    double? sourceExtension,
    double? targetExtension,
  }) {
    return [
      createBezierSegment(
        start: start,
        end: end,
        sourcePosition: sourceSide,
        targetPosition: targetSide,
        curvature: curvature,
        portExtension: portExtension,
        sourceExtension: sourceExtension,
        targetExtension: targetExtension,
      ),
    ];
  }

  // ===========================================================================
  // Straight
  // ===========================================================================

  /// Builds the three straight segments for a forward straight connection:
  /// port -> extension, extension -> extension, extension -> port.
  static List<PathSegment> straightSegments({
    required Offset start,
    required Offset end,
    required PortSide sourceSide,
    required PortSide targetSide,
    double portExtension = kDefaultPortExtension,
    double? sourceExtension,
    double? targetExtension,
  }) {
    final startExtension = getExtendedPoint(
      start,
      sourceSide,
      sourceExtension ?? portExtension,
    );
    final endExtension = getExtendedPoint(
      end,
      targetSide,
      targetExtension ?? portExtension,
    );

    return [
      StraightSegment(end: startExtension),
      StraightSegment(end: endExtension),
      StraightSegment(end: end),
    ];
  }

  // ===========================================================================
  // Smoothstep (rounded-orthogonal)
  // ===========================================================================

  /// Builds rounded-orthogonal segments between two ports.
  static List<PathSegment> smoothstepSegments({
    required Offset start,
    required Offset end,
    required PortSide sourceSide,
    required PortSide targetSide,
    double portExtension = kDefaultPortExtension,
    double cornerRadius = kDefaultCornerRadius,
  }) {
    final waypoints = smoothstepWaypoints(
      start: start,
      end: end,
      sourceSide: sourceSide,
      targetSide: targetSide,
      portExtension: portExtension,
    );
    return waypointsToSegments(waypoints, cornerRadius: cornerRadius);
  }

  /// Computes the orthogonal waypoints for a smoothstep route. Forward routing
  /// only (no obstacle avoidance): source extension, an L- or Z-bend, target
  /// extension.
  static List<Offset> smoothstepWaypoints({
    required Offset start,
    required Offset end,
    required PortSide sourceSide,
    required PortSide targetSide,
    double portExtension = kDefaultPortExtension,
  }) {
    final s = getExtendedPoint(start, sourceSide, portExtension);
    final e = getExtendedPoint(end, targetSide, portExtension);
    final srcH = isHorizontal(sourceSide);
    final tgtH = isHorizontal(targetSide);

    final points = <Offset>[start, s];
    if (srcH && tgtH) {
      final midX = (s.dx + e.dx) / 2;
      points
        ..add(Offset(midX, s.dy))
        ..add(Offset(midX, e.dy));
    } else if (!srcH && !tgtH) {
      final midY = (s.dy + e.dy) / 2;
      points
        ..add(Offset(s.dx, midY))
        ..add(Offset(e.dx, midY));
    } else if (srcH && !tgtH) {
      points.add(Offset(e.dx, s.dy));
    } else {
      points.add(Offset(s.dx, e.dy));
    }
    points
      ..add(e)
      ..add(end);

    return _dedupe(points);
  }

  static List<Offset> _dedupe(List<Offset> points) {
    final out = <Offset>[];
    for (final p in points) {
      if (out.isEmpty || (out.last - p).distance > 0.01) out.add(p);
    }
    return out;
  }

  // ===========================================================================
  // Segment/path/hit-test builders (ported verbatim)
  // ===========================================================================

  /// Builds a [Path] from [segments] starting at [start].
  static Path generatePathFromSegments({
    required Offset start,
    required List<PathSegment> segments,
  }) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    for (final segment in segments) {
      switch (segment) {
        case StraightSegment():
          path.lineTo(segment.end.dx, segment.end.dy);
        case QuadraticSegment():
          path.quadraticBezierTo(
            segment.controlPoint.dx,
            segment.controlPoint.dy,
            segment.end.dx,
            segment.end.dy,
          );
        case CubicSegment():
          path.cubicTo(
            segment.controlPoint1.dx,
            segment.controlPoint1.dy,
            segment.controlPoint2.dx,
            segment.controlPoint2.dy,
            segment.end.dx,
            segment.end.dy,
          );
      }
    }

    return path;
  }

  /// Generates hit-test rectangles from a list of [segments].
  static List<Rect> generateHitTestFromSegments({
    required Offset start,
    required List<PathSegment> segments,
    required double tolerance,
  }) {
    if (segments.isEmpty) return [];

    final hitRects = <Rect>[];
    Offset currentPoint = start;

    for (final segment in segments) {
      hitRects.addAll(segment.getHitTestRects(currentPoint, tolerance));
      currentPoint = segment.end;
    }

    return hitRects;
  }

  /// Converts waypoints to path segments, inserting [QuadraticSegment]s at
  /// perpendicular corners when [cornerRadius] > 0.
  static List<PathSegment> waypointsToSegments(
    List<Offset> waypoints, {
    double cornerRadius = 0,
  }) {
    if (waypoints.length < 2) return [];

    final segments = <PathSegment>[];

    if (waypoints.length == 2) {
      segments.add(StraightSegment(end: waypoints[1]));
      return segments;
    }

    // No corner radius - all straight segments
    if (cornerRadius <= 0) {
      for (int i = 1; i < waypoints.length; i++) {
        segments.add(StraightSegment(end: waypoints[i]));
      }
      return segments;
    }

    // Build segments with rounded corners
    for (int i = 1; i < waypoints.length - 1; i++) {
      final prev = i == 1 ? waypoints[0] : segments.last.end;
      final current = waypoints[i];
      final next = waypoints[i + 1];

      final incomingVector = current - prev;
      final outgoingVector = next - current;

      if (incomingVector.distance < 0.01 || outgoingVector.distance < 0.01) {
        segments.add(StraightSegment(end: current));
        continue;
      }

      final incomingHorizontal = incomingVector.dy.abs() < 0.01;
      final incomingVertical = incomingVector.dx.abs() < 0.01;
      final outgoingHorizontal = outgoingVector.dy.abs() < 0.01;
      final outgoingVertical = outgoingVector.dx.abs() < 0.01;

      if ((incomingHorizontal && outgoingVertical) ||
          (incomingVertical && outgoingHorizontal)) {
        final maxRadius = math.min(
          incomingVector.distance / 2,
          outgoingVector.distance / 2,
        );
        final actualRadius = math.min(cornerRadius, maxRadius);

        if (actualRadius < 1.0) {
          segments.add(StraightSegment(end: current));
          continue;
        }

        final inDir = incomingVector / incomingVector.distance;
        final outDir = outgoingVector / outgoingVector.distance;
        final cornerStart = current - (inDir * actualRadius);
        final cornerEnd = current + (outDir * actualRadius);

        segments.add(StraightSegment(end: cornerStart));
        segments.add(
          QuadraticSegment(
            controlPoint: current,
            end: cornerEnd,
            generateHitTestRects: false,
          ),
        );
      } else {
        segments.add(StraightSegment(end: current));
      }
    }

    segments.add(StraightSegment(end: waypoints.last));

    return segments;
  }
}
