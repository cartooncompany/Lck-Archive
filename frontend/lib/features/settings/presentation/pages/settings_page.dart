import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../features/favorite_team/presentation/bloc/favorite_team_controller.dart';
import '../../../../features/favorite_team/presentation/widgets/favorite_team_picker_sheet.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteTeam = FavoriteTeamScope.of(context).favoriteTeam;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        12,
        AppSpacing.screen,
        120,
      ),
      children: [
        Text('설정', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          '응원팀과 앱 정보를 간단하게 관리합니다.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: favoriteTeam.color.withValues(alpha: 0.18),
                  foregroundColor: favoriteTeam.color,
                  child: Text(favoriteTeam.initials),
                ),
                title: const Text('응원팀 변경'),
                subtitle: Text('현재 ${favoriteTeam.name} 선택됨'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showPicker(context),
              ),
              const Divider(height: 1),
              const ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                leading: Icon(Icons.info_outline_rounded),
                title: Text('앱 정보'),
                subtitle: Text('LCK Archive 1.0.0'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('개인화 안내', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Text(
                '응원팀을 변경하면 홈의 팀 카드, 최근 경기, 주요 선수, 관련 뉴스 노출 순서가 함께 바뀝니다.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showPicker(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      builder: (_) => const FavoriteTeamPickerSheet(),
    );
  }
}
