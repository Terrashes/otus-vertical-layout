import 'dart:ui';

/// Loads a picture from the assets of the application.
///
/// rootBundle lives in the flutter framework and is not used here: dart:ui
/// reads the bytes, detects the format and decodes the first frame.
Future<Image> loadAssetImage(String assetKey) async {
  final buffer = await ImmutableBuffer.fromAsset(assetKey);
  return decodeImageBuffer(buffer);
}

/// Decodes the bytes of a jpg or a png into an image.
Future<Image> decodeImageBuffer(ImmutableBuffer buffer) async {
  final descriptor = await ImageDescriptor.encoded(buffer);
  final codec = await descriptor.instantiateCodec();
  final frame = await codec.getNextFrame();
  return frame.image;
}
