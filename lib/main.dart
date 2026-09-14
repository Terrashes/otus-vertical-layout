import 'dart:ui';

import 'src/core/constraints.dart';
import 'src/core/layout_object.dart';
import 'src/layout/vertical_layout_manager.dart';
import 'src/objects/card_object.dart';
import 'src/objects/colored_rectangle.dart';
import 'src/objects/text_object.dart';

/// Background color of the screen.
const Color _background = Color(0xFF101418);

/// Color of the secondary text.
const Color _grayText = Color(0xFF8B98A5);

/// Grows in height on tap, which moves the objects below it.
final _greenBar = ColoredRectangle(
  preferredSize: const Size(240.0, 80.0),
  color: const Color(0xFF3DDC84),
);

/// Asks for a width larger than the screen to show how constraints cut it.
final _blueBar = ColoredRectangle(
  preferredSize: const Size(320.0, 56.0),
  color: const Color(0xFF4C8DFF),
);

/// Changes its color on tap.
final _orangeBar = ColoredRectangle(
  preferredSize: const Size(180.0, 90.0),
  color: const Color(0xFFFFB020),
);

/// Bar that lives inside the card.
final _cardBar = ColoredRectangle(
  preferredSize: const Size(160.0, 36.0),
  color: const Color(0xFF9B7BFF),
  cornerRadius: 8.0,
);

/// Structural object: a title with its own column of objects inside.
final _card = CardObject(
  title: 'Card with objects inside',
  content: VerticalLayoutManager(
    spacing: 10.0,
    children: <LayoutObject>[
      TextObject(
        text:
            'Inside the card there is one more manager. Tap the card to fold '
            'it, or tap the small bar to make it wider.',
        fontSize: 14.0,
        color: _grayText,
      ),
      _cardBar,
    ],
  ),
);

/// All objects of the screen. The manager places them one under another,
/// no y position is written by hand.
final _screen = VerticalLayoutManager(
  padding: const Insets.all(24.0),
  spacing: 16.0,
  children: <LayoutObject>[
    TextObject(
      text: 'Vertical layout with dart:ui',
      fontSize: 26.0,
      fontWeight: FontWeight.w700,
    ),
    TextObject(
      text: 'Tap any object: it changes size and the column moves the rest.',
      fontSize: 14.0,
      color: _grayText,
    ),
    _greenBar,
    _blueBar,
    _orangeBar,
    _card,
  ],
);

/// Entry point of the application.
///
/// There are no flutter widgets here, only dart:ui: frames are requested
/// from the engine and painted by hand.
void main() {
  // A tap changes the size of one object and the manager moves the others.
  _greenBar.onTap = () {
    final isSmall = _greenBar.preferredSize.height < 120.0;
    _greenBar.preferredSize = isSmall
        ? const Size(240.0, 160.0)
        : const Size(240.0, 80.0);
  };
  // This one grows wider than the screen, and the constraints cut it.
  _blueBar.onTap = () {
    final isNarrow = _blueBar.preferredSize.width < 400.0;
    _blueBar.preferredSize = isNarrow
        ? const Size(5000.0, 56.0)
        : const Size(320.0, 56.0);
  };
  // Color does not change the size, so nothing moves.
  _orangeBar.onTap = () {
    _orangeBar.color = _orangeBar.color == const Color(0xFFFFB020)
        ? const Color(0xFFE5484D)
        : const Color(0xFFFFB020);
  };
  // The bar inside the card also makes the card wider.
  _cardBar.onTap = () {
    final isNarrow = _cardBar.preferredSize.width < 200.0;
    _cardBar.preferredSize = isNarrow
        ? const Size(260.0, 36.0)
        : const Size(160.0, 36.0);
  };

  final dispatcher = PlatformDispatcher.instance;
  dispatcher.onDrawFrame = _drawFrame;
  dispatcher.onPointerDataPacket = _handlePointerData;
  // A resized window needs a new frame.
  dispatcher.onMetricsChanged = dispatcher.scheduleFrame;
  dispatcher.scheduleFrame();
}

/// Handles the pointer events that come from the engine.
void _handlePointerData(PointerDataPacket packet) {
  final devicePixelRatio =
      PlatformDispatcher.instance.views.first.devicePixelRatio;
  for (final data in packet.data) {
    if (data.change != PointerChange.down) {
      continue;
    }
    // Pointer positions arrive in physical pixels, the layout is logical.
    final position = Offset(data.physicalX, data.physicalY) / devicePixelRatio;
    if (_screen.handleTap(position)) {
      // A changed object invalidates the layout, so the next frame counts
      // it again with the new sizes.
      PlatformDispatcher.instance.scheduleFrame();
    }
  }
}

/// Draws a single frame into the first view of the application.
void _drawFrame() {
  final view = PlatformDispatcher.instance.views.first;
  final physicalSize = view.physicalSize;
  if (physicalSize.isEmpty) {
    // The view has no size yet, so the frame is retried later.
    PlatformDispatcher.instance.scheduleFrame();
    return;
  }
  // Physical size of the screen is the outer limit of the layout.
  final devicePixelRatio = view.devicePixelRatio;
  final screenSize = physicalSize / devicePixelRatio;

  // Outer constraints run from (0, 0) to the size of the screen.
  _screen.layout(LayoutConstraints.loose(screenSize));

  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, Offset.zero & physicalSize);
  // Everything below this line is measured in logical pixels.
  canvas.scale(devicePixelRatio);
  canvas.drawRect(Offset.zero & screenSize, Paint()..color = _background);
  _screen.paint(canvas, Offset.zero);

  // The recorded drawing is packed into a scene for the engine.
  final picture = recorder.endRecording();
  final builder = SceneBuilder()..addPicture(Offset.zero, picture);
  final scene = builder.build();
  view.render(scene);
  // The scene and the picture are not disposed here: the engine rasterizes
  // them after this function returns.
}
