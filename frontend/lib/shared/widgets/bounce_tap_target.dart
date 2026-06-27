import 'package:flutter/material.dart';

/// 탭하면 살짝 줄어들었다 돌아오는 "쫀득한" 바운스 효과를 주는 탭 래퍼.
///
/// 홈/로그인/회원가입/랜딩 등 여러 화면에 동일하게 중복 정의되어 있던
/// `_BounceAction`을 하나로 통합한 공용 위젯이다.
class BounceTapTarget extends StatefulWidget {
  const BounceTapTarget({
    required this.child,
    required this.onTap,
    super.key,
  });

  final Widget child;
  final VoidCallback onTap;

  @override
  State<BounceTapTarget> createState() => _BounceTapTargetState();
}

class _BounceTapTargetState extends State<BounceTapTarget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
