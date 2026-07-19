import 'package:flutter/rendering.dart';

import '../models/coordinates.dart';
import '../models/flow_viewport.dart';
import '../theme/flow_theme.dart';

/// Paints the dotted background grid in screen space.
///
/// The painter lives outside the [InteractiveViewer] (rather than inside the
/// transformed canvas) and maps each grid point to the screen via
/// [FlowViewport]. Dots are culled to the visible area and skipped entirely
/// once they would be smaller than half a pixel.
class GridPainter extends CustomPainter {
  const GridPainter({required this.viewport, required this.theme});

  final FlowViewport viewport;
  final FlowTheme theme;

  /// Base dot radius in graph units, scaled by zoom for screen size.
  static const double _baseRadius = 1.2;

  @override
  void paint(Canvas canvas, Size size) {
    final zoom = viewport.zoom;
    final gap = theme.gridGap;
    if (gap <= 0 || zoom <= 0) return;

    final radius = _baseRadius * zoom;
    // Skip painting when dots would be sub-pixel (also bounds the dot count at
    // low zoom).
    if (radius < 0.5) return;

    final paint = Paint()
      ..color = theme.gridDot
      ..style = PaintingStyle.fill;

    final visible = viewport.getVisibleArea(size);
    final startX = (visible.left / gap).floor() * gap;
    final startY = (visible.top / gap).floor() * gap;

    for (var gx = startX; gx <= visible.right; gx += gap) {
      for (var gy = startY; gy <= visible.bottom; gy += gap) {
        final screen = viewport.toScreen(GraphPosition.fromXY(gx, gy));
        canvas.drawCircle(screen.offset, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) =>
      oldDelegate.viewport != viewport || oldDelegate.theme != theme;
}
