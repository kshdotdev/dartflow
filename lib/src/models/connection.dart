import 'coordinates.dart';
import 'flow_port.dart';

/// A request to create an edge, emitted by the canvas when a drag-to-connect
/// gesture drops on a compatible target port.
///
/// The request is always normalized so [sourceNodeId]/[sourcePortId] is the
/// output side and [targetNodeId]/[targetPortId] is the input side, regardless
/// of which end the drag started from. The canvas never mutates the graph
/// itself: the app decides whether to accept the request (via `onConnect`) and,
/// if so, adds the edge through its controller.
final class FlowConnectionRequest {
  const FlowConnectionRequest({
    required this.sourceNodeId,
    required this.sourcePortId,
    required this.targetNodeId,
    required this.targetPortId,
  });

  /// Node owning the output port.
  final String sourceNodeId;

  /// The output port id on [sourceNodeId].
  final String sourcePortId;

  /// Node owning the input port.
  final String targetNodeId;

  /// The input port id on [targetNodeId].
  final String targetPortId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlowConnectionRequest &&
          other.sourceNodeId == sourceNodeId &&
          other.sourcePortId == sourcePortId &&
          other.targetNodeId == targetNodeId &&
          other.targetPortId == targetPortId;

  @override
  int get hashCode =>
      Object.hash(sourceNodeId, sourcePortId, targetNodeId, targetPortId);

  @override
  String toString() =>
      'FlowConnectionRequest($sourceNodeId.$sourcePortId -> '
      '$targetNodeId.$targetPortId)';
}

/// A resolved port location reported to the app on hover, so it can render a
/// hover card. The canvas only reports geometry; it draws no card itself.
final class FlowPortAnchor {
  const FlowPortAnchor({
    required this.nodeId,
    required this.port,
    required this.anchorScreenRect,
  });

  /// Node owning [port].
  final String nodeId;

  /// The hovered port.
  final FlowPort port;

  /// The handle's rectangle in canvas-local screen coordinates.
  final ScreenRect anchorScreenRect;
}

/// Transient state for an in-flight drag-to-connect gesture.
///
/// Held on the controller so the preview painter can subscribe to it, mirroring
/// how the marquee rectangle is exposed.
final class PendingConnection {
  const PendingConnection({
    required this.sourceNodeId,
    required this.sourcePort,
    required this.point,
    this.targetNodeId,
    this.targetPort,
  });

  /// Node the drag started from.
  final String sourceNodeId;

  /// Port the drag started from (may be an input or an output).
  final FlowPort sourcePort;

  /// The current pointer position in graph coordinates.
  final GraphPosition point;

  /// The compatible target node currently under the pointer, if any.
  final String? targetNodeId;

  /// The compatible target port currently under the pointer, if any.
  final FlowPort? targetPort;

  /// Whether the drag is currently over a compatible target port.
  bool get hasTarget => targetNodeId != null && targetPort != null;

  PendingConnection copyWith({
    GraphPosition? point,
    String? targetNodeId,
    FlowPort? targetPort,
    bool clearTarget = false,
  }) {
    return PendingConnection(
      sourceNodeId: sourceNodeId,
      sourcePort: sourcePort,
      point: point ?? this.point,
      targetNodeId: clearTarget ? null : (targetNodeId ?? this.targetNodeId),
      targetPort: clearTarget ? null : (targetPort ?? this.targetPort),
    );
  }
}
