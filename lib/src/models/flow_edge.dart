import 'package:flutter/foundation.dart';

/// A directed connection between two node ports.
///
/// Edges are pure data in phases 1-2; rendering arrives in phase 3. Only the
/// [selected] flag is reactive.
final class FlowEdge<E> {
  FlowEdge({
    required this.id,
    required this.sourceNodeId,
    required this.sourcePortId,
    required this.targetNodeId,
    required this.targetPortId,
    this.data,
    bool selected = false,
    this.dangling = false,
    this.label,
  }) : selected = ValueNotifier(selected);

  /// Unique identifier within the owning controller.
  final String id;

  /// Id of the node the edge starts from.
  final String sourceNodeId;

  /// Id of the source port on [sourceNodeId].
  final String sourcePortId;

  /// Id of the node the edge ends at.
  final String targetNodeId;

  /// Id of the target port on [targetNodeId].
  final String targetPortId;

  /// Optional application payload.
  final E? data;

  /// Whether the edge is part of the current selection.
  final ValueNotifier<bool> selected;

  /// Whether the edge is dangling (an endpoint is missing/unresolved).
  final bool dangling;

  /// Optional label rendered along the edge (phase 3).
  final String? label;

  /// Releases the edge's notifier. Called by the controller.
  void dispose() {
    selected.dispose();
  }
}
