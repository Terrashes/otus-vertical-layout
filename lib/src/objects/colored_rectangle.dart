import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import '../core/constraints.dart';
import '../core/layout_object.dart';

/// Rectangle with round corners, filled with a color or with a picture.
///
/// It asks for [preferredSize], and the base [layout] clamps that size to
/// the limits of the parent, so a rectangle wider than the screen is drawn
/// only up to its border.
class ColoredRectangle extends LayoutObject {
  ColoredRectangle({
    required this.preferredSize,
    required this.color,
    this.image,
    this.imageAlignX = 0.5,
    this.imageAlignY = 0.0,
    this.cornerRadius = 12.0,
    this.onTap,
  });

  /// Size the rectangle asks for.
  Size preferredSize;

  /// Fill color, drawn under [image].
  Color color;

  /// Picture drawn inside the rectangle, like background-image in css.
  Image? image;

  /// Horizontal part of the picture that stays visible when it does not
  /// fit: 0.0 keeps the left side, 0.5 the middle, 1.0 the right side. Works
  /// like background-position in css.
  double imageAlignX;

  /// The same for the height: 0.0 keeps the top of the picture, 1.0 the
  /// bottom. Faces usually sit near the top, so 0.0 is the default.
  double imageAlignY;

  /// Radius of the corners.
  double cornerRadius;

  /// Called when the user taps the rectangle.
  VoidCallback? onTap;

  @override
  Size measure(LayoutConstraints constraints) => preferredSize;

  @override
  void paint(Canvas canvas, Offset offset) {
    final rect = offset & size;
    final body = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));
    // The color goes first, like background-color in css: a png may have
    // transparent parts, and they show this color instead of the page.
    canvas.drawRRect(body, Paint()..color = color);
    final picture = image;
    if (picture != null) {
      canvas.drawRRect(body, Paint()..shader = _coverShader(picture, rect));
    }
  }

  /// Builds a shader that fills [rect] with the picture and keeps its
  /// proportions.
  ///
  /// Works like background-size: cover in css: the picture is scaled until
  /// it covers the whole box, and the extra part is cut off.
  Shader _coverShader(Image picture, Rect rect) {
    final scale = math.max(
      rect.width / picture.width,
      rect.height / picture.height,
    );
    // The extra part is cut off, and these two values choose the side it
    // is cut from.
    final dx = rect.left + (rect.width - picture.width * scale) * imageAlignX;
    final dy = rect.top + (rect.height - picture.height * scale) * imageAlignY;
    // A 4x4 matrix: the diagonal holds the scale, the last row the offset.
    final matrix = Float64List.fromList(<double>[
      scale, 0.0, 0.0, 0.0, //
      0.0, scale, 0.0, 0.0, //
      0.0, 0.0, 1.0, 0.0, //
      dx, dy, 0.0, 1.0, //
    ]);
    return ImageShader(picture, TileMode.clamp, TileMode.clamp, matrix);
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
