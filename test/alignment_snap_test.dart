import 'package:flutter_test/flutter_test.dart';
import 'package:node_flow/node_flow.dart';

void main() {
  group('resolveAlignmentSnap', () {
    test('snaps to a left-edge alignment within the threshold', () {
      final result = resolveAlignmentSnap(
        movingBounds: GraphRect.fromLTWH(104, 300, 100, 50),
        delta: GraphOffset.fromXY(10, 0),
        others: [GraphRect.fromLTWH(100, 0, 100, 50)],
      );

      // left(104) aligns to other's left(100): adjust dx by -4.
      expect(result.delta.dx, 10 - 4);
      expect(result.delta.dy, 0);
      final guide = result.guides.singleWhere((g) => g.vertical);
      expect(guide.position, 100);
      // Spans both rects (padded).
      expect(guide.start, lessThan(0));
      expect(guide.end, greaterThan(350));
    });

    test('snaps centers on both axes simultaneously', () {
      final result = resolveAlignmentSnap(
        movingBounds: GraphRect.fromLTWH(203, 102, 100, 100),
        delta: GraphOffset.zero,
        others: [GraphRect.fromLTWH(200, 100, 100, 100)],
      );

      expect(result.delta.dx, -3);
      expect(result.delta.dy, -2);
      expect(result.guides, hasLength(2));
      expect(result.guides.where((g) => g.vertical), hasLength(1));
      expect(result.guides.where((g) => !g.vertical), hasLength(1));
    });

    test('outside the threshold nothing snaps', () {
      final result = resolveAlignmentSnap(
        movingBounds: GraphRect.fromLTWH(110, 300, 100, 50),
        delta: GraphOffset.fromXY(5, 5),
        others: [GraphRect.fromLTWH(100, 0, 100, 50)],
        threshold: 6,
      );

      expect(result.delta.dx, 5);
      expect(result.delta.dy, 5);
      expect(result.guides, isEmpty);
    });

    test('picks the closest alignment among several candidates', () {
      final result = resolveAlignmentSnap(
        movingBounds: GraphRect.fromLTWH(100, 0, 100, 50),
        delta: GraphOffset.zero,
        others: [
          GraphRect.fromLTWH(105, 200, 100, 50), // left 5 away
          GraphRect.fromLTWH(102, 400, 100, 50), // left 2 away — closest
        ],
      );

      final guide = result.guides.singleWhere((g) => g.vertical);
      expect(guide.position, 102);
      expect(result.delta.dx, 2);
    });
  });

  group('FlowController alignment guides', () {
    test('moveNodeBy soft-snaps and publishes guides when enabled', () {
      final controller = FlowController<void, void>()..snapGuidesEnabled = true;
      addTearDown(controller.dispose);

      controller.addNode(
        FlowNode<void>(
          id: 'anchor',
          type: 'n',
          data: null,
          position: GraphPosition.fromXY(0, 0),
        ),
      );
      controller.addNode(
        FlowNode<void>(
          id: 'moving',
          type: 'n',
          data: null,
          position: GraphPosition.fromXY(4, 300),
        ),
      );

      // Raw delta keeps left at x=4, within 6 of the anchor's left (0).
      controller.moveNodeBy('moving', GraphOffset.zero);

      expect(controller.activeGuides.value, isNotEmpty);
      expect(controller.getNode('moving')!.position.value.dx, 0);

      // Commit preserves the aligned position (alignment wins over grid) and
      // clears the guides.
      controller.commitMove();
      expect(controller.activeGuides.value, isEmpty);
      expect(controller.getNode('moving')!.position.value.dx, 0);
    });

    test('disabled controller keeps exact deltas and no guides', () {
      final controller = FlowController<void, void>();
      addTearDown(controller.dispose);

      controller.addNode(
        FlowNode<void>(
          id: 'anchor',
          type: 'n',
          data: null,
          position: GraphPosition.fromXY(0, 0),
        ),
      );
      controller.addNode(
        FlowNode<void>(
          id: 'moving',
          type: 'n',
          data: null,
          position: GraphPosition.fromXY(4, 300),
        ),
      );

      controller.moveNodeBy('moving', GraphOffset.fromXY(1, 1));

      expect(controller.activeGuides.value, isEmpty);
      expect(controller.getNode('moving')!.position.value.dx, 5);
    });
  });
}
