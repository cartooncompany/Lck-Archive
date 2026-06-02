import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// LCK Archive의 모든 페이지에서 예외 또는 빈 상태를 사용자 친화적으로 렌더링하는 공통 상태 카드 위젯입니다.
/// 날것의 기계어 에러를 감지하여 따뜻한 언어로 자동 변환하고,
/// 개발자용 상세 디버그 정보는 아코디언 형태로 감추어 사용자 경험을 보존합니다.
class AppStatusCard extends StatefulWidget {
  const AppStatusCard({
    required this.title,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onActionTap,
    this.technicalMessage,
    this.dense = false,
    super.key,
  });

  final String title;
  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final String? technicalMessage;
  final bool dense;

  @override
  State<AppStatusCard> createState() => _AppStatusCardState();
}

class _AppStatusCardState extends State<AppStatusCard> {
  bool _showTechnicalDetails = false;

  /// 에러 문자열이 개발자 중심의 시스템/네트워크 기계어인지 판별합니다.
  bool _isTechnicalError(String msg) {
    final lower = msg.toLowerCase();
    return lower.contains('exception') ||
        lower.contains('failed') ||
        lower.contains('http') ||
        lower.contains('uncaught') ||
        lower.contains('database') ||
        lower.contains('error') ||
        lower.contains('404') ||
        lower.contains('500') ||
        lower.contains('connect') ||
        lower.contains('dio') ||
        lower.contains('socket') ||
        lower.contains('null');
  }

  @override
  Widget build(BuildContext context) {
    final rawMessage = widget.message;
    final isTechnical = _isTechnicalError(rawMessage) ||
        (widget.technicalMessage != null && _isTechnicalError(widget.technicalMessage!));

    // 기계어 에러일 경우 사용자 중심의 부드럽고 다정한 화법으로 자동 마스킹
    String friendlyMessage = rawMessage;
    IconData displayIcon = widget.icon ?? Icons.info_outline_rounded;

    if (isTechnical) {
      final lower = rawMessage.toLowerCase();
      if (lower.contains('connect') || lower.contains('socket') || lower.contains('internet') || lower.contains('network')) {
        friendlyMessage = '네트워크 연결이 일시적으로 원활하지 않아요. 인터넷 신호를 확인하고 다시 한번 시도해 볼까요?';
        displayIcon = widget.icon ?? Icons.wifi_off_rounded;
      } else {
        friendlyMessage = '서버와 정보를 주고받는 중에 살짝 문제가 생겼어요. 잠시 후에 다시 한번 시도해 주세요.';
        displayIcon = widget.icon ?? Icons.cloud_off_rounded;
      }
    }

    final detailText = widget.technicalMessage ?? rawMessage;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(widget.dense ? 18 : 24),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isTechnical 
                ? AppColors.danger.withValues(alpha: 0.15) 
                : AppColors.glassBorderMuted,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
            if (isTechnical)
              BoxShadow(
                color: AppColors.danger.withValues(alpha: 0.03),
                blurRadius: 24,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 네온 글로우 스타일 아이콘 컨테이너
            Container(
              width: widget.dense ? 44 : 52,
              height: widget.dense ? 44 : 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isTechnical ? AppColors.danger : AppColors.accent)
                      .withValues(alpha: 0.25),
                ),
                boxShadow: AppColors.neonGlow(
                  color: isTechnical ? AppColors.danger : AppColors.accent,
                  blurRadius: 6,
                ),
              ),
              child: Icon(
                displayIcon,
                color: isTechnical ? AppColors.danger : AppColors.accent,
                size: widget.dense ? 20 : 24,
              ),
            ),
            const SizedBox(height: 16),
            // 감성적인 사용자 중심 타이틀
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 8),
            // 다정한 안내 문구
            Text(
              friendlyMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
            
            // 디버그용 날것의 에러 텍스트 아코디언 (개발 중에만 보이도록 kDebugMode 처리 및 토글 제공)
            if (isTechnical && !kReleaseMode) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  setState(() {
                    _showTechnicalDetails = !_showTechnicalDetails;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '문제 세부 정보 (개발자용)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showTechnicalDetails
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
              if (_showTechnicalDetails) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.divider.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    detailText,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
            
            // 다시 시도 또는 액션 버튼
            if (widget.actionLabel != null && widget.onActionTap != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onActionTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isTechnical ? AppColors.danger : AppColors.accent,
                    side: BorderSide(
                      color: (isTechnical ? AppColors.danger : AppColors.accent)
                          .withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    backgroundColor: (isTechnical ? AppColors.danger : AppColors.accent)
                        .withValues(alpha: 0.05),
                  ),
                  child: Text(
                    widget.actionLabel!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
