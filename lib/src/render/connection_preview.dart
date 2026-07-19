import 'package:flutter/widgets.dart';

import '../controller/flow_controller.dart';
import '../edges/edge_style.dart';
import '../edges/flowing_dash.dart';
import '../geometry/port_anchor.dart';
import '../models/flow_port.dart';
import '../theme/flow_theme.dart';

/// Paints the in-flight drag-to-connect preview from the source port to the
/// pointer, snapping to a hovered compatible target and highlighting it.
class ConnectionPreviewPainter<T, E> extends CustomPainter {
  ConnectionPreviewPainter({
    required this.controller,
    required this.theme,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final FlowController<T, E> controller;
  final FlowTheme theme;

  static PortSide _opposite(PortSide side) => switch (side) {
    PortSide.left => PortSide.right,
    PortSide.right => PortSide.left,
    PortSide.top => PortSide.bottom,
    PortSide.bottom => PortSide.top,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final pending = controller.pendingConnection.value;
    if (pending == null) return;

    final vp = controller.viewport.value;
    final sourceNode = controller.getNode(pending.sourceNodeId);
    if (sourceNode == null) return;

    final srcScreen = vp
        .toScreen(portAnchor(sourceNode, pending.sourcePort))
        .offset;

    Offset endScreen;
    PortSide endSide;
    if (pending.hasTarget) {
      final targetNode = controller.getNode(pending.targetNodeId!);
      if (targetNode != null) {
        endScreen = vp
            .toScreen(portAnchor(targetNode, pending.targetPort!))
            .offset;
        endSide = pending.targetPort!.side;
      } else {
        endScreen = vp.toScreen(pending.point).offset;
        endSide = _opposite(pending.sourcePort.side);
      }
    } else {
      endScreen = vp.toScreen(pending.point).offset;
      endSide = _opposite(pending.sourcePort.side);
    }

    final path = FlowEdgeStyle.bezier
        .geometry(
          srcScreen,
          pending.sourcePort.side,
          endScreen,
          endSide,
          // Don't overshoot past the free mouse end.
          targetExtension: pending.hasTarget ? null : 0,
        )
        .toPath();

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6
      ..color = theme.connectionPreview;

    paintFlowingDash(
      canvas,
      path,
      paint,
      phase: 0,
      dashLength: 5,
      gapLength: 5,
    );

    if (pending.hasTarget) {
      canvas.drawCircle(
        endScreen,
        8,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = theme.connectionPreview,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ConnectionPreviewPainter<T, E> oldDelegate) =>
      oldDelegate.theme != theme;
}
