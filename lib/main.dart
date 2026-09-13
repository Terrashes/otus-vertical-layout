import 'dart:ui';

import 'src/core/constraints.dart';
import 'src/core/layout_object.dart';
import 'src/layout/vertical_layout_manager.dart';
import 'src/objects/colored_rectangle.dart';

/// Background color of the screen.
const Color _background = Color(0xFF101418);

/// Grows in height on tap, which moves the objects below it.
final _greenBar = ColoredRectangle(
  preferredSize: const Size(240.0, 80.0),
  color: const Color(0xFF3DDC84),
);

/// tap me and i become wide
final _blueBar = ColoredRectangle(
  preferredSize: const Size(320.0, 56.0),
  color: const Color(0xFF4C8DFF),
);

/// Changes its color on tap.
final _orangeBar = ColoredRectangle(
  preferredSize: const Size(180.0, 120.0),
  color: const Color(0xFFFFB020),
);

/// All objects of the screen. The manager places them one under another,
/// no y position is written by hand.
final _screen = VerticalLayoutManager(
  padding: const Insets.all(24.0),
  spacing: 16.0,
  children: <LayoutObject>[_greenBar, _blueBar, _orangeBar],
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
        ? const Size(240.0, 220.0)
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
