import 'dart:ui';

import '../core/constraints.dart';
import '../core/layout_object.dart';

/// Piece of text on the screen.
///
/// The size is counted by the font engine: a Paragraph is laid out inside
/// the width of the parent, and the height of its lines becomes the size of
/// the object.
class TextObject extends LayoutObject {
  TextObject({
    required this.text,
    this.fontSize = 16.0,
    this.color = const Color(0xFFE6EDF3),
    this.fontWeight = FontWeight.normal,
  });

  /// Width used for the measure when the parent sets no limit.
  static const double _noLimitWidth = 10000.0;

  /// Text to draw.
  String text;

  /// Font size in logical pixels.
  double fontSize;

  /// Color of the letters.
  Color color;

  /// Weight of the font.
  FontWeight fontWeight;

  /// Paragraph built by the last measure, the one [paint] draws.
  Paragraph? _paragraph;

  @override
  Size measure(LayoutConstraints constraints) {
    final builder =
        ParagraphBuilder(ParagraphStyle(textDirection: TextDirection.ltr))
          ..pushStyle(
            TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: fontWeight,
              height: 1.3,
            ),
          )
          ..addText(text);

    // The text breaks into lines inside this width.
    final width = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : _noLimitWidth;
    final paragraph = builder.build()
      ..layout(ParagraphConstraints(width: width));

    _paragraph = paragraph;
    // longestLine is the real width of the text, height covers all lines.
    return Size(paragraph.longestLine.ceilToDouble(), paragraph.height);
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    final paragraph = _paragraph;
    if (paragraph != null) {
      canvas.drawParagraph(paragraph, offset);
    }
  }
}
