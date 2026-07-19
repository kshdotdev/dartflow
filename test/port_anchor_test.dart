import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:node_flow/node_flow.dart';

FlowNode<String> makeNode(
  List<FlowPort> ports, {
  Offset position = Offset.zero,
  Size size = const Size(100, 80),
}) => FlowNode<String>(
  id: 'n',
  type: 't',
  data: 'n',
  position: GraphPosition(position),
  size: size,
  ports: ports,
);

FlowPort port(String id, PortSide side, PortKind kind) =>
    FlowPort(id: id, side: side, kind: kind);

void main() {
  group('vertical distribution ((i + 1) / (n + 1))', () {
    test('single port sits at the mid-height', () {
      final node = makeNode(<FlowPort>[
        port('a', PortSide.left, PortKind.input),
      ]);
      final a = portAnchor(node, node.ports[0]);
      expect(a.dx, 0);
      expect(a.dy, closeTo(40, 1e-9)); // 1/2 * 80
    });

    test('two ports split the edge into thirds', () {
      final node = makeNode(<FlowPort>[
        port('a', PortSide.left, PortKind.input),
        port('b', PortSide.left, PortKind.input),
      ]);
      expect(portAnchor(node, node.ports[0]).dy, closeTo(80 / 3, 1e-9));
      expect(portAnchor(node, node.ports[1]).dy, closeTo(160 / 3, 1e-9));
    });

    test('three ports split the edge into quarters', () {
      final node = makeNode(<FlowPort>[
        port('a', PortSide.left, PortKind.input),
        port('b', PortSide.left, PortKind.input),
        port('c', PortSide.left, PortKind.input),
      ]);
      expect(portAnchor(node, node.ports[0]).dy, closeTo(20, 1e-9));
      expect(portAnchor(node, node.ports[1]).dy, closeTo(40, 1e-9));
      expect(portAnchor(node, node.ports[2]).dy, closeTo(60, 1e-9));
    });
  });

  group('side x-coordinates at node bounds', () {
    test('left is at bounds.left, right is at bounds.right', () {
      final node = makeNode(<FlowPort>[
        port('l', PortSide.left, PortKind.input),
        port('r', PortSide.right, PortKind.output),
      ]);
      expect(portAnchor(node, node.ports[0]).dx, 0);
      expect(portAnchor(node, node.ports[1]).dx, 100); // left + width
    });

    test('each side distributes independently', () {
      final node = makeNode(<FlowPort>[
        port('l', PortSide.left, PortKind.input),
        port('r1', PortSide.right, PortKind.output),
        port('r2', PortSide.right, PortKind.output),
      ]);
      // The single left port is centered; the two right ports are in thirds.
      expect(portAnchor(node, node.ports[0]).dy, closeTo(40, 1e-9));
      expect(portAnchor(node, node.ports[1]).dy, closeTo(80 / 3, 1e-9));
      expect(portAnchor(node, node.ports[2]).dy, closeTo(160 / 3, 1e-9));
    });

    test('top/bottom distribute along X and sit at the node top/bottom', () {
      final node = makeNode(<FlowPort>[
        port('t', PortSide.top, PortKind.input),
        port('b', PortSide.bottom, PortKind.output),
      ]);
      final t = portAnchor(node, node.ports[0]);
      final b = portAnchor(node, node.ports[1]);
      expect(t.dy, 0);
      expect(t.dx, closeTo(50, 1e-9)); // 1/2 * width
      expect(b.dy, 80);
      expect(b.dx, closeTo(50, 1e-9));
    });

    test('anchors are offset by the node position', () {
      final node = makeNode(<FlowPort>[
        port('l', PortSide.left, PortKind.input),
      ], position: const Offset(10, 20));
      final a = portAnchor(node, node.ports[0]);
      expect(a.dx, 10);
      expect(a.dy, closeTo(60, 1e-9)); // 20 + 40
    });
  });
}
