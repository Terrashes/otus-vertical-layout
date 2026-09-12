import 'dart:ui';

import '../core/constraints.dart';
import '../core/layout_object.dart';

/// Rectangle with round corners, filled with a color.
///
/// It asks for [preferredSize], and the base [layout] clamps that size to
/// the limits of the parent, so a rectangle wider than the screen is drawn
/// only up to its border.
class ColoredRectangle extends LayoutObject {
  ColoredRectangle({
    required this.preferredSize,
    required this.color,
    this.cornerRadius = 12.0,
    this.onTap,
  });

  /// Size the rectangle asks for.
  Size preferredSize;

  /// Fill color of the rectangle.
  Color color;

  /// Radius of the corners.
  double cornerRadius;

  /// Called when the user taps the rectangle.
  VoidCallback? onTap;

  @override
  Size measure(LayoutConstraints constraints) => preferredSize;

  @override
  void paint(Canvas canvas, Offset offset) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(offset & size, Radius.circular(cornerRadius)),
      Paint()..color = color,
    );
  }

  @override
  bool handleTap(Offset localPosition) {
    final callback = onTap;
    if (callback == null) {
      return false;
    }
    callback();
    return true;
  }
}
