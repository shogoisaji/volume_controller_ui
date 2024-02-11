import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:math' as math;
import 'dart:ui';

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final level = useState(0.0);
    final tapStartAngle = useState(0.0);
    final controllerSize = 300.0;

    return Scaffold(
      backgroundColor: Colors.blueGrey[700],
      appBar: AppBar(
        title: const Text('Flutter Demo'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Container(
              width: controllerSize,
              height: controllerSize,
              child: Stack(
                children: [
                  Container(
                    width: controllerSize,
                    height: controllerSize,
                    color: Colors.blueGrey[700],
                    child: ClipPath(
                      clipper: MaskClipper(),
                      child: Container(
                        width: controllerSize,
                        height: controllerSize,
                        color: Colors.blueGrey[800],
                        child: CustomPaint(
                          painter: InnerPainter(level: level.value, w: controllerSize),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onPanStart: (details) {
                        final centerPoint = Offset(controllerSize / 2, controllerSize / 2);
                        // タッチ位置と中心点との差を計算
                        final dx = details.localPosition.dx - centerPoint.dx;
                        final dy = details.localPosition.dy - centerPoint.dy;
                        // atan2を使用して角度をラジアンで計算
                        tapStartAngle.value = math.atan2(dy, dx);
                        print("Angle in start: ${tapStartAngle.value}");
                      },
                      onPanUpdate: (details) {
                        final centerPoint = Offset(controllerSize / 2, controllerSize / 2);
                        // タッチ位置と中心点との差を計算
                        final dx = details.localPosition.dx - centerPoint.dx;
                        final dy = details.localPosition.dy - centerPoint.dy;
                        // atan2を使用して角度をラジアンで計算
                        final angleRadians = math.atan2(dy, dx);
                        // ラジアンを度数法に変換
                        final angleDiff = tapStartAngle.value - angleRadians;
                        // 角度を出力（必要に応じて他の処理に使用）
                        print("Angle in diff: $angleDiff   ${tapStartAngle.value}  $angleRadians");
                        level.value = (level.value + angleDiff / (math.pi * 2)).clamp(0.0, 1.0);
                      },
                      child: Container(
                          width: controllerSize * 0.6,
                          height: controllerSize * 0.6,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueGrey[300]!, width: 1),
                            // color: Colors.blueGrey[300],
                            gradient: RadialGradient(
                              center: Alignment(0, -0.2),
                              colors: [Colors.blueGrey[400]!, Colors.blueGrey[600]!],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(0, 2),
                                blurRadius: 6,
                                spreadRadius: 4,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(0, 15),
                                blurRadius: 30,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                          child: Transform.rotate(
                            angle: math.pi * level.value,
                            child: Align(
                              alignment: const Alignment(-0.9, 0),
                              child: Container(
                                width: controllerSize * 0.08,
                                height: controllerSize * 0.08,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[200]!, width: 1),
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Level : ${(level.value * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[200]),
              ),
            ),
            SizedBox(
              width: controllerSize,
              child: Slider(
                activeColor: Colors.orange[500],
                value: level.value,
                onChanged: (value) {
                  level.value = value;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MaskClipper extends CustomClipper<Path> {
  final double rectWidth = 10.0;
  final double rectHeight = 10.0;
  final int count = 24;
  final double radius = 120;
  final double startAngle = 0.0;
  final double endAngle = math.pi;

  @override
  Path getClip(Size size) {
    Path path = Path();
    final Offset center = Offset(size.width / 2, size.height / 2); // 円の中心

    for (int i = 0; i < count; i++) {
      // 各Rectの中心点の角度を計算
      // double angle = math.pi / 100 * i * 5;
      double angle = -(endAngle - startAngle) * (i + 0.5) / (count);
      // 角度から中心点の座標を計算
      double x = center.dx + radius * math.cos(angle);
      double y = center.dy + radius * math.sin(angle);
      // Rectを作成し、Pathに追加
      path.addOval(Rect.fromCenter(center: Offset(x, y), width: rectWidth, height: rectHeight));
    }

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class InnerPainter extends CustomPainter {
  final double level;
  final double w;
  InnerPainter({required this.level, required this.w});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.orange[500]!
      ..style = PaintingStyle.fill;

    Path path = Path();
    var rect = Rect.fromCenter(
      center: Offset(w / 2, w / 2),
      width: w,
      height: w,
    );
    path
      ..moveTo(w / 2, w / 2)
      ..arcTo(rect, math.pi, math.pi * level, false);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
