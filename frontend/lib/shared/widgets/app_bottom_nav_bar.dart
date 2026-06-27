import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:frontend/app/theme/app_colors.dart';
import 'package:frontend/core/enums/app_tab.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.currentTab,
    required this.onSelected,
    super.key,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex = AppTab.values.indexOf(currentTab);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xD9050814), // 반투명 다크 스페이스 배경
            border: Border(
              top: BorderSide(color: AppColors.divider, width: 1.2),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 68,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: AppTab.values.map((tab) {
                  final index = AppTab.values.indexOf(tab);
                  final isSelected = index == selectedIndex;
                  final color = isSelected
                      ? AppColors.accent
                      : AppColors.textSecondary;

                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onSelected(tab),
                        splashColor: AppColors.accent.withValues(alpha: 0.08),
                        highlightColor: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accent.withValues(alpha: 0.08)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: AnimatedScale(
                                scale: isSelected ? 1.15 : 1.0,
                                duration: const Duration(milliseconds: 150),
                                child: Icon(tab.icon, color: color, size: 22),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tab.label,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: color,
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
