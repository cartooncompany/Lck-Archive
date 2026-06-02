import 'package:flutter/material.dart';

final class AppColors {
  // 깊이감 있는 우주 공간(다크 스페이스) 배경/표면 컬러
  static const Color background = Color(0xFF050814);
  static const Color surface = Color(0xFF0C1224);
  static const Color surfaceElevated = Color(0xFF121B32);
  static const Color surfaceMuted = Color(0xFF182341);

  // e스포츠 프리미엄 시그니처 네온 컬러
  static const Color accent = Color(0xFF2AD3FF); // 네온 시안 블루
  static const Color accentStrong = Color(0xFF5A7CFF); // 딥 네온 퍼플리쉬 블루
  static const Color success = Color(0xFF00FFCC); // 네온 일렉트릭 민트
  static const Color danger = Color(0xFFFF3366); // 네온 로즈 레드
  static const Color warning = Color(0xFFFFB800); // 네온 골드 옐로우

  // 가독성을 위한 세련된 텍스트 계열
  static const Color textPrimary = Color(0xFFF4F7FB);
  static const Color textSecondary = Color(0xFF8E9CB2);
  static const Color textMuted = Color(0xFF5F6E85);

  // 글래스모피즘과 구분선을 위한 투명도 기반 보더라인
  static const Color divider = Color(0x1AFFFFFF); // 글래스 내부 경계
  static const Color glassBorder = Color(0x26FFFFFF); // 외곽 유백색 테두리
  static const Color glassBorderMuted = Color(0x0EFFFFFF);

  // 프리미엄 네온 그라디언트 조합
  static const List<Color> primaryGradient = [
    Color(0xFF2AD3FF),
    Color(0xFF5A7CFF),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF5A7CFF),
    Color(0xFF9F5CFF),
  ];

  static const List<Color> darkGlassGradient = [
    Color(0x1F0C1224),
    Color(0x0D121B32),
  ];

  static const List<Color> lightGlassGradient = [
    Color(0x1F2AD3FF),
    Color(0x0B5A7CFF),
  ];

  // 네온 글로우 섀도우 효과
  static List<BoxShadow> neonGlow({Color? color, double blurRadius = 8}) {
    final glowColor = color ?? accent;
    return [
      BoxShadow(
        color: glowColor.withValues(alpha: 0.25),
        blurRadius: blurRadius,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: glowColor.withValues(alpha: 0.12),
        blurRadius: blurRadius * 2,
        spreadRadius: 2,
      ),
    ];
  }
}
