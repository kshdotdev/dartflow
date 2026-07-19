import '../models/coordinates.dart';
import '../models/flow_node.dart';
import '../models/flow_port.dart';

/// Computes the graph-space position of [port] on the edge of [node].
///
/// Inputs sit on the left edge, outputs on the right by convention, but the
/// port's own [FlowPort.side] always wins. Ports sharing a side are distributed
/// evenly along that edge using `top = ((index + 1) / (count + 1)) * height`,
/// matching the React Flow editor.
///
/// This is the single source of truth for both the [PortHandle] widgets and the
/// edge painters, so a handle and the wire attached to it always coincide.
GraphPosition portAnchor<T>(FlowNode<T> node, FlowPort port) {
  final bounds = node.bounds;
  final sameSide = <FlowPort>[
    for (final p in node.ports)
      if (p.side == port.side) p,
  ];

  var index = -1;
  for (var i = 0; i < sameSide.length; i++) {
    if (identical(sameSide[i], port) || sameSide[i].id == port.id) {
      index = i;
      break;
    }
  }
  final i = index < 0 ? 0 : index;
  final count = sameSide.isEmpty ? 1 : sameSide.length;

  final tHorizontal = (i + 1) / (count + 1);

  switch (port.side) {
    case PortSide.left:
      return GraphPosition.fromXY(
        bounds.left,
        bounds.top + tHorizontal * bounds.height,
      );
    case PortSide.right:
      return GraphPosition.fromXY(
        bounds.right,
        bounds.top + tHorizontal * bounds.height,
      );
    case PortSide.top:
      return GraphPosition.fromXY(
        bounds.left + tHorizontal * bounds.width,
        bounds.top,
      );
    case PortSide.bottom:
      return GraphPosition.fromXY(
        bounds.left + tHorizontal * bounds.width,
        bounds.bottom,
      );
  }
}

/// Returns the [FlowPort] with [portId] on [node], or `null` if none matches.
FlowPort? portById<T>(FlowNode<T> node, String portId) {
  for (final p in node.ports) {
    if (p.id == portId) return p;
  }
  return null;
}
