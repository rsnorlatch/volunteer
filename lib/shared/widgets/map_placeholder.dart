import 'package:flutter/material.dart';

import 'package:volunteer/shared/constants/app_colors.dart';

class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 240,
        width: double.infinity,
        color: const Color(0xFFE8EFEA),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _RoadPainter())),
            const Align(alignment: Alignment(-0.62, -0.45), child: _Pin()),
            const Align(alignment: Alignment(0.58, -0.62), child: _Pin()),
            const Align(alignment: Alignment(0.04, 0.0), child: _Pin()),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Center(
                child: Text('Peta lokasi (ilustrasi)',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.add, size: 14, color: Colors.white),
    );
  }
}

class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const lines = [
      [0.04, 0.07, 0.19, 0.07],
      [0.34, 0.07, 0.52, 0.07],
      [0.74, 0.07, 0.95, 0.07],
      [0.20, 0.20, 0.38, 0.20],
      [0.58, 0.20, 0.72, 0.20],
      [0.10, 0.30, 0.10, 0.62],
      [0.26, 0.38, 0.26, 0.72],
      [0.46, 0.30, 0.46, 0.64],
      [0.62, 0.40, 0.62, 0.78],
      [0.76, 0.30, 0.76, 0.62],
    ];
    for (final l in lines) {
      canvas.drawLine(
        Offset(l[0] * size.width, l[1] * size.height),
        Offset(l[2] * size.width, l[3] * size.height),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
