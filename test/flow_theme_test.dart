import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:node_flow/node_flow.dart';

void main() {
  group('FlowTheme.copyWith', () {
    test('overridden fields win, untouched fields keep their defaults', () {
      const overriddenEdge = Color(0xFFAB12CD);
      const dark = FlowTheme.dark();

      final themed = dark.copyWith(edge: overriddenEdge, handleSize: 21.0);

      // Overridden fields win.
      expect(themed.edge, overriddenEdge);
      expect(themed.handleSize, 21.0);
      // Fields left alone still resolve to the dark defaults.
      expect(themed.background, dark.background);
      expect(themed.edgeSelected, dark.edgeSelected);
    });
  });

  group('FlowTheme.resolve', () {
    testWidgets('reads a FlowTheme registered as a ThemeExtension', (
      tester,
    ) async {
      const overriddenEdge = Color(0xFFAB12CD);
      late FlowTheme resolved;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: [
              const FlowTheme.dark().copyWith(
                edge: overriddenEdge,
                handleSize: 21.0,
              ),
            ],
          ),
          home: Builder(
            builder: (context) {
              resolved = FlowTheme.resolve(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolved.edge, overriddenEdge);
      expect(resolved.handleSize, 21.0);
      expect(resolved.background, const FlowTheme.dark().background);
    });

    testWidgets('falls back to the dark defaults when none is registered', (
      tester,
    ) async {
      const dark = FlowTheme.dark();
      late FlowTheme resolved;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            resolved = FlowTheme.resolve(context);
            return const SizedBox();
          },
        ),
      );

      expect(resolved.edge, dark.edge);
      expect(resolved.background, dark.background);
      expect(resolved.handleSize, dark.handleSize);
    });
  });

  testWidgets(
    'NodeFlow with theme:null resolves its background from the ThemeData '
    'extension',
    (tester) async {
      const overriddenBackground = Color(0xFF00FF88);
      final controller = FlowController<String, String>();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: [
              const FlowTheme.dark().copyWith(background: overriddenBackground),
            ],
          ),
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              // theme omitted -> resolves from the ambient Theme above.
              child: NodeFlow<String, String>(
                controller: controller,
                fitViewOnLoad: false,
                minimap: false,
                nodeBuilder: (context, node) => const SizedBox(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The canvas paints its background through a ColoredBox reading
      // FlowTheme.background, so the overridden value must reach it.
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ColoredBox && widget.color == overriddenBackground,
        ),
        findsOneWidget,
      );
    },
  );
}
