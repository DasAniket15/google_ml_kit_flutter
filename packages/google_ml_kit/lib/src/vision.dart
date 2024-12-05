import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

/// Get instance of the individual api's using instance of [Vision]
/// For example
/// To get an instance of [ImageLabeler]
/// ImageLabeler imageLabeler = GoogleMlKit.instance.imageLabeler();
class Vision {
  Vision._();

  // Creates an instance of [GoogleMlKit] by calling the private constructor
  static final Vision instance = Vision._();

  /// Returns an instance of [ObjectDetector].
  @Deprecated(
      'Use [google_mlkit_object_detection] plugin instead of [google_ml_kit].')
  ObjectDetector objectDetector({required ObjectDetectorOptions options}) {
    return ObjectDetector(options: options);
  }
}
