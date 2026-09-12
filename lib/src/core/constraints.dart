import 'dart:ui';

/// Empty space around the content of an object.
///
/// Replaces EdgeInsets, which lives in the flutter framework and is not
/// available in dart:ui.
class Insets {
  const Insets.all(double value)
    : left = value,
      top = value,
      right = value,
      bottom = value;

  const Insets.symmetric({double horizontal = 0.0, double vertical = 0.0})
    : left = horizontal,
      right = horizontal,
      top = vertical,
      bottom = vertical;

  const Insets.only({
    this.left = 0.0,
    this.top = 0.0,
    this.right = 0.0,
    this.bottom = 0.0,
  });

  /// Insets without any space.
  static const Insets zero = Insets.all(0.0);

  final double left;
  final double top;
  final double right;
  final double bottom;

  /// Sum of the left and the right insets.
  double get horizontal => left + right;

  /// Sum of the top and the bottom insets.
  double get vertical => top + bottom;

  /// Offset of the content from the top left corner.
  Offset get topLeft => Offset(left, top);
}

/// Minimum and maximum size that a parent allows for its child.
///
/// Replaces BoxConstraints from the flutter framework. A child chooses any
/// size between the minimum and the maximum values.
class LayoutConstraints {
  const LayoutConstraints({
    this.minWidth = 0.0,
    this.maxWidth = double.infinity,
    this.minHeight = 0.0,
    this.maxHeight = double.infinity,
  });

  /// Constraints from (0, 0) up to [size], the ones the screen provides.
  LayoutConstraints.loose(Size size)
    : minWidth = 0.0,
      maxWidth = size.width,
      minHeight = 0.0,
      maxHeight = size.height;

  /// Constraints that allow [size] and nothing else.
  LayoutConstraints.tight(Size size)
    : minWidth = size.width,
      maxWidth = size.width,
      minHeight = size.height,
      maxHeight = size.height;

  final double minWidth;
  final double maxWidth;
  final double minHeight;
  final double maxHeight;

  /// Whether the maximum width is limited.
  bool get hasBoundedWidth => maxWidth < double.infinity;

  /// Whether the maximum height is limited.
  bool get hasBoundedHeight => maxHeight < double.infinity;

  /// The largest allowed size.
  Size get biggest => Size(maxWidth, maxHeight);

  /// The smallest allowed size.
  Size get smallest => Size(minWidth, minHeight);

  double constrainWidth(double width) =>
      width.clamp(minWidth, maxWidth).toDouble();

  double constrainHeight(double height) =>
      height.clamp(minHeight, maxHeight).toDouble();

  /// Clamps the size an object asks for to the allowed range.
  Size constrain(Size size) =>
      Size(constrainWidth(size.width), constrainHeight(size.height));

  /// Keeps the maximum values and drops the minimum ones.
  LayoutConstraints loosen() =>
      LayoutConstraints(maxWidth: maxWidth, maxHeight: maxHeight);

  /// Reduces the limits by [insets], the space taken by padding.
  LayoutConstraints deflate(Insets insets) {
    return LayoutConstraints(
      minWidth: (minWidth - insets.horizontal).clamp(0.0, double.infinity),
      maxWidth: hasBoundedWidth
          ? (maxWidth - insets.horizontal).clamp(0.0, double.infinity)
          : double.infinity,
      minHeight: (minHeight - insets.vertical).clamp(0.0, double.infinity),
      maxHeight: hasBoundedHeight
          ? (maxHeight - insets.vertical).clamp(0.0, double.infinity)
          : double.infinity,
    );
  }

  LayoutConstraints copyWith({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    return LayoutConstraints(
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is LayoutConstraints &&
        other.minWidth == minWidth &&
        other.maxWidth == maxWidth &&
        other.minHeight == minHeight &&
        other.maxHeight == maxHeight;
  }

  @override
  int get hashCode => Object.hash(minWidth, maxWidth, minHeight, maxHeight);

  @override
  String toString() =>
      'LayoutConstraints(w: $minWidth..$maxWidth, h: $minHeight..$maxHeight)';
}
