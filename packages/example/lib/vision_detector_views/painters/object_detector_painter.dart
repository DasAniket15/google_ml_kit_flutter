// ignore: unused_import
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
  final bool calculate3DCoordinates;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.lightGreenAccent;

    final Paint backgroundPaint = Paint()..color = Colors.white;

    for (final DetectedObject detectedObject in _objects) {
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
      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), boxPaint);

      // Build label text
      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
            textAlign: TextAlign.left,
            fontSize: 16,
            textDirection: TextDirection.ltr),
      )..pushStyle(ui.TextStyle(color: Colors.black));

      if (detectedObject.labels.isNotEmpty) {
        final label = detectedObject.labels
            .reduce((a, b) => a.confidence > b.confidence ? a : b);
        builder.addText(
            '${label.text} (${(label.confidence * 100).toStringAsFixed(1)}%)\n');
      }

      if (calculate3DCoordinates) {
        final center3D =
            _estimate3DCoordinates(detectedObject.boundingBox, size);
        builder.addText(
            '3D: (${center3D.dx.toStringAsFixed(2)}, ${center3D.dy.toStringAsFixed(2)}, ${center3D.dy.toStringAsFixed(2)})\n');
      }

      // Build the paragraph to measure size
      final Paragraph paragraph = builder.build();
      paragraph.layout(ParagraphConstraints(width: right - left));

      // Calculate position for white box
      final whiteBoxRect = Rect.fromLTWH(
        left,
        top - paragraph.height - 4,
        paragraph.width + 8,
        paragraph.height + 4,
      );

      // Draw white box
      canvas.drawRect(whiteBoxRect, backgroundPaint);

      // Draw text on top of the white box
      canvas.drawParagraph(paragraph, Offset(left + 4, top - paragraph.height));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  /// Helper function to estimate 3D coordinates
  Offset _estimate3DCoordinates(Rect boundingBox, Size widgetSize) {
    final centerX = boundingBox.center.dx / widgetSize.width;
    final centerY = boundingBox.center.dy / widgetSize.height;
    // ignore: unused_local_variable
    final depth = 1.0 / boundingBox.width;

    return Offset(centerX, centerY); // Replace with actual depth estimation
  }
}
