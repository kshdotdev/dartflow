import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Fully-resolved visual values consumed directly by the canvas painters.
///
/// This is a plain value class on purpose: painters must not perform context
/// lookups while painting. Resolve once against the widget tree with
/// [FlowTheme.resolve], then hand the resulting plain theme down to painters.
///
/// Theming options, in precedence order:
///
/// 1. Pass an explicit `theme:` to the canvas widget.
/// 2. Register a [FlowTheme] as a [ThemeExtension] on your [ThemeData]:
///    `ThemeData(extensions: [FlowTheme.dark().copyWith(...)])`.
/// 3. Do nothing and get the built-in dark palette, [FlowTheme.dark].
final class FlowTheme extends ThemeExtension<FlowTheme> {
  const FlowTheme({
    this.background = _Defaults.background,
    this.gridDot = _Defaults.gridDot,
    this.gridGap = _Defaults.gridGap,
    this.selectionFill = _Defaults.selectionFill,
    this.selectionStroke = _Defaults.selectionStroke,
    this.selectionStrokeWidth = _Defaults.selectionStrokeWidth,
    this.edge = _Defaults.edge,
    this.edgeSelected = _Defaults.edgeSelected,
    this.warning = _Defaults.warning,
    this.nodeHandleFill = _Defaults.nodeHandleFill,
    this.nodeHandleBorder = _Defaults.nodeHandleBorder,
    this.connectionPreview = _Defaults.connectionPreview,
    this.minimapBackground = _Defaults.minimapBackground,
    this.minimapNode = _Defaults.minimapNode,
    this.minimapViewport = _Defaults.minimapViewport,
    this.minimapBorder = _Defaults.minimapBorder,
    this.snapGuide = _Defaults.snapGuide,
    this.handleSize = _Defaults.handleSize,
    this.branchHandleSize = _Defaults.branchHandleSize,
    this.minimapRadius = _Defaults.minimapRadius,
  });

  /// The dark default palette. Identical to a bare `FlowTheme()`; provided as
  /// a named constructor so call sites can state the intent explicitly.
  const FlowTheme.dark() : this();

  /// Resolves the canvas palette for [context]: a [FlowTheme] registered as a
  /// [ThemeExtension] on the ambient [Theme] wins, else [FlowTheme.dark].
  ///
  /// Callers that resolve in build/didChangeDependencies re-resolve
  /// automatically when the ambient theme changes.
  static FlowTheme resolve(BuildContext context) =>
      Theme.of(context).extension<FlowTheme>() ?? const FlowTheme.dark();

  /// Canvas background fill.
  final Color background;

  /// Color of a single grid dot.
  final Color gridDot;

  /// Spacing between grid dots, in graph units.
  final double gridGap;

  /// Fill of the marquee selection rectangle.
  final Color selectionFill;

  /// Stroke of the marquee selection rectangle.
  final Color selectionStroke;

  /// Stroke width of the marquee selection rectangle, in screen pixels.
  final double selectionStrokeWidth;

  /// Default edge (connection) stroke color.
  final Color edge;

  /// Edge stroke color when the edge is selected.
  final Color edgeSelected;

  /// Accent used for warnings (e.g. the dangling-edge badge).
  final Color warning;

  /// Fill of a port handle.
  final Color nodeHandleFill;

  /// Border of a port handle.
  final Color nodeHandleBorder;

  /// Stroke color of the drag-to-connect preview line.
  final Color connectionPreview;

  /// Fill of the minimap's glass panel (a high-alpha [background]).
  final Color minimapBackground;

  /// Fill of an unselected node rectangle in the minimap. Selected nodes use
  /// [selectionStroke].
  final Color minimapNode;

  /// Stroke/fill accent of the minimap's viewport indicator rectangle.
  final Color minimapViewport;

  /// Border of the minimap's glass panel.
  final Color minimapBorder;

  /// Stroke of the alignment guide lines shown while dragging nodes.
  final Color snapGuide;

  /// Diameter of a [PortVisual.circle] handle, in graph units.
  final double handleSize;

  /// Diameter of a [PortVisual.branch] handle, in graph units.
  final double branchHandleSize;

  /// Corner radius of the minimap's glass panel, in logical pixels.
  final double minimapRadius;

  @override
  FlowTheme copyWith({
    Color? background,
    Color? gridDot,
    double? gridGap,
    Color? selectionFill,
    Color? selectionStroke,
    double? selectionStrokeWidth,
    Color? edge,
    Color? edgeSelected,
    Color? warning,
    Color? nodeHandleFill,
    Color? nodeHandleBorder,
    Color? connectionPreview,
    Color? minimapBackground,
    Color? minimapNode,
    Color? minimapViewport,
    Color? minimapBorder,
    Color? snapGuide,
    double? handleSize,
    double? branchHandleSize,
    double? minimapRadius,
  }) {
    return FlowTheme(
      background: background ?? this.background,
      gridDot: gridDot ?? this.gridDot,
      gridGap: gridGap ?? this.gridGap,
      selectionFill: selectionFill ?? this.selectionFill,
      selectionStroke: selectionStroke ?? this.selectionStroke,
      selectionStrokeWidth: selectionStrokeWidth ?? this.selectionStrokeWidth,
      edge: edge ?? this.edge,
      edgeSelected: edgeSelected ?? this.edgeSelected,
      warning: warning ?? this.warning,
      nodeHandleFill: nodeHandleFill ?? this.nodeHandleFill,
      nodeHandleBorder: nodeHandleBorder ?? this.nodeHandleBorder,
      connectionPreview: connectionPreview ?? this.connectionPreview,
      minimapBackground: minimapBackground ?? this.minimapBackground,
      minimapNode: minimapNode ?? this.minimapNode,
      minimapViewport: minimapViewport ?? this.minimapViewport,
      minimapBorder: minimapBorder ?? this.minimapBorder,
      snapGuide: snapGuide ?? this.snapGuide,
      handleSize: handleSize ?? this.handleSize,
      branchHandleSize: branchHandleSize ?? this.branchHandleSize,
      minimapRadius: minimapRadius ?? this.minimapRadius,
    );
  }

  @override
  FlowTheme lerp(ThemeExtension<FlowTheme>? other, double t) {
    if (other is! FlowTheme) return this;
    return FlowTheme(
      background: Color.lerp(background, other.background, t)!,
      gridDot: Color.lerp(gridDot, other.gridDot, t)!,
      gridGap: lerpDouble(gridGap, other.gridGap, t)!,
      selectionFill: Color.lerp(selectionFill, other.selectionFill, t)!,
      selectionStroke: Color.lerp(selectionStroke, other.selectionStroke, t)!,
      selectionStrokeWidth: lerpDouble(
        selectionStrokeWidth,
        other.selectionStrokeWidth,
        t,
      )!,
      edge: Color.lerp(edge, other.edge, t)!,
      edgeSelected: Color.lerp(edgeSelected, other.edgeSelected, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      nodeHandleFill: Color.lerp(nodeHandleFill, other.nodeHandleFill, t)!,
      nodeHandleBorder: Color.lerp(
        nodeHandleBorder,
        other.nodeHandleBorder,
        t,
      )!,
      connectionPreview: Color.lerp(
        connectionPreview,
        other.connectionPreview,
        t,
      )!,
      minimapBackground: Color.lerp(
        minimapBackground,
        other.minimapBackground,
        t,
      )!,
      minimapNode: Color.lerp(minimapNode, other.minimapNode, t)!,
      minimapViewport: Color.lerp(minimapViewport, other.minimapViewport, t)!,
      minimapBorder: Color.lerp(minimapBorder, other.minimapBorder, t)!,
      snapGuide: Color.lerp(snapGuide, other.snapGuide, t)!,
      handleSize: lerpDouble(handleSize, other.handleSize, t)!,
      branchHandleSize: lerpDouble(
        branchHandleSize,
        other.branchHandleSize,
        t,
      )!,
      minimapRadius: lerpDouble(minimapRadius, other.minimapRadius, t)!,
    );
  }
}

/// Authoritative default values for the canvas palette and metrics (the dark
/// look). The [FlowTheme] constructor defaults reference these, so
/// [FlowTheme.dark] and a bare `FlowTheme()` can never drift.
abstract final class _Defaults {
  // Colors (mirror every FlowTheme color field).
  static const background = Color(0xFF101013);
  static const gridDot = Color(0x24FFFFFF); // white @ ~14% alpha
  static const selectionFill = Color(0x1A3EB8C9); // cyan @ ~10% alpha
  static const selectionStroke = Color(0xFF3EB8C9);
  static const edge = Color(0x8C3EB8C9); // cyan @ ~55% alpha
  static const edgeSelected = Color(0xFF3EB8C9);
  static const warning = Color(0xFFF5B544);
  static const nodeHandleFill = Color(0xFF141418);
  static const nodeHandleBorder = Color(0x1FFFFFFF); // white @ ~12% alpha
  static const connectionPreview = Color(0xFF3EB8C9);
  static const minimapBackground = Color(0xE6101013); // #101013 @ ~90% alpha
  static const minimapNode = Color(0x59FFFFFF); // white @ ~35% alpha
  static const minimapViewport = Color(0xFF3EB8C9);
  static const minimapBorder = Color(0x1FFFFFFF); // white @ ~12% alpha
  static const snapGuide = Color(0x993EB8C9); // cyan @ ~60% alpha

  // Sizes / metrics.
  static const gridGap = 32.0;
  static const selectionStrokeWidth = 1.0;
  static const handleSize = 12.0;
  static const branchHandleSize = 14.0;
  static const minimapRadius = 8.0;
}
