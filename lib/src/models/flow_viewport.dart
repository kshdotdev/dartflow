import 'dart:ui';

import 'coordinates.dart';

/// Maps the infinite graph coordinate space onto the screen: a pan offset
/// ([x], [y]) in screen pixels plus a [zoom] scale factor.
final class FlowViewport {
  const FlowViewport({this.x = 0.0, this.y = 0.0, this.zoom = 1.0});

  /// Horizontal pan offset in screen pixels (positive moves the graph right).
  final double x;

  /// Vertical pan offset in screen pixels (positive moves the graph down).
  final double y;

  /// Zoom scale factor where `1.0` is 100%.
  final double zoom;

  GraphPosition toGraph(ScreenPosition screenPoint) {
    return GraphPosition(
      Offset((screenPoint.dx - x) / zoom, (screenPoint.dy - y) / zoom),
    );
  }

  GraphOffset toGraphOffset(ScreenOffset screenOffset) {
    return GraphOffset(Offset(screenOffset.dx / zoom, screenOffset.dy / zoom));
  }

  ScreenPosition toScreen(GraphPosition graphPoint) {
    return ScreenPosition(
      Offset(graphPoint.dx * zoom + x, graphPoint.dy * zoom + y),
    );
  }

  ScreenOffset toScreenOffset(GraphOffset graphOffset) {
    return ScreenOffset(Offset(graphOffset.dx * zoom, graphOffset.dy * zoom));
  }

  ScreenRect toScreenRect(GraphRect graphRect) {
    return ScreenRect.fromPoints(
      toScreen(graphRect.topLeft),
      toScreen(graphRect.bottomRight),
    );
  }

  GraphRect toGraphRect(ScreenRect screenRect) {
    return GraphRect.fromPoints(
      toGraph(screenRect.topLeft),
      toGraph(ScreenPosition(screenRect.rect.bottomRight)),
    );
  }

  /// The visible area in graph coordinates, for culling.
  GraphRect getVisibleArea(Size screenSize) {
    return GraphRect.fromPoints(
      toGraph(ScreenPosition.zero),
      toGraph(ScreenPosition.fromXY(screenSize.width, screenSize.height)),
    );
  }

  bool isRectVisible(GraphRect rect, Size screenSize) {
    return getVisibleArea(screenSize).overlaps(rect);
  }

  FlowViewport copyWith({double? x, double? y, double? zoom}) {
    return FlowViewport(
      x: x ?? this.x,
      y: y ?? this.y,
      zoom: zoom ?? this.zoom,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlowViewport &&
        other.x == x &&
        other.y == y &&
        other.zoom == zoom;
  }

  @override
  int get hashCode => Object.hash(x, y, zoom);

  @override
  String toString() => 'FlowViewport(x: $x, y: $y, zoom: $zoom)';
}
