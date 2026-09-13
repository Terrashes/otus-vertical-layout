import 'dart:math' as math;
import 'dart:ui';

import '../core/constraints.dart';
import '../core/layout_object.dart';

/// Places its children one under another.
///
/// Each child is measured with the space that is still free in the column
/// and then gets a position. The x is the same for every child, only the y
/// grows, so the left borders stay on one line.
class VerticalLayoutManager extends LayoutObject {
  VerticalLayoutManager({
    List<LayoutObject>? children,
    this.spacing = 0.0,
    this.padding = Insets.zero,
  }) : children = children ?? <LayoutObject>[];

  /// Objects of the column, from the top to the bottom.
  final List<LayoutObject> children;

  /// Empty space between two neighbouring children.
  double spacing;

  /// Empty space between the border of the column and its children.
  Insets padding;

  @override
  Size measure(LayoutConstraints constraints) {
    // Padding takes a part of the space that came from the parent.
    final inner = constraints.deflate(padding);
    double y = padding.top;
    double widest = 0.0;
    double freeHeight = inner.maxHeight;

    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      if (i > 0) {
        y += spacing;
        freeHeight -= spacing;
      }
      // A child may take any size that is still free in the column.
      final childSize = child.layout(
        LayoutConstraints(
          maxWidth: inner.maxWidth,
          maxHeight: math.max(freeHeight, 0.0),
        ),
      );
      // The same x for every child keeps the left borders on one line.
      child.offset = Offset(padding.left, y);
      y += childSize.height;
      freeHeight -= childSize.height;
      widest = math.max(widest, childSize.width);
    }

    // The column is as tall as all of its children together.
    return Size(widest + padding.horizontal, y + padding.bottom);
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    for (final child in children) {
      child.paint(canvas, offset + child.offset);
    }
  }

  @override
  bool handleTap(Offset localPosition) {
    for (final child in children) {
      if (child.bounds.contains(localPosition)) {
        // The child receives the position in its own coordinates.
        return child.handleTap(localPosition - child.offset);
      }
    }
    return false;
  }
}
