import 'package:flutter/material.dart';

class PosePainter extends CustomPainter {
  final List<List<double>> keypoints;
  final Size imageSize;

  PosePainter({required this.keypoints, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (keypoints.isNotEmpty && keypoints.length >= 17) {
      _drawSkeleton(canvas, size);
    } else {
      _drawDetectionFailedMessage(canvas, size);
    }
  }

  void _drawSkeleton(Canvas canvas, Size size) {
    final jointPaint = Paint()
      ..color = Colors.yellowAccent
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Sambungan tubuh
    final connections = [
      [5, 6], [5, 11], [6, 12], [11, 12],
      [5, 7], [7, 9], [6, 8], [8, 10],
      [11, 13], [13, 15], [12, 14], [14, 16],
    ];

    // Rasio normalisasi agar sesuai kamera
    for (var connection in connections) {
      final p1 = keypoints[connection[0]];
      final p2 = keypoints[connection[1]];

      if (p1[0] != -1 && p2[0] != -1) {
        final start = Offset(
          (1 - p1[1]) * size.width,
          p1[0] * size.height,
        );
        final end = Offset(
          (1 - p2[1]) * size.width,
          p2[0] * size.height,
        );
        canvas.drawLine(start, end, linePaint);
      }
    }

    for (var p in keypoints) {
      if (p[0] != -1) {
        final x = (1 - p[1]) * size.width;
        final y = p[0] * size.height;
        canvas.drawCircle(Offset(x, y), 4, jointPaint);
      }
    }
  }

  void _drawDetectionFailedMessage(Canvas canvas, Size size) {
    final text = 'Tidak ada orang terdeteksi.\nCoba atur posisi & pencahayaan.';
    final textStyle = TextStyle(
      color: Colors.white.withOpacity(0.8),
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final tp = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: size.width * 0.8);
    final offset =
        Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: offset.translate(tp.width / 2, tp.height / 2),
                width: tp.width + 30,
                height: tp.height + 20),
            const Radius.circular(10)),
        Paint()..color = Colors.black.withOpacity(0.5));
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}