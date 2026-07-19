import 'package:flutter/rendering.dart';

import '../controller/alignment_snap.dart';
import '../models/coordinates.dart';
import '../models/flow_viewport.dart';
import '../theme/flow_theme.dart';

/// Screen-space painter for the active alignment guides: dashed 1px lines in
/// [FlowTheme.snapGuide], mapped from graph to screen through the viewport.
final class SnapGuidesPainter extends CustomPainter {
  const SnapGuidesPainter({
    required this.guides,
    required this.viewport,
    required this.theme,
  });

  final List<FlowAlignmentGuide> guides;
  final FlowViewport viewport;
  final FlowTheme theme;

  static const _dash = 5.0;
  static const _gap = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (guides.isEmpty) return;
    final paint = Paint()
      ..color = theme.snapGuide
      ..strokeWidth = 1;

    for (final guide in guides) {
      final Offset from;
      final Offset to;
      if (guide.vertical) {
        from = viewport
            .toScreen(GraphPosition.fromXY(guide.position, guide.start))
            .offset;
        to = viewport
            .toScreen(GraphPosition.fromXY(guide.position, guide.end))
            .offset;
      } else {
        from = viewport
            .toScreen(GraphPosition.fromXY(guide.start, guide.position))
            .offset;
        to = viewport
            .toScreen(GraphPosition.fromXY(guide.end, guide.position))
            .offset;
      }
      _dashedLine(canvas, from, to, paint);
    }
  }

  void _dashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    final total = (to - from).distance;
    if (total <= 0) return;
    final direction = (to - from) / total;
    var covered = 0.0;
    while (covered < total) {
      final segment = covered + _dash < total ? _dash : total - covered;
      canvas.drawLine(
        from + direction * covered,
        from + direction * (covered + segment),
        paint,
      );
      covered += _dash + _gap;
    }
  }

  @override
  bool shouldRepaint(covariant SnapGuidesPainter oldDelegate) =>
      !identical(oldDelegate.guides, guides) ||
      oldDelegate.viewport != viewport ||
      oldDelegate.theme != theme;
}
