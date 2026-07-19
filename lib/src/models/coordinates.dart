import 'dart:ui';

/// Absolute position in graph/world coordinate space. Extension types keep
/// graph and screen coordinates from being mixed at compile time.
extension type const GraphPosition(Offset offset) {
  GraphPosition.fromXY(double dx, double dy) : this(Offset(dx, dy));

  static const zero = GraphPosition(Offset.zero);

  double get dx => offset.dx;

  double get dy => offset.dy;

  bool get isFinite => offset.isFinite;

  GraphPosition operator +(GraphPosition other) =>
      GraphPosition(offset + other.offset);

  GraphPosition operator -(GraphPosition other) =>
      GraphPosition(offset - other.offset);

  GraphPosition operator *(double operand) => GraphPosition(offset * operand);

  double distanceTo(GraphPosition other) => (offset - other.offset).distance;

  static GraphPosition lerp(GraphPosition a, GraphPosition b, double t) =>
      GraphPosition(Offset.lerp(a.offset, b.offset, t)!);
}

/// Absolute position in screen coordinate space (pixels, post pan/zoom).
extension type const ScreenPosition(Offset offset) {
  ScreenPosition.fromXY(double dx, double dy) : this(Offset(dx, dy));

  static const zero = ScreenPosition(Offset.zero);

  double get dx => offset.dx;

  double get dy => offset.dy;

  bool get isFinite => offset.isFinite;

  ScreenPosition operator +(ScreenPosition other) =>
      ScreenPosition(offset + other.offset);

  ScreenPosition operator -(ScreenPosition other) =>
      ScreenPosition(offset - other.offset);
}

/// A delta/movement in graph coordinate space (scaling only, no pan).
extension type const GraphOffset(Offset offset) {
  GraphOffset.fromXY(double dx, double dy) : this(Offset(dx, dy));

  static const zero = GraphOffset(Offset.zero);

  double get dx => offset.dx;

  double get dy => offset.dy;

  double get distance => offset.distance;

  GraphOffset operator +(GraphOffset other) =>
      GraphOffset(offset + other.offset);

  GraphOffset operator -(GraphOffset other) =>
      GraphOffset(offset - other.offset);

  GraphOffset operator *(double operand) => GraphOffset(offset * operand);
}

/// A delta/movement in screen coordinate space.
extension type const ScreenOffset(Offset offset) {
  ScreenOffset.fromXY(double dx, double dy) : this(Offset(dx, dy));

  static const zero = ScreenOffset(Offset.zero);

  double get dx => offset.dx;

  double get dy => offset.dy;

  double get distance => offset.distance;

  ScreenOffset operator +(ScreenOffset other) =>
      ScreenOffset(offset + other.offset);

  ScreenOffset operator -(ScreenOffset other) =>
      ScreenOffset(offset - other.offset);
}

extension GraphPositionOffsetExtension on GraphPosition {
  GraphPosition translate(GraphOffset delta) =>
      GraphPosition(offset + delta.offset);
}

extension ScreenPositionOffsetExtension on ScreenPosition {
  ScreenPosition translate(ScreenOffset delta) =>
      ScreenPosition(offset + delta.offset);
}

/// A rectangle in graph/world coordinate space.
extension type const GraphRect(Rect rect) {
  GraphRect.fromLTWH(double left, double top, double width, double height)
    : this(Rect.fromLTWH(left, top, width, height));

  GraphRect.fromPoints(GraphPosition a, GraphPosition b)
    : this(Rect.fromPoints(a.offset, b.offset));

  GraphRect.fromCenter({
    required GraphPosition center,
    required double width,
    required double height,
  }) : this(
         Rect.fromCenter(center: center.offset, width: width, height: height),
       );

  static const zero = GraphRect(Rect.zero);

  GraphPosition get topLeft => GraphPosition(rect.topLeft);

  GraphPosition get bottomRight => GraphPosition(rect.bottomRight);

  GraphPosition get center => GraphPosition(rect.center);

  double get left => rect.left;

  double get top => rect.top;

  double get right => rect.right;

  double get bottom => rect.bottom;

  double get width => rect.width;

  double get height => rect.height;

  Size get size => rect.size;

  bool get isEmpty => rect.isEmpty;

  bool contains(GraphPosition point) => rect.contains(point.offset);

  bool overlaps(GraphRect other) => rect.overlaps(other.rect);

  GraphRect expandToInclude(GraphRect other) =>
      GraphRect(rect.expandToInclude(other.rect));

  GraphRect inflate(double delta) => GraphRect(rect.inflate(delta));

  GraphRect translate(GraphOffset delta) =>
      GraphRect(rect.translate(delta.dx, delta.dy));
}

/// A rectangle in screen coordinate space.
extension type const ScreenRect(Rect rect) {
  ScreenRect.fromLTWH(double left, double top, double width, double height)
    : this(Rect.fromLTWH(left, top, width, height));

  ScreenRect.fromPoints(ScreenPosition a, ScreenPosition b)
    : this(Rect.fromPoints(a.offset, b.offset));

  static const zero = ScreenRect(Rect.zero);

  ScreenPosition get topLeft => ScreenPosition(rect.topLeft);

  ScreenPosition get center => ScreenPosition(rect.center);

  double get width => rect.width;

  double get height => rect.height;

  Size get size => rect.size;

  bool contains(ScreenPosition point) => rect.contains(point.offset);

  bool overlaps(ScreenRect other) => rect.overlaps(other.rect);
}
