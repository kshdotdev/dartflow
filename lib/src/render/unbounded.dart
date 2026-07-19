import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A [Stack] that allows hit testing on children positioned outside its bounds.
///
/// Flutter's default [Stack] blocks hit testing for children outside its bounds,
/// even when `clipBehavior` is [Clip.none]. This custom stack overrides
/// [RenderBox.hitTest] to allow gestures on overflow content, which is essential
/// for an infinite canvas where nodes may be transformed to arbitrary positions
/// after pan/zoom.
class UnboundedStack extends Stack {
  const UnboundedStack({
    super.key,
    super.alignment,
    super.textDirection,
    super.fit,
    super.clipBehavior,
    super.children,
  });

  @override
  RenderStack createRenderObject(BuildContext context) {
    return _UnboundedRenderStack(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.maybeOf(context),
      fit: fit,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderStack renderObject) {
    renderObject
      ..alignment = alignment
      ..textDirection = textDirection ?? Directionality.maybeOf(context)
      ..fit = fit
      ..clipBehavior = clipBehavior;
  }
}

class _UnboundedRenderStack extends RenderStack {
  _UnboundedRenderStack({
    super.alignment,
    super.textDirection,
    super.fit,
    super.clipBehavior,
  });

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Skip the default bounds check (`size.contains(position)`) so that hit
    // testing reaches children positioned outside this stack's bounds.
    if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}

/// A [SizedBox] that allows hit testing on children outside its bounds.
///
/// Use this to give the [InteractiveViewer]'s (unconstrained) child a definite
/// size while still allowing gestures to reach content transformed outside the
/// box by pan/zoom.
class UnboundedSizedBox extends SingleChildRenderObjectWidget {
  const UnboundedSizedBox({super.key, this.width, this.height, super.child});

  final double? width;
  final double? height;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _UnboundedRenderConstrainedBox(
      additionalConstraints: BoxConstraints.tightFor(
        width: width,
        height: height,
      ),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderConstrainedBox renderObject,
  ) {
    renderObject.additionalConstraints = BoxConstraints.tightFor(
      width: width,
      height: height,
    );
  }
}

class _UnboundedRenderConstrainedBox extends RenderConstrainedBox {
  _UnboundedRenderConstrainedBox({required super.additionalConstraints});

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Skip the default bounds check - allow hit testing outside this box, which
    // is essential once content has been transformed (pan/zoom) to positions
    // outside this box's layout bounds.
    final RenderBox? child = this.child;
    if (child != null) {
      return child.hitTest(result, position: position);
    }
    return false;
  }
}
