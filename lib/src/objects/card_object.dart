import 'dart:math' as math;
import 'dart:ui';

import '../core/constraints.dart';
import '../core/layout_object.dart';
import 'text_object.dart';

/// Card with a background, a title and content inside.
///
/// A structural object: it keeps other objects and measures them itself. A
/// tap folds the card, so only the title stays, the card becomes lower and
/// the neighbours in the column move up.
class CardObject extends LayoutObject {
  CardObject({
    required String title,
    required this.content,
    this.padding = const Insets.all(16.0),
    this.gap = 12.0,
    this.cornerRadius = 16.0,
    this.background = const Color(0xFF18202B),
    this.borderColor = const Color(0xFF2C3A4B),
    this.expanded = true,
  }) : _title = TextObject(
         text: title,
         fontSize: 18.0,
         fontWeight: FontWeight.w600,
       );

  /// Width reserved on the right of the title for the arrow.
  static const double _arrowSlot = 28.0;

  /// Empty space between the border of the card and its content.
  Insets padding;

  /// Empty space between the title and the content.
  double gap;

  /// Radius of the corners.
  double cornerRadius;

  /// Color of the card background.
  Color background;

  /// Color of the border line.
  Color borderColor;

  /// Whether the content is visible; a folded card shows only the title.
  bool expanded;

  /// Content of the card, usually a manager with several objects.
  LayoutObject content;

  final TextObject _title;

  /// Text of the title.
  String get title => _title.text;

  set title(String value) => _title.text = value;

  @override
  Size measure(LayoutConstraints constraints) {
    // Padding takes a part of the space that came from the parent.
    final inner = constraints.deflate(padding);

    final titleSize = _title.layout(
      LayoutConstraints(
        maxWidth: math.max(inner.maxWidth - _arrowSlot, 0.0),
        maxHeight: inner.maxHeight,
      ),
    );
    _title.offset = padding.topLeft;

    double height = titleSize.height;
    double width = titleSize.width + _arrowSlot;

    if (expanded) {
      height += gap;
      // The content gets the height that is still free inside the card.
      final contentSize = content.layout(
        LayoutConstraints(
          maxWidth: inner.maxWidth,
          maxHeight: math.max(inner.maxHeight - height, 0.0),
        ),
      );
      content.offset = Offset(padding.left, padding.top + height);
      height += contentSize.height;
      width = math.max(width, contentSize.width);
    }

    // The card takes all the width it is allowed to take.
    final totalWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : width + padding.horizontal;
    return Size(totalWidth, height + padding.vertical);
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    final frame = RRect.fromRectAndRadius(
      offset & size,
      Radius.circular(cornerRadius),
    );
    canvas.drawRRect(frame, Paint()..color = background);
    canvas.drawRRect(
      frame,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    _title.paint(canvas, offset + _title.offset);
    _paintArrow(canvas, offset);
    if (expanded) {
      content.paint(canvas, offset + content.offset);
    }
  }

  /// Draws the small triangle on the right: it points down when the card
  /// is open and to the right when it is folded.
  void _paintArrow(Canvas canvas, Offset offset) {
    const double side = 9.0;
    final center = Offset(
      offset.dx + size.width - padding.right - side,
      offset.dy + padding.top + _title.size.height / 2.0,
    );
    final path = Path();
    if (expanded) {
      path
        ..moveTo(center.dx - side, center.dy - side / 2.0)
        ..lineTo(center.dx + side, center.dy - side / 2.0)
        ..lineTo(center.dx, center.dy + side / 2.0);
    } else {
      path
        ..moveTo(center.dx - side / 2.0, center.dy - side)
        ..lineTo(center.dx + side / 2.0, center.dy)
        ..lineTo(center.dx - side / 2.0, center.dy + side);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = _title.color);
  }

  @override
  bool handleTap(Offset localPosition) {
    // The objects inside get the tap first.
    if (expanded && content.bounds.contains(localPosition)) {
      if (content.handleTap(localPosition - content.offset)) {
        return true;
      }
    }
    // Nothing inside handled it, so the card folds or opens.
    expanded = !expanded;
    return true;
  }
}
