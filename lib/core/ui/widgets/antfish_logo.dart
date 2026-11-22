import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Logotipo vectorial oficial de AntFish derivado de `web/logo-antfish-vg.svg`.
///
/// Renderizado nativo vía [CustomPainter] sin librerías externas para máxima
/// nitidez, rendimiento a 60/120 fps y escalado perfecto en cualquier resolución.
class AntFishLogo extends StatelessWidget {
  const AntFishLogo({super.key, this.size = 28, this.color});

  /// Tamaño en píxeles (ancho y alto del lienzo cuadrado).
  final double size;

  /// Color del trazo y relleno. Por defecto usa [AppColors.gold] (#D7BA89).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _AntFishLogoPainter(color: color ?? AppColors.gold),
    );
  }
}

class _AntFishLogoPainter extends CustomPainter {
  const _AntFishLogoPainter({required this.color});

  final Color color;

  static const double _viewBoxWidth = 115.0;
  static const double _viewBoxHeight = 115.0;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(
      size.width / _viewBoxWidth,
      size.height / _viewBoxHeight,
    );

    canvas.save();
    canvas.scale(scale, scale);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.72872
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Path 0: Contorno del pez / escudo (Stroke)
    final path0 = Path();
    path0.moveTo(58.9961, 40.1253);
    path0.cubicTo(58.9961, 40.1253, 56.5264, 36.3808, 52.023, 26.734);
    path0.cubicTo(70.0368, 26.734, 81.4408, 35.8694, 81.4408, 35.8694);
    path0.cubicTo(81.4408, 35.8694, 98.2198, 32.4646, 106.936, 56.2979);
    path0.cubicTo(106.936, 73.3217, 87.3243, 75.92, 87.3243, 75.92);
    path0.lineTo(83.4019, 75.92);
    path0.lineTo(67.7125, 91.6596);
    path0.cubicTo(67.7125, 91.6596, 57.9065, 81.8224, 61.8289, 75.0241);
    path0.cubicTo(50.5703, 70.2007, 34.3722, 63.533, 34.3723, 56.2979);
    path0.cubicTo(34.3724, 49.0628, 58.9961, 40.1253, 58.9961, 40.1253);
    path0.close();
    canvas.drawPath(path0, strokePaint);

    // Path 1: Cuerpo y aletas (Fill)
    final path1 = Path();
    path1.moveTo(8.11383, 44.7395);
    path1.lineTo(7.87591, 41.8951);
    path1.cubicTo(6.69374, 41.9568, 5.69255, 42.7304, 5.35362, 43.844);
    path1.cubicTo(5.01469, 44.9576, 5.40734, 46.1834, 6.34283, 46.9322);
    path1.lineTo(8.11383, 44.7395);
    path1.close();
    path1.moveTo(24.9141, 58.1863);
    path1.lineTo(27.1881, 60.0013);
    path1.cubicTo(28.1634, 58.7901, 27.9384, 56.9967, 26.6851, 55.9936);
    path1.lineTo(24.9141, 58.1863);
    path1.close();
    path1.moveTo(9.96182, 76.753);
    path1.lineTo(7.68788, 74.938);
    path1.cubicTo(6.91904, 75.8926, 6.87753, 77.2481, 7.58519, 78.2908);
    path1.cubicTo(8.29285, 79.3335, 9.58741, 79.8244, 10.7875, 79.5051);
    path1.lineTo(9.96182, 76.753);
    path1.close();
    path1.moveTo(8.11383, 44.7395);
    path1.lineTo(6.34283, 46.9322);
    path1.lineTo(23.1431, 60.3789);
    path1.lineTo(24.9141, 58.1863);
    path1.lineTo(26.6851, 55.9936);
    path1.lineTo(9.88483, 42.5469);
    path1.lineTo(8.11383, 44.7395);
    path1.close();
    path1.moveTo(24.9141, 58.1863);
    path1.lineTo(22.6402, 56.3713);
    path1.lineTo(7.68788, 74.938);
    path1.lineTo(9.96182, 76.753);
    path1.lineTo(12.2358, 78.568);
    path1.lineTo(27.1881, 60.0013);
    path1.lineTo(24.9141, 58.1863);
    path1.close();
    path1.moveTo(9.96182, 76.753);
    path1.cubicTo(10.7875, 79.5051, 10.788, 79.5049, 10.7887, 79.5048);
    path1.cubicTo(10.7891, 79.5047, 10.7899, 79.5044, 10.7908, 79.5042);
    path1.cubicTo(10.7926, 79.5037, 10.7951, 79.5031, 10.7982, 79.5022);
    path1.cubicTo(10.8044, 79.5006, 10.8132, 79.4982, 10.8246, 79.4952);
    path1.cubicTo(10.8474, 79.489, 10.8806, 79.4801, 10.9237, 79.4685);
    path1.cubicTo(11.01, 79.4451, 11.1362, 79.4108, 11.2997, 79.3658);
    path1.cubicTo(11.6267, 79.2758, 12.1027, 79.1433, 12.7059, 78.971);
    path1.cubicTo(13.9121, 78.6266, 15.6284, 78.123, 17.6794, 77.4834);
    path1.cubicTo(21.7748, 76.2064, 27.2349, 74.3783, 32.6433, 72.184);
    path1.cubicTo(38.016, 70.0043, 43.4944, 67.4015, 47.5336, 64.5417);
    path1.cubicTo(49.5479, 63.1155, 51.3494, 61.5254, 52.5826, 59.7686);
    path1.cubicTo(53.8271, 57.9955, 54.6425, 55.8224, 54.1703, 53.4152);
    path1.lineTo(51.3433, 53.8762);
    path1.lineTo(48.5163, 54.3373);
    path1.cubicTo(48.5972, 54.7497, 48.5342, 55.4062, 47.8183, 56.4262);
    path1.cubicTo(47.0909, 57.4624, 45.8495, 58.6288, 44.0881, 59.876);
    path1.cubicTo(40.5756, 62.3629, 35.5704, 64.7744, 30.3211, 66.9041);
    path1.cubicTo(25.1077, 69.0192, 19.8075, 70.7955, 15.7982, 72.0456);
    path1.cubicTo(13.7969, 72.6696, 12.1247, 73.1602, 10.9554, 73.4941);
    path1.cubicTo(10.3709, 73.6611, 9.91254, 73.7887, 9.60199, 73.8741);
    path1.cubicTo(9.44673, 73.9169, 9.32846, 73.949, 9.2499, 73.9703);
    path1.cubicTo(9.21062, 73.9809, 9.18128, 73.9888, 9.16221, 73.9939);
    path1.cubicTo(9.15267, 73.9965, 9.1457, 73.9983, 9.14134, 73.9995);
    path1.cubicTo(9.13917, 74.0001, 9.13764, 74.0005, 9.13677, 74.0007);
    path1.cubicTo(9.13634, 74.0008, 9.13618, 74.0009, 9.13597, 74.0009);
    path1.cubicTo(9.13597, 74.0009, 9.13615, 74.0009, 9.96182, 76.753);
    path1.close();
    path1.moveTo(51.3433, 53.8762);
    path1.lineTo(54.1703, 53.4152);
    path1.cubicTo(53.7179, 51.109, 52.2935, 49.3321, 50.5706, 48.013);
    path1.cubicTo(48.8726, 46.7129, 46.746, 45.7423, 44.5009, 44.994);
    path1.cubicTo(40.0075, 43.4965, 34.3961, 42.6837, 29.054, 42.2401);
    path1.cubicTo(23.672, 41.7933, 18.3826, 41.7079, 14.4523, 41.7328);
    path1.cubicTo(12.4834, 41.7453, 10.847, 41.7855, 9.69981, 41.8227);
    path1.cubicTo(9.12605, 41.8413, 8.67418, 41.8592, 8.36378, 41.8726);
    path1.cubicTo(8.20856, 41.8792, 8.08867, 41.8848, 8.00656, 41.8887);
    path1.cubicTo(7.9655, 41.8906, 7.93388, 41.8922, 7.912, 41.8933);
    path1.cubicTo(7.90107, 41.8938, 7.89256, 41.8943, 7.88654, 41.8946);
    path1.cubicTo(7.88352, 41.8947, 7.88112, 41.8949, 7.87935, 41.8949);
    path1.cubicTo(7.87847, 41.895, 7.8776, 41.895, 7.87716, 41.8951);
    path1.cubicTo(7.87646, 41.8951, 7.87591, 41.8951, 8.11383, 44.7395);
    path1.cubicTo(8.35175, 47.5839, 8.35152, 47.5839, 8.35144, 47.5839);
    path1.cubicTo(8.35162, 47.5839, 8.35169, 47.5839, 8.35206, 47.5839);
    path1.cubicTo(8.35278, 47.5839, 8.35412, 47.5838, 8.35607, 47.5837);
    path1.cubicTo(8.35998, 47.5835, 8.36635, 47.5832, 8.37513, 47.5827);
    path1.cubicTo(8.3927, 47.5819, 8.41995, 47.5805, 8.45657, 47.5788);
    path1.cubicTo(8.5298, 47.5753, 8.6405, 47.5702, 8.78625, 47.5639);
    path1.cubicTo(9.07776, 47.5514, 9.50927, 47.5343, 10.0614, 47.5163);
    path1.cubicTo(11.1659, 47.4805, 12.7513, 47.4415, 14.6623, 47.4294);
    path1.cubicTo(18.4918, 47.4051, 23.595, 47.4893, 28.7437, 47.9168);
    path1.cubicTo(33.9324, 48.3476, 38.9901, 49.114, 42.8097, 50.387);
    path1.cubicTo(44.7211, 51.024, 46.1619, 51.7364, 47.1305, 52.478);
    path1.cubicTo(48.0742, 53.2005, 48.4156, 53.8239, 48.5163, 54.3373);
    path1.lineTo(51.3433, 53.8762);
    path1.close();
    canvas.drawPath(path1, fillPaint);

    // Path 2: Ojo del pez (Stroke)
    final path2 = Path();
    path2.moveTo(88.7028, 52.2866);
    path2.lineTo(88.7516, 52.2325);
    canvas.drawPath(path2, strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AntFishLogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
