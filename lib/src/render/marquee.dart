import 'package:flutter/rendering.dart';

import '../models/coordinates.dart';
import '../models/flow_viewport.dart';
import '../theme/flow_theme.dart';

/// Paints the marquee (rubber-band) selection rectangle in screen space.
///
/// [rect] is in graph coordinates and is mapped to the screen through
/// [viewport], so the rectangle tracks pan/zoom without a canvas transform.
class MarqueePainter extends CustomPainter {
  const MarqueePainter({
    required this.rect,
    required this.viewport,
    required this.theme,
  });

  final GraphRect? rect;
  final FlowViewport viewport;
  final FlowTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final graphRect = rect;
    if (graphRect == null) return;

    final screenRect = viewport.toScreenRect(graphRect).rect;

    canvas.drawRect(
      screenRect,
      Paint()
        ..color = theme.selectionFill
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      screenRect,
      Paint()
        ..color = theme.selectionStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = theme.selectionStrokeWidth,
    );
  }

  @override
  bool shouldRepaint(MarqueePainter oldDelegate) =>
      oldDelegate.rect != rect ||
      oldDelegate.viewport != viewport ||
      oldDelegate.theme != theme;
}
