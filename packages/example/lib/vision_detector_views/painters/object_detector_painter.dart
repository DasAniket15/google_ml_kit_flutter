import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import 'coordinates_translator.dart';

class ObjectDetectorPainter extends CustomPainter {
  ObjectDetectorPainter(
    this._objects,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection, {
    this.calculate3DCoordinates = false,
  });

  final List<DetectedObject> _objects;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final bool
      calculate3DCoordinates; // New parameter for 3D coordinate calculations

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.lightGreenAccent;

    final Paint background = Paint()..color = Color(0x99000000);

    for (final DetectedObject detectedObject in _objects) {
      // Paragraph builder for object labels and optional 3D coordinates
      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
            textAlign: TextAlign.left,
            fontSize: 16,
            textDirection: TextDirection.ltr),
      );
      builder.pushStyle(
          ui.TextStyle(color: Colors.lightGreenAccent, background: background));

      // Add object label with confidence
      if (detectedObject.labels.isNotEmpty) {
        final label = detectedObject.labels
            .reduce((a, b) => a.confidence > b.confidence ? a : b);
        builder.addText(
            '${label.text} (${(label.confidence * 100).toStringAsFixed(1)}%)\n');
      }

      // Add 3D coordinates if enabled
      if (calculate3DCoordinates) {
        final center3D =
            _estimate3DCoordinates(detectedObject.boundingBox, size);
        builder.addText(
            '3D: (${center3D.dx.toStringAsFixed(2)}, ${center3D.dy.toStringAsFixed(2)}, ${center3D.dy.toStringAsFixed(2)})\n');
      }
      builder.pop();

      // Calculate bounding box corners
      final left = translateX(
        detectedObject.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        detectedObject.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        detectedObject.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        detectedObject.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

      // Draw bounding box
      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paint,
      );

      // Draw label and 3D coordinates
      canvas.drawParagraph(
        builder.build()
          ..layout(ParagraphConstraints(
            width: (right - left).abs(),
          )),
        Offset(
            Platform.isAndroid &&
                    cameraLensDirection == CameraLensDirection.front
                ? right
                : left,
            top),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  /// Helper function to estimate 3D coordinates
  Offset _estimate3DCoordinates(Rect boundingBox, Size widgetSize) {
    // Use the bounding box center and arbitrary depth calculation
    final centerX = boundingBox.center.dx / widgetSize.width;
    final centerY = boundingBox.center.dy / widgetSize.height;
    final depth = 1.0 / boundingBox.width; // Placeholder depth estimation

    return Offset(centerX, centerY); // Replace with actual depth estimation
  }
}
