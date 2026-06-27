import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/app/theme/app_colors.dart';
import 'package:frontend/shared/models/player_profile.dart';

class PlayerRadarChart extends StatelessWidget {
  const PlayerRadarChart({
    required this.stats,
    required this.accentColor,
    super.key,
  });

  final PlayerStats stats;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    // 5개 축 데이터 정규화 (0.0 ~ 1.0)
    final double gamesPlayedNormalized = (stats.gamesPlayed / 40.0).clamp(0.1, 1.0);
    final double kdaNormalized = (stats.avgKda / 8.0).clamp(0.1, 1.0);
    final double killsNormalized = (stats.avgKills / 5.0).clamp(0.1, 1.0);
    // 데스는 낮을수록 좋음 (생존 지표)
    final double survivalNormalized = (1.0 - (stats.avgDeaths / 4.0)).clamp(0.1, 1.0);
    final double assistsNormalized = (stats.avgAssists / 8.0).clamp(0.1, 1.0);

    final dataPoints = [
      gamesPlayedNormalized,
      kdaNormalized,
      killsNormalized,
      survivalNormalized,
      assistsNormalized,
    ];

    final labels = [
      '출전수\n(${stats.gamesPlayed}세트)',
      'KDA\n(${stats.avgKda.toStringAsFixed(1)})',
      '평균 킬\n(${stats.avgKills.toStringAsFixed(1)})',
      '생존력\n(${(4.0 - stats.avgDeaths).clamp(0.0, 4.0).toStringAsFixed(1)})',
      '평균 어시\n(${stats.avgAssists.toStringAsFixed(1)})',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorderMuted),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_rounded,
                color: accentColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                '포지션 밸런스 지표',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: _RadarChartPainter(
                dataPoints: dataPoints,
                labels: labels,
                accentColor: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  _RadarChartPainter({
    required this.dataPoints,
    required this.labels,
    required this.accentColor,
  });

  final List<double> dataPoints;
  final List<String> labels;
  final Color accentColor;

  static const int _sides = 5;
  static const double _angle = (2 * math.pi) / _sides;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // 텍스트 영역을 확보하기 위해 차트 반경 계산
    final radius = math.min(size.width, size.height) / 2.7;

    final outlinePaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final webPaint = Paint()
      ..color = AppColors.divider.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // 1. 배경 그리드 그리기 (4단계 원 모양의 다각형 그물망)
    for (var i = 1; i <= 4; i++) {
      final factor = i / 4.0;
      final path = Path();
      for (var j = 0; j < _sides; j++) {
        // -math.pi/2 는 정상을 향하기 위한 오프셋
        final currentAngle = j * _angle - math.pi / 2;
        final point = Offset(
          center.dx + radius * factor * math.cos(currentAngle),
          center.dy + radius * factor * math.sin(currentAngle),
        );
        if (j == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, i == 4 ? outlinePaint : webPaint);
    }

    // 2. 중심에서 꼭짓점으로 뻗어나가는 축 선 그리기
    for (var j = 0; j < _sides; j++) {
      final currentAngle = j * _angle - math.pi / 2;
      final point = Offset(
        center.dx + radius * math.cos(currentAngle),
        center.dy + radius * math.sin(currentAngle),
      );
      canvas.drawLine(center, point, outlinePaint);
    }

    // 3. 데이터 영역 그리기
    final dataPath = Path();
    for (var j = 0; j < _sides; j++) {
      final currentAngle = j * _angle - math.pi / 2;
      final pointValue = dataPoints[j];
      final point = Offset(
        center.dx + radius * pointValue * math.cos(currentAngle),
        center.dy + radius * pointValue * math.sin(currentAngle),
      );
      if (j == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();

    // 데이터 영역 채우기
    final fillPaint = Paint()
      ..color = accentColor.withOpacity(0.24)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dataPath, fillPaint);

    // 데이터 영역 테두리
    final borderPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(dataPath, borderPaint);

    // 데이터 포인트에 점 찍기
    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final pointStrokePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var j = 0; j < _sides; j++) {
      final currentAngle = j * _angle - math.pi / 2;
      final pointValue = dataPoints[j];
      final point = Offset(
        center.dx + radius * pointValue * math.cos(currentAngle),
        center.dy + radius * pointValue * math.sin(currentAngle),
      );
      canvas.drawCircle(point, 3.5, pointPaint);
      canvas.drawCircle(point, 3.5, pointStrokePaint);
    }

    // 4. 축별 텍스트 레이블 렌더링
    for (var j = 0; j < _sides; j++) {
      final currentAngle = j * _angle - math.pi / 2;
      // 레이블을 축보다 살짝 더 바깥에 배치
      final labelOffsetFactor = 1.25;
      final labelX = center.dx + radius * labelOffsetFactor * math.cos(currentAngle);
      final labelY = center.dy + radius * labelOffsetFactor * math.sin(currentAngle);

      final textSpan = TextSpan(
        text: labels[j],
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      // 꼭짓점 위치에 따른 텍스트 레이아웃 보정
      final offset = Offset(
        labelX - textPainter.width / 2,
        labelY - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor ||
        oldDelegate.dataPoints != dataPoints ||
        oldDelegate.labels != labels;
  }
}
