import 'package:flutter/material.dart';
import 'package:node_flow/node_flow.dart';

/// Payload for the demo nodes: a title and an accent color.
class DemoNode {
  const DemoNode(this.title, this.color);

  final String title;
  final Color color;
}

/// A 256-wide placeholder card whose height is intrinsic. Reflects selection
/// live via the node's `selected` notifier.
class DemoNodeCard extends StatelessWidget {
  const DemoNodeCard({super.key, required this.node});

  final FlowNode<DemoNode> node;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: node.selected,
      builder: (context, selected, _) {
        return Container(
          width: 256,
          decoration: BoxDecoration(
            color: node.data.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFF3EB8C9)
                  : const Color(0x22FFFFFF),
              width: selected ? 2 : 1,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                node.data.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'id: ${node.id}${node.locked ? '  (locked)' : ''}',
                style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
