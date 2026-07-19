import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:node_flow/src/render/edges_painter.dart';
import 'package:node_flow/node_flow.dart';

FlowNode<String> node(
  String id,
  double x,
  double y, {
  Size size = const Size(120, 60),
  List<FlowPort> ports = const <FlowPort>[],
}) => FlowNode<String>(
  id: id,
  type: 'test',
  data: id,
  position: GraphPosition(Offset(x, y)),
  size: size,
  ports: ports,
);

FlowEdge<String> edge(
  String id,
  String from,
  String to, {
  bool dangling = false,
}) => FlowEdge<String>(
  id: id,
  sourceNodeId: from,
  sourcePortId: 'out',
  targetNodeId: to,
  targetPortId: 'in',
  dangling: dangling,
);

const _outPort = FlowPort(
  id: 'out',
  side: PortSide.right,
  kind: PortKind.output,
);
const _inPort = FlowPort(id: 'in', side: PortSide.left, kind: PortKind.input);

Future<void> pumpCanvas(
  WidgetTester tester,
  FlowController<String, String> controller,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 800,
            height: 600,
            child: NodeFlow<String, String>(
              controller: controller,
              fitViewOnLoad: false,
              animateEdges: false,
              minimap: false,
              nodeBuilder: (context, n) => SizedBox(
                key: ValueKey<String>('card-${n.id}'),
                width: n.measuredSize.value.width,
                height: n.measuredSize.value.height,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('edges layer renders for connected nodes without crashing', (
    tester,
  ) async {
    final c = FlowController<String, String>();
    addTearDown(c.dispose);
    c.addNode(node('a', 100, 100, ports: const <FlowPort>[_outPort]));
    c.addNode(node('b', 400, 100, ports: const <FlowPort>[_inPort]));
    c.addEdge(edge('e', 'a', 'b'));

    await pumpCanvas(tester, c);

    expect(find.byType(EdgesLayer<String, String>), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('branch handles with labels render without crashing', (
    tester,
  ) async {
    final c = FlowController<String, String>();
    addTearDown(c.dispose);
    c.addNode(
      node(
        'a',
        100,
        100,
        ports: const <FlowPort>[
          FlowPort(id: 'in', side: PortSide.left, kind: PortKind.input),
          FlowPort(
            id: 't',
            side: PortSide.right,
            kind: PortKind.output,
            visual: PortVisual.branch,
            label: 'true',
            accent: Color(0xFF3FB950),
          ),
          FlowPort(
            id: 'f',
            side: PortSide.right,
            kind: PortKind.output,
            visual: PortVisual.branch,
            label: 'false',
            accent: Color(0xFFE5534B),
          ),
        ],
      ),
    );

    await pumpCanvas(tester, c);

    expect(tester.takeException(), isNull);
    expect(find.text('TRUE'), findsOneWidget);
    expect(find.text('FALSE'), findsOneWidget);
  });

  testWidgets('tapping near an edge selects it', (tester) async {
    final c = FlowController<String, String>();
    addTearDown(c.dispose);
    c.addNode(node('a', 100, 100, ports: const <FlowPort>[_outPort]));
    c.addNode(node('b', 400, 100, ports: const <FlowPort>[_inPort]));
    c.addEdge(edge('e', 'a', 'b'));

    await pumpCanvas(tester, c);

    expect(c.getEdge('e')!.selected.value, isFalse);

    // Source anchor (220,130) -> target anchor (400,130); the wire runs along
    // y = 130. Tap its midpoint in empty space between the two nodes.
    final canvasTopLeft = tester.getTopLeft(
      find.byType(NodeFlow<String, String>),
    );
    await tester.tapAt(canvasTopLeft + const Offset(310, 130));
    await tester.pump();

    expect(c.getEdge('e')!.selected.value, isTrue);
  });

  testWidgets('tapping empty space away from any edge clears edge selection', (
    tester,
  ) async {
    final c = FlowController<String, String>();
    addTearDown(c.dispose);
    c.addNode(node('a', 100, 100, ports: const <FlowPort>[_outPort]));
    c.addNode(node('b', 400, 100, ports: const <FlowPort>[_inPort]));
    c.addEdge(edge('e', 'a', 'b'));

    await pumpCanvas(tester, c);
    c.selectEdge('e');
    expect(c.getEdge('e')!.selected.value, isTrue);

    final canvasTopLeft = tester.getTopLeft(
      find.byType(NodeFlow<String, String>),
    );
    await tester.tapAt(canvasTopLeft + const Offset(310, 300));
    await tester.pump();

    expect(c.getEdge('e')!.selected.value, isFalse);
  });

  group('dangling badge painter', () {
    test('paints an amber badge at the path midpoint', () async {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final path = Path()
        ..moveTo(0, 50)
        ..lineTo(100, 50); // midpoint (50, 50)

      paintDanglingBadge(canvas, path, const Color(0xFFF5B544));

      final picture = recorder.endRecording();
      final image = await picture.toImage(100, 100);
      final bytes = await image.toByteData();
      addTearDown(image.dispose);

      // A pixel on the badge fill (left of the central "!" ink) is amber.
      const x = 44;
      const y = 50;
      final i = (y * 100 + x) * 4;
      expect(bytes!.getUint8(i), greaterThan(200)); // R of #F5B544 == 0xF5
      expect(bytes.getUint8(i + 3), greaterThan(200)); // opaque
    });
  });

  group('EdgesPainter.shouldRepaint', () {
    test('repaints when the style changes, not when identical', () {
      final c = FlowController<String, String>();
      addTearDown(c.dispose);
      const dash = AlwaysStoppedAnimation<double>(0);
      final dragging = <String>{};

      EdgesPainter<String, String> make(FlowEdgeStyle style) =>
          EdgesPainter<String, String>(
            controller: c,
            theme: const FlowTheme.dark(),
            style: style,
            dash: dash,
            dragging: dragging,
            includeDragging: false,
            repaint: c.viewport,
          );

      final base = make(FlowEdgeStyle.bezier);
      expect(base.shouldRepaint(make(FlowEdgeStyle.bezier)), isFalse);
      expect(base.shouldRepaint(make(FlowEdgeStyle.smoothstep)), isTrue);
    });
  });
}
