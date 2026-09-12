import 'dart:ui';

import 'constraints.dart';

/// Base class for every object on the screen.
///
/// An object reports the size it wants and draws itself. The position is
/// chosen by the layout manager, which writes it into [offset].
abstract class LayoutObject {
  /// Position inside the parent, assigned by the parent.
  Offset offset = Offset.zero;

  Size _size = Size.zero;

  /// Size from the last measure.
  Size get size => _size;

  /// Rectangle of the object in the coordinates of the parent.
  Rect get bounds => offset & _size;

  /// Measures the object under the [constraints] of the parent.
  ///
  /// The requested size is clamped to the allowed range and stored in
  /// [size].
  Size layout(LayoutConstraints constraints) {
    _size = constraints.constrain(measure(constraints));
    return _size;
  }

  /// Size the object asks for.
  ///
  /// Each kind of object counts it differently: a rectangle returns its own
  /// size, a text asks the font engine, a manager sums up its children.
  Size measure(LayoutConstraints constraints);

  /// Draws the object at [offset] on the canvas.
  void paint(Canvas canvas, Offset offset);

  /// Handles a tap at [localPosition], counted from the top left corner of
  /// the object. Returns whether the tap was handled.
  bool handleTap(Offset localPosition) => false;
}
