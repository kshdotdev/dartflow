import 'dart:ui';

/// Paints [path] as a moving dashed line.
///
/// [phase] is the animation value in `[0, 1)`; passing `0` yields a static
/// dashed line (used for the connection preview and when animation is off).
/// [speed] must be a positive integer so the dash pattern loops seamlessly.
void paintFlowingDash(
  Canvas canvas,
  Path path,
  Paint basePaint, {
  required double phase,
  double dashLength = 8,
  double gapLength = 4,
  int speed = 1,
}) {
  assert(speed > 0, 'speed must be positive');
  assert(dashLength > 0, 'dashLength must be positive');
  assert(gapLength > 0, 'gapLength must be positive');

  final totalDashLength = dashLength + gapLength;

  for (final metric in path.computeMetrics()) {
    // Integer speed + modulo → seamless loop (offset = 0 at t=0 and t=1).
    final animationOffset = (phase * speed * totalDashLength) % totalDashLength;

    // Start before the path, shifted by offset (forward motion).
    double distance = animationOffset - totalDashLength;
    bool isDash = true;

    while (distance < metric.length) {
      final segmentLength = isDash ? dashLength : gapLength;
      final start = distance.clamp(0.0, metric.length);
      final end = (distance + segmentLength).clamp(0.0, metric.length);

      if (isDash && start < end) {
        canvas.drawPath(metric.extractPath(start, end), basePaint);
      }

      distance += segmentLength;
      isDash = !isDash;
    }
  }
}
