import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:node_flow/node_flow.dart';

void main() {
  group('FlowViewport transforms', () {
    test('toScreen/toGraph round-trip', () {
      const vp = FlowViewport(x: 40, y: -25, zoom: 1.5);
      const graph = GraphPosition(Offset(120, 80));

      final screen = vp.toScreen(graph);
      final back = vp.toGraph(screen);

      expect(back.dx, closeTo(graph.dx, 1e-9));
      expect(back.dy, closeTo(graph.dy, 1e-9));
    });

    test('toScreen applies zoom then pan', () {
      const vp = FlowViewport(x: 10, y: 20, zoom: 2);
      final screen = vp.toScreen(const GraphPosition(Offset(5, 5)));
      expect(screen.dx, 5 * 2 + 10);
      expect(screen.dy, 5 * 2 + 20);
    });

    test('toGraphOffset / toScreenOffset scale by zoom only', () {
      const vp = FlowViewport(x: 100, y: 100, zoom: 2);
      final graphOffset = vp.toGraphOffset(const ScreenOffset(Offset(20, 40)));
      expect(graphOffset.dx, 10);
      expect(graphOffset.dy, 20);

      final screenOffset = vp.toScreenOffset(const GraphOffset(Offset(10, 20)));
      expect(screenOffset.dx, 20);
      expect(screenOffset.dy, 40);
    });

    test('getVisibleArea covers the screen in graph coordinates', () {
      const vp = FlowViewport(x: 0, y: 0, zoom: 2);
      final area = vp.getVisibleArea(const Size(800, 600));
      // Top-left of screen maps to graph origin; bottom-right to (400, 300).
      expect(area.left, 0);
      expect(area.top, 0);
      expect(area.right, 400);
      expect(area.bottom, 300);
    });

    test('getVisibleArea accounts for pan', () {
      const vp = FlowViewport(x: -200, y: -100, zoom: 1);
      final area = vp.getVisibleArea(const Size(800, 600));
      expect(area.left, 200);
      expect(area.top, 100);
      expect(area.right, 1000);
      expect(area.bottom, 700);
    });

    test('isRectVisible reflects overlap with the visible area', () {
      const vp = FlowViewport(x: 0, y: 0, zoom: 1);
      const screen = Size(800, 600);

      final inside = GraphRect.fromLTWH(10, 10, 50, 50);
      final outside = GraphRect.fromLTWH(2000, 2000, 50, 50);

      expect(vp.isRectVisible(inside, screen), isTrue);
      expect(vp.isRectVisible(outside, screen), isFalse);
    });
  });
}
