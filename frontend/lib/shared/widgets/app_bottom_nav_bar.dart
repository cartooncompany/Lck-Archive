import 'package:flutter/material.dart';

import '../../core/enums/app_tab.dart';

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
    return NavigationBar(
      selectedIndex: AppTab.values.indexOf(currentTab),
      onDestinationSelected: (index) => onSelected(AppTab.values[index]),
      destinations: AppTab.values
          .map(
            (tab) =>
                NavigationDestination(icon: Icon(tab.icon), label: tab.label),
          )
          .toList(),
    );
  }
}
