import 'dart:ui';

import '../core/constraints.dart';
import '../core/layout_object.dart';

/// Raster image on the screen.
///
/// The size comes from the image itself: its own pixels multiplied by
/// [scale]. A result that does not fit the parent is reduced with the
/// proportions kept.
class ImageObject extends LayoutObject {
  ImageObject({required this.image, this.scale = 1.0, this.onTap});

  /// Picture to draw.
  Image image;

  /// Scale factor applied to the size of the picture.
  double scale;

  /// Called when the user taps the image.
  VoidCallback? onTap;

  /// Size of the image in its own pixels.
  Size get pixelSize => Size(image.width.toDouble(), image.height.toDouble());

  @override
  Size measure(LayoutConstraints constraints) {
    final wanted = pixelSize * scale;
    double factor = 1.0;
    // The image is wider than the free space, so it is scaled down.
    if (constraints.hasBoundedWidth && wanted.width > constraints.maxWidth) {
      factor = constraints.maxWidth / wanted.width;
    }
    // The same for the height, with the proportions kept.
    if (constraints.hasBoundedHeight &&
        wanted.height * factor > constraints.maxHeight) {
      factor = constraints.maxHeight / wanted.height;
    }
    return wanted * factor;
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    // The whole image is drawn into the rectangle from the measure.
    canvas.drawImageRect(
      image,
      Offset.zero & pixelSize,
      offset & size,
      Paint()..filterQuality = FilterQuality.medium,
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
