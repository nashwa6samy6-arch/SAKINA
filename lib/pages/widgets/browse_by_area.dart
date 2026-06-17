import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Drop this file into your Flutter project and call [BrowseByAreaWidget]
/// anywhere in your widget tree.
///
/// No external packages required.

// ─────────────────────────────────────────────
//  Entry point (for standalone testing)
// ─────────────────────────────────────────────
// void main() {
//   runApp(
//     const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         backgroundColor: Color(0xFFF0EBE0),
//         body: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.all(20),
//             child: BrowseByAreaWidget(),
//           ),
//         ),
//       ),
//     ),
//   );
// }

// ─────────────────────────────────────────────
//  Public widget
// ─────────────────────────────────────────────
class BrowseByAreaWidget extends StatelessWidget {
  const BrowseByAreaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Header row ──────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Browse by Area',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.4,
              ),
            ),
            GestureDetector(
              child: Text(
                'View Map',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF888880),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 14.h),

        // ── Map card ────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final W = constraints.maxWidth;
              return SizedBox(
                width: double.infinity,
                height: 220.h,
                child: Stack(
                  children: [
                    // Street-grid background
                    CustomPaint(
                      painter: _StreetMapPainter(),
                      size: Size(W, 220.h),
                      child: const SizedBox.expand(),
                    ),

                    // Dark pin – 12k (placed relatively on horizontal axis)
                    Positioned(
                      top: 52.h,
                      left: W * 0.18,
                      child: const _MapPin(label: '12k', isDark: true),
                    ),

                    // Light pin – 9k
                    Positioned(
                      top: 108.h,
                      left: W * 0.42,
                      child: const _MapPin(label: '9k', isDark: false),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Pill-shaped map pin
// ─────────────────────────────────────────────
class _MapPin extends StatelessWidget {
  final String label;
  final bool isDark;

  const _MapPin({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final fg = isDark ? Colors.white : const Color(0xFF1C1C1C);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, size: 13.r, color: fg),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Street-map CustomPainter
// ─────────────────────────────────────────────
class _StreetMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width;
    final H = size.height;

    // ── Background ──────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, W, H),
      Paint()..color = const Color(0xFFDDD9CF),
    );

    // ── Block paint ─────────────────────────
    final block = Paint()..color = const Color(0xFFC8C4B8);

    void drawBlock(double x, double y, double w, double h) {
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        const Radius.circular(3),
      );
      canvas.drawRRect(rr, block);
    }

    // Row 1
    drawBlock(W * 0.01, H * 0.03, W * 0.17, H * 0.25);
    drawBlock(W * 0.22, H * 0.03, W * 0.14, H * 0.23);
    drawBlock(W * 0.40, H * 0.02, W * 0.18, H * 0.26);
    drawBlock(W * 0.62, H * 0.03, W * 0.15, H * 0.24);
    drawBlock(W * 0.81, H * 0.02, W * 0.18, H * 0.26);

    // Row 2
    drawBlock(W * 0.01, H * 0.36, W * 0.12, H * 0.27);
    drawBlock(W * 0.16, H * 0.35, W * 0.19, H * 0.26);
    drawBlock(W * 0.40, H * 0.36, W * 0.16, H * 0.27);
    drawBlock(W * 0.62, H * 0.35, W * 0.14, H * 0.28);
    drawBlock(W * 0.81, H * 0.36, W * 0.18, H * 0.27);

    // Row 3
    drawBlock(W * 0.01, H * 0.71, W * 0.14, H * 0.26);
    drawBlock(W * 0.19, H * 0.70, W * 0.17, H * 0.27);
    drawBlock(W * 0.40, H * 0.71, W * 0.17, H * 0.27);
    drawBlock(W * 0.62, H * 0.71, W * 0.15, H * 0.26);
    drawBlock(W * 0.81, H * 0.71, W * 0.18, H * 0.27);

    // ── Road paint ──────────────────────────
    final mainRoad = Paint()
      ..color = const Color(0xFFECE8DF)
      ..strokeWidth = W * 0.014
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final smallRoad = Paint()
      ..color = const Color(0xFFECE8DF)
      ..strokeWidth = W * 0.007
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Horizontal main roads
    for (final y in [0.31, 0.65]) {
      canvas.drawLine(Offset(0, H * y), Offset(W, H * y), mainRoad);
    }
    // Horizontal minor roads
    for (final y in [0.50, 0.85]) {
      canvas.drawLine(Offset(0, H * y), Offset(W, H * y), smallRoad);
    }

    // Vertical main roads
    for (final x in [0.14, 0.38, 0.60, 0.80]) {
      canvas.drawLine(Offset(W * x, 0), Offset(W * x, H), mainRoad);
    }
    // Vertical minor roads
    for (final x in [0.27, 0.71]) {
      canvas.drawLine(Offset(W * x, 0), Offset(W * x, H), smallRoad);
    }

    // Diagonal boulevard
    canvas.drawLine(Offset(0, H * 0.18), Offset(W * 0.55, H), mainRoad);
    canvas.drawLine(Offset(W * 0.30, 0), Offset(W, H * 0.62), smallRoad);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
