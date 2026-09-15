import 'dart:js_interop';
import 'dart:ui';

import 'package:web/web.dart' as web;

import 'asset_images_io.dart' show decodeImageBuffer;

/// Downloads a picture over http, because a browser has no files.
///
/// Flutter serves the assets from the "assets" folder of the site, so the
/// address is "assets/" plus the key from pubspec.yaml.
Future<Image> loadAssetImage(String assetKey) async {
  final response = await web.window.fetch('assets/$assetKey'.toJS).toDart;
  final jsBuffer = await response.arrayBuffer().toDart;
  final bytes = jsBuffer.toDart.asUint8List();
  final buffer = await ImmutableBuffer.fromUint8List(bytes);
  return decodeImageBuffer(buffer);
}
