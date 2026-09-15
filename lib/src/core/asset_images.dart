/// Loads pictures from the assets folder.
///
/// dart:ui reads an asset file only on a device. A browser has no files, so
/// there the same asset is downloaded over http. The export below picks the
/// version for the target platform.
library;

export 'asset_images_io.dart'
    if (dart.library.js_interop) 'asset_images_web.dart';
