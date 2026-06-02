import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class FormStrip extends StatelessWidget {
  const FormStrip({required this.form, super.key});

  final List<String> form;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: form.map((entry) {
        final isWin = entry == 'W' || entry == '승';
        final color = isWin ? AppColors.success : AppColors.danger;
        return Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
            boxShadow: AppColors.neonGlow(color: color, blurRadius: 4),
          ),
          child: Text(
            entry,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              shadows: [
                Shadow(color: color.withValues(alpha: 0.4), blurRadius: 4),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
