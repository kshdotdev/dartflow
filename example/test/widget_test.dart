import 'package:flutter_test/flutter_test.dart';

import 'package:node_flow/node_flow.dart';
import 'package:node_flow_example/demo_node.dart';
import 'package:node_flow_example/main.dart';

void main() {
  testWidgets('demo app opens the static page and mounts a NodeFlow canvas', (
    tester,
  ) async {
    await tester.pumpWidget(const NodeFlowExampleApp());

    await tester.tap(find.text('01 · Static camera'));
    // Pump the route transition manually: edge dashes animate continuously,
    // so pumpAndSettle would never settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(NodeFlow<DemoNode, Object?>), findsOneWidget);
  });
}
