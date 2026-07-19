import 'dart:ui';

import '../models/flow_port.dart';
import 'edge_path.dart';
import 'path_segments.dart';

/// How an edge's path is drawn between its two ports.
enum FlowEdgeStyle {
  /// A single smooth cubic bezier curve (React Flow's default). Control-point
  /// offsets follow `max(portExtension, |distance| * curvature)`.
  bezier,

  /// A rounded orthogonal path (horizontal/vertical runs with rounded corners).
  smoothstep,

  /// A near-straight line with short port extensions.
  straight,
}

/// The computed geometry of one edge: the [start] point plus the ordered
/// [segments] that reach the target. Derive the drawable [Path] and hit-test
/// rectangles from the same segments so painting and hit testing never diverge.
class EdgeGeometry {
  const EdgeGeometry({required this.start, required this.segments});

  /// The path's starting point (the source port anchor).
  final Offset start;

  /// The ordered segments from [start] to the target port anchor.
  final List<PathSegment> segments;

  /// Builds the drawable path.
  Path toPath() =>
      EdgePathMath.generatePathFromSegments(start: start, segments: segments);

  /// Builds the hit-test rectangles covering the path, each expanded by
  /// [tolerance].
  List<Rect> hitTestRects(double tolerance) =>
      EdgePathMath.generateHitTestFromSegments(
        start: start,
        segments: segments,
        tolerance: tolerance,
      );
}

/// Geometry helpers for each [FlowEdgeStyle]. Coordinate-space agnostic: pass
/// screen or graph [Offset]s; results come back in the same space.
extension FlowEdgeStyleGeometry on FlowEdgeStyle {
  /// Computes the edge geometry between [source] (facing [sourceSide]) and
  /// [target] (facing [targetSide]).
  EdgeGeometry geometry(
    Offset source,
    PortSide sourceSide,
    Offset target,
    PortSide targetSide, {
    double curvature = kDefaultEdgeCurvature,
    double portExtension = kDefaultPortExtension,
    double cornerRadius = kDefaultCornerRadius,
    double? sourceExtension,
    double? targetExtension,
  }) {
    final segments = switch (this) {
      FlowEdgeStyle.bezier => EdgePathMath.bezierSegments(
        start: source,
        end: target,
        sourceSide: sourceSide,
        targetSide: targetSide,
        curvature: curvature,
        portExtension: portExtension,
        sourceExtension: sourceExtension,
        targetExtension: targetExtension,
      ),
      FlowEdgeStyle.smoothstep => EdgePathMath.smoothstepSegments(
        start: source,
        end: target,
        sourceSide: sourceSide,
        targetSide: targetSide,
        portExtension: portExtension,
        cornerRadius: cornerRadius,
      ),
      FlowEdgeStyle.straight => EdgePathMath.straightSegments(
        start: source,
        end: target,
        sourceSide: sourceSide,
        targetSide: targetSide,
        portExtension: portExtension,
        sourceExtension: sourceExtension,
        targetExtension: targetExtension,
      ),
    };
    return EdgeGeometry(start: source, segments: segments);
  }

  /// Builds the drawable path directly (convenience over [geometry]).
  Path buildPath(
    Offset source,
    PortSide sourceSide,
    Offset target,
    PortSide targetSide, {
    double curvature = kDefaultEdgeCurvature,
    double portExtension = kDefaultPortExtension,
    double cornerRadius = kDefaultCornerRadius,
  }) => geometry(
    source,
    sourceSide,
    target,
    targetSide,
    curvature: curvature,
    portExtension: portExtension,
    cornerRadius: cornerRadius,
  ).toPath();
}
