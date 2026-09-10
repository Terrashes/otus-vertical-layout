import 'dart:ui';

/// Background color of the screen.
const Color _background = Color(0xFF101418);

/// Entry point of the application.
///
/// There are no flutter widgets here, only dart:ui: frames are requested
/// from the engine and painted by hand.
void main() {
  final dispatcher = PlatformDispatcher.instance;
  dispatcher.onDrawFrame = _drawFrame;
  // A resized window needs a new frame.
  dispatcher.onMetricsChanged = dispatcher.scheduleFrame;
  dispatcher.scheduleFrame();
}

/// Draws a single frame into the first view of the application.
void _drawFrame() {
  final view = PlatformDispatcher.instance.views.first;
  final physicalSize = view.physicalSize;
  if (physicalSize.isEmpty) {
    return;
  }
  // Physical size of the screen is the outer limit of the layout.
  final devicePixelRatio = view.devicePixelRatio;
  final screenSize = physicalSize / devicePixelRatio;

  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, Offset.zero & physicalSize);
  // Everything below this line is measured in logical pixels.
  canvas.scale(devicePixelRatio);
  canvas.drawRect(Offset.zero & screenSize, Paint()..color = _background);
  canvas.drawRect(
    const Rect.fromLTWH(32.0, 32.0, 240.0, 80.0),
    Paint()..color = const Color(0xFF3DDC84),
  );

  // The recorded drawing is packed into a scene for the engine.
  final picture = recorder.endRecording();
  final builder = SceneBuilder()..addPicture(Offset.zero, picture);
  final scene = builder.build();
  view.render(scene);
  scene.dispose();
  picture.dispose();
}
