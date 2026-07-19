import 'dart:ui' show Color;

/// Which edge of a node a port is anchored to.
enum PortSide { left, right, top, bottom }

/// Whether a port receives connections ([input]) or emits them ([output]).
enum PortKind { input, output }

/// How a port is drawn. Phase 3 renders these; the model exists now so that
/// [FlowNode] can stay `final`.
enum PortVisual {
  /// A simple filled circle.
  circle,

  /// A branch-style connector (e.g. for flow-control fan-out).
  branch,
}

/// A connection point on a [FlowNode].
///
/// Ports are pure data in phases 1-2; rendering and connection interaction
/// arrive in phase 3. Modeling them now keeps [FlowNode] immutable in shape.
final class FlowPort {
  const FlowPort({
    required this.id,
    required this.side,
    required this.kind,
    this.visual = PortVisual.circle,
    this.label,
    this.accent,
  });

  /// Identifier, unique within the owning node.
  final String id;

  /// Which node edge this port anchors to.
  final PortSide side;

  /// Input or output.
  final PortKind kind;

  /// How the port should be drawn (phase 3).
  final PortVisual visual;

  /// Optional human-readable label.
  final String? label;

  /// Optional accent color override (phase 3).
  final Color? accent;
}
