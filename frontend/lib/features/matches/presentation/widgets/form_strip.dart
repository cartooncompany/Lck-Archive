import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class FormStrip extends StatelessWidget {
  const FormStrip({required this.form, super.key});

  final List<String> form;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: form
          .map(
            (entry) => Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: entry == 'W'
                    ? AppColors.success.withValues(alpha: 0.16)
                    : AppColors.danger.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                entry,
                style: TextStyle(
                  color: entry == 'W' ? AppColors.success : AppColors.danger,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
