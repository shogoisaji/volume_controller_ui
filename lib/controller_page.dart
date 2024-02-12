import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:math' as math;
import 'dart:ui';

class ControllerPage extends HookWidget {
  const ControllerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final level = useState(0.0);
    final tapAngle = useState<double?>(null);
    final angleDiff = useState(0.0);
    const controllerSize = 300.0;
    final controllerCenter = useState(const Offset(0, 0));
    final key = GlobalKey();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
        final Size size = renderBox.size;
        controllerCenter.value = Offset(size.width, size.height);
      });
      return null;
    }, []);

    return Scaffold(
      backgroundColor: Colors.blueGrey[700],
      appBar: AppBar(
        title: const Text('Flutter Demo'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            SizedBox(
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
                      onPanStart: (details) => tapAngle.value = null,
                      onPanUpdate: (details) {
                        final centerPoint = Offset((controllerCenter.value.dx) / 2, controllerCenter.value.dx / 2);
                        // タッチ位置と中心点との差を計算
                        final dx = details.localPosition.dx - centerPoint.dx;
                        final dy = details.localPosition.dy - centerPoint.dy;
                        // 円外に出たら処理を修了
                        final distance = (details.localPosition - centerPoint).distance;
                        if (distance > controllerSize / 2) {
                          return;
                        }
                        // atan2を使用して角度をラジアンで計算 0 ~ 2π
                        if (tapAngle.value == null) {
                          tapAngle.value =
                              math.atan2(dy, dx) < 0 ? math.pi * 2 + math.atan2(dy, dx) : math.atan2(dy, dx);
                          return;
                        }
                        // 前回の角度
                        final prevAngle = tapAngle.value;
                        // 現在の角度
                        tapAngle.value = math.atan2(dy, dx) < 0 ? math.pi * 2 + math.atan2(dy, dx) : math.atan2(dy, dx);
                        // 角度の差分
                        angleDiff.value = -(prevAngle! - tapAngle.value!);
                        // 角度差分からレベルを計算
                        final addLevel = (angleDiff.value / math.pi);
                        // 次のレベルを計算
                        final nextLevel = (level.value + addLevel);
                        // レベルが0 ~ 1の間に収まるように制限
                        if (nextLevel > 1 || nextLevel < 0) return;
                        // レベルを更新
                        HapticFeedback.lightImpact();
                        level.value = nextLevel.clamp(0.0, 1.0);
                      },
                      child: Container(
                          key: key,
                          width: controllerSize * 0.6,
                          height: controllerSize * 0.6,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueGrey[300]!, width: 1),
                            // color: Colors.blueGrey[300],
                            gradient: RadialGradient(
                              center: const Alignment(0, -0.2),
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
                                child: Center(
                                  child: Container(
                                    width: controllerSize * 0.04,
                                    height: controllerSize * 0.04,
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 0.6,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
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
